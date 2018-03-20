        module megarom

        ;; --- pages ---
        defpage 0, 0x4000, 0x2000
        defpage 1, 0x6000, 0x2000
        defpage 2, 0x8000, 0x2000
        defpage 3..63, 0xa000, 0x2000
        map 0xc000    ; ram

bank1 equ 0x5000
bank2 equ 0x7000
bank3 equ 0x9000
bank4 equ 0xb000

macro setpage page, slot
        ifdif slot, a
         ld a,slot
        endif
        ifidn page, 0
          ld (megarom.bank1),a
        else
          ifidn page, 1
            ld (megarom.bank2),a
          else
            ifidn page, 2
              ld (megarom.bank3),a
            else
              ifidn page, 3
                ld (megarom.bank4),a
              else
                error "wrong page", page, slot
              endif
            endif
          endif
        endif
endmacro

        ;; --- rom header ---
        page 0
        code @ 0x4000
romheader:
        db "AB"
        dw main.start
        db 0,0,0,0,0,0

        ;; --- init ---
        page 0
init:   call bios.RSLREG
        rrca
        rrca
        and 0x03
        ld c,a
        ld b,0
        ld hl,bios.EXPTBL
        add hl,bc
        or (hl)
        ld b,a
        inc hl
        inc hl
        inc hl
        inc hl
        ld a,(hl)
        and 0x0c
        or b
        ld h,0x80
        call bios.ENASLT

        ;; default slots
        setpage 0,0
        setpage 1,1
        setpage 2,2
        setpage 3,3
        ret
