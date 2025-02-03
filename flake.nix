{
  description = "Hacklab Development Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            docker
            grml-zsh-config
            kubectl
            kubernetes-helm
            kustomize
            minio-client
            openssl
            zsh
          ];

          shellHook = ''           
            export SHELL=$(which zsh)
            export KUSTOMIZE_ENABLE_HELM=true
            echo "🌀 Welcome to the hacklab project development shell!"
            echo "Available tools:"
            echo " - kustomize $(kustomize version)"
            echo " - kubectl $(kubectl version --client | head -n1)"
            echo " - helm $(helm version --short)"
            if [ -t 1 ]; then
              exec zsh
            fi
          '';
        };
      }
    );
}