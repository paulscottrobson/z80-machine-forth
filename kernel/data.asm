	; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		data.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		5th January 2019
;		Purpose :	Data area
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;								System Information
;
; ***************************************************************************************

Sys_SystemInformation:

Here:												; +0 	Here 
		dw 		FreeMemory
HerePage: 											; +2	Here.Page
		db 		FirstCodePage,0
NextFreePage: 										; +4 	Next available code page (2 8k pages/page)
		db 		FirstCodePage+2,0,0,0
DisplayInfo: 										; +8 	Display information
		dw 		Sys_SystemInformation,0
BootAddress:										; +12 	Boot Address
		dw 		StopDefault
BootPage:											; +14 	Boot Page
		db 		FirstCodePage,0
StackDefault: 										; +16 	Initial value of stack.
		dw 		StackTop,0 

; ***************************************************************************************
;
;							 Display system information
;
; ***************************************************************************************

Sys_DisplayInformation:

SIScreenWidth: 										; +0 	screen width
		db 		0,0,0,0	
SIScreenHeight:										; +4 	screen height
		db 		0,0,0,0
SIScreenMode:										; +8 	current mode
		db 		0,0,0,0
SIFontBase:											; +12 	font in use
		dw 		AlternateFont
SIScreenDriver:										; +16 	Screen Driver
		dw 		0	

; ***************************************************************************************
;
;								 Other data and buffers
;
; ***************************************************************************************

__PAGEStackPointer: 								; stack used for switching pages
		dw 		0
__PAGEStackBase:
		ds 		16

FreeMemory:		
		org 	$C000 								; empty dictionary.
		db 		0
		