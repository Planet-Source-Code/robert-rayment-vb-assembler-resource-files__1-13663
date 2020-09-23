;HLB.asm

;HEX LONG BINARY CONVERSION by Robert Rayment

;NB Assumes all 8 hex bytes filled with 48("0") to 70("F")
;   and all 32 bin bytes filled with 48("0") or 49("1")

; VB

;Select Case Index
;Case 0   'Hex Input
;   Hex2Long2Bin
;Case 1   'Long Input
;   Long2Bin2Hex
;Case 2   'Bin Input
;   Bin2Hex2Long
;End Select

; For calling machine code
; res = CallWindowProc(lpMCode,InpDec, lpHex, lpBin,  OpType)
;								8		12		16		20							
; lpMCode    pointer to machine code
; InpDec     long decimal number input
; lpHex      pointer to HexBytes(1)  input & output
; lpBin      pointer to BinBytes(1)  input & output
; OpType     long number 1,2 or 4 for respec. Hex, Dec & Bin input
; res        long decimal output (from reg EAX)


[bits 32]

	push ebp
	mov ebp,esp
	push edi
	push esi
	push ebx


	mov eax,[ebp+20]	;Get OpType
	rcr eax,1
	jnc TestOp2
	
	;OPERATION 1  HEX INPUT

	CALL Hex2Long		;Long result in eax & edx
	push eax
	CALL Long2Bin		;In: Long in edx
	pop eax				;Long result in eax
	
	jmp GETOUT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestOp2:

	rcr eax,1
	jnc TestOp3

	;OPERATION 2  LONG INTEGER INPUT

	mov edx,[ebp+8]		;Get decimal input
	
	CALL Long2Bin
	CALL Bin2Hex
	
	jmp GETOUT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestOp3:

	rcr eax,1
	jnc GETOUT			;Error? ignore
	
	;OPERATION 3  BINARY INPUT

	CALL Bin2Hex	
	CALL Bin2Long		;Long result in eax
	
	;jmp GETOUT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GETOUT:
pop ebx
pop esi
pop edi
mov esp,ebp
pop ebp
ret 16
;##########################################################
Hex2Long:

	;CONVERT UP TO 8 ASCII HEX BYTES("0" to "F") TO LONG INTEGER  ;;;;;

	mov ebx,[ebp+12]	;Pointer to HexBytes(1) 8 bytes long
	xor edx,edx			;zeroed before entering bytes, summer
	mov ecx,8
getchar:
	mov al,[ebx+ecx-1]	;start at HexBytes(8)

	cmp al,65			;& work down to 1st
	jge A2F
			
	and al,0Fh			;al 48-59 ("0"-"9") -> 0-9
	jmp AHEX
A2F:
	and al,0Fh			;al 65-70 ("A"-"F") -> 1-6
	add al,9			;al 10-15
AHEX:
	shl edx,4			;shift up edx 4 places to
	or dl,al			;allow in 4 bits from al to dl
	dec cx
	jnz getchar

	mov eax,edx			;long result in eax & edx
ret
;=========================================================
Long2Bin:	;In; Long in edx
	
	;TAKE LONG INTEGER INPUT & PUT ASCII BITS TO BinBytes(32)

	mov ebx,[ebp+16]	;Pointer to BinBytes(1) 32 bytes long
	mov al,48			;"0"
	mov ah,49			;"1"
	mov ecx,32
GetBit:
	rcl edx,1			;rotate to carry, hi-bit 1st
	jc OneBit
	mov [ebx+ecx-1],al	;"0"
	jmp DecrBit
OneBit:
	mov [ebx+ecx-1],ah	;"1"
DecrBit:
	dec ecx
	jnz GetBit
ret
;=========================================================
Bin2Hex	:

	;CONVERT 32 ASCII BINARY BYTES("0" & "1") TO 8 HEX BYTES  ;;;;;

	mov esi,[ebp+16]	;Pointer to BinBytes(1) 32 bytes long
	mov edi,[ebp+12]	;Pointer to HexBytes(1) 8 bytes long
	add edi,7			;point to HexBytes(8)
	mov dl,10h			;bit4 set for counter bits0-3 zero
	mov ecx,32
GetABit:
	mov al,[esi+ecx-1]	;Get ASCII "0" or "1"
						;al 48-49  bit0 = 0 or 1
	rcr al,1			;get bit0 to carry
	rcl dl,1			;build 4 bit hex in dl
	jnc NextBit
		;Convert dl 0-15 to 48-57 ("0"-"9")or 65 to 70 ("A"-"F")
		add dl,48		;48-57(for 0-9)58-63 (for 10-15) 
		cmp dl,57
		jbe	storehex
		add dl,7		;58+7=65
	storehex:
		mov [edi],dl	;hex to HexByte()
		dec edi			;To store next hex
		mov dl,10h		;bit4 set for counter bits0-3 zero
NextBit:
	dec ecx
	jnz GetABit
ret
;=========================================================
Bin2Long:
	
	;CONVERT 32 ASCII BINARY BYTES("0" & "1") TO LONG INTEGER  ;;;;;

	mov esi,[ebp+16]	;Pointer to BinBytes(1) 32 bytes long
	xor edx,edx			;zeroed before entering bytes, summer
	mov ecx,32
GetABit2:
	mov al,[esi+ecx-1]	;Get ASCII "0" or "1"
						;al 48-49  bit0 = 0 or 1
	rcr al,1			;get bit to carry
	rcl edx,1			;build long in edx

	dec ecx
	jnz GetABit2
	
	mov eax,edx			;long result in eax & edx
ret
;=========================================================

ENDS