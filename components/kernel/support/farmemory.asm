; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		farmemory.asm
;		Author :	paul@robsons.org.uk
;		Date : 		11th January 2019
;		Purpose :	Kernel - Far memory routines.
;
; ***************************************************************************************
; ***************************************************************************************
	
; ***********************************************************************************************
;
;								Byte compile far memory A
;
; ***********************************************************************************************

FARCompileByte:
		push 	af 									; save byte and HL
		push 	hl
		push 	af 									; save byte
		ld		a,(HerePage) 						; switch to page
		call 	PAGESwitch
		ld 		hl,(Here) 							; write to memory location
		pop 	af
		ld 		(hl),a
		inc 	hl 									; bump memory location
		ld 		(Here),hl 							; write back
		call 	PAGERestore
		pop 	hl 									; restore and exit
		pop 	af
		ret

; ***********************************************************************************************
;
;								Word compile far memory HL
;
; ***********************************************************************************************

FARCompileWord:
		push 	af 									; save byte and HL
		push 	de
		push 	hl
		ex 		de,hl 								; word into DE
		ld		a,(HerePage) 						; switch to page
		call 	PAGESwitch
		ld 		hl,(Here) 							; write to memory location
		ld 		(hl),e
		inc 	hl 	
		ld 		(hl),d
		inc 	hl
		ld 		(Here),hl 							; write back
		call 	PAGERestore
		pop 	hl
		pop 	de 									; restore and exit
		pop 	af
		ret

; ***********************************************************************************************
;
;								Expand macro during compilation
;
; ***********************************************************************************************

FARMacroExpander:
		ex 		(sp),hl 							; old HL on stack, following byte address in HL
		ld 		b,(hl)								; get count
__MacroCopy:
		inc 	hl 									; get next
		ld		a,(hl)
		call 	FARCompileByte 						; compile it
		djnz 	__MacroCopy 								
		pop 	hl 									; restore old HL
		ret
