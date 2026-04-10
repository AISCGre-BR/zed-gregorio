#!/usr/bin/env python3
"""
inspect_highlights.py
Analisa o HTML gerado por `tree-sitter highlight --html` e exibe,
linha a linha, cada token do arquivo GABC com o nome da captura
tree-sitter que lhe foi atribuída (ou <none> quando não há captura).

Uso:
    python inspect_highlights.py kyrie_highlight.html [--no-color] [--only-captures] [--uncaptured]
"""

import argparse
import re
import sys
from html.parser import HTMLParser

# ---------------------------------------------------------------------------
# Extrai mapeamento  style-string → nome-da-captura  a partir do bloco <style>
# ---------------------------------------------------------------------------
# O tree-sitter highlight --html gera um bloco CSS assim:
#
#   .keyword { color: #5f00d7; }
#   .constant.builtin { font-weight: bold;color: #875f00; }
#
# E depois usa spans com inline style equivalente:
#
#   <span style='color: #5f00d7'>c4</span>
#
# Fazemos o reverse-map: normalizamos o valor CSS e indexamos pelo conteúdo
# da regra, mapeando para o nome da classe.

_CSS_RULE_RE = re.compile(r"\.([\w.]+)\s*\{([^}]+)\}", re.MULTILINE)


def _normalize_style(style: str) -> str:
    """Remove espaços irrelevantes e garante ponto-e-vírgula final."""
    parts = [p.strip() for p in style.split(";") if p.strip()]
    return ";".join(sorted(parts))


def build_style_to_capture(html: str) -> dict[str, str]:
    """
    Extrai todos os blocos .classname { ... } do HTML e devolve
    um dicionário  normalized_style → capture_name.
    """
    mapping: dict[str, str] = {}
    for m in _CSS_RULE_RE.finditer(html):
        capture_name = m.group(1).replace(".", ".")  # ex: "constant.builtin"
        rule_body = m.group(2).strip()
        normalized = _normalize_style(rule_body)
        mapping[normalized] = capture_name
    return mapping


# ---------------------------------------------------------------------------
# Parser HTML → lista de linhas, cada linha = lista de (texto, captura|None)
# ---------------------------------------------------------------------------


class HighlightHTMLParser(HTMLParser):
    """
    Percorre o HTML gerado por tree-sitter highlight --html.
    Estrutura esperada:
        <tr>
          <td class=line-number>N</td>
          <td class=line>
            texto livre
            <span style='...'>token</span>
            ...
          </td>
        </tr>
    """

    def __init__(self, style_map: dict[str, str]):
        super().__init__()
        self.style_map = style_map
        self.lines: list[list[tuple[str, str | None]]] = []

        self._in_line_td = False
        self._in_row = False
        # pilha de capturas: cada entrada é str|None
        self._capture_stack: list[str | None] = []
        self._current_line: list[tuple[str, str | None]] = []

    # ------------------------------------------------------------------ tags

    def handle_starttag(self, tag: str, attrs: list) -> None:
        attr = dict(attrs)
        if tag == "tr":
            self._in_row = True
            self._current_line = []
            self._in_line_td = False

        elif tag == "td":
            self._in_line_td = attr.get("class") == "line"

        elif tag == "span" and self._in_line_td:
            raw_style = attr.get("style", "")
            norm = _normalize_style(raw_style)
            capture = self.style_map.get(norm)  # None se não encontrar
            self._capture_stack.append(capture)

        elif tag == "br" and self._in_line_td:
            self._current_line.append(("\n", None))

    def handle_endtag(self, tag: str) -> None:
        if tag == "span" and self._in_line_td and self._capture_stack:
            self._capture_stack.pop()
        elif tag == "td":
            self._in_line_td = False
        elif tag == "tr" and self._in_row:
            if self._current_line:
                self.lines.append(self._current_line)
            self._current_line = []
            self._in_row = False

    def handle_data(self, data: str) -> None:
        if not self._in_line_td:
            return
        capture = self._capture_stack[-1] if self._capture_stack else None
        parts = data.split("\n")
        for i, part in enumerate(parts):
            if part:
                self._current_line.append((part, capture))
            if i < len(parts) - 1:
                self._current_line.append(("\n", None))

    # -------------------- entidades HTML

    def handle_entityref(self, name: str) -> None:
        entities = {"amp": "&", "lt": "<", "gt": ">", "quot": '"', "nbsp": "\xa0"}
        self.handle_data(entities.get(name, f"&{name};"))

    def handle_charref(self, name: str) -> None:
        try:
            ch = chr(int(name[1:], 16) if name.startswith("x") else int(name))
        except ValueError:
            ch = f"&#{name};"
        self.handle_data(ch)


# ---------------------------------------------------------------------------
# Saída
# ---------------------------------------------------------------------------

RESET = "\033[0m"

