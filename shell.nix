{
  pkgs ?
  import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball {
        url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
      }))
    ];
  },
}: let
  rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
  libPath = pkgs.lib.makeLibraryPath [
    pkgs.openssl
    pkgs.fontconfig
    pkgs.opencv
  ];
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Rust toolchain
    rust
    rust-analyzer

    # Tooling
    clang
    llvmPackages_latest.lld
    llvmPackages_latest.libclang
    pkg-config

    # Native deps
    opencv
    openssl.dev
    fontconfig

    # Python
    python3
    uv
  ];

  LD_LIBRARY_PATH = libPath;
  LIBCLANG_PATH =
    pkgs.lib.makeLibraryPath [pkgs.llvmPackages_latest.libclang.lib];
  BINDGEN_EXTRA_CLANG_ARGS =
    (builtins.map (p: ''-I${p}/include'') [
      pkgs.glibc.dev
    ])
    ++ [
        ''-I${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include''
        ''-I${pkgs.glib.dev}/include/glib-2.0''
        ''-I${pkgs.glib.out}/lib/glib-2.0/include''
      ];
}
