; ============================================================================
; TREE-SITTER HIGHLIGHTING QUERIES FOR GABC+NABC — Zed Editor
; ============================================================================
; Adapted from tree-sitter-gregorio queries for Zed compatibility

; ============================================================================
; HEADERS
; ============================================================================

; Separator : between header name and value
":" @punctuation.delimiter

; Header names
; header_generic uses a proper named node (header_name)
(header_name) @attribute

; Numeric and TeX headers use anonymous literal tokens as names → use _
(header_numeric_mode        name: _ @attribute)
(header_numeric_nabc_lines  name: _ @attribute)
(header_numeric_staff_lines name: _ @attribute)
(header_tex_annotation      name: _ @attribute)
(header_tex_mode_modifier   name: _ @attribute)
(header_tex_mode_differentia name: _ @attribute)

; Header values
; NOTE: header_generic value is an anonymous regex node (/[^;%]*/) — not accessible
; via tree-sitter field queries. The plain-text value (e.g. "Kyrie XVI") remains
; unhighlighted; this is a grammar-level limitation, not a query error.

; Numeric header value (named node already highlighted elsewhere)
(header_value_numeric) @number

; TeX header values (injected LaTeX code)
(header_tex_annotation       value: (tex_code_header) @string)
(header_tex_mode_modifier    value: (tex_code_header) @string)
(header_tex_mode_differentia value: (tex_code_header) @string)
(header_tex_def_macro        value: (tex_code_header) @string)

; Header terminators (; and ;;)
(header_generic              terminator: _ @punctuation.delimiter)
(header_numeric_mode         terminator: _ @punctuation.delimiter)
(header_numeric_nabc_lines   terminator: _ @punctuation.delimiter)
(header_numeric_staff_lines  terminator: _ @punctuation.delimiter)
(header_tex_annotation       terminator: _ @punctuation.delimiter)
(header_tex_mode_modifier    terminator: _ @punctuation.delimiter)
(header_tex_mode_differentia terminator: _ @punctuation.delimiter)
(header_tex_def_macro        terminator: _ @punctuation.delimiter)

(section_separator) @punctuation.special

; ============================================================================
; GABC NOTATION - PITCHES
; ============================================================================

(pitch_lowercase) @constant.builtin
(pitch_uppercase) @constant.builtin

; ============================================================================
; GABC NOTATION - CLEFS
; ============================================================================

(c_clef) @keyword
(f_clef) @keyword
(c_clef_flat) @keyword

; ============================================================================
; GABC NOTATION - SEPARATION BARS
; ============================================================================

(virgula) @punctuation.special
(virgula_upper_ledger_line) @punctuation.special
(divisio_minimis) @punctuation.special
(divisio_minimis_upper_ledger_line) @punctuation.special
(divisio_minima) @punctuation.special
(divisio_minima_upper_ledger_line) @punctuation.special
(divisio_minor) @punctuation.special
(divisio_maior) @punctuation.special
(divisio_maior_dotted) @punctuation.special
(divisio_finalis) @punctuation.special
(dominican_bar) @punctuation.special

; Bar modifiers
(vertical_episema) @attribute
(brace) @punctuation.bracket

; ============================================================================
; GABC NOTATION - CUSTOS
; ============================================================================

(custos_auto_pitch) @keyword
(custos_symbol) @keyword
(force_custos) @keyword
(disable_custos) @keyword

; ============================================================================
; GABC NOTATION - LINE BREAKS
; ============================================================================

(justified_line_break) @keyword
(ragged_line_break) @keyword

; ============================================================================
; GABC NOTATION - SPACING
; ============================================================================

(small_neume_separation) @punctuation.delimiter
(medium_neume_separation) @punctuation.delimiter
(large_space) @punctuation.delimiter
(large_unbreakable_space) @punctuation.delimiter
(half_space_same_neume) @punctuation.delimiter
(small_space_same_neume) @punctuation.delimiter
(zero_space) @punctuation.delimiter
(scaled_large_neume_separation) @punctuation.delimiter

; ============================================================================
; GABC NOTATION - ALTERATIONS
; ============================================================================

(natural) @operator
(flat) @operator
(sharp) @operator
(natural_parenthesized) @operator
(flat_parenthesized) @operator
(sharp_parenthesized) @operator
(natural_soft) @operator
(flat_soft) @operator
(sharp_soft) @operator

; Musica ficta
(musica_ficta_natural) @operator
(musica_ficta_flat) @operator
(musica_ficta_sharp) @operator

; ============================================================================
; GABC NOTATION - EXTRA SYMBOLS
; ============================================================================

; Punctum mora
(punctum_mora) @attribute

; Ictus
(ictus) @attribute
(always_below) @attribute
(always_above) @attribute

; Episema
(episema) @attribute
(below_note) @attribute
(above_note) @attribute
(disable_bridging) @attribute
(small_left) @attribute
(small_center) @attribute
(small_right) @attribute

; Accents above staff
(accent_above_staff) @operator
(accent_grave_above_staff) @operator
(circle_above_staff) @operator
(lower_semicircle_above_staff) @operator
(upper_semicircle_above_staff) @operator

; ============================================================================
; GABC NOTATION - NEUME SHAPES
; ============================================================================

; Basic shapes
(oriscus) @type
(oriscus_scapus) @type
(quilisma) @type
(quilisma_quadratum) @type
(quadratum) @type
(virga) @type
(virga_reversa) @type
(bivirga) @type
(trivirga) @type
(stropha) @type
(distropha) @type
(tristropha) @type
(linea) @type
(cavum) @type
(punctum_linea) @type
(cavum_linea) @type

; Initio debilis
(initio_debilis) @type

; Liquescence
(deminutus) @type
(augmented) @type
(diminished) @type

; Orientation
(upwards) @keyword
(downwards) @keyword

; Leaning
(left_leaning) @keyword
(right_leaning) @keyword
(non_leaning) @keyword

; ============================================================================
; GABC NOTATION - ATTRIBUTES
; ============================================================================

; Shape & stroke
(shape) @keyword
(stroke) @keyword

; Custos control
(nocustos) @keyword

; Choral signs
(cs) @keyword
(cn) @keyword

; Braces
(ob) @keyword
(ub) @keyword
(ocb) @keyword
(ocba) @keyword

; Stem length
(ll) @keyword

; Ledger lines
(oll) @keyword
(ull) @keyword

; Slurs
(oslur) @keyword
(uslur) @keyword

; Horizontal episema
(oh) @keyword
(uh) @keyword
(episema_position) @string

; Above lines text
(alt) @keyword

; Verbatim
(nv) @keyword
(gv) @keyword
(ev) @keyword

; ============================================================================
; SYLLABLE TEXT & STYLING
; ============================================================================

; Special syllable elements
(syllable_other_verbatim) @string.special
(syllable_other_above_lines_text) @string.special
(syllable_other_special_character) @string.escape

; Asterisk markers (* = half-asterisk/division, ** = second asterisk)
; These are parsed as syllable_text but have structural meaning
((syllable_text) @keyword
  (#match? @keyword "^\\*+$"))

; Style tags - captura do nó completo (compatível com todas versões do tree-sitter)
; O nó inclui as tags <b>/<i>/etc. + conteúdo; o realce cobre toda a região
(syllable_style_bold) @emphasis.strong
(syllable_style_italic) @emphasis
(syllable_style_underline) @title
(syllable_style_small_caps) @title
(syllable_style_teletype) @text.literal
(syllable_style_colored) @string.special

; Style tags - cross-syllable (open/close)
; Bold
(syllable
  (syllable_style_bold_open)
  (syllable_text) @emphasis.strong)

(syllable
  (syllable_text) @emphasis.strong
  (syllable_style_bold_close))

; Italic
(syllable
  (syllable_style_italic_open)
  (syllable_text) @emphasis)

(syllable
  (syllable_text) @emphasis
  (syllable_style_italic_close))

; Underline
(syllable
  (syllable_style_underline_open)
  (syllable_text) @title)

(syllable
  (syllable_text) @title
  (syllable_style_underline_close))

; Small Caps
(syllable
  (syllable_style_small_caps_open)
  (syllable_text) @title)

(syllable
  (syllable_text) @title
  (syllable_style_small_caps_close))

; Teletype
(syllable
  (syllable_style_teletype_open)
  (syllable_text) @text.literal)

(syllable
  (syllable_text) @text.literal
  (syllable_style_teletype_close))

; Colored
(syllable
  (syllable_style_colored_open)
  (syllable_text) @string.special)

(syllable
  (syllable_text) @string.special
  (syllable_style_colored_close))

; ============================================================================
; NABC - BASIC GLYPHS
; ============================================================================

; Single note glyphs
(punctum) @constant
(tractulus) @constant
(gravis) @constant

; Compound glyphs
(clivis) @constant
(pes) @constant
(porrectus) @constant
(torculus) @constant
(climacus) @constant
(scandicus) @constant
(porrectus_flexus) @constant
(scandicus_flexus) @constant
(torculus_resupinus) @constant
(trigonus) @constant
(pressus_maior) @constant
(pressus_minor) @constant
(virga_strata) @constant
(salicus) @constant
(pes_quassus) @constant
(pes_stratus) @constant
(nihil) @constant
(uncinus) @constant
(oriscus_clivis) @constant
(quilisma_3_loops) @constant
(quilisma_2_loops) @constant

; ============================================================================
; NABC - MODIFIERS
; ============================================================================

(mark_modification) @keyword
(grouping_modification) @keyword
(melodic_modification) @keyword
(augmentive_liquescence) @type
(diminutive_liquescence) @type
(variant_number) @number

; ============================================================================
; NABC - SUBPUNCTIS/PREPUNCTIS
; ============================================================================

(subpunctis) @keyword
(prepunctis) @keyword
(tractulus_episema) @constant
(tractulus_double_episema) @constant
(gravis_episema) @constant
(liquescens_stropha_cephalicus) @constant
(repetition_count) @number

; ============================================================================
; NABC - STRUCTURE
; ============================================================================

(nabc_glyph_descriptor) @type
(nabc_glyph_fusion) @type
(pitch_descriptor) @constant

; NABC spacing
(larger_space_right) @punctuation.delimiter
(inter_element_space_right) @punctuation.delimiter
(larger_space_left) @punctuation.delimiter
(inter_element_space_left) @punctuation.delimiter

; ============================================================================
; NABC - SIGNIFICANT LETTERS
; ============================================================================

(augete) @keyword
(altius) @keyword
(altius_mediocriter) @keyword
(bene) @keyword
(celeriter) @keyword
(celeriter_mediocriter) @keyword
(coniunguntur) @keyword
(celeriter_wide) @keyword
(deprimatur) @keyword
(equaliter) @keyword
(equaliter_eq) @keyword
(equaliter_dash) @keyword
(equaliter_equ) @keyword
(equaliter_wide) @keyword
(fastigium) @keyword
(fideliter) @keyword
(frendor) @keyword
(gutture) @keyword
(humiliter) @keyword
(humiliter_nectum) @keyword
(humiliter_parum) @keyword
(iusum) @keyword
(iusum_mediocriter) @keyword
(iusum_valde) @keyword
(klenche) @keyword
(levare) @keyword
(levare_bene) @keyword
(levare_celeriter) @keyword
(leniter) @keyword
(levare_mediocriter) @keyword
(levare_parvum) @keyword
(levare_tenere) @keyword
(mediocriter) @keyword
(mediocriter_md) @keyword
(molliter) @keyword
(non_tenere_negare_nectum_naturaliter) @keyword
(non_levare) @keyword
(non_tenere) @keyword
(parvum) @keyword
(paratim) @keyword
(perfecte) @keyword
(parvum_mediocriter) @keyword
(pulcre) @keyword
(sursum) @keyword
(sursum_bene) @keyword
(sursum_celeriter) @keyword
(similiter) @keyword
(simpliciter) @keyword
(simpliciter_simpl) @keyword
(simul) @keyword
(sursum_mediocriter) @keyword
(sursum_parum) @keyword
(sursum_tenere) @keyword
(statim) @keyword
(tenere) @keyword
(tenere_bene) @keyword
(tenere_humiliter) @keyword
(tenere_mediocriter) @keyword
(tenere_wide) @keyword
(valde) @keyword
(volubiliter) @keyword
(expectare) @keyword

; Tironian letters (Laon notation)
(deorsum) @keyword
(devertit) @keyword
(devexum) @keyword
(prode_sub_eam) @keyword
(quam_mox) @keyword
(sub) @keyword
(seorsum) @keyword
(subjice) @keyword
(saltim) @keyword
(sonare) @keyword
(supra) @keyword
(saltate) @keyword
(ut_supra) @keyword

; Structural wrappers for significant/tironian letters
(significant_letter) @keyword
(tironian_letter) @keyword
(position_number) @number

; ============================================================================
; COMMENTS
; ============================================================================

(comment) @comment
