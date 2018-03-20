        module uncompress

	      ;; --- variables ---
buffer: # 512                   ; reusable ram


        ;; --- to_vram_noset ---
        ;;
        ;; HL=compressed data ptr
to_vram_write:
        ;; bc=token count
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl

        ;; de=dest (256 bytes align)
        ld de,(buffer+256)&0xff00

        ;; uncompress loop
1:
        ;; a=len
        ld a,(hl)
        inc hl
        or a
        jp z,3f

        push bc
        ld b,a                  ; b=back reference len
        ld c,(hl)               ; c=back reference offset
        inc hl
        push hl
        ;; hl=offset=(de-backoffset) mod 256
        ld a,e
        sub c
        ld l,a
        ld h,d
        ;; copy back reference
2:
        ld a,(hl)
        inc l                   ; hl=hl mod 256
        ld (de),a
        inc e                   ; de=de mod 256
        out (0x98),a
        djnz 2b
        pop hl
        pop bc

3:
        ;; a=next char
        ld a,(hl)
        inc hl

        ;; write nextchar
        out (0x98),a
        ld (de),a
        inc e

        ;; end?
        dec bc
        ld a,c
        or b
        jp nz,1b
        ret
