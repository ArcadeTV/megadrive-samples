VDP_WriteTMSS:

	; The TMSS (Trademark Security System) locks up the VDP if we don't
	; write the string 'SEGA' to a special address. This was to discourage
	; unlicensed developers, since doing this displays the "LICENSED BY SEGA
	; ENTERPRISES LTD" message to screen (on Mega Drive models 1 and higher).
	;
	; First, we need to check if we're running on a model 1+, then write
	; 'SEGA' to hardware address $A14000.

	move.b  hardware_ver_address,d0			; Move Megadrive hardware version to d0
	andi.b  #$0F,d0						    ; The version is stored in last four bits, so mask it with 0F
	beq     @SkipTMSS						; If version is equal to 0, skip TMSS signature
	move.l  #tmss_signature,tmss_address	; Move the string "SEGA" to $A14000
	@SkipTMSS:

	; Check VDP
	move.w vdp_control,d0					; Read VDP status register (hangs if no access)

	rts
