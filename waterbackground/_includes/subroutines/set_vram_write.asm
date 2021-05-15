;-------------------------------------------------------------------------------
; SendXRAMWriteAddress
; builds the VRAM write address based on a relative address
; i.e. - passing $2200 should return $62000000
; d2 = relative VDP write address, final result is also stored in d2
; d3 is modified in this routine
;-------------------------------------------------------------------------------
SendVRAMWriteAddress:
	move.l 	d3,-(sp)
	clr.l 	d3
	; the two highest bits in d2 need to be the lowest bits in the final result
	move.w	d2,d3                                   ; start by copying d2 to d3	
	lsr.w	#$07,d3	                                ; shift bits 7 to the right
	lsr.w	#$07,d3	                                ; shift bits 7 more to the right
	and.l	#%00000000000000000000000000000011,d3	; clear all but lowest two
	; the two highest bits from d2 are now in d3
	swap	d2	                                    ; move the value in d2 to the high word
	and.l	#%00111111111111110000000000000000,d2	; clear all but the magic 14
	add.l	d3,d2	                                ; add the value in d0
	add.l	#vdp_cmd_vram_write,d2	                ; add the base VRAM write address
    move.l  d2,vdp_control
	move.l 	(sp)+,d3
	rts

SendCRAMWriteAddress:
	move.l 	d3,-(sp)
	clr.l 	d3
	; the two highest bits in d2 need to be the lowest bits in the final result
	move.w	d2,d3                                   ; start by copying d2 to d3	
	lsr.w	#$07,d3	                                ; shift bits 7 to the right
	lsr.w	#$07,d3	                                ; shift bits 7 more to the right
	and.l	#%00000000000000000000000000000011,d3	; clear all but lowest two
	; the two highest bits from d2 are now in d3
	swap	d2	                                    ; move the value in d2 to the high word
	and.l	#%00111111111111110000000000000000,d2	; clear all but the magic 14
	add.l	d3,d2	                                ; add the value in d0
	add.l	#vdp_cmd_cram_write,d2	                ; add the base VRAM write address
    move.l  d2,vdp_control
	move.l 	(sp)+,d3
	rts