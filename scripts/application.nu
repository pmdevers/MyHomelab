#!/usr/bin/env nu

def main [] {

}

def "main create repository" [
    name: string
    repository: string
    branch: string = "main"
] {

    {
        apiVersion: "source.toolkit.fluxcd.io/v1",
        kind: "GitRepository", 
        metadata: {
            name: $name,
            namespace: "flux-system",
        },
        spec: {
            interval: 1m0s,
            ref: {
                branch: $branch 
            },
            secretRef: {
                name: "flux-system"
            },    
            url: $repository
        }
    } | to yaml | save $"repository.yaml" --force
}

def "main kustomize" [
    name: string,
    repositoryName: string,
    --imageName: string =  "ghcr.io/pmdevers",
    --version: string = "v1.0.0",
    --policyName: string = "gitopsdemo",
    --path: string = "./deploy/production"
] {

    let image = 'newName: ' + $imageName + ' # {"$imagepolicy": "flux-system:' + $policyName + ':name"}'
    let tag = 'newTag: ' + $version + ' # {"$imagepolicy": "flux-system:' + $policyName + ':tag"}'

    {
        apiVersion: "kustomize.toolkit.fluxcd.io/v1",
        kind: "Kustomization",
        metadata: {
            name: $name,
            namespace: "flux-system"
        },
        spec: {
            interval: "10m0s",
            dependsOn: [
                { name: "infrastructure" },
            ],
            sourceRef: {
                kind: "GitRepository",
                name: $repositoryName
            },
            path: $path,
            prune: true,
            wait: true,
            timeout: "5m0s",
            images: [
                { 
                    name: $imageName,
                    newName: "template",
                    newTag: "template"
                }
            ]
        }
    } | to yaml 
    | str replace 'newName: template' $image
    | str replace 'newTag: template' $tag
    | save "source.yaml" --force
}

def "main kustomization" [] {

    let files = ls | where name ends-with "yaml";

    if ($files | length) > 0 {

        {
            apiVersion: "kustomize.config.k8s.io/v1beta1",
            kind: "Kustomization"
            resources: ($files | each { |elt| $"($elt.name)" })
        } | to yaml
        | save "kustomization.yaml" --force
    }
    
}

def "main "