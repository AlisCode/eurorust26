{
  description = "Development environment for the EuroRust 2026 hackathon";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, rust-overlay, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
          rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          libPath = pkgs.lib.makeLibraryPath [
            pkgs.openssl
            pkgs.fontconfig
            pkgs.opencv
          ];
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              rust
              rust-analyzer
              clang
              llvmPackages_latest.lld
              llvmPackages_latest.libclang
              pkg-config
              opencv
              openssl.dev
              fontconfig
              python3
              uv
            ];

            RUST_LOG="overloard=trace,car-control=trace";
            LD_LIBRARY_PATH = libPath;
            LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
            BINDGEN_EXTRA_CLANG_ARGS =
              pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ "-I${pkgs.glibc.dev}/include" ]
              ++ [
                "-I${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"
                "-I${pkgs.glib.dev}/include/glib-2.0"
                "-I${pkgs.glib.out}/lib/glib-2.0/include"
              ];
          };
        }
      );
    };
}
