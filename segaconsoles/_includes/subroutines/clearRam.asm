clearRam:
; Clear RAM (top 64k of memory space)
    move.l #$00000000,d0       ; We're going to write zeroes over the whole of RAM, 4 bytes at a time
    move.l #$00000000,a0       ; Starting from address 0x0, clearing backwards
    move.l #$00003FFF,d1       ; Clear 64k, 4 bytes at a time. That's 16383 writes
@ClearRAMLoop:
    move.l d0,-(a0)            ; Decrement address by 4 bytes and then copy our zero to that address
    dbra d1,@ClearRAMLoop      ; Decrement loop counter d1, exiting when it reaches zero
    rts