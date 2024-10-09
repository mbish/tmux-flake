{
  description = "My customized tmux executable";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = {
    self,
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
      fullConf = ./tmux.conf;
      mkTmux = let
        packagesInExe = [
          pkgs.tmuxinator
          pkgs.gnugrep
          pkgs.perl
          pkgs.xclip
          pkgs.powerline
          pkgs.tmux
        ];
      in
        config:
          pkgs.stdenv.mkDerivation {
            name = "tmux-custom";

            nativeBuildInputs = [pkgs.makeWrapper];
            phases = ["installPhase"];
            installPhase = ''
              mkdir -p $out/share
              mkdir -p $out/bin
              cp ${config} $out/share/tmux.conf
              cp ${pkgs.tmux}/bin/tmux $out/bin/tmux
              wrapProgram $out/bin/tmux \
                --prefix PATH : ${pkgs.lib.makeBinPath packagesInExe} \
                --add-flags -f --add-flags $out/share/tmux.conf \
                --set LOCALE_ARCHIVE ${pkgs.glibcLocales}/lib/locale/locale-archive
            '';
          };
    in {
      packages = rec {
        tmux = mkTmux fullConf;
        default = tmux;
      };
    };
  in
    flake-utils.lib.eachSystem systems build;
}
