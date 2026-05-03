# Changelog

## 1.0.0-alpha.1 — 2026-05-02

First alpha release of the `zed-gregorio` extension aligned with the
`tree-sitter-gregorio` and `gregorio-lsp` v1.0.0-alpha.1 ecosystem.

### Changed
- `tree-sitter-gregorio` grammar pinned to tag `v1.0.0-alpha.1`
  (commit `002d6b31`, Gregorio 6.2.0 compatible).
- `src/lib.rs`: removed npm/npx fallback — `gregorio-lsp` is now a Rust binary
  distributed via Cargo; error message updated with `cargo install` instructions.
- `extension.toml`: `authors` updated to `AISCGre Brasil`.
- Copyright updated to `Copyright (c) 2026 AISCGre Brasil` across `LICENSE` and
  `README.md`.
- `README.md`: prerequisites section updated to reflect Rust/Cargo installation.

### Added
- `AGENTS.md`: comprehensive AI code generation guide covering architecture, query
  file conventions, dependency update workflow, common pitfalls, and checklists.

## 0.1.x

Earlier history (TypeScript-based LSP, Node.js prerequisites) preserved in Git commits.
