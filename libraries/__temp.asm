
	org $86ec

sys_displayinformation = $86ca
sys_gfx_setmode = $80a6
sys_gfx_write = $80d0
sys_gfx_writehex = $80e3
sys_macroexpander = $809b
sys_page_restore = $8052
sys_page_switch = $8039
sys_systeminformation = $86b6

; *********************************************************************************************
; *********************************************************************************************
;
;  Name :   core.asm
;  Date :  10th January 2019
;  Author :  Paul Robson (paul@robsons.org.uk)
;  Purpose : Core words for the Machine Forth system
;
; *********************************************************************************************
; *********************************************************************************************
;
;  Notes :  TOS cached in DE
;     A is HL
;     No real return stack.
;     * implemented directly.
;
;  Missing : ;    handled by compiler
;     pop/push  short term working stack, seperate.
;     @R+,!R+  make no sense because of single stack.
;
;  To Add :  b versions of !a !a+ @a @a+ @ ! , port access functions.
;
; *********************************************************************************************

; *********************************************************************************************
;          @a+ read A and increment
; *********************************************************************************************


; ----- @a+ macro -----

define_macro_40_61_2b:
	db 0,0
	call sys_macroexpander
	db end_40_61_2b-start_40_61_2b
start_40_61_2b:
	push  de          ; save current TOS
	ld   e,(hl)         ; read new TOS
	inc  hl
	ld   d,(hl)
	inc  hl
end_40_61_2b:

; *********************************************************************************************
;            @a read A
; *********************************************************************************************


; ----- @a macro -----

define_macro_40_61:
	db 0,0
	call sys_macroexpander
	db end_40_61-start_40_61
start_40_61:
	push  de          ; save current TOS
	ld   e,(hl)        ; read new TOS
	inc  hl
	ld   d,(hl)
	dec  hl
end_40_61:

; *********************************************************************************************
;        !a+ write TOS to A and increment
; *********************************************************************************************


; ----- !a+ macro -----

define_macro_21_61_2b:
	db 0,0
	call sys_macroexpander
	db end_21_61_2b-start_21_61_2b
start_21_61_2b:
	ld   (hl),e         ; write out
	inc  hl
	ld   (hl),d
	inc  hl
	pop  de          ; update TOS
end_21_61_2b:

; *********************************************************************************************
;          !a write TOS to A
; *********************************************************************************************


; ----- !a macro -----

define_macro_21_61:
	db 0,0
	call sys_macroexpander
	db end_21_61-start_21_61
start_21_61:
	ld   (hl),e         ; write out
	inc  hl
	ld   (hl),d
	dec  hl
	pop  de          ; update TOS
end_21_61:

; *********************************************************************************************
;          com one's complement
; *********************************************************************************************


; ----- com wordr -----

define_word_63_6f_6d:
	ld   a,d
	cpl
	ld   d,a
	ld   a,e
	cpl
	ld   e,a
	ret

; *********************************************************************************************
;          2* double TOS
; *********************************************************************************************


; ----- 2* macro -----

define_macro_32_2a:
	db 0,0
	call sys_macroexpander
	db end_32_2a-start_32_2a
start_32_2a:
	ex   de,hl
	add  hl,hl
	ex   de,hl
end_32_2a:

; *********************************************************************************************
;          2/ halve TOS unsigned
; *********************************************************************************************


; ----- 2/ macro -----

define_macro_32_2f:
	db 0,0
	call sys_macroexpander
	db end_32_2f-start_32_2f
start_32_2f:
	srl  d
	rr   e
end_32_2f:

; *********************************************************************************************
;           * multiplier
; *********************************************************************************************


; ----- * wordx -----

define_word_2a:
	pop ix
	pop  bc        ; multiplicand.
	push  hl        ; save A
	ld   hl,$0000      ; result.
__multiply_loop:
	bit  0,c       ; check bit 0.
	jr   z,__multiply_noadd    ; don't add if 0
	add  hl,de       ; add to total
__multiply_noadd:
	ex   de,hl       ; shift DE left
	add  hl,hl
	ex   de,hl       ; shift BC right
	srl  b
	rr   c
	ld   a,b       ; go back if not done
	or   c
	jr   nz,__multiply_loop
	ex   de,hl       ; result in DE (top of stack)
	pop  hl        ; restore A
	jp (ix)

; *********************************************************************************************
;           -or exclusive OR
; *********************************************************************************************


; ----- -or wordx -----

define_word_2d_6f_72:
	pop ix
	pop  bc
	ld   a,d
	xor  b
	ld   d,a
	ld   a,e
	xor  c
	ld   e,a
	jp (ix)

; *********************************************************************************************
;           and logical AND
; *********************************************************************************************


; ----- and wordx -----

define_word_61_6e_64:
	pop ix
	pop  bc
	ld   a,d
	and  b
	ld   d,a
	ld   a,e
	and  c
	ld   e,a
	jp (ix)

; *********************************************************************************************
;           + add
; *********************************************************************************************


; ----- + macro -----

define_macro_2b:
	db 0,0
	call sys_macroexpander
	db end_2b-start_2b
start_2b:
	ex   de,hl
	pop  bc
	add  hl,bc
	ex   de,hl
end_2b:

; *********************************************************************************************
;           A@ copy A to stack
; *********************************************************************************************


; ----- A@ macro -----

define_macro_41_40:
	db 0,0
	call sys_macroexpander
	db end_41_40-start_41_40
start_41_40:
	push  de          ; save old TOS
	ld   e,l         ; copy A into TOS
	ld   d,h
end_41_40:

; *********************************************************************************************
;          dup Duplicate TOS
; *********************************************************************************************


; ----- dup macro -----

define_macro_64_75_70:
	db 0,0
	call sys_macroexpander
	db end_64_75_70-start_64_75_70
start_64_75_70:
	push  de
end_64_75_70:

; *********************************************************************************************
;          over, 2nd copied to TOS.
; *********************************************************************************************


; ----- over macro -----

define_macro_6f_76_65_72:
	db 0,0
	call sys_macroexpander
	db end_6f_76_65_72-start_6f_76_65_72
start_6f_76_65_72:
	pop  bc          ; 2nd on stack
	push  bc          ; put back
	push  de          ; save TOS
	ld   e,b         ; copy 2nd value into DE
	ld   d,c
end_6f_76_65_72:

; *********************************************************************************************
;          A! copy stack to A
; *********************************************************************************************


; ----- A! macro -----

define_macro_41_21:
	db 0,0
	call sys_macroexpander
	db end_41_21-start_41_21
start_41_21:
	ex   de,hl         ; TOS in HL
	pop  de          ; update TOS
end_41_21:

; *********************************************************************************************
;          drop Drop TOS
; *********************************************************************************************


; ----- drop macro -----

define_macro_64_72_6f_70:
	db 0,0
	call sys_macroexpander
	db end_64_72_6f_70-start_64_72_6f_70
start_64_72_6f_70:
	pop  de
end_64_72_6f_70:

; *********************************************************************************************
; *********************************************************************************************
;
;  Name :   standard.asm
;  Date :  10th January 2019
;  Author :  Paul Robson (paul@robsons.org.uk)
;  Purpose : Normal macro words for the Machine Forth system
;
; *********************************************************************************************
; *********************************************************************************************

; *********************************************************************************************
;         @ indirect read
; *********************************************************************************************


; ----- @ macro -----

define_macro_40:
	db 0,0
	call sys_macroexpander
	db end_40-start_40
start_40:
	ex   de,hl         ; address to HL
	ld   e,(hl)        ; read it
	inc  hl
	ld   d,(hl)
	dec  hl
end_40:

; *********************************************************************************************
;         ! indirect write
; *********************************************************************************************


; ----- ! macro -----

define_macro_21:
	db 0,0
	call sys_macroexpander
	db end_21-start_21
start_21:
	ex   de,hl         ; address to HL
	pop  de          ; data to DE
	ld   (hl),e         ; write it
	inc  hl
	ld   (hl),d
	pop  de          ; fix up TOS
end_21:

; *********************************************************************************************
;           or logical OR
; *********************************************************************************************


; ----- or wordx -----

define_word_6f_72:
	pop ix
	pop  bc
	ld   a,d
	or   b
	ld   d,a
	ld   a,e
	or   c
	ld   e,a
	jp (ix)

; *********************************************************************************************
;           swap exchange top 2
; *********************************************************************************************


; ----- swap macro -----

define_macro_73_77_61_70:
	db 0,0
	call sys_macroexpander
	db end_73_77_61_70-start_73_77_61_70
start_73_77_61_70:
	ex   de,hl         ; HL = tos
	ex   (sp),hl        ; swap it
	ex   de,hl         ; fix up
end_73_77_61_70:

; *********************************************************************************************
; *********************************************************************************************
;
;  Name :   extensions.asm
;  Date :  10th January 2019
;  Author :  Paul Robson (paul@robsons.org.uk)
;  Purpose : Core extensions
;
; *********************************************************************************************
; *********************************************************************************************

; *********************************************************************************************
;          b@a+ read byte A and increment
; *********************************************************************************************


; ----- b@a+ macro -----

define_macro_62_40_61_2b:
	db 0,0
	call sys_macroexpander
	db end_62_40_61_2b-start_62_40_61_2b
start_62_40_61_2b:
	push  de          ; save current TOS
	ld   e,(hl)         ; read new TOS
	inc  hl
	ld   d,$00
end_62_40_61_2b:

; *********************************************************************************************
;            b@a byte read A
; *********************************************************************************************


; ----- b@a macro -----

define_macro_62_40_61:
	db 0,0
	call sys_macroexpander
	db end_62_40_61-start_62_40_61
start_62_40_61:
	push  de          ; save current TOS
	ld   e,(hl)        ; read new TOS
	ld   d,$00
end_62_40_61:

; *********************************************************************************************
;        b!a+ byte write TOS to A and increment
; *********************************************************************************************


; ----- b!a+ macro -----

define_macro_62_21_61_2b:
	db 0,0
	call sys_macroexpander
	db end_62_21_61_2b-start_62_21_61_2b
start_62_21_61_2b:
	ld   (hl),e         ; write out
	inc  hl
	pop  de          ; update TOS
end_62_21_61_2b:

; *********************************************************************************************
;         b!a byte write TOS to A
; *********************************************************************************************


; ----- b!a macro -----

define_macro_62_21_61:
	db 0,0
	call sys_macroexpander
	db end_62_21_61-start_62_21_61
start_62_21_61:
	ld   (hl),e         ; write out
	pop  de          ; update TOS
end_62_21_61:

; *********************************************************************************************
;         b@ byte indirect read
; *********************************************************************************************


; ----- b@ macro -----

define_macro_62_40:
	db 0,0
	call sys_macroexpander
	db end_62_40-start_62_40
start_62_40:
	ex   de,hl         ; address to HL
	ld   e,(hl)        ; read it
	ld   d,$00
end_62_40:

; *********************************************************************************************
;         b! byte indirect write
; *********************************************************************************************


; ----- b! macro -----

define_macro_62_21:
	db 0,0
	call sys_macroexpander
	db end_62_21-start_62_21
start_62_21:
	ex   de,hl         ; address to HL
	pop  de          ; data to DE
	ld   (hl),e         ; write it
	pop  de          ; fix up TOS
end_62_21:

; *********************************************************************************************
;         nip drop second on stack
; *********************************************************************************************


; ----- nip macro -----

define_macro_6e_69_70:
	db 0,0
	call sys_macroexpander
	db end_6e_69_70-start_6e_69_70
start_6e_69_70:
	pop  bc
end_6e_69_70:
