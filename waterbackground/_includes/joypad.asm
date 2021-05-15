;==============================================================
; Joypad/Controllers Routines
;==============================================================

PAD_InitPads:
    ; Initialise both gamepad IO ports by writing the latch bit
    ; to each pad's control port.
    move.b #pad_byte_latch,pad_ctrl_a
    move.b #pad_byte_latch,pad_ctrl_b
    rts

PAD_ReadPadA:
    ; Returns: d7 (word) - pad A state in format 00SA0000 00CBRLDU

    ; To read a gamepad, we need to read one byte at a time from
    ; address A10003 (gamepad port 1) or A10005 (gamepad port 2).
    ; To do this, we write to the port first to tell it whether we
    ; we want the first or the second byte of data, then read from it.
    ;
    ; The first byte contains the Start and A button states (in binary
    ; format 00SA0000), and the second byte contains C, B, RIGHT, LEFT,
    ; UP, and DOWN button states (in binary format 00CBRLDU).
    ;
    ; 6-button pads are a little more complex, and are beyond the
    ; scope of this sample.

    ; First, write 0 to the data port for pad A to tell it we want
    ; the first byte (clears the "latch" bit).
    move.b  #$00,pad_data_a

    ; Delay by 2 NOPs (opcodes that do nothing) to ensure the
    ; request was received before continuing. This was recommended
    ; by a SEGA developer bulletin in response to some rare cases
    ; where the data port was returning incorrect data.
    nop
    nop

    ; Read the first byte of data from the data port
    move.b  pad_data_a,d7

    ; Shift the byte into place in register d7 (we are returning
    ; both bytes as a single word from this routine).
    lsl.w   #$08,d7

    ; Write the "latch" bit, to tell it we want to read the second
    ; byte next.
    move.b  #pad_byte_latch,pad_data_a

    ; 2-NOP delay to respond to change
    nop
    nop

    ; Read the second byte of data from data port
    move.b  pad_data_a,d7

    ; Invert and mask all bytes received.
    ; The data port returns the button state bits as 1=button up,
    ; 0=button down, which doesnt make sense when using it in game code.
    ;
    ; We also clear any unused bits, so we can determine if ANY buttons
    ; are held by checking if the returned word is non-zero.
    neg.w   d7
    subq.w  #$01,d7
    andi.w  #pad_button_all,d7
    move.l  d7,(ram_joypad).l
    rts
