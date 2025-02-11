#!/usr/bin/env nu

def "create git-repository" [
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
    } | to yaml | save $"git-repository.yaml" --force
}

def "create kustomize" [
    name: string,
    repositoryName: string,
    policyName: string,
    imageName: string,
    --version: string = "v1.0.0",
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

def "create kustomization" [] {

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

def "create image-policy" [
    name: string,
    imageRepositoryName: string
] {
    {
        apiVersion: "image.toolkit.fluxcd.io/v1beta2",
        kind: "ImagePolicy",
        metadata: {
            name: $"($name)-tag",
            namespace: "flux-system"
        }
        spec: {
            imageRepositoryRef: {
                name: $imageRepositoryName
            },
            filterTags: {
                pattern: '^v(?P<semver>[0-9]*\.[0-9]*\.[0-9]*)'
                extract: '$semver'
            }
            policy:{
                semver: {
                    range: '>=1.0.0'
                }
            }   
        }
    }  | to yaml | save "image-policy-tag.yaml" --force
    
    {
        apiVersion: "image.toolkit.fluxcd.io/v1beta2",
        kind: "ImagePolicy",
        metadata: {
            name: $"($name)-buildnr",
            namespace: "flux-system"
        }
        spec: {
            imageRepositoryRef: {
                name: $imageRepositoryName
            },
            filterTags: {
                pattern: '^main-[a-fA-F0-9]+-(?P<ts>.*)'
                extract: '$ts'
            }
            policy:{
                numerical: {
                    order: 'asc'
                }
            }   
        }
    } | to yaml | save "image-policy-buildnr.yaml" --force
}

def "create image-repository" [
    name: string,
    image: string
] {
    {
        apiVersion: "image.toolkit.fluxcd.io/v1beta2",
        kind: "ImageRepository",
        metadata: {
            name: $name,
            namespace: "flux-system"
        },
        spec: {
            image: $image,
            interval: "5m"
        }
    } | to yaml | save "image-repository.yaml" --force
}