{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [ 
    git
    kubectl
    k9s
    fluxcd
    minikube
  ];
}