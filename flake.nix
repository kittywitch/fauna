{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (nixpkgs) lib;
    inherit (lib.attrsets) genAttrs;
    inherit (lib.meta) getExe';
    forAllSystems = genAttrs lib.systems.flakeExposed;
    pkgs' = system: import nixpkgs {
      inherit system;
    };

  in {
    devShells = forAllSystems (system: let
        pkgs = pkgs' system;
      in {
        default = pkgs.mkShell {
          nativeBuildInputs = (with pkgs; [
            gnumake
            gleam
            dart-sass
            watchexec
            inotify-tools
          ]) ++ (with pkgs.beamMinimal28Packages; [
            erlang
            rebar3
          ]);
        };
    });
  };
}
