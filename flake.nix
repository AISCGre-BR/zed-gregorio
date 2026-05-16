{
  description = "Development shell for zed-gregorio — Zed extension for GABC/NABC notation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Provides rust-bin.stable/beta/nightly with per-component and per-target control.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        # Stable Rust toolchain.
        # wasm32-wasip1 is the target required by cargo-component and by Zed's
        # extension loader — do NOT switch to wasm32-wasip2, which is still
        # incompatible with several transitive dependencies of zed_extension_api.
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = [ "wasm32-wasip1" ];
          extensions = [
            "rust-src"
            "rustfmt"
            "clippy"
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            rustToolchain

            # C linker — required by rustc for native (host) builds.
            pkgs.gcc

            # cargo-component wraps `cargo build` and automatically converts the
            # wasm32-wasip1 core module into a WebAssembly Component (the format
            # expected by Zed's extension loader). Plain `cargo build` produces a
            # core MVP module that Zed cannot load.
            #
            # Correct build command:
            #   cargo component build --target wasm32-wasip1 --release
            # Output: target/wasm32-wasip1/release/zed_gregorio.wasm  (component)
            pkgs.cargo-component

            # WebAssembly tooling — validate, inspect, and decompose .wasm components.
            #   wasm-tools validate --features component-model extension.wasm
            pkgs.wasm-tools
          ];

          env.RUST_BACKTRACE = "1";

          shellHook = ''
            echo ""
            echo "  zed-gregorio dev shell"
            echo "  ──────────────────────────────────────────────────────────────────"
            echo "  Compile-check (native):"
            echo "    cargo build"
            echo "    cargo clippy -- -D warnings"
            echo "    cargo fmt --check"
            echo ""
            echo "  Build Zed extension .wasm (WebAssembly Component):"
            echo "    cargo component build --target wasm32-wasip1 --release"
            echo "    cp target/wasm32-wasip1/release/zed_gregorio.wasm extension.wasm"
            echo ""
            echo "  Validate produced component:"
            echo "    wasm-tools validate --features component-model extension.wasm"
            echo "  ──────────────────────────────────────────────────────────────────"
            echo ""
          '';
        };
      }
    );
}
