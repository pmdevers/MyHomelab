{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = with pkgs; [ 
    git
    gh
    kubectl
    k9s
    fluxcd
    minikube
  ];
}