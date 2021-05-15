displayScreen:
; A1: ASSETS_TABLE:
; [0].l => number of longwords in tile data
; [1].l => start of tile data in ROM
; [2].l => 64 x 32 words of map data (Plane B)
; [3].l => 64 x 32 words of map data (Plane A)
; [4].l => Sprite Table data (280 Bytes)
; [5].l => 4 x 16 words of palette data
;
; d1.b: (RAM_SELECTED_ITEM).l => index of item to be displayed

    movem.l	d0-a6,-(sp)

   	jsr 	clearCram
	jsr 	clearVram

	; Animation config
    move.b  #$F,(RAM_FADE_COUNTER).l

    moveq.l #0,d1                           ; clr d1 first
    move.b  (RAM_SELECTED_ITEM).l,d1        ; currently selected item index into d1
    mulu.w  #(6*size_long),d1
    move.l  #ASSETS_TABLE,a1                ; Start of table in a1
    ;add.l   d1,a1                           ; offset to item data pointers

	; LOAD TILE DATA
	SetVRAMWrite vram_addr_tiles
	move.l  (a1,d1),d0                      ; set Loop counter
    addi.l  #size_long,d1                   ; ASSETS_TABLE[0]
	move.l  (a1,d1),a0					    ; ASSETS_TABLE[1]
	Tiles_Lp:							    ; Start of loop
	move.l  (a0)+,vdp_data					; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,Tiles_Lp					    ; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PLANE A MAP
    addi.l  #size_long,d1                   ; ASSETS_TABLE[3]
    SetVRAMWrite vram_addr_plane_a
	move.l  (a1,d1),a0  			        ; Move the address of the first map entry into a0
	move.l  #(64*32)-1,d0                   ; Loop counter (-1 for DBRA loop)
	MapA_Loop:				                ; Start of loop
	move.w  (a0)+,vdp_data			        ; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,MapA_Loop				    ; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD PLANE B MAP
    addi.l  #size_long,d1                   ; ASSETS_TABLE[2]
    SetVRAMWrite vram_addr_plane_b
	move.l  (a1,d1),a0  			        ; Move the address of the first map entry into a0
	move.l  #(64*32)-1,d0                   ; Loop counter (-1 for DBRA loop)
	MapB_Loop:				                ; Start of loop
	move.w  (a0)+,vdp_data			        ; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,MapB_Loop				    ; Decrement d0 and loop until finished (when d0 reaches -1)

	; LOAD SPRITE TABLE
    addi.l  #size_long,d1                   ; ASSETS_TABLE[4]
    SetVRAMWrite vram_addr_sprite_table
	move.l  (a1,d1),a0  			        ; Move the address of the first sprite table entry into a0
	move.l  #($280/2)-1,d0                  ; Loop counter (-1 for DBRA loop)
	SprTbl_Loop:				            ; Start of loop
	move.w  (a0)+,vdp_data			        ; Write tile line (4 bytes per line), and post-increment address
	dbra    d0,SprTbl_Loop				    ; Decrement d0 and loop until finished (when d0 reaches -1)


	; LOAD PALETTES
    addi.l  #size_long,d1                   ; ASSETS_TABLE[5]
	move.l  (a1,d1),a0  			        ; Move the address of the first palette entry into a0
	lea 	(RAM_SCENE_PALETTE).l,a2
	lea 	(RAM_SCENE_PALETTE_UPD).l,a3
	move.l  #((size_palette_w*4)-1),d0
	@Pal_Loop:
	move.w  (a0)+,(a2)+
	move.w  #0000,(a3)+
	dbra    d0,@Pal_Loop

	movem.l	(sp)+,d0-a6
    rts