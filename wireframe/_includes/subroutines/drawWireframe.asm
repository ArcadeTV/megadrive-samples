drawWireframe:
    movem.l	d0-a6,-(sp)

    ; LOAD PLANE B MAP, 3D wireframe gfx, 20x14 tiles
   	move.l 	#0,d4                           					; start y
	clr.l 	d5
	lea     (Tilemap_Plane_B),a0
    move.w  (RAM_CURRENT_FRAME).l,d6
    mulu.w  #(40*28*size_word),d6
    add.l   d6,a0
	move.l  #(28-1),d1                      					; Counter rows: Map height
	move.l 	#vram_addr_plane_b,d2     	    					; start x/y on canvas: entry=((y*planeW)+x)*size_word
	jsr 	SendVRAMWriteAddress

Map_B_Loop_cols:
	move.l  #(40)-1,d0                      					; Map width
Map_B_Loop_rows:
    move.w  (a0)+,d3 
    move.w  d3,vdp_data
	dbra    d0,Map_B_Loop_rows		   

	addi.b 	#1,d4                           					; increment row counter
	move.l  d4,d5
	mulu.w  #64,d5
    mulu.w  #size_word,d5
	move.l 	#vram_addr_plane_b,d2
	add.w 	d5,d2
	jsr 	SendVRAMWriteAddress
	dbra    d1,Map_B_Loop_cols	

    move.w  (RAM_CURRENT_FRAME).l,d6
    cmpi.w  #(TOTAL_FRAMES-1),d6 
    bne.s   DontResetCurrentFrame
    move.l  #0,d6
    bra.s   CurrentFrameWasResetted
DontResetCurrentFrame:
    addi.w  #1,d6
CurrentFrameWasResetted:
    move.w  d6,(RAM_CURRENT_FRAME).l

    movem.l	(sp)+,d0-a6
    rts