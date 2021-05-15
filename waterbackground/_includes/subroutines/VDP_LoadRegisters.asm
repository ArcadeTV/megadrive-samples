VDP_LoadRegisters:

	; To initialise the VDP, we write all of its initial register values from
	; the table at the top of the file, using a loop.
	;
	; To write a register, we write a word to the control port.
	; The top bit must be set to 1 (so $8000), bits 8-12 specify the register
	; number to write to, and the bottom byte is the value to set.
	;
	; In binary:
	;   100X XXXX YYYY YYYY
	;   X = register number
	;   Y = value to write

	; Set VDP registers
	lea     VDPRegisters,a0		; Load address of register table into a0
	move.w  #$18-1,d0			; 24 registers to write (-1 for loop counter)
	move.w  #$8000,d1			; 'Set register 0' command to d1

	@CopyRegLp:
	move.b  (a0)+,d1			; Move register value from table to lower byte of d1 (and post-increment the table address for next time)
	move.w  d1,vdp_control		; Write command and value to VDP control port
	addi.w  #$0100,d1			; Increment register #
	dbra    d0,@CopyRegLp		; Decrement d0, and jump back to top of loop if d0 is still >= 0

	rts
