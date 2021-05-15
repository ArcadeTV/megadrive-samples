;==============================================================
; Header Overwrites
;==============================================================

    org     $4
    dc.l    ENTRY_POINT                     ; custom entry point for redirecting

    org     $70
    dc.l    HINT

    org     $78
    dc.l    VINT

    if      COPYRIGHT_OVERWRITE
    org     $110
    COPYRIGHT
    endif

    if      DOMESTIC_TITLE_OVERWRITE
    org     $120
    DOMESTIC_TITLE
    endif

    if      OVERSEAS_TITLE_OVERWRITE
    org     $150
    OVERSEAS_TITLE
    endif

    org     $1A4                            ; Header: ROM_END
    dc.l    EXPANDED_ROM_SIZE               ; Overwrite with specified MBIT size

    if      REGION_OVERWRITE
    org     $1F0
    REGION                                  ; Region String Overwrite
    endif

    org     $374                            ; TF3 Checksum Bypass
    nop 
