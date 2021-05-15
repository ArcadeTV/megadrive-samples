;-------------------------------------------------------------------------------
; FadeIn
; Fades in the screen to RAM_SCENE_PALETTE, RAM_SCENE_PALETTE is not modified
;
; a0:    target palettes
; a1:    currently updated palettes
; a2:    palette-entry check table: FF=done, 00=not done yet
;
; d0:    counter/palette entry
; d1:    index/check
; d2:    index/entry of check table
; d3:    value/entry of target palette
; d4:    value/entry of currently updated palette
; d5:    loopcounter of all entries in the processing loop
; d6,d7: nybbles for R/G/B
;-------------------------------------------------------------------------------
FadeIn:
    ;cmpi.b 	#FADE_FRAME_DELAY,(RAM_FRAME_DELAY).l
    ;bne.w   FadeIn_exit

    movem.l d0-a6,-(sp)

    lea	    (RAM_SCENE_PALETTE),a0              ; 4 target palettes, each 16 words
    lea	    (RAM_SCENE_PALETTE_UPD),a1          ; 4 palettes in process (current values)
    lea	    (RAM_SCENE_PALETTE_CHK),a2          ; check-entries for each entry in all 4 palettes: 00 means not done yet

    moveq	#$003F,d5	                        ; 64 ($40) words of palette data = 4 palettes ($80 Bytes)
    moveq   #0,d0                               ; initial entry index
processingLoop:
    move.w  (a0,d0),d3                          ; entry from target palette into d3
    move.w  (a1,d0),d4                          ; current value of entry in processed palette in d4
    bsr     processEntry                        ; increases the nybbles by 1 if not equal to ref value
    move.w  d4,(a1,d0)                          ; write processed entry back to RAM_SCENE_PALETTE_UPD

    add.w   #size_word,d0                       ; increment entry-index
    dbra    d5,processingLoop                   ; start process again with next index

    jsr     writeUpdatedPalettes                ; after all 4 palettes have gone through 1 incrementation, update CRAM

AllDone:
    tst.b   (RAM_FADE_COUNTER).l
    beq.s   FadeIn_return
    subi.b  #1,(RAM_FADE_COUNTER).l

FadeIn_return:
    movem.l (sp)+,d0-a6
FadeIn_exit:
    rts                                         ; return


;writeUpdatedPalettes:
;    moveq	#$003F,d2	                        ; 64 ($40) words of palette data = 4 palettes ($80 Bytes)
;    moveq   #0,d1
;    ;WaitVBlank
;    move.l	#vdp_cmd_cram_write,(vdp_control)   ; set up VDP write to CRAM
;writeUpdatedPalettes_Loop
;    move.w	(a1,d1),(vdp_data)	                ; write the palette entry
;    add.w   #size_word,d1
;    dbra    d2,writeUpdatedPalettes_Loop
;    rts

writeUpdatedPalettes:
    stopZ80
    waitZ80
    WaitVBlank
    writeCRAM_DMA RAM_SCENE_PALETTE_UPD,$80,0
    startZ80
    jsr     ScrollPlanes
    rts

processEntry:
    ; d3: ref value
    ; d4: current value ($0000 at start)
    bsr     procB
    bsr     procG
    bsr     procR
    rts 

procB:
    ; isolate B nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F00,d6 
    lsr.w   #8,d6 
    ; isolate B nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F00,d7 
    lsr.w   #8,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procB_return
    add.w   #$100,d4
procB_return:
    rts

procG:
    ; isolate G nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F0,d6 
    lsr.w   #4,d6 
    ; isolate G nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F0,d7 
    lsr.w   #4,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procG_return
    add.w   #$10,d4
procG_return:
    rts

procR:
    ; isolate R nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F,d6 
    ; isolate R nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procR_return
    add.w   #1,d4
procR_return:
    rts


; ------------------------------------------------------------------------------

FadeInLogo:
    disable_ints
    cmpi.b 	#FADE_FRAME_DELAY,(RAM_FRAME_DELAY).l
    bne.w   FadeInLogo_exit

    movem.l d0-a6,-(sp)

    lea	    (RAM_SCENE_PALETTE),a0              ; 4 target palettes, each 16 words
    lea	    (RAM_SCENE_PALETTE_UPD),a1          ; 4 palettes in process (current values)
    lea	    (RAM_SCENE_PALETTE_CHK),a2          ; check-entries for each entry in all 4 palettes: 00 means not done yet

    moveq	#(16-1),d5	                        ; 16 ($F) words of palette data = 1 palette ($32 Bytes)
    moveq   #0,d0                               ; initial entry index
processingLoopLogo:
    move.w  (a0,d0),d3                          ; entry from target palette into d3
    move.w  (a1,d0),d4                          ; current value of entry in processed palette in d4
    bsr     processEntry                        ; increases the nybbles by 1 if not equal to ref value
    move.w  d4,(a1,d0)                          ; write processed entry back to RAM_SCENE_PALETTE_UPD

    add.w   #size_word,d0                       ; increment entry-index
    dbra    d5,processingLoopLogo               ; start process again with next index

    jsr     writeUpdatedPalettesLogo            ; after all 4 palettes have gone through 1 incrementation, update CRAM

AllDoneLogo:
    tst.b   (RAM_FADE_COUNTER).l
    beq.s   FadeInLogo_return
    subi.b  #1,(RAM_FADE_COUNTER).l

FadeInLogo_return:
    movem.l (sp)+,d0-a6
FadeInLogo_exit:
    enable_ints
    rts                                         ; return

writeUpdatedPalettesLogo:
    moveq.l #0,d2 
    jsr     SendCRAMWriteAddress
    moveq	#(16-1),d2	                        ; 16 ($F) words of palette data = 1 palette ($32 Bytes)
    moveq   #0,d1
writeUpdatedPalettesLogo_Loop
    move.w	(a1,d1),(vdp_data)	                ; write the palette entry
    add.w   #size_word,d1
    dbra    d2,writeUpdatedPalettesLogo_Loop
    rts

;-------------------------------------------------------------------------------
; FlashIn
; Flashes in the Palette from white to original colors
; a0:    target palette
; a1:    currently updated palettes
; a2:    palette-entry check table: FF=done, 00=not done yet
; a3:    offset of palette in CRAM
; d0:    index/palette entry
; d1,d2: indexes in sub-loops
; d3:    entry of target palette
; d4:    entry of currently updated palette
; d5:    counter of all entries in the processing loop
; d6,d7: nybbles for R/G/B
;-------------------------------------------------------------------------------
FlashIn:
    disable_ints
    cmpi.b  #$FF,(RAM_PALETTE_FLASHING).l
    beq.s   FlashIn_return

    movem.l d0-a6,-(sp)

    lea	    (RAM_OBJECT_PALETTE),a0             ; target palette, 16 words
    lea	    (RAM_OBJECT_PALETTE_UPD),a1         ; 1 palette in process
    lea	    (RAM_OBJECT_PALETTE_CHK),a2         ; check-entries for each entry in palette: 00 means not done yet
    moveq	#(16-1),d5	                        ; 16 words of palette data = 1 palettes ($20 Bytes)
    moveq   #0,d0                               ; initial entry index
    clr.l   d6                                  ; cram offset multiplyer reset
processingFlashLoop:
    move.w  (a0,d0),d3                          ; entry from palette into d3
    move.w  (a1,d0),d4                          ; current value of entry in processed palette in d4
    bsr     processFlashEntry                   ; decreases the nybbles by 1 if not equal to ref value
    move.w  d4,(a1,d0)                          ; write processed entry back to RAM_SCENE_PALETTE_UPD
