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
	lea 	(Tiledata),a0
	SetVRAMWrite vram_addr_tiles
	move.w  #((TiledataEnd-Tiledata)/size_word)-1,d0 	; set Loop counter
	Tiles_Lp:							    			; Start of loop
	move.l  (a0)+,vdp_data								; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,Tiles_Lp					    			; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PLANE B MAP
	lea 	(Tilemap_Plane_B),a0
    SetVRAMWrite vram_addr_plane_b
	move.l  #(64*32)-1,d0                   			; Loop counter (-1 for DBRA loop)
	MapB_Loop:				                			; Start of loop
	move.w  (a0)+,vdp_data			        			; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,MapB_Loop				    			; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PLANE A MAP
    SetVRAMWrite vram_addr_plane_a
	move.l  #(64*32)-1,d0                   			; Loop counter (-1 for DBRA loop)
	MapA_Loop:				                			; Start of loop
	move.w  $2000,vdp_data			        			; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,MapA_Loop				    			; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PALETTES
	lea 	(PALETTES),a0  								; Move the address of the first palette entry into a0
	SetCRAMWrite $0000
	move.l  #(size_palette_w-1),d0
	@Pal_Loop:
	move.w  (a0)+,vdp_data
	move.w  #0000,(a3)+
	dbra    d0,@Pal_Loop

;==============================================================
; Enter Main Loop
;==============================================================

	enable_ints

	SetVRAMWrite vram_addr_hscroll
	move.l 	#$100-1,d0 
	lea 	HSCROLL_DATA,a0 
HScrollDataLoop:
	move.w 	(a0)+,vdp_data
	move.w 	(a0)+,vdp_data
	dbra 	d0,HScrollDataLoop

InfLoop:
	WaitVBlank
	move.w 	(RAM_PLANE_B_SCROLL_Y).l,d0 
	addi.w 	#1,d0 
	SetVSRAMWrite 	$0000+size_word
	move.w 	d0,vdp_data
	move.w 	d0,(RAM_PLANE_B_SCROLL_Y).l 
	bra.s 	InfLoop

;==============================================================
; INCLUDE CODE
;==============================================================

	include	"_includes/vdp_registers.asm"
	include "_includes/hint.asm"
	include "_includes/vint.asm"
	include "_includes/joypad.asm"
	include "_includes/psg.asm"

	; Subroutines:
	include "_includes/subroutines/VDP_WriteTMSS.asm"
	include "_includes/subroutines/clearRam.asm"
	include "_includes/subroutines/clearVram.asm"
	include "_includes/subroutines/clearCram.asm"
	include "_includes/subroutines/VDP_LoadRegisters.asm"
	include "_includes/subroutines/set_vram_write.asm"
	include "_includes/subroutines/scroll_planes.asm"

;==============================================================
; INCLUDE BINARIES
;==============================================================
    even 2
	; order of included palettes is important at boot!
	; 4 palettes are loaded to RAM for FadeIn

Palettes:
	incbin	"BIN/PALETTES/water.bin"
PalettesEnd:

Tiledata:
	incbin 	"BIN/TILEDATA/water_256.bin"
TiledataEnd:

Tilemap_Plane_B:
	incbin 	"BIN/TILEMAPS/water_64x32.bin"
Tilemap_Plane_B_End:
	even 2



	even 2
HSCROLL_DATA:
	incbin 	"_includes/data/sinus-hscroll.bin"
HSCROLL_DATA_END:

; The end of ROM
ROM_End: