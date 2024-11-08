{
  description = "purescript-book";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { self, nixpkgs, purescript-overlay, ... }: let
    name = "purescript-book";
    supportedSystems = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
  in {
    devShell = forAllSystems (system: let
      overlays = [
        purescript-overlay.overlays.default
      ];
      pkgs = import nixpkgs { inherit system overlays; };
    in
      pkgs.mkShell {
        inherit name;
        shellHook = ''
          echo "Welcome to the PureScript book development environment!"
        '';
        buildInputs = [
            pkgs.esbuild
            pkgs.nodejs_20
            pkgs.nixpkgs-fmt
            pkgs.purs
            pkgs.purs-tidy
            pkgs.purs-backend-es
            pkgs.purescript-language-server
            pkgs.spago-unstable
            ]
            ++ (pkgs.lib.optionals (system == "aarch64-darwin")
              (with pkgs.darwin.apple_sdk.frameworks; [
                Cocoa
                CoreServices
              ]));
      });
  };
}