nextFlashEntry:
    add.w   #size_word,d0                       ; increment entry-index
    dbra    d5,processingFlashLoop              ; start process again with next index
    jsr     writeUpdatedFlashPalette            ; after all 4 palettes have gone through 1 incrementation, update CRAM

    subi.b  #1,(RAM_FADE_COUNTER).l
    tst.b   (RAM_FADE_COUNTER).l
    beq.s   FlashIn_done

FlashIn_return:
    movem.l (sp)+,d0-a6
    enable_ints
    rts                                         ; return, because all CHK entries are not 00

FlashIn_done:
    move.b  #$FF,(RAM_PALETTE_FLASHING).l
    bra.w   FlashIn_return

writeUpdatedFlashPalette:
    moveq	#(16-1),d2	                        ; 16 words of palette data = 1 palettes ($20 Bytes)
    moveq   #0,d1
    ;WaitVBlank
    move.b	(RAM_PALETTE_FLASHING).l,d6         ; palette slot no. that is flashing right now
    mulu.w  #32,d6                              ; 32 Bytes per palette
    move.l  d2,-(sp)
    move.l  d6,d2
    jsr SendCRAMWriteAddress
    move.l  (sp)+,d2
writeUpdatedFlashPalette_Loop
    move.w	(a1,d1),(vdp_data)	                ; write the palette entry
    add.w   #size_word,d1
    dbra    d2,writeUpdatedFlashPalette_Loop
    rts

processFlashEntry:
    ; d3: ref value
    ; d4: current value ($0000 at start)
    movem.l d6-d7,-(sp)
    bsr     procFlashB
    bsr     procFlashG
    bsr     procFlashR
    movem.l (sp)+,d6-d7
    rts 

procFlashB:
    ; isolate B nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F00,d6 
    lsr.w   #8,d6 
    ; isolate B nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F00,d7 
    lsr.w   #8,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procFlashB_return
    sub.w   #$100,d4
procFlashB_return:
    rts

procFlashG:
    ; isolate G nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F0,d6 
    lsr.w   #4,d6 
    ; isolate G nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F0,d7 
    lsr.w   #4,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procFlashG_return
    sub.w   #$10,d4
procFlashG_return:
    rts

procFlashR:
    ; isolate R nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F,d6 
    ; isolate R nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procFlashR_return
    sub.w   #1,d4
procFlashR_return:
    rts

PaletteAllWhite:
    dc.w    $0000,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE,$0EEE
PaletteAllBlack:
    dc.w    $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000




;-------------------------------------------------------------------------------
; FadeOut
; Fades the Palette from original colors to black
; a0:    target palette
; a1:    currently updated palettes
; a2:    palette-entry check table: FF=done, 00=not done yet
; a3:    offset of palette in CRAM
; d0:    index/palette entry
; d1,d2: indexes in sub-loops
; d3:    entry of target palette
; d4:    entry of currently updated palette
; d5:    counter of all entries in the processing loop
; d6,d7: nybbles for R/G/B
;-------------------------------------------------------------------------------
FadeOut:

    movem.l d0-a6,-(sp)

    lea	    (RAM_OBJECT_PALETTE),a0             ; source palette, 16 words
    lea	    (RAM_OBJECT_PALETTE_UPD),a1         ; 1 palette in process
    lea	    (RAM_OBJECT_PALETTE_CHK),a2         ; check-entries for each entry in palette: 00 means not done yet
    moveq	#(16-1),d5	                        ; 16 words of palette data = 1 palettes ($20 Bytes)
    moveq   #0,d0                               ; initial entry index
    clr.l   d6                                  ; cram offset multiplyer reset
processingFadeOutLoop:                          
    move.w  (a0,d0),d3                          ; entry from palette into d3
    move.w  (a1,d0),d4                          ; current value of entry in processed palette in d4
    bsr     processFadeOutEntry                 ; decreases the nybbles by 1 if not equal to ref value
    move.w  d4,(a1,d0)                          ; write processed entry back to RAM_SCENE_PALETTE_UPD
