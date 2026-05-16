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

        # Stable Rust toolchain with:
        #   - wasm32-wasip1  — required to compile the extension to a .wasm binary
        #   - rust-src       — enables rust-analyzer and cargo doc
        #   - rustfmt        — code formatting
        #   - clippy         — linter
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

            # C linker — required by the Rust compiler for native (host) builds.
            pkgs.gcc

            # WebAssembly tooling — used to inspect, validate, and convert between
            # core Wasm and the Component Model format consumed by the Zed extension
            # loader (e.g. `wasm-tools component new`, `wasm-tools validate`).
            pkgs.wasm-tools
          ];

          # Improve error output during development.
          env.RUST_BACKTRACE = "1";

          shellHook = ''
            echo ""
            echo "  zed-gregorio dev shell"
            echo "  ──────────────────────────────────────────────────────────────"
            echo "  cargo build                            native compile-check"
            echo "  cargo build --target wasm32-wasip1     build extension .wasm"
            echo "  cargo clippy -- -D warnings            lint"
            echo "  cargo fmt --check                      check formatting"
            echo "  wasm-tools validate extension.wasm     validate built .wasm"
            echo "  ──────────────────────────────────────────────────────────────"
            echo ""
          '';
        };
      }
    );
}
