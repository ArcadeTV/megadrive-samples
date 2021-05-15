ScrollPlanes:
	movem.l	d2-d4,-(sp)
    ; set vscroll
	moveq.l #0,d2
	move.b 	(RAM_FADE_COUNTER).l,d2
	move.l 	d2,d3
	divu.w  #2,d2
	divu.w  #4,d3
	SetVSRAMWrite $0000
	move.w 	d2,vdp_data
	SetVSRAMWrite $0000+size_word       	; Plane B's is at $0002
	move.w 	d3,vdp_data						; update position of Plane B by array[d0]
	movem.l (sp)+,d2-d4
    rts