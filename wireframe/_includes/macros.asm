;==============================================================
; MACROS
;==============================================================

; Set the VRAM (video RAM) address to write to next
    macro SetVRAMWrite
	move.l  #(vdp_cmd_vram_write)|((\1)&$3FFF)<<16|(\1)>>14,vdp_control
	endm

; Set the CRAM (colour RAM) address to write to next
    macro SetCRAMWrite
	move.l  #(vdp_cmd_cram_write)|((\1)&$3FFF)<<16|(\1)>>14,vdp_control
	endm

; Set the VSRAM (vertical scroll RAM) address to write to next
    macro SetVSRAMWrite
	move.l  #(vdp_cmd_vsram_write)|((\1)&$3FFF)<<16|(\1)>>14,vdp_control
	endm

; Wait for VBlank
	macro WaitVBlank
	jsr 	WaitVBlank
	endm

* Wait for msumd driver ready
	macro	MCD_WAIT
.\@
		tst.b	MCD_STAT
		bne.s	.\@
	endm

* Load Palette [Label] to Palette Slot [0-3]
	macro 	loadPalette \1 \2
	lea 	\1,a0 
	moveq.l \2,d2 
	jsr 	loadPaletteAdressToCram
	endm

; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

	macro stopZ80
	move.w	#$100,(z80_bus_request).l
	endm

; ---------------------------------------------------------------------------
; wait for Z80 to stop
; ---------------------------------------------------------------------------

	macro waitZ80
.\@wait:	
	btst	#0,(z80_bus_request).l
	bne.s	.\@wait
	endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

	macro resetZ80
	move.w	#$100,(z80_reset).l
	endm

	macro resetZ80a
	move.w	#0,(z80_reset).l
	endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

	macro startZ80
	move.w	#0,(z80_bus_request).l
	endm

; ---------------------------------------------------------------------------
; disable interrupts
; ---------------------------------------------------------------------------

	macro disable_ints
	move	#$2700,sr
	endm

; ---------------------------------------------------------------------------
; enable interrupts
; ---------------------------------------------------------------------------

	macro enable_ints
	move	#$2300,sr
	endm

; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the CRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

	macro writeCRAM_DMA
	lea	(vdp_control).l,a5
	move.l	#$94000000+(((\2>>1)&$FF00)<<8)+$9300+((\2>>1)&$FF),(a5)
	move.l	#$96000000+(((\1>>1)&$FF00)<<8)+$9500+((\1>>1)&$FF),(a5)
	move.w	#$9700+((((\1>>1)&$FF0000)>>16)&$7F),(a5)
	move.w	#$C000+(\3&$3FFF),(a5)
	move.w	#$80+((\3&$C000)>>14),(RAM_VDP_BUFFER).w
	move.w	(RAM_VDP_BUFFER).w,(a5)
	endm
