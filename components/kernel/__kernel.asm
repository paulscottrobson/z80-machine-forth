; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		13th January 2019
;		Purpose :	Machine Forth Kernel
;
; ***************************************************************************************
; ***************************************************************************************

DictionaryPage = $20 								; dictionary page
FirstCodePage = $22 								; first code page.
;
;		Memory allocated from the Unused space in $4000-$7FFF
;
StackTop = $7EFC 									;      -$7EFC Top of stack

		org 	$8000 								; $8000 boot.
		jr 		Boot
		org 	$8004 								; $8004 address of sysinfo
		dw 		SystemInformation 

Boot:	ld 		sp,(StackDefault)					; reset Z80 Stack
		db 		$DD,$01
		di											; disable interrupts
		db 		$ED,$91,7,2							; set turbo port (7) to 2 (14Mhz speed)
		ld 		a,1 								; blue border
		out 	($FE),a
		ld 		a,FirstCodePage 					; get the page to start
		call 	PAGEInitialise
		ld 		a,(BootPage)						; switch to boot page.
		call 	PAGEInitialise
		ld 		hl,(BootAddress)					; start address
		jp 		(hl)

StopDefault:	
		jp 		StopDefault
		
