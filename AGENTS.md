# AGENTS.md — AI Code Generation Guide for zed-gregorio

This document is the primary reference for AI agents (GitHub Copilot, Claude, etc.)
contributing code to this repository. Read it before making any changes.

> **Language policy**: All content in this repository **must be in English** — without
> exception. This applies to: source code identifiers (variables, functions, constants,
> types), code comments, documentation (`.md` files), commit messages, query file
> comments, error messages, and any other human-readable text added or modified in a
> contribution.

---

## 1. Project Overview

`zed-gregorio` is a [Zed](https://zed.dev) editor extension that adds support for
**GABC/NABC** (Gregorian chant notation) files. It integrates:

- **[tree-sitter-gregorio](https://github.com/aiscgre-br/tree-sitter-gregorio)** —
  tree-sitter grammar for syntax highlighting, bracket matching, and code outline.
- **[gregorio-lsp](https://github.com/aiscgre-br/gregorio-lsp)** — Language Server
  Protocol (LSP) implementation providing diagnostics, hover, completions, and document
  symbols.

**Language specs** live in the companion projects' `docs/` directories. All GABC/NABC
syntax questions should be answered by reading those specs, not by guessing.

---

## 2. Repository Structure

```
extension.toml          ← Zed extension manifest (version, grammar ref, LSP declaration)
Cargo.toml              ← Rust crate (zed_extension_api)
LICENSE                 ← MIT — Copyright (c) 2026 AISCGre Brasil
README.md               ← User-facing documentation

src/
  lib.rs                ← Extension entry point: language_server_command()

languages/
  gabc/
    config.toml         ← Language configuration (name, file suffixes, brackets)
    highlights.scm      ← Tree-sitter syntax highlighting captures
    injections.scm      ← Language injection (LaTeX inside verbatim attributes/headers)
    brackets.scm        ← Bracket matching pairs
    outline.scm         ← Document outline / symbols captures
```

---

## 3. Development Workflow

> **NixOS environment**: `cargo` and `rustc` are not in PATH directly.
> Always use nix shells:

```bash
# Build the extension (Zed loads it as a cdylib)
nix shell nixpkgs#cargo nixpkgs#rustc nixpkgs#gcc -c cargo build

# Install as a dev extension in Zed:
# Zed → Extensions → Install Dev Extension → select this directory
```

**The cycle for any change:**

1. Edit the relevant file(s)
2. `cargo build` — verify the Rust crate compiles (only needed when editing `src/lib.rs`)
3. Reload the dev extension in Zed to test
4. Commit and push

---

## 4. Architecture

### 4.1 Extension Manifest (`extension.toml`)

```toml
[grammars.gregorio]
repository = "https://github.com/AISCGre-BR/tree-sitter-gregorio"
rev = "<commit-sha>"          # always pin to an exact commit, never a branch

[language_servers.gregorio-lsp]
name = "Gregorio LSP"
languages = ["GABC"]
```

The `rev` field must be a full 40-character SHA pointing to the tagged release commit.
**Never use a branch name** — Zed fetches grammar sources directly.

To update the grammar, get the commit SHA for the new tag:
```bash
git -C /path/to/tree-sitter-gregorio rev-list -n 1 vX.Y.Z
```

### 4.2 Language Server Detection (`src/lib.rs`)

`language_server_command()` searches for the `gregorio-lsp` binary using
`worktree.which()`. The lookup order is:

1. First hit of `gregorio-lsp` in `PATH` (e.g. installed via `cargo install`)
2. Cached path from a previous successful lookup

If not found, returns an error with `cargo install` instructions pointing to the
latest tagged release.

**Do NOT add npm/npx fallback** — `gregorio-lsp` is a Rust binary distributed via
Cargo, not a Node.js package.

### 4.3 Query Files (`languages/gabc/`)

The `.scm` files are evaluated by Zed's tree-sitter integration. They consume node
kinds and field names from `tree-sitter-gregorio`.

| File | Purpose |
|---|---|
| `highlights.scm` | Maps node kinds to Zed theme capture names (`@attribute`, `@keyword`, etc.) |
| `injections.scm` | Injects `latex` language into `tex_code` / `tex_code_header` nodes |
| `brackets.scm` | Defines matching bracket pairs |
| `outline.scm` | Selects nodes that appear as symbols in the outline panel |

---

## 5. Key Constraints

### 5.1 Zed Capture Names

Zed uses a subset of the standard tree-sitter capture names. When adding highlights,
use only names that Zed themes recognise. Common ones used in this extension:

| Capture | Used For |
|---|---|
| `@attribute` | Header names |
| `@string` | Header values |
| `@number` | Numeric header values |
| `@constant.builtin` | Pitch letters |
| `@keyword.directive` | Clefs, bar types |
| `@keyword` | Shape modifiers |
| `@operator` | Fusion operators, spacers |
| `@punctuation.special` | Section separator `%%`, pipes `\|` |
| `@punctuation.delimiter` | Header terminators `;` `;;` |
| `@comment` | `% …` comments |
| `@label` | Lyric text |
| `@variable` | Style tag content |
| `@tag` | Style tag delimiters |
| `@embedded` | Injected code blocks |

Do not invent new capture names — Zed will silently ignore unknown captures.

### 5.2 Anonymous Nodes in Field Queries

Tree-sitter named fields can point to anonymous literal nodes (e.g., the `name` field
of `header_numeric_mode` is the anonymous literal `"mode"`). In `.scm` files, match
these with `_` (unnamed wildcard), not `(_)` (named wildcard):

```scheme
; Correct: matches anonymous literal nodes
(header_numeric_mode name: _ @attribute)

; Wrong: only matches named nodes — misses anonymous literals
(header_numeric_mode name: (_) @attribute)
```

### 5.3 Grammar Version Pinning

The `rev` in `extension.toml` must always be pinned to a specific commit SHA.
When `tree-sitter-gregorio` releases a new version, update `rev` to the exact commit
of that tag and verify all `.scm` queries still work with the new node kinds.

If `tree-sitter-gregorio` bumps `STABLE_NODE_KIND_CONTRACT_VERSION` (a breaking change),
all `.scm` files must be reviewed for renamed or removed node kinds.

---

## 6. Updating Dependencies

### Updating `tree-sitter-gregorio`

1. Get the commit SHA for the new tag:
   ```bash
   git -C /path/to/tree-sitter-gregorio rev-list -n 1 vX.Y.Z
   ```
2. Update `rev` in `extension.toml`.
3. Review `languages/gabc/*.scm` for any node kind changes.
4. Test with the Zed dev extension.
5. Update `extension.toml` version (semver bump).
6. Commit and tag.

### Updating `gregorio-lsp`

1. Update the install instructions in `README.md` and `src/lib.rs` error message
   to reference the new tag.
2. No code changes needed — the extension detects the binary dynamically via `PATH`.

---

## 7. Testing

There is no automated test suite for the extension itself. Testing is done manually:

1. Install as a dev extension in Zed.
2. Open a `.gabc` file (e.g. `kyrie.gabc` in the repo root).
3. Verify syntax highlighting covers headers, pitches, clefs, bars, NABC, and comments.
4. With `gregorio-lsp` installed, verify diagnostics appear for known errors (e.g.
   missing `name:` header).
5. Open the outline panel and verify headers appear as symbols.
6. Test bracket matching inside `()` and `[]`.

---

## 8. Common Pitfalls

1. **`rev` must be a full SHA**: Zed fetches grammar sources by rev. A tag name or
   branch name will not work — always resolve the tag to its commit SHA first.

2. **`_` vs `(_)` in field queries**: Anonymous token fields must use bare `_` wildcard.
   Using `(_)` will silently miss them and produce no highlights for those nodes.

3. **Zed-specific capture names**: Zed does not support all standard tree-sitter
   capture names. Unsupported captures are silently ignored. Always test highlights
   visually in Zed, not just by validating the S-expression.

4. **Injections require `#set! injection.language`**: When injecting a language, always
   set the language name explicitly:
   ```scheme
   ((tex_code) @injection.content
     (#set! injection.language "latex"))
   ```

5. **`cdylib` crate type**: `Cargo.toml` must declare `crate-type = ["cdylib"]`. This
   is required by Zed's extension system. Do not change it.

6. **No async in `lib.rs`**: The `zed_extension_api` API is synchronous. Do not
   introduce `tokio` or `async-std` — the extension runs in Zed's own async runtime.

7. **`worktree.which()` for binary detection**: Always use `worktree.which()` to find
   the LSP binary, not `std::process::Command`. This respects the workspace's PATH
   and Zed's sandboxing.

---

## 9. Companion Projects

| Project | Role |
|---|---|
| [tree-sitter-gregorio](https://github.com/aiscgre-br/tree-sitter-gregorio) | Grammar source; pinned via `rev` in `extension.toml` |
| [gregorio-lsp](https://github.com/aiscgre-br/gregorio-lsp) | LSP server binary (`gregorio-lsp`); installed separately by the user |

When either companion project releases a new version, update this extension accordingly
(see §6).

---

## 10. Commit Style

- Follow **Conventional Commits**: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Scope (optional): `feat(highlights):`, `fix(outline):`, `chore(release):`
- GPG-sign commits (preferred):
  ```bash
  git -c gpg.program=gpg -c commit.gpgsign=true commit \
    --gpg-sign=BAC0B1B569777A733E37447FB10712C404063D38 -m "feat(highlights): ..."
  ```
- Keep **all text in English**: commit messages, comments, query comments, identifiers.
- Reference upstream changes when bumping grammar: `chore: update to tree-sitter-gregorio v1.0.0`

---

## 11. Checklist for Updating the Grammar

- [ ] Get new tag commit SHA: `git rev-list -n 1 vX.Y.Z`
- [ ] Update `rev` in `extension.toml`
- [ ] Review `languages/gabc/*.scm` for node kind renames or removals
- [ ] Test highlights, outline, injections, and brackets in Zed
- [ ] Bump `version` in `extension.toml`
- [ ] Update `README.md` grammar version reference
- [ ] Commit and tag
- [ ] GPG-sign the commit

## 12. Checklist for Adding a New Highlight

- [ ] Read the relevant section of `tree-sitter-gregorio`'s grammar to find the correct node kind
- [ ] Add the capture to `languages/gabc/highlights.scm` using a supported Zed capture name (§5.1)
- [ ] Use `_` (not `(_)`) for anonymous field nodes (§5.2)
- [ ] Test visually in Zed with a representative `.gabc` file
- [ ] Commit with `feat(highlights): ...`
