# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2026-05-05

### Fixed
- Removed bundled `extension.wasm`, `grammars/gregorio`, `grammars/gregorio.wasm`,
  and `grammars/tree-sitter-gregorio` from version control — their presence
  prevented the Zed dev extension installer from cloning the tree-sitter grammar.
- Added `grammars/gregorio/` and `grammars/tree-sitter-gregorio/` to `.gitignore`
  so Zed-managed build outputs are never accidentally staged.

### Changed
- Extension renamed back to **Gregorio GABC** (from "Gregorio (GABC)").

## [0.3.0] - 2026-05-05

### Added
- `AGENTS.md`: comprehensive AI code generation guide covering architecture, query
  file conventions, dependency update workflow, common pitfalls, and checklists.

### Changed
- `languages/gabc/highlights.scm`: extensive rework for improved One Dark theme
  compatibility — captures reorganized across headers, clefs, bars, neumes, NABC
  glyphs, spacing, attributes, and syllable text; invalid node-type references
  (`header_value`, `f_clef_flat`, `gabc_macro`, `translation_content`,
  `centering_content`) replaced with comments documenting when they should be
  restored once the grammar exposes those nodes.
- `tree-sitter-gregorio` grammar updated from commit `002d6b31` to
  **v0.5.2** (commit `c9034de8`), adding Gregorio 6.2.0 support:
  - `lyric_tie` token (`~` in syllable text) now highlighted as
    `@punctuation.special`.
  - Empty GABC/NABC snippets in alternation contexts (`(|vi)`, `(||ta)`,
    `(g||ta)`) are now parsed correctly.
- `gregorio-lsp` dependency updated to **v0.3.0**;
  install instructions updated accordingly.
- `tree-sitter-gregorio` grammar pinned to tag `v1.0.0-alpha.1`
  (commit `002d6b31`, Gregorio 6.2.0 compatible).
- `src/lib.rs`: removed npm/npx fallback — `gregorio-lsp` is now a Rust binary
  distributed via Cargo; error message updated with `cargo install` instructions.
- `extension.toml`: `authors` updated to `AISCGre Brasil`.
- Copyright updated to `Copyright (c) 2026 AISCGre Brasil` across `LICENSE` and
  `README.md`.
- `README.md`: prerequisites section updated to reflect Rust/Cargo installation.

## [0.2.0]

- Updated grammar reference to `tree-sitter-gregorio` and `gregorio-lsp`
  `v1.0.0-alpha.1`.

## [0.1.x]

Earlier history (TypeScript-based LSP, Node.js prerequisites) preserved in Git
commits.

---

[0.3.1]: https://github.com/AISCGre-BR/zed-gregorio/releases/tag/v0.3.1
[0.3.0]: https://github.com/AISCGre-BR/zed-gregorio/releases/tag/v0.3.0
[0.2.0]: https://github.com/AISCGre-BR/zed-gregorio/releases/tag/v0.2.0
