;==============================================================
; Display the Logo
;==============================================================

	; set initial vscroll Plane A
	SetVSRAMWrite $0000
	move.w 	(DATA_EASING_LOGO).l,vdp_data

	WaitVBlank
    ; Fill Tilemap with BLANK tile
    move.l 	#vram_addr_plane_a,d2
	jsr 	SendVRAMWriteAddress
    move.l  #(64*32)-1,d3                   ; blank entire plane
    jsr     fillBlanks

	WaitVBlank
	; Load Palette
	;lea     Palette_Logo,a0
	;move.l 	#0,d2                                           ; set slot 0
	;jsr 	loadPaletteAdressToCram	
	lea     Palette_Logo,a0
	lea 	(RAM_SCENE_PALETTE).l,a1
	lea 	(RAM_SCENE_PALETTE_UPD).l,a2
	move.l  #((size_palette_w*4)-1),d0
	@PalLogo_Loop:
	move.w  (a0)+,(a1)+
	move.w  #0000,(a2)+
	dbra    d0,@PalLogo_Loop

	WaitVBlank
	; Load Tiledata
	SetVRAMWrite 	vram_addr_tiles
	lea     Tiledata_Logo,a0				
	move.l  #((endTiledata_Logo-Tiledata_Logo)/size_long)-1,d0  	; Data length / $20(32 Bytes) => 618 Tiles
.LoadLogoTiledataLoop:							    	
	move.l  (a0)+,vdp_data					
	dbra    d0,.LoadLogoTiledataLoop						

	WaitVBlank
	; Load Tilemap
   	move.l 	#7,d4                           ; start y = 8th row
	clr.l 	d5
	lea     Tilemap_Logo,a0	                 
	move.l  #(11)-1,d1                      ; Map height
	move.l 	#vram_addr_plane_a+(((8*64)+10)*size_word),d2     ; start x/y on canvas
	jsr 	SendVRAMWriteAddress

@Map_Logo_Loop_cols:
	move.l  #(20)-1,d0                      ; Map width
@Map_Logo_Loop_rows:
    move.w  (a0)+,vdp_data
	dbra    d0,@Map_Logo_Loop_rows		   

	addi.b 	#1,d4                           ; increment row counter
	move.l  d4,d5
	mulu.w  #64,d5
    addi.w  #10,d5 
    mulu.w  #size_word,d5
	move.l 	#vram_addr_plane_a,d2
	add.w 	d5,d2
	jsr 	SendVRAMWriteAddress
	dbra    d1,@Map_Logo_Loop_cols		    


	WaitVBlank
    ; Add Music to the Logo:
	move.b 	#$82,d0 
	jsr 	PlaySound

	WaitVBlank
    ; Move the Logo with Easing data:
	lea 	DATA_EASING_LOGO,a0
	move.w 	#(DATA_EASING_LOGO_END-DATA_EASING_LOGO-2),d1 	; -2 because of word size
	move.l 	#0,d0
	move.b 	#$F,(RAM_FADE_COUNTER).l
LogoAnimation:
	SetVSRAMWrite $0000
	WaitVBlank
	jsr 	FadeInLogo
	tst.b 	(RAM_FADE_COUNTER).l							; forbid pressing start while fading
	bne.s 	disableStartButton
	clr.l 	d7 
	move.l 	(ram_joypad).l,d7
	btst    #pad_button_start,d7 
    bne.w   SkipLogo
disableStartButton:	
	move.w 	(a0,d0),d2
	move.w 	d2,vdp_data										; update position by array[d1]
	addi.w 	#size_word,d0
	addi.l 	#1,(RAM_FRAME_LOGO).l
	dbra 	d1,LogoAnimation
LogoStill:
	WaitVBlank
	clr.l 	d7 
	move.l 	(ram_joypad).l,d7
	btst    #pad_button_start,d7 
    bne.w   SkipLogo
	addi.l 	#1,(RAM_FRAME_LOGO).l
	cmp.l 	#TIME_LOGO,(RAM_FRAME_LOGO).l
	bls.s 	LogoStill

SkipLogo:
	move.b	#$E4,d0				; stopMusic
	bsr.w	PlaySound

    ; Animate out!
	clr.l 	d3
	clr.l 	d5
	move.l 	#(20*11*size_word),d7
    move.l 	#11,d6                          ; no of frames

NextLogoAnimFrame:
    WaitVBlank
   	move.l 	#7,d4                           ; start y = 8th row
	lea     Tilemap_Logo,a0
    addi.w  #1,d3                           ; increment frame counter
    move.l  d3,d7                           ; move counting value in d7
    mulu.w  #(20*11*size_word),d7           ; multiply (mapW x mapH * words) * frame
    add.l   d7,a0                           ; add offset to map location in ROM
	move.l  #(11)-1,d1                      ; Map height
	move.l 	#(vram_addr_plane_a+(((8*64)+10)*size_word)),d2     ; start x/y on canvas
	jsr 	SendVRAMWriteAddress

@Map_LogoAnim_Loop_cols:
	move.l  #(20)-1,d0                      ; Map width
@Map_LogoAnim_Loop_rows:
    move.w  (a0)+,vdp_data
	dbra    d0,@Map_LogoAnim_Loop_rows		   

	addi.b 	#1,d4                           ; increment row counter
	move.l  d4,d5
	mulu.w  #64,d5
    addi.w  #10,d5 
    mulu.w  #size_word,d5
	move.l 	#vram_addr_plane_a,d2
	add.w 	d5,d2
	jsr 	SendVRAMWriteAddress
	dbra    d1,@Map_LogoAnim_Loop_cols		    

	dbra    d6,NextLogoAnimFrame		    

	WaitVBlank
	; Blank last Frame:
    move.l 	#vram_addr_plane_a,d2
	jsr 	SendVRAMWriteAddress
    move.l  #(64*32)-1,d3                   ; blank entire plane
    jsr     fillBlanks

	lea	    (Palette_Logo),a0
	jsr 	loadPaletteAdressToRamForFadeOut
	move.b  #$F,(RAM_FADE_COUNTER).l
LogoEnd:
	WaitVBlank
	jsr 	FadeOut
	tst.b 	(RAM_FADE_COUNTER).l
	bne.s 	LogoEnd