nextFadeOutEntry:
    add.w   #size_word,d0                       ; increment entry-index
    dbra    d5,processingFadeOutLoop            ; start process again with next index
    jsr     writeUpdatedFadeOutPalette          ; after all 4 palettes have gone through 1 incrementation, update CRAM

    tst.b   (RAM_FADE_COUNTER).l
    beq.s   FadeOut_return
    subi.b  #1,(RAM_FADE_COUNTER).l

FadeOut_return:
    movem.l (sp)+,d0-a6
FadeOut_exit:
    rts                                         ; return, because all CHK entries are not 00

markFadeOutAsDone:
    move.w  #$FF,(a2,d0)                        ; mark current entry as done in CHK table
    bra.s   nextFadeOutEntry

writeUpdatedFadeOutPalette:
    moveq	#(16-1),d2	                        ; 16 words of palette data = 1 palettes ($20 Bytes)
    moveq   #0,d1
    ;WaitVBlank
    move.b	(RAM_PALETTE_FADEOUT).l,d6          ; palette slot no. that is flashing right now
    mulu.w  #32,d6                              ; 32 Bytes per palette
    move.l  d2,-(sp)
    move.l  d6,d2
    jsr SendCRAMWriteAddress
    move.l  (sp)+,d2
writeUpdatedFadeOutPalette_Loop
    move.w	(a1,d1),(vdp_data)	                ; write the palette entry
    add.w   #size_word,d1
    dbra    d2,writeUpdatedFadeOutPalette_Loop
    rts

processFadeOutEntry:
    ; d3: ref value
    ; d4: current value ($0000 at start)
    movem.l d6-d7,-(sp)
    bsr     procFadeOutB
    bsr     procFadeOutG
    bsr     procFadeOutR
    movem.l (sp)+,d6-d7
    rts 

procFadeOutB:
    ; isolate B nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F00,d6 
    lsr.w   #8,d6 
    ; isolate B nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F00,d7 
    lsr.w   #8,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procFadeOutB_return
    sub.w   #$100,d4
procFadeOutB_return:
    rts

procFadeOutG:
    ; isolate G nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F0,d6 
    lsr.w   #4,d6 
    ; isolate G nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F0,d7 
    lsr.w   #4,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procFadeOutG_return
    sub.w   #$10,d4
procFadeOutG_return:
    rts

procFadeOutR:
    ; isolate R nybble (in ref value) into d6
    move.w  d3,d6
    and.w   #$F,d6 
    ; isolate R nybble (in current value) into d7
    move.w  d4,d7
    and.w   #$F,d7 
    ; compare
    cmp.b   d6,d7
    beq.s   procFadeOutR_return
    sub.w   #1,d4
procFadeOutR_return:
    rts




;-------------------------------------------------------------------------------
; BlockOut
; Fills the visible area of Plane A with blank tiles, per row on vblank
;-------------------------------------------------------------------------------

BlockOut:
    movem.l d0-a6,-(sp)
    move.l  #(28-1),d4
BlockOut_Loop:
    WaitVBlank
    move.w  (RAM_BLOCKOUT_CURRENT).l,d0     ; current row in d0
    move.l  #(64*size_word),d1              ; no. of bytes in map's complete row (64 tiles)
    move.w  #vram_addr_plane_a,d2           ; tell vdp_control_port that we write to Plane A map
    moveq   #(40-1),d3                      ; fill counter with row-width
    mulu.w  d0,d1                           ; current row index * row-width = start of next row
    add.w   d1,d2                           ; add start of next row to base address of Plane A
    jsr 	SendVRAMWriteAddress	        ; tell vdp the start address of the next row in d2
blockOutRow_Loop:
    move.w  #$2000,(vdp_data)               ; write blank-tile id to vdp data port
    dbra    d3,blockOutRow_Loop
    add.w   #1,(RAM_BLOCKOUT_CURRENT).l

    dbra    d4,BlockOut_Loop

    movem.l (sp)+,d0-a6
    rts