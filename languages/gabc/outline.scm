; ============================================================================
; OUTLINE QUERIES FOR GABC
; ============================================================================
; Show headers in the document outline / symbols panel

; TeX annotation headers
(header_tex_annotation
  name: (_) @name) @item

; TeX mode-modifier headers
(header_tex_mode_modifier
  name: (_) @name) @item

; TeX mode-differentia headers
(header_tex_mode_differentia
  name: (_) @name) @item

; TeX def-macro headers
(header_tex_def_macro
  name: (_) @name) @item

; Numeric headers (mode, staff-lines, nabc-lines)
(header_numeric_mode
  name: (_) @name) @item

(header_numeric_staff_lines
  name: (_) @name) @item

(header_numeric_nabc_lines
  name: (_) @name) @item

; Generic headers (name, gabc-copyright, office-part, etc.)
(header_generic
  name: (header_name) @name) @item
