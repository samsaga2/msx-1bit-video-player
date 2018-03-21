  include bios.asm
  include megarom.asm

  page 0

  module main


start:
  ;;  init megarom
  call megarom.init
  ;; screen 2
  ld a,2
  call bios.CHGMOD
  ;; change border color to black
  xor a
  ld (bios.BAKCLR),a
  ld (bios.BDRCLR),a
  call bios.CHGCLR
  ;; video play
  di
	call clear_color
.loop:
  call load_frames
  jp .loop


clear_color:
  ld hl,0x2000
  call bios.SETWRT
  ld bc,256*8*3
1:
  ld a,0xf1
  out (0x98),a
  dec bc
  ld a,b
  or c
  jp nz,1b
  ret


load_frames:
  ld hl,frames.data
1:
  ;; frame page
  ld a,(hl)
  or a
  ret z                         ; break if page is zero
  inc hl
  setpage 3,a
  ;; frame ptr
  ld a,(hl)
  ld e,a
  inc hl
  ld a,(hl)
  ld d,a
  inc hl

  push hl
  call load_frame
  pop hl
  jp 1b


load_frame:
  push de
  ld hl,0
  call bios.SETWRT
  pop hl
  jp uncompress.to_vram_write

  include uncompress.asm

  module frames
  include out/frames.asm
