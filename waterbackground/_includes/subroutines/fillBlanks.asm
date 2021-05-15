fillBlanks:
    move.w  #LOGO_BLANK_TILE_ID,vdp_data
    dbra    d3,fillBlanks
    rts
