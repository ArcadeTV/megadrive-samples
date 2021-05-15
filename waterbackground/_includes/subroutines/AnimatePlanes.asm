	;==============================================================
	; AnimatePlanes
	;==============================================================
	; Replaces map entries in given rectangle coordinates.

AnimatePlanes:
	; a0: table with original/alternate tile ids
	; d0: tile index
	; d1: current tile id
	; d2: VRAM address to write
	; d3: column counter
	; d4: row counter
	; d5: current x in plane
	; d6: current y in plane

	tst.w 	(RAM_GRADIENT_BLANK).l
	beq.w 	AnimatePlanes_exit

	movem.l	d0-a6,-(sp)

	move.l 	#(1-1),d4 						; 1 tiles in row
	move.l 	#(32-1),d3 						; 28 tiles in column

	move.w 	(RAM_GRADIENT_BLANK).l,d5		; raster x coordinate
	move.l 	#0,d6 							; raster y coordinate

	; A----------------------B-C--D--E----------
	; ^                      ^ ^  ^  ^
	; #(vram_addr_plane_a+(((y*w)+x)*size_word))
	
	clr.l 	d2 								; address of first tile to process in d2:
	move.w  d5,d2   						; #(vram_addr_plane_a+(( [0*64] +x)*size_word)) => (vram_addr_plane_a+x)*2
	add.w   d2,d2							; *2 for word size
	add.w 	#vram_addr_plane_a,d2			; address adds to $E000, Formula A

transfer_map_entry_column_loop:
	jsr 	SendVRAMWriteAddress			; tell vdp the start address of the next row in d2
transfer_map_entry_row_loop:
	move.w 	#$6428,vdp_data					; send word containing tile id to vdp data port (pal:3,id:428)
	dbra 	d4,transfer_map_entry_row_loop

	move.l 	#(1-1),d4 						; 1 tiles in row
	add.w 	#1,d6 							; increment column index, raster y coordinate, restart address calculation
	move.l  d6,d2							; raster y coordinate, Formula B
	mulu.w  #64,d2							; multiply with plane width for next column tile, Formula C
	add.w 	d5,d2							; set plane x, Formula D
	add.w   d2,d2							; *2 for word size, Formula E
	add.w 	#vram_addr_plane_a,d2			; address adds to $E000, Formula A
	dbra 	d3,transfer_map_entry_column_loop

    movem.l (sp)+,d0-a6
AnimatePlanes_exit:
	rts