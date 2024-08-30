{
  description = "My customized tmux executable";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zsh-flake.url = "github:mbish/zsh-flake";
  };

  outputs = {
    self,
    zsh-flake,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
      ];
    };
    tmuxConf = import ./tmux.nix {
      pkgs = pkgs;
      lib = pkgs.lib;
      zsh = zsh-flake;
      inherit system;
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
