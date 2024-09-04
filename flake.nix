{
  description = "";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    ruby-nix = {
      url = github:inscapist/ruby-nix/main;
    };
  };

  outputs = { self, nixpkgs, ruby-nix }@inputs: let
    rubyVersion = "3.3.1";
    overlays = [
      (final: prev: {
        ruby-nix-installed = let
          # gems = prev.bundlerEnv {
          #   ruby = final.ruby;
          #   name = "gems-for-some-project";
          #   gemdir = ./.;
          #   gemset = ./gemset.nix;
          # };
          rubyNix = ruby-nix.lib final;
        in
          rubyNix {
            ruby = final.ruby;
            name = "project-local-gems";
            gemset = ./gemset.nix;
          };
      })
    ];
  in {
    devShells.aarch64-darwin.default = let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit overlays system;
      };
    in pkgs.mkShell {
      packages = [
        pkgs.bundix
      ];
      buildInputs = [
        pkgs.ruby-nix-installed.ruby
        pkgs.ruby-nix-installed.env
      ];
    };

  };
}
