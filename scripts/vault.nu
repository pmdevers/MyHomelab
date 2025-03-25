def "main apply vault-secret" [
    --environment = "local"
] {

    if ($environment == "local") {
        return
    }
    
    (
        kubectl create secret generic vault-token --from-literal=token=root
    )
}