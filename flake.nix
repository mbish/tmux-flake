{
  description = "My customized tmux executable";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zsh-flake.url = "github:mbish/zsh-flake";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = {
    self,
    zsh-flake,
    nixpkgs,
    flake-utils,
  }: let
    systems = ["x86_64-linux" "armv7l-linux"];
    build = system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
        ];
      };
      fullConf = import ./tmux.nix {
        inherit pkgs system;
        inherit (pkgs) lib;
        zsh = zsh-flake;
        shell = "${zsh-flake.packages.${system}.default}/bin/zsh";
      };
      mkTmux = tmuxConf:
        pkgs.writeShellScriptBin "tmux" ''
          ${pkgs.tmux}/bin/tmux -f ${tmuxConf} $@
        '';
      minimalTmuxConf = import ./tmux.nix {
        inherit pkgs system;
        inherit (pkgs) lib;
        shell = "${zsh-flake.packages.${system}.minimal}/bin/zsh";
      };
      localTmuxConf = import ./tmux.nix {
        inherit pkgs system;
        inherit (pkgs) lib;
        shell = "$SHELL";
      };
    in {
      packages = {
        tmux = mkTmux fullConf;
        default = mkTmux fullConf;
        minimal = mkTmux minimalTmuxConf;
        local = mkTmux localTmuxConf;
      };
    };
  in
    flake-utils.lib.eachSystem systems build;
}
