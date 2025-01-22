#!/usr/bin/env nu

def --env "main kubernetes create" [
    --environment = "local"
] {

    if $environment == "local" {
        (minikube start)
    }	
}