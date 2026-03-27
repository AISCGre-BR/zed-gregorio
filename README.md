# Gregorio GABC — Zed Extension

Adds support for **GABC/NABC** (Gregorian chant notation) files to [Zed](https://zed.dev).

## Features

- **Syntax Highlighting** — Full highlighting for GABC headers, pitches, clefs, neumes, bars, alterations, style tags, NABC notation, and comments.
- **LaTeX Injection** — TeX code inside `<v>…</v>` tags and verbatim attributes (`[nv:…]`, `[gv:…]`, `[ev:…]`) gets LaTeX highlighting.
- **Bracket Matching** — Auto-matching for `()`, `[]`, `{}`, and `<>`.
- **Code Outline** — Headers appear in the document outline/symbols panel.
- **Language Server** — Diagnostics, hover, completion, and document symbols via [gregorio-lsp](https://github.com/AISCGre-BR/gregorio-lsp).

## Prerequisites

For **Language Server** features (diagnostics, hover, completions):

1. [Node.js](https://nodejs.org) ≥ 16
2. Install gregorio-lsp globally:
   ```sh
   npm install -g gregorio-lsp
   ```

Syntax highlighting works without any prerequisites.

## Installation

### From Zed Extensions Marketplace

Search for "Gregorio" in **Zed → Extensions**.

### As Dev Extension

1. Clone this repository
2. In Zed, run **`zed: install dev extension`** and select the cloned directory

## Grammar

This extension uses [tree-sitter-gregorio](https://github.com/AISCGre-BR/tree-sitter-gregorio) (v0.3.0+), a complete tree-sitter grammar for GABC+NABC notation compatible with Gregorio 6.1.0.

## License

MIT