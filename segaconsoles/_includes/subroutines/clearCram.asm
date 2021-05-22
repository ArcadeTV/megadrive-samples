	;==============================================================
	; Clear CRAM (color memory)
	;==============================================================
    
clearCram:
	; Setup the VDP to write to VRAM address $0000 (start of VRAM)
	SetCRAMWrite $0000

	; Write 0's across all of CRAM
	move.w  #(4*size_palette_b)-1,d0	    ; Loop counter 4*32 Bytes (-1 for DBRA loop)
	@ClrCramLp:								; Start of loop
	move.w  #$0,vdp_data					; Write a $0000 (word size) to CRAM
	dbra    d0,@ClrCramLp					; Decrement d0 and loop until finished (when d0 reaches -1)
    rts