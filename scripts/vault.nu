def add_account [
    --environment: string = "local"
] {
    return (
        op account add 
            --shorthand $environment
            --address "my.1password.com"
            --signin
            --raw
    )
}

def "main apply vault-secret" [
    --environment: string = "local"
] {

    const connect_name = "Homelab"
    const vaults = "k8s"
    const k8s_cred_secret = "op-credentials"
    const k8s_token_secret = "op-token"
    const namespace = "default"

    let token = (add_account --environment $environment)

    let items = (op connect server list --format json --session $token)
    let existing = ($items | from json | where name == $connect_name)
    if ($existing | length) == 0 {
        op connect server create --name $connect_name --vaults $vaults --session=$token
    } else {
        echo "Connect server '$connect_name' already exists"
    }

    let cred_b64 = (
        op connect server get $connect_name 
            --session $token --format json 
            | encode base64
        )
    (
        kubectl create secret generic $k8s_cred_secret 
            --from-literal=connect.credentials=($cred_b64)
            -n $namespace
            --dry-run=client -o yaml
        | kubectl apply -f -
    )


    let sid = $existing | first | get id
    let token = (op connect token create $environment --server $sid --vaults $vaults --session $token --format json)

    (
        kubectl create secret generic $k8s_token_secret
            --from-literal=token=($token)
            -n $namespace
            --dry-run=client -o yaml
        | kubectl apply -f -
    )
    
}