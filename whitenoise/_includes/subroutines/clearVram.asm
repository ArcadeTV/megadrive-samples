	;==============================================================
	; Clear VRAM (video memory)
	;==============================================================
clearVram:
	; Setup the VDP to write to VRAM address $0000 (start of VRAM)
	SetVRAMWrite $0000

	; Write 0's across all of VRAM
	move.w  #($00010000/size_word)-1,d0	    ; Loop counter = 64kb, in words (-1 for DBRA loop)
	@ClrVramLp:								; Start of loop
	move.w  #$0,vdp_data					; Write a $0000 (word size) to VRAM
	dbra    d0,@ClrVramLp					; Decrement d0 and loop until finished (when d0 reaches -1)
    rts