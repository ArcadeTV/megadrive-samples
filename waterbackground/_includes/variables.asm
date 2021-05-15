;==============================================================
; RAM Locations
;==============================================================

RAM_PLANE_A_SCROLL_X        equ $00FF0000 ; w
RAM_PLANE_A_SCROLL_Y        equ $00FF0002 ; w
RAM_PLANE_B_SCROLL_X        equ $00FF0004 ; w
RAM_PLANE_B_SCROLL_Y        equ $00FF0006 ; w

ram_scroll_counter          equ $00FF0008 ; b

ram_plane_a_scroll_x_slow   equ $00FF000A ; w 
ram_lock_inputs             equ $00FF000C ; b

ram_intro_active            equ $00FF0010 ; l
intro_active                equ $B0BB1B0B ; l unique string

ram_intro_ends              equ $00FF0014 ; b

spritectrl                  equ $00FF0020 ; w
ram_joypad                  equ $00FF0030 ; l

RAM_VINT_FLAG               equ $00FF0040 ; b
RAM_TICTOC                  equ $00FF0042 ; b
RAM_WAVETILE                equ $00FF0044 ; w Index in tilemap
RAM_FRAME_DELAY             equ $00FF0046 ; b count to 3 on Vint

RAM_FADE_COUNTER            equ $00FF0048 ; b
RAM_ISFADING                equ $00FF004A ; b
RAM_ISENDING                equ $00FF004C ; b
RAM_BLOCKOUT_CURRENT        equ $00FF004E ; w

RAM_SCENE_PALETTE           equ $00FF0050 ;   storing for fade in/out
RAM_SCENE_PALETTE_UPD       equ $00FF00D0 ;   storing for fade in/out
RAM_SCENE_PALETTE_CHK       equ $00FF0150 ;   storing for fade in/out entry-check

RAM_CURRENT_FRAME           equ $00FF01D0 ; l Frame Counter
RAM_FRAME_LOGO              equ $00FF01D4 ; l Frame Counter

RAM_SELECTED_ITEM           equ $00FF01E0 ; b Selected Item

RAM_GAME_MODE               equ $00FF01E2 ; b Game Mode

RAM_PALETTE_FLASHING        equ $00FF01F0 ; b
RAM_PALETTE_FADEOUT         equ $00FF01F2 ; b
RAM_OBJECT_PALETTE          equ $00FF0200 ;   storing for flash in/out
RAM_OBJECT_PALETTE_UPD      equ $00FF0220 ;   storing for flash in/out
RAM_OBJECT_PALETTE_CHK      equ $00FF0240 ;   storing for flash in/out entry-check

RAM_GRADIENT_SCROLL_SPEED   equ $00FF0260 ; w
RAM_GRADIENT_BLANK          equ $00FF0262 ; w index of column to be blanked
RAM_GRADIENT_FINISHED       equ $00FF0264 ; w
RAM_GRADIENT_FRAME          equ $00FF0266 ; w

RAM_IS_MOVING               equ $00FF0268 ; b

RAM_VDP_BUFFER:	            equ $FFFFF270 ; VDP instruction buffer (2 bytes)
;==============================================================
; Variables
;==============================================================

tiles_pos_x				    equ $00
tiles_pos_y				    equ $00

plane_a_scroll_speed_x	    equ $01
plane_a_scroll_speed_y	    equ $00
plane_b_scroll_speed_x	    equ $00
plane_b_scroll_speed_y	    equ $00

gradient_scroll_speed       equ 1

FADE_FRAME_DELAY            equ 4	        ; how many frames to wait between fade in/out
INTRO_END_FRAME             equ (60*11)     ; Auto-end intro after this many frames (60fps x XX = XX seconds)

GAME_MODE_LOGO              equ 1
GAME_MODE_MENU              equ 2

TIME_LOGO                   equ (60*6)
LOGO_BLANK_TILE_ID          equ 4