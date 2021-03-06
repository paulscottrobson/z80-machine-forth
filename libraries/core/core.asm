; *********************************************************************************************
; *********************************************************************************************
;
;		Name : 		core.asm
;		Date :		10th January 2019
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Purpose :	Core words for the Machine Forth system
;		
; *********************************************************************************************
; *********************************************************************************************
;
;		Notes : 	TOS cached in DE
;					A is HL
;					No real return stack.
;					* implemented directly.
;
;		Missing :	; 			handled by compiler
;					pop/push 	short term working stack, seperate.
;					@R+,!R+		make no sense because of single stack.
;					
;		To Add : 	b versions of !a !a+ @a @a+ @ ! , port access functions. 
;
; *********************************************************************************************

; *********************************************************************************************
; 									@a+ read A and increment
; *********************************************************************************************

@macro 	@a+
		push 	de 									; save current TOS
		ld 		e,(hl) 								; read new TOS
		inc 	hl
		ld 		d,(hl)
		inc 	hl
@end

; *********************************************************************************************
; 											@a read A
; *********************************************************************************************

@macro 	@a
		push 	de 									; save current TOS
		ld 		e,(hl)								; read new TOS
		inc 	hl
		ld 		d,(hl)
		dec 	hl
@end

; *********************************************************************************************
;								!a+ write TOS to A and increment
; *********************************************************************************************

@macro 	!a+
		ld 		(hl),e 								; write out
		inc 	hl
		ld 		(hl),d
		inc 	hl
		pop 	de 									; update TOS
@end

; *********************************************************************************************
;										!a write TOS to A
; *********************************************************************************************

@macro 	!a
		ld 		(hl),e 								; write out
		inc 	hl
		ld 		(hl),d
		dec		hl 					
		pop 	de 									; update TOS
@end

; *********************************************************************************************
;										com one's complement
; *********************************************************************************************

@wordr	com
		ld 		a,d
		cpl 
		ld 		d,a
		ld 		a,e
		cpl 
		ld 		e,a
@end

; *********************************************************************************************
;										2* double TOS
; *********************************************************************************************

@macro 	2*
		ex 		de,hl
		add 	hl,hl
		ex 		de,hl
@end

; *********************************************************************************************
;									 2/ halve TOS unsigned
; *********************************************************************************************

@macro 	2/
		srl 	d
		rr 		e
@end

; *********************************************************************************************
;									 	* multiplier 
; *********************************************************************************************

@wordx 	*
		pop 	bc 							; multiplicand.
		push 	hl 							; save A
		ld 		hl,$0000 					; result.
__multiply_loop:
		bit 	0,c 						; check bit 0.
		jr 		z,__multiply_noadd 			; don't add if 0
		add 	hl,de 						; add to total
__multiply_noadd:
		ex 		de,hl 						; shift DE left
		add 	hl,hl
		ex 		de,hl 						; shift BC right
		srl 	b 
		rr 		c
		ld 		a,b 						; go back if not done
		or 		c
		jr 		nz,__multiply_loop 
		ex 		de,hl 						; result in DE (top of stack)
		pop 	hl 							; restore A
@end

; *********************************************************************************************
; 										-or exclusive OR
; *********************************************************************************************

@wordx 	-or
		pop 	bc
		ld 		a,d
		xor 	b
		ld 		d,a
		ld 		a,e
		xor 	c
		ld 		e,a
@end

; *********************************************************************************************
; 										and logical AND
; *********************************************************************************************

@wordx 	and
		pop 	bc
		ld 		a,d
		and 	b
		ld 		d,a
		ld 		a,e
		and 	c
		ld 		e,a
@end

; *********************************************************************************************
; 										+ add
; *********************************************************************************************

@macro 	+
		ex 		de,hl
		pop 	bc
		add 	hl,bc
		ex 		de,hl
@end

; *********************************************************************************************
; 										A@ copy A to stack
; *********************************************************************************************

@macro 	A@
		push 	de 									; save old TOS
		ld 		e,l 								; copy A into TOS
		ld 		d,h 
@end

; *********************************************************************************************
;										dup Duplicate TOS
; *********************************************************************************************

@macro 	dup
		push 	de
@end

; *********************************************************************************************
;										over, 2nd copied to TOS.
; *********************************************************************************************

@macro 	over 	
		pop 	bc 									; 2nd on stack
		push 	bc 									; put back
		push 	de 									; save TOS
		ld 		e,b 								; copy 2nd value into DE
		ld 		d,c
@end

; *********************************************************************************************
;										A! copy stack to A
; *********************************************************************************************

@macro 	A!
		ex 		de,hl 								; TOS in HL
		pop 	de 									; update TOS
@end

; *********************************************************************************************
;										drop Drop TOS
; *********************************************************************************************

@macro 	drop
		pop 	de
@end

