gradientFade:
    movem.l	d0-a6,-(sp)

    WaitVBlank
    move.w  #$2700,sr                               ; Interrupts off

    ; set gradient to initial position:
   	move.w  #($FFFF-192),(ram_plane_a_scroll_x).l	
    SetVRAMWrite vram_addr_hscroll
	move.w #($FFFF-192),vdp_data
    
    ; replace Plane A map (logos) with gradient map:
    SetVRAMWrite vram_addr_plane_a
	lea     (Tilemap_Gradient),a0                 	; Move the address of the first map entry into a0
	move.l  #(64*32)-1,d0                   		; Loop counter (-1 for DBRA loop)
gradientFade_writeTileMap_Loop:				        ; Start of loop
	move.w  (a0)+,d1			            		; Write tile line (4 bytes per line), and post-increment address
    or.w    #$6000,d1                       		; Set Palette Index to 3 (0000:0, 2000:1, 4000:2, 6000:3)
    addi.w  #(tile_count_menu-21),d1                ; set beginning of gradient tiledata
    move.w  d1,vdp_data
	dbra    d0,gradientFade_writeTileMap_Loop  		; Decrement d0 and loop until finished (when d0 reaches -1)


    move.w  #(64-1),(RAM_GRADIENT_BLANK).l          ; set next column index to be blanked

    move.w  #$2300,sr                               ; Interrupts on
    WaitVBlank
    movem.l	(sp)+,d0-a6
    rts 