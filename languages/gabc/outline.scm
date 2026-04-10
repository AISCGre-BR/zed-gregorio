; ============================================================================
; OUTLINE QUERIES FOR GABC
; ============================================================================
; Show headers in the document outline / symbols panel

; TeX annotation headers
; name field contains anonymous node "annotation" → use _ (not (_))
(header_tex_annotation
  name: _ @name) @item

; TeX mode-modifier headers
; name field contains anonymous node "mode-modifier" → use _
(header_tex_mode_modifier
  name: _ @name) @item

; TeX mode-differentia headers
; name field contains anonymous node "mode-differentia" → use _
(header_tex_mode_differentia
  name: _ @name) @item

; TeX def-macro headers
; header_tex_def_macro has NO name field → capture value instead
(header_tex_def_macro
  value: _ @name) @item

; Numeric headers (mode, staff-lines, nabc-lines)
; all have anonymous name fields → use _
(header_numeric_mode
  name: _ @name) @item

(header_numeric_staff_lines
  name: _ @name) @item

(header_numeric_nabc_lines
  name: _ @name) @item

; Generic headers (name, gabc-copyright, office-part, etc.)
; header_name is a proper named node → (_) is valid here
(header_generic
  name: (header_name) @name) @item
