# Nushell script to create a Kubernetes namespace if it does not exist
# Usage: ./create-namespace.nu <namespace>

let namespace = ($in | get 0)
if ($namespace | is-empty) {
  print "Usage: ./create-namespace.nu <namespace>"
  exit 1
}

let exists = (kubectl get namespace $namespace | complete | get exit_code)
if $exists != 0 {
  kubectl create namespace $namespace
  print "Namespace '$namespace' created."
} else {
  print "Namespace '$namespace' already exists."
}
