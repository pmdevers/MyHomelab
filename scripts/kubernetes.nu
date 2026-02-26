#!/usr/bin/env nu

def --env "main create kubernetes" [
    --environment = "local"
] {

    if $environment == "local" {
        {
            kind: "Cluster"
            apiVersion: "kind.x-k8s.io/v1alpha4"
            nodes: [{
                role: "control-plane"
                kubeadmConfigPatches: ['kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    node-labels: "ingress-ready=true"'
                ]
                extraPortMappings: [{
                    containerPort: 80
                    hostPort: 80
                    protocol: "TCP"
                }, {
                    containerPort: 443
                    hostPort: 443
                    protocol: "TCP"
                }]
            }]
        } | to yaml | save $"kind.yaml" --force

        kind create cluster --config kind.yaml
    }	
}

def --env "main destroy kubernetes" [
    --environment = "local"
] {

    if $environment == "local" {
        kind delete cluster
    }	
}

# Apply all Talos Omni machine config patches from talos/
def "main apply talos" [] {
    print "Applying cluster-wide patches..."
    omnictl apply -f talos/patches/cluster-wide.yaml
    omnictl apply -f talos/patches/control-planes.yaml

    print "Applying per-node network patches..."
    ls talos/nodes/*.yaml | each {|f|
        print $"  -> ($f.name)"
        omnictl apply -f $f.name
    }

    print "Done. Verify with: omnictl get machineconfigs"
}

# Show current Omni machine config patches for the cluster
def "main get talos" [] {
    omnictl get machineconfigs --selector omni.sidero.dev/cluster=MyHomeLab
}