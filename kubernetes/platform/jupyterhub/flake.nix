{
  description = ''
    A Nix flake for securely managing JupyterHub secrets.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ownpkgs.url = "github:heshdotcc/ownpkgs";
    env.url     = "github:heshdotcc/crypt";
  };

  outputs = { nixpkgs, ownpkgs, env, ... }: ownpkgs.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; overlays = [ ownpkgs.overlay ]; };
    toBase64 = ownpkgs.toBase64;
    secrets = import ./secrets.nix { inherit pkgs toBase64 env; };
  in
  {
    devShell = pkgs.mkShell {
      buildInputs = [ pkgs.coreutils ];
      shellHook = ''
        ${builtins.concatStringsSep "\n" (builtins.map (secret: ''
          echo -n '${secret.content}' > ${secret.path}/${secret.name}
        '') secrets)}
      '';
    };
  });
}
