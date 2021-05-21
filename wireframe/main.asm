; Start of ROM
ROM_Start:


;==============================================================
; INCLUDES
;==============================================================

	include "_includes/constants.asm"
	include "_includes/variables.asm"
	include "_includes/macros.asm"


;==============================================================
; ROM HEADER
;==============================================================

	include "_includes/header.asm"


;==============================================================
; ENTRY POINT
;==============================================================
CPU_EntryPoint:
	jsr     VDP_WriteTMSS                   ; Write the TMSS signature (if a model 1+ Mega Drive)
	jsr     VDP_LoadRegisters               ; Load the initial VDP registers
	jsr 	clearVram


;==============================================================
; LOAD ASSETS
;==============================================================

	; LOAD TILE DATA
	clr.l 	d0
	clr.l 	d1													

	lea 	(Tiledata),a0										; upload all tiledata to VRAM in one loop
	SetVRAMWrite vram_addr_tiles								; tell the VDP to write to address $0000
	move.w  #((TiledataEnd-Tiledata)/size_long)-1,d0 			; set Loop counter
	Tiles_Lp:							    					; Start of loop
	move.l  (a0)+,vdp_data										; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,Tiles_Lp					    					; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PLANE A MAP
	lea 	(Tilemap_Plane_A),a0
    SetVRAMWrite vram_addr_plane_a
	move.l  #(64*32)-1,d0                   					; Loop counter (-1 for DBRA loop)
	MapA_Loop:				                					; Start of loop
	move.w  (a0)+,d1				        					; Write tile line (4 bytes per line), and post-increment address
	addi.w 	#785,d1												; IDs in tilemap start at at 0, so we need to add the no. of tiles already used
	or.w 	#$2000,d1 											; Palette specified in tilemap is #0, but needs to be #1
																; OR the word (0000:0, 2000:1, 4000:2, 6000:3)
	move.w 	d1,vdp_data											; Write a word (2 Bytes = 1 tilemap entry) to the VDP data port
	dbra    d0,MapA_Loop				    					; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PALETTES
	lea 	(PALETTES),a0  										; Move the address of the first palette entry into a0
	SetCRAMWrite $0000
	move.l  #((size_palette_w*2)-1),d0							; load 2 palettes, that's 2 x 16 words
	@Pal_Loop:
	move.w  (a0)+,vdp_data
	move.w  #0000,(a3)+
	dbra    d0,@Pal_Loop

;==============================================================
; Enter Main Loop
;==============================================================

	enable_ints
	
InfLoop:
	WaitVBlank													; wait for vblank
	jsr 	drawWireframe
	bra.s 	InfLoop												; jump to label, loop forever

;==============================================================
; INCLUDE CODE
;==============================================================

	include	"_includes/vdp_registers.asm"
	include "_includes/hint.asm"
	include "_includes/vint.asm"

	; Subroutines:
	include "_includes/subroutines/VDP_WriteTMSS.asm"
	include "_includes/subroutines/clearRam.asm"
	include "_includes/subroutines/clearVram.asm"
	include "_includes/subroutines/clearCram.asm"
	include "_includes/subroutines/VDP_LoadRegisters.asm"
	include "_includes/subroutines/set_vram_write.asm"
	include "_includes/subroutines/drawWireframe.asm"

;==============================================================
; INCLUDE BINARIES
;==============================================================
    even 2
	; order of included palettes is important at boot!
	; 4 palettes are loaded to RAM for FadeIn

Palettes:
	incbin	"BIN/PALETTES/wireframe.bin"
	incbin	"BIN/PALETTES/logo.bin"
PalettesEnd:

Tiledata:
TiledataPlaneB:
	incbin 	"BIN/TILEDATA/wireframe_785.bin"
TiledataPlaneBEnd:
TiledataPlaneA:
	incbin 	"BIN/TILEDATA/logo_87.bin"
TiledataPlaneAEnd:
TiledataEnd:

Tilemap_Plane_B:
	include "BIN/TILEMAPS/wireframe_arranged.asm"
Tilemap_Plane_B_End:
Tilemap_Plane_A:
	incbin 	"BIN/TILEMAPS/logo_64x32.bin"
Tilemap_Plane_A_End:
	even 2

; The end of ROM
ROM_End:
