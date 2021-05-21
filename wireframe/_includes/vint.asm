;==============================================================
; Vertical Interrupt
;==============================================================
INT_VInterrupt:
	movem.l	d0-a6,-(sp)
	move.b 	#$FF,(RAM_VINT_FLAG)
	;add.l 	#1,(RAM_CURRENT_FRAME).l 
	not.b 	(RAM_TICTOC).l
	
INT_VInterrupt_return:
	movem.l	(sp)+,d0-a6
    rte


;-------------------------------------------------------------------------------
; WaitVBlank
;-------------------------------------------------------------------------------
WaitVBlank:
	cmpi.b	#$FF,(RAM_VINT_FLAG)
	bne.s	WaitVBlank					; loop until flag changes
	move.b 	#$00,(RAM_VINT_FLAG)
	rts

