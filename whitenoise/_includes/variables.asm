;==============================================================
; RAM Locations
;==============================================================

RAM_RANDOM_DATA_INDEX       equ $00FF0000 ; w
RAM_PALETTE_CYCLE           equ $00FF0002 ; b

RAM_VINT_FLAG               equ $00FF0004 ; b
RAM_TICTOC                  equ $00FF0006 ; b

RAM_PLANE_B_SCROLL_X        equ $00FF0008 ; w
RAM_PLANE_B_SCROLL_Y        equ $00FF000A ; w

RAM_CURRENT_FRAME           equ $00FF000C ; l Frame Counter
