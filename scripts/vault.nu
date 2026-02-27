def "main apply vault-secret" [
    token: string,
    --environment = "local"
] {

    (
        kubectl create secret generic vault-token 
            --namespace external-secrets
            --from-literal=token=$token
    )
}