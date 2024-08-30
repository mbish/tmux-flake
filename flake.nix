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
    fullConf = import ./tmux.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      zsh = zsh-flake;
      shell = "${zsh-flake.packages.${system}.default}/bin/zsh";
      inherit system;
    };
    mkTmux = tmuxConf:
      pkgs.writeShellScriptBin "tmux" ''
        ${pkgs.tmux}/bin/tmux -f ${tmuxConf}
      '';
    minimalTmuxConf = import ./tmux.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      shell = "${zsh-flake.packages.${system}.minimal}/bin/zsh";
      inherit system;
    };
    localTmuxConf = import ./tmux.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      shell = "$SHELL";
      inherit system;
    };
  in {
    packages = {
      x86_64-linux = {
        tmux = mkTmux fullConf;
        default = mkTmux fullConf;
        minimal = mkTmux minimalTmuxConf;
        local = mkTmux localTmuxConf;
      };
    };
  };
}
