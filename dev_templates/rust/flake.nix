{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    supportedSystem = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in
    flake-utils.lib.eachSystem supportedSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        stdenv = pkgs.stdenv;

        overrides = builtins.fromTOML (builtins.readFile (self + "/rust-toolchain.toml"));
        libPath = pkgs.lib.makeLibraryPath [];

        isLinux = stdenv.isLinux;
        isDarwin = stdenv.isDarwin;
      in {
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [pkgs.pkg-config];

          buildInputs = with pkgs;
            [
              clang
              llvmPackages.bintools
              rustup
            ]
            ++ lib.optionals stdenv.isDarwin [
              libiconv-darwin
            ];

          RUSTC_VERSION = overrides.toolchain.channel;

          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [pkgs.llvmPackages_latest.libclang.lib];

          shellHook = ''
            export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
            export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
          '';

          RUSTFLAGS = builtins.map (a: "-L ${a}/lib") [
            # add additional precompiled libraries here
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);

          # Conditional bindgen flags
          BINDGEN_EXTRA_CLANG_ARGS =
            # General include paths (platform agnostic)
            (builtins.map (a: "-I${a}/include") [
              # Add dev libraries here (platform-independent ones)
            ])
            ++
            # Linux-specific include paths
            (
              if isLinux
              then [
                "-I${pkgs.glibc.dev}/include"
                "-I${pkgs.glib.dev}/include/glib-2.0"
                "-I${pkgs.glib.out}/lib/glib-2.0/include"
              ]
              else []
            )
            ++ [
              "-I${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"
            ];
        };
      }
    )
    // {
      templates.default = {
        path = ./.;
        description = "Rust environment template";
      };
    };
}
