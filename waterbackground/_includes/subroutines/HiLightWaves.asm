; a0: address of table
; d0: RAM_WAVETILE (0-767)
; d1: entry from table holder
; d2: VRAM address (we want $E000+offset)
; ---------------------------------------

; ----------------------
; ----------------------
; ---------------------- A:1088 tiles
; ++++++++++++++++++++++
; ++++++++++++++++++++++ B:1792 tiles
;                           704 tiles total from A to B

; RANDOM_TILE_IDS holds randomly sorted indexes from tilemap
; to get a random tile id, we get an index from RANDOM_TILE_IDS 
; and index into tilemap which holds the tile id.

; ---------------------------------------
HiLightWaves:
    lea     RANDOM_TILE_IDS,a0      ; Address of first index of random numbers (words) sequence from 1024 to 1791 (768 entries)
    lea     Tilemap_B,a1
    move.w  (RAM_WAVETILE).l,d0     ; get stored val from RAM (0-767): index for RANDOM_TILE_IDS table

	tst.b 	RAM_TICTOC				; test if 00
	beq.w 	restore_hilight  		; if RAM_TICTOC=00, use the other set

change_hilight:
    move.w 	(a0,d0),d1              ; index into the table and load in d1
    add.w   d1,d1                   ; *2 for word size
    move.w 	(a1,d1),d4              ; index into the tilemap and load in d1
    or.w    #$6000,d4               ; Set Palette Index to $03
    bsr.w   changeTile
    rts

restore_hilight:
    move.w 	(a0,d0),d1              ; index into the table and load in d1
    add.w   d1,d1                   ; *2 for word size
    move.w 	(a1,d1),d4              ; index into the tilemap and load in d1
    or.w    #$2000,d4               ; Set Palette Index to $01
    bsr.w   changeTile

Update_RAM_After_Hilight:
    add.w 	#size_word,d0 			; increment d0 table index
    cmp.w   #(702*2),d0 
    bne.s   increment_further
    move.l  #0,d0
increment_further:
    move.w  d0,(RAM_WAVETILE).l     ; store incremented index in RAM
    rts 


changeTile:
    move.w  d1,d2                   ; add offset to $E000
    add.w   #vram_addr_plane_b,d2 
    jsr 	SendVRAMWriteAddress	; tell vdp the start address of the next row in d2
    move.w  d4,vdp_data
    rts 

; Flow---:
; load RAM var
; get tilemap entry 
; restore palette [1]
; write back to vram $E000+offset 
; get next tilemap entry 
; change palette [3]
; write back to vram $E000+offset 
; check RAM var if max and reset if neccessary
; save var in RAM 