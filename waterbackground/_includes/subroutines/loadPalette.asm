loadPaletteAdressToCram:
    ;a0: address of palette in ROM
    ;d1: counter
    ;d2: palette no. (0-3)
    
    mulu.w  #$20,d2
	jsr SendCRAMWriteAddress
	
	move.l  #size_palette_w-1,d1	        ; Loop counter = 8 words in palette (-1 for DBRA loop)
	@Pal_Lp:					            ; Start of loop
	move.w  (a0)+,vdp_data			        ; Write palette entry, post-increment address
	dbra    d1,@Pal_Lp				        ; Decrement d0 and loop until finished (when d0 reaches -1)
    rts


loadPaletteAdressToRam:
    ;a0: address of palette in ROM
    ;d1: counter
    movem.l d0-a6,-(sp)

    lea     (RAM_OBJECT_PALETTE).l,a1
	move.l  #size_palette_w-1,d1	        ; Loop counter = 8 words in palette (-1 for DBRA loop)
	@PalR_Lp:					            ; Start of loop
	move.w  (a0)+,(a1)+			            ; Write palette entry, post-increment address
	dbra    d1,@PalR_Lp				        ; Decrement d0 and loop until finished (when d0 reaches -1)

    movem.l (sp)+,d0-a6
    rts


loadPaletteAdressToRamForFlashIn:
    ;a0: address of palette in ROM
    ;d1: counter
    movem.l d0-a6,-(sp)

    lea     (RAM_OBJECT_PALETTE).l,a1
    lea     (RAM_OBJECT_PALETTE_UPD).l,a2
    lea     (PaletteAllWhite).l,a3
	move.l  #size_palette_w-1,d1	        ; Loop counter = 8 words in palette (-1 for DBRA loop)
	@PalRF_Lp:					            ; Start of loop
	move.w  (a0)+,(a1)+			            ; Write palette entry, post-increment address
	move.w  (a3)+,(a2)+			            ; Write palette entry, post-increment address
	dbra    d1,@PalRF_Lp				    ; Decrement d0 and loop until finished (when d0 reaches -1)

    movem.l (sp)+,d0-a6
    rts

loadPaletteAdressToRamForFadeOut:
    ;a0: address of palette in ROM
    ;d1: counter
    movem.l d0-a6,-(sp)

    lea     (RAM_OBJECT_PALETTE).l,a1
    lea     (RAM_OBJECT_PALETTE_UPD).l,a2
    lea     (PaletteAllBlack).l,a3
    clr.l   d1
	move.l  #size_palette_w-1,d1	        ; Loop counter = 8 words in palette (-1 for DBRA loop)
	@PalLPFFO_Lp:					        ; Start of loop
	move.w  (a3)+,(a1)+			            ; Write palette entry, post-increment address
	move.w  (a0)+,(a2)+			            ; Write palette entry, post-increment address
	dbra    d1,@PalLPFFO_Lp				    ; Decrement d0 and loop until finished (when d0 reaches -1)

    movem.l (sp)+,d0-a6
    rts

