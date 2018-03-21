  include bios.asm
  include megarom.asm

  page 0

  module main

current # 2
page # 1


start:
  ;;  init megarom
  call megarom.init
  ;;  turbor if exists
  ld a,0x82
  call bios.CHGCPU
  ;; screen 4
  ld a,4
  call bios.CHGMOD
  ;; change border color to black
  xor a
  ld (bios.BAKCLR),a
  ld (bios.BDRCLR),a
  call bios.CHGCLR
  ;; video play
  di
	call clear_color
  call restart
  ld hl,frames.data
  ld (current),hl
  xor a
  ld (page),a
.loop:
  call next_frame
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


next_frame:
  call flip_page
  ;;  frame
  ld hl,(current)
  ;; frame page
  ld a,(hl)
  or a
  jp z,restart               ; restart if page is zero
  inc hl
  setpage 3,a
  ;; frame ptr
  ld a,(hl)
  ld e,a
  inc hl
  ld a,(hl)
  ld d,a
  inc hl
  ld (current),hl
  ;; draw frame
  jp load_frame


restart:
  ld hl,frames.data
	ld (current),hl
  jp  next_frame


flip_page:
  ld a,(page)
  xor 1
  ld (page),a
  or a
  jp z,vdp.page0
  jp vdp.page1


load_frame:
  push de
  ld a,(page)
  or a
  jp z,.p0
.p1:
 	ld hl,0
  jp 1f
.p0:
  ld hl,0x8000
1:
  call bios.NSTWRT
  pop hl
  jp uncompress.to_vram_write

  include uncompress.asm

  module frames
  include out/frames.asm


  module vdp

	macro vdpreg reg
	  out (0x99),a
	  ld a,reg+0x080
	  out (0x99),a
	endmacro


page0:
  ld a,0x03
	vdpreg 4
  ret


page1:
  ld a,0x13
	vdpreg 4
  ret