# ANSI aproximado por captura (só usado quando stdout é TTY)
_ANSI: dict[str, str] = {
    "attribute": "\033[3;91m",
    "comment": "\033[3;90m",
    "constant": "\033[33m",
    "constant.builtin": "\033[1;33m",
    "constructor": "\033[93m",
    "emphasis": "\033[3m",
    "emphasis.strong": "\033[1;3m",
    "function": "\033[34m",
    "function.builtin": "\033[1;34m",
    "keyword": "\033[95m",
    "number": "\033[1;33m",
    "operator": "\033[1;90m",
    "property": "\033[91m",
    "property.builtin": "\033[1;91m",
    "punctuation": "\033[90m",
    "punctuation.bracket": "\033[90m",
    "punctuation.delimiter": "\033[90m",
    "punctuation.special": "\033[1;90m",
    "string": "\033[32m",
    "string.special": "\033[36m",
    "tag": "\033[94m",
    "text.literal": "\033[32m",
    "title": "\033[1;34m",
    "type": "\033[96m",
    "type.builtin": "\033[1;96m",
    "variable": "\033[37m",
    "variable.builtin": "\033[1;37m",
    "variable.parameter": "\033[4;37m",
}


def _ansi(capture: str | None, use_color: bool) -> str:
    if not use_color or capture is None:
        return ""
    return _ANSI.get(capture, "")


def print_token_table(
    lines: list[list[tuple[str, str | None]]],
    use_color: bool,
    only_captures: bool,
) -> None:
    COL_W = 32
    header = f"{'LN':>4}  {'TOKEN':<22}  {'CAPTURA'}"
    sep = "-" * len(header)
    print(sep)
    print(header)
    print(sep)

    for line_no, tokens in enumerate(lines, start=1):
        shown = False
        for text, capture in tokens:
            if text in ("\n", ""):
                continue
            if only_captures and capture is None:
                continue
            label = capture if capture else "<none>"
            col = _ansi(capture, use_color)
            rst = RESET if use_color else ""
            tok = repr(text)
            print(f"{line_no:>4}  {col}{tok:<22}{rst}  {col}{label}{rst}")
            shown = True

        if not only_captures and not shown:
            raw = "".join(t for t, _ in tokens if t != "\n")
            if raw.strip():
                print(f"{line_no:>4}  {'(sem capturas)':<22}  <none>")

    print(sep)


def print_summary(lines: list[list[tuple[str, str | None]]]) -> None:
    from collections import Counter

    counter: Counter[str] = Counter()
    uncaptured = 0

    for tokens in lines:
        for text, cap in tokens:
            if text in ("\n", ""):
                continue
            if cap:
                counter[cap] += 1
            else:
                uncaptured += len(text)

    print("\n=== RESUMO DE CAPTURAS ===")
    print(f"  {'CAPTURA':<35} {'TOKENS':>7}")
    print("  " + "-" * 43)
    for cap, cnt in sorted(counter.items(), key=lambda x: -x[1]):
        print(f"  {cap:<35} {cnt:>7}")
    print("  " + "-" * 43)
    print(f"  {'<sem captura> (chars totais)':<35} {uncaptured:>7}")


def print_uncaptured(lines: list[list[tuple[str, str | None]]]) -> None:
    print("\n=== TOKENS SEM CAPTURA (por linha) ===")
    found = False
    for line_no, tokens in enumerate(lines, start=1):
        for text, cap in tokens:
            if text in ("\n", "") or cap is not None:
                continue
            print(f"  linha {line_no:>3}: {repr(text)}")
            found = True
    if not found:
        print("  (nenhum)")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------


def main() -> None:
    ap = argparse.ArgumentParser(
        description=(
            "Inspeciona highlights tree-sitter a partir do HTML gerado por "
            "`tree-sitter highlight --html`."
        )
    )
    ap.add_argument("html_file", help="Arquivo HTML gerado pelo tree-sitter CLI")
    ap.add_argument("--no-color", action="store_true", help="Desativa ANSI no terminal")
    ap.add_argument(
        "--only-captures", action="store_true", help="Mostra só tokens com captura"
    )
    ap.add_argument(
        "--no-summary", action="store_true", help="Suprime o resumo de capturas"
    )
    ap.add_argument(
        "--uncaptured", action="store_true", help="Lista tokens sem captura"
    )
    args = ap.parse_args()

    use_color = (not args.no_color) and sys.stdout.isatty()

    try:
        with open(args.html_file, "r", encoding="utf-8-sig") as f:
            html = f.read()
    except FileNotFoundError:
        sys.exit(f"Erro: arquivo '{args.html_file}' não encontrado.")

    style_map = build_style_to_capture(html)
    if not style_map:
        sys.exit(
            "Erro: nenhum bloco CSS encontrado no HTML.\n"
            "Verifique se o arquivo foi gerado com `tree-sitter highlight --html`."
        )

    print(f"[mapeamento CSS] {len(style_map)} estilos → capturas encontrados")
    for norm, cap in sorted(style_map.items(), key=lambda x: x[1]):
        print(f"  {cap:<35}  {norm}")
    print()

    parser = HighlightHTMLParser(style_map)
    parser.feed(html)

    if not parser.lines:
        sys.exit("Nenhuma linha encontrada no HTML.")

    print_token_table(
        parser.lines, use_color=use_color, only_captures=args.only_captures
    )

    if not args.no_summary:
        print_summary(parser.lines)

    if args.uncaptured:
        print_uncaptured(parser.lines)


if __name__ == "__main__":
    main()
