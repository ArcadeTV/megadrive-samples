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

	enable_ints

	WaitVBlank
	; LOAD PALETTES
	lea 	(PALETTES),a0  										; Move the address of the first palette entry into a0
	SetCRAMWrite $0000
	move.l  #((size_palette_w*2)-1),d0							; load 2 palettes, that's 2 x 16 words
	@Pal_Loop:
	move.w  (a0)+,vdp_data
	move.w  #0000,(a3)+
	dbra    d0,@Pal_Loop


	; LOAD TILE DATA
	clr.l 	d0
	clr.l 	d1													

	lea 	(Tiledata),a0										; upload all tiledata to VRAM in one loop
	SetVRAMWrite vram_addr_tiles								; tell the VDP to write to address $0000
	move.w  #((TiledataEnd-Tiledata)/size_long)-1,d0 			; set Loop counter
	Tiles_Lp:							    					; Start of loop
	move.l  (a0)+,vdp_data										; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,Tiles_Lp					    					; Decrement d0 and loop until finished (when d0 reaches -1)
	
	; LOAD PLANE B MAP
	lea 	(Tilemap_Plane_B),a0								; load address of tilemap in ROM into a0
    SetVRAMWrite vram_addr_plane_b								; tell the VDP to write to address of Plane B
	move.l  #(64*64)-1,d0                   					; Loop counter (-1 for DBRA loop)
	MapB_Loop:				                					; Start of loop
	move.w  (a0)+,vdp_data			        					; Write a word (2 Bytes = 1 tilemap entry) to the VDP data port 
	dbra    d0,MapB_Loop				    					; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PLANE A MAP
	lea 	(Tilemap_Plane_A),a0
    SetVRAMWrite vram_addr_plane_a
	move.l  #(64*32)-1,d0                   					; Loop counter (-1 for DBRA loop)
	MapA_Loop:				                					; Start of loop
	move.w  (a0)+,d1				        					; Write tile line (4 bytes per line), and post-increment address
	addi.w 	#995,d1												; IDs in tilemap start at at 0, so we need to add the no. of tiles already used
	or.w 	#$2000,d1 											; Palette specified in tilemap is #0, but needs to be #1
																; OR the word (0000:0, 2000:1, 4000:2, 6000:3)
	move.w 	d1,vdp_data											; Write a word (2 Bytes = 1 tilemap entry) to the VDP data port
	dbra    d0,MapA_Loop				    					; Decrement d0 and loop until finished (when d0 reaches -1)

;==============================================================
; Enter Main Loop
;==============================================================

	move.w 	#(1800/4),(RAM_PLANE_B_SCROLL_X).l 					; set initial value
	move.w 	#0,(RAM_PLANE_B_SCROLL_Y).l 						; set initial value

InfLoop:
	WaitVBlank													; wait for vblank
	lea 	sine,a0												; load the address of the data location into a0
	move.w 	(RAM_PLANE_B_SCROLL_X).l,d5 						; get stored data-index from RAM
	move.w 	(RAM_PLANE_B_SCROLL_Y).l,d6 						; get stored data-index from RAM

	move.w 	d5,d3												; since we need to calculate with the index value
	move.w 	d6,d4												; store them in other registers, so the original stays untouched

	mulu.w 	#size_word,d3										; multiply by word size (2)
	mulu.w 	#size_word,d4

	move.w 	(a0,d3),d0											; get the data entry for HSCROLL (same but different offset)
	move.w 	(a0,d4),d1											; get the data entry for VSCROLL 

	SetVRAMWrite	vram_addr_hscroll+size_word					; tell the VDP to write to HSCROLL TABLE of PLANE B at $0002
	move.w 	d0,vdp_data											; write the word to the VDP data port

	SetVSRAMWrite 	$0000+size_word								; tell the VDP to write to VSCROLL TABLE of PLANE B at $0002
	move.w 	d1,vdp_data											; write the word to the VDP data port

	cmpi.w 	#1800,d5											; Have we reached the last index?
	bne.s 	DontResetXindex										; if not, go increment the index
	move.w 	#0,d5												; otherwise reset to #0
	bra.s 	XindexWasResetted									; and skip incrementation
DontResetXindex:
	add.w 	#1,d5 												; increment by 1
XindexWasResetted:

	cmpi.w 	#1800,d6 											; Have we reached the last index?
	bne.s 	DontResetYindex										; if not, go increment the index
	move.w 	#0,d6												; otherwise reset to #0
	bra.s 	YindexWasResetted									; and skip incrementation
DontResetYindex:												
	add.w 	#1,d6 												; increment by 1
YindexWasResetted:

	move.w 	d5,(RAM_PLANE_B_SCROLL_X).l 						; store incremented data-index back in RAM
	move.w 	d6,(RAM_PLANE_B_SCROLL_Y).l 						; store incremented data-index back in RAM
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

;==============================================================
; INCLUDE BINARIES
;==============================================================
    even 2
	; order of included palettes is important at boot!
	; 4 palettes are loaded to RAM for FadeIn

Palettes:
	incbin	"BIN/PALETTES/bg.bin"
	incbin	"BIN/PALETTES/logo.bin"
PalettesEnd:

Tiledata:
TiledataPlaneB:
	incbin 	"BIN/TILEDATA/bg_995.bin"
TiledataPlaneBEnd:
TiledataPlaneA:
	incbin 	"BIN/TILEDATA/logo_87.bin"
TiledataPlaneAEnd:
TiledataEnd:

Tilemap_Plane_B:
	incbin 	"BIN/TILEMAPS/bg_64x64.bin"
Tilemap_Plane_B_End:
Tilemap_Plane_A:
	incbin 	"BIN/TILEMAPS/logo_64x32.bin"
Tilemap_Plane_A_End:
	even 2

	include	"_includes/data/sine.asm"
; The end of ROM
ROM_End: