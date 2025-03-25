def "main apply vault-secret" [
    --environment = "local"
] {

    if ($environment == "local") {
        return
    }

    (
        kubectl create secret generic vault-token 
            --namespace external-secrets
            --from-literal=token=root
    )
}