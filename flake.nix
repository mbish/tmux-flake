{
  description = "My customized tmux executable";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [
      ];
    };
    tmuxConf = import ./tmux.nix {
      pkgs = pkgs;
      lib = pkgs.lib;
    };
    tmux = pkgs.writeShellScriptBin "tmux" ''
      ${pkgs.tmux}/bin/tmux -f ${tmuxConf}
    '';
  in {
    packages = {
      x86_64-linux = rec {
        inherit tmux;
        default = tmux;
      };
    };
  };
}
