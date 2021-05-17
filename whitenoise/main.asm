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

	; Generate PLANE B MAP
	lea 	(RandomNumbers),a0
    SetVRAMWrite vram_addr_plane_b
	move.l  #(64*32)-1,d0                   					; Loop counter (-1 for DBRA loop)
	MapB_Loop:				                					; Start of loop
	move.b  (a0)+,d1				        					; Write tile line (4 bytes per line), and post-increment address
	or.w 	#$2000,d1 											; Palette specified in tilemap is #0, but needs to be #1
	move.w 	d1,vdp_data											; Write a word (2 Bytes = 1 tilemap entry) to the VDP data port
																; OR the word (0000:0, 2000:1, 4000:2, 6000:3)
	dbra    d0,MapB_Loop				    					; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PLANE A MAP
	lea 	(Tilemap_Plane_A),a0
    SetVRAMWrite vram_addr_plane_a
	move.l  #(64*32)-1,d0                   					; Loop counter (-1 for DBRA loop)
	MapA_Loop:				                					; Start of loop
	move.w  (a0)+,d1				        					; Write tile line (4 bytes per line), and post-increment address
	addi.w 	#25,d1												; IDs in tilemap start at at 0, so we need to add the no. of tiles already used
	move.w 	d1,vdp_data											; Write a word (2 Bytes = 1 tilemap entry) to the VDP data port
	dbra    d0,MapA_Loop				    					; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PALETTES
	lea 	(PALETTES),a0  										; Move the address of the first palette entry into a0
	SetCRAMWrite $0000
	move.l  #((size_palette_w*2)-1),d0							; load 2 palettes, that's 2 x 16 words
	@Pal_Loop:
	move.w  (a0)+,vdp_data
	dbra    d0,@Pal_Loop

;==============================================================
; Enter Main Loop
;==============================================================

	enable_ints

InfLoop:
	clr.l   d1 													
	clr.l   d2 
	move.b 	(RAM_PALETTE_CYCLE).l,d1 							; get stored value (1-3), which palette to use
	cmpi.b  #3,d1 												; if index is not #3, don't reset value to #0
	bne.s   DontResetPaletteCycleIndex
	clr.l   d1 													; reset index
DontResetPaletteCycleIndex:
	addi.b  #1,d1												; increment index
	move.w  #32,d2												; size in Bytes of 1 palette into d2
	mulu.w  d1,d2 												; calculate address offset by index * paletteSize
	lea 	(PALETTES),a0										; Move the address of the first palette entry into a0
	add.w   d2,a0												; add calculated offset
	SetCRAMWrite $20											; write to palette slot #1 (0 *1* 2 3)
	move.l  #(size_palette_w-1),d0								; palette word size -1 for dbra loop
	WaitVBlank													; wait for vblank before writing to cram
PalCycle_Loop:
	move.w  (a0)+,vdp_data 										; write palette data to vdp data port
	dbra    d0,PalCycle_Loop 									; decrement d0 and loop till d0 reaches -1
	move.b 	d1,(RAM_PALETTE_CYCLE).l							; store current index back in RAM

	tst.b 	(RAM_TICTOC).l										; every other frame, only do the palette thing
	beq.w 	skipDisplacement									; skip changing Plane B's X/Y position

	move.w 	(RAM_PLANE_B_SCROLL_X).l,d1 						; get stored value from RAM
	move.w 	(RAM_PLANE_B_SCROLL_Y).l,d2 						; get stored value from RAM
		
	SetVSRAMWrite 	$0000+size_word								; tell the VDP to write to VSCROLL TABLE of PLANE B at $0002
	add.w 	#111,d1												; use an odd number that's not a multiple of tile size
	move.w 	d1,vdp_data											; write the word to the VDP data port
	
	SetVRAMWrite 	vram_addr_hscroll+size_word					; tell the VDP to write to HSCROLL TABLE of PLANE B at $0002
	add.w 	#68,d2												; use another odd number that's not a multiple of tile size
	move.w 	d2,vdp_data											; write the word to the VDP data port

	move.w 	d1,(RAM_PLANE_B_SCROLL_X).l 						; store incremented value back in RAM
	move.w 	d2,(RAM_PLANE_B_SCROLL_Y).l 						; store incremented value back in RAM
skipDisplacement:	
	bra.w 	InfLoop												; jump to label, loop forever

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
	incbin	"BIN/PALETTES/logo.bin"
	incbin	"BIN/PALETTES/noise.bin"
PalettesEnd:

Tiledata:
TiledataPlaneB:
	incbin 	"BIN/TILEDATA/noise_25.bin"
TiledataPlaneBEnd:
TiledataPlaneA:
	incbin 	"BIN/TILEDATA/logo_87.bin"
TiledataPlaneAEnd:
TiledataEnd:

Tilemap_Plane_A:
	incbin 	"BIN/TILEMAPS/logo_64x32.bin"
Tilemap_Plane_A_End:
	even 2

RandomNumbers:
	incbin 	"_includes/data/2048_random_bytes_0-18.bin"

; The end of ROM
ROM_End: