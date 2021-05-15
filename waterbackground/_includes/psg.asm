;==============================================================
; PSG init
;==============================================================

PSG_Init:
	; Initialises the PSG - sets volumes of all channels to 0
	move.b  #$9F,psg_control
	move.b  #$BF,psg_control
	move.b  #$DF,psg_control
	move.b  #$FF,psg_control
	rts
