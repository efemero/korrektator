{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    naersk,
    rust-overlay,
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [(import rust-overlay)];
    };
    naerskLib = pkgs.callPackage naersk {};
    rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
  in {
    packages."x86_64-linux".default = naerskLib.buildPackage {
      src = ./.;
      buildInputs = [
        #pkgs.glib
      ];
      nativeBuildInputs = [pkgs.pkg-config];
    };

    devShells."x86_64-linux".default = pkgs.mkShell {
      buildInputs = [
        # used for pre-commit hook
        pkgs.python313
        pkgs.pre-commit
        pkgs.python313Packages.jinja2

        # the rust toolchain defined in rust-toolchain.toml
        rustToolchain
      ];

      nativeBuildInputs = [pkgs.pkg-config];

      env.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
  };
}
