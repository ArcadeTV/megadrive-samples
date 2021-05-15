;==============================================================
; INITIAL VDP REGISTER VALUES
;==============================================================

VDPRegisters:
	dc.b $14 ; $00: H interrupt on, palettes on
	dc.b $74 ; $01: V interrupt on, display on, DMA on, Genesis mode on
	dc.b $30 ; $02: Pattern table for Scroll Plane A at VRAM $C000 (bits 3-5 = bits 13-15)
	dc.b $00 ; $03: Pattern table for Window Plane at VRAM $0000 (disabled) (bits 1-5 = bits 11-15)
	dc.b $07 ; $04: Pattern table for Scroll Plane B at VRAM $E000 (bits 0-2 = bits 11-15)
	dc.b $78 ; $05: Sprite table at VRAM $F000 (bits 0-6 = bits 9-15)
	dc.b $00 ; $06: Unused
	dc.b $00 ; $07: Background colour: bits 0-3 = colour, bits 4-5 = palette
	dc.b $00 ; $08: Unused
	dc.b $00 ; $09: Unused
	dc.b $08 ; $0A: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
	dc.b $03 ; $0B: External interrupts off, V scroll fullscreen, 00: H scroll full, 02: H scroll tiles, 03: H scroll lines
	dc.b $81 ; $0C: Shadows and highlights off, interlace off, 00:H32 mode (256 x 224 screen res), 81:H40 mode (320 x 224 screen res)
	dc.b $3F ; $0D: Horiz. scroll table at VRAM $FC00 (bits 0-5)
	dc.b $00 ; $0E: Unused
	dc.b $02 ; $0F: Autoincrement 2 bytes
	dc.b $01 ; $10: Scroll plane size: 00:32x32 tiles, 01:64x32 tiles
	dc.b $00 ; $11: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
	dc.b $00 ; $12: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
	dc.b $FF ; $13: DMA length lo byte
	dc.b $FF ; $14: DMA length hi byte
	dc.b $00 ; $15: DMA source address lo byte
	dc.b $00 ; $16: DMA source address mid byte
	dc.b $80 ; $17: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)

	even
