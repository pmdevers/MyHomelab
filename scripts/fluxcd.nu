#!/usr/bin/env nu

def --env "main apply fluxcd" [
    --environment = "local"
] {

(
    flux bootstrap github 
        --token-auth 
        --owner=pmdevers 
        --repository=MyHomelab 
        --branch=main 
        --path=clusters/($environment)
        --personal 
        --components-extra image-reflector-controller,image-automation-controller
)
    
}

def --env "main reconcile" [
    name = "infrastructure"
] {
    (flux reconcile kustomization $name --with-source)
}