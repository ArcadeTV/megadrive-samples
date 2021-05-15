controlAnimations:
	movem.l	d0-a6,-(sp)
    tst.b   (ram_intro_ends).l 
    beq.s   controlAnimations_menu                          ; if intro_ends flag is 00, branch to menu routines

controlAnimations_intro_ends:
    addi.w  #1,(RAM_GRADIENT_FRAME).l
    move.w  (ram_plane_a_scroll_x).l,d0
    addi.w   #4,d0                                          ; increase scroll by 4px
    move.w  d0,(ram_plane_a_scroll_x).l

    SetVRAMWrite vram_addr_hscroll
	move.w d0,vdp_data

    ; calculate column in map that exceeds the visible area (>320px + hscrollValue)
    ; and fill with blank tile, so it is black when it is repeated into the viewport:
    tst.w   (RAM_TICTOC).l 
    beq.w   controlAnimations_exit

    cmpi.w  #4,(RAM_GRADIENT_FRAME).l
    bls.w   skipForSaveOffset                               ; if RAM_GRADIENT_FRAME is greater than 4
    
    jsr     AnimatePlanes
    subi.w 	#1,(RAM_GRADIENT_BLANK).l						; decrement RAM_GRADIENT_BLANK

skipForSaveOffset:
    tst.w   (RAM_GRADIENT_BLANK).l
    beq.w   GRADIENT_FINISHED

    bra.w   controlAnimations_exit

GRADIENT_FINISHED:
    move.w  #$FFFF,(RAM_GRADIENT_FINISHED).l
    bra.w   controlAnimations_exit

controlAnimations_menu:
	jsr 	ScrollPlanes	
    
controlAnimations_exit:
    movem.l (sp)+,d0-a6
    rts 

