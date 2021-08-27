;Program #2
;By Robert jun1219@calu.edu , Luke tin2093@calu.edu , Josh vit8629@calu.edu
;course CSC 323: Assembly Language Programming
INCLUDE Irvine32.inc

.data 
count DWORD 0													;variable to control loop
buffer BYTE 5 DUP(0)											;buffer for input											
temp DWORD ?													;temp for when needed
temp2 DWORD ?													;temp2 for when needed
stacksize equ 8													;MAKING THE STACK SIZE 8
stackindex DWORD -4											;setting the stack to -4
numstack DWORD stacksize DUP(0)								;making all the numbers in the stack 0
Dec DWORD PTR [esi]
tempstack DWORD stacksize DUP(0)
countd DWORD 0


;messages for program

welcome byte "Welcome to group 6's RPN caclulator!",0
Command byte "Here are your avaviable commands: + , - , / , * , X , N , U , D , V , C , ENTER , and Q",0
Answer byte "Your New Answer is: ",0
Prompt byte "Enter your command here: ",0
Prompt2 byte "The number youve entered:",0
Prompt3 byte "the number switched:",0

.code		
main PROC

	mov edx, OFFSET welcome
	call WriteString
	call Crlf

target:

	mov edx, OFFSET Command
	call WriteString
	call Crlf

	mov edx, OFFSET Prompt
	call WriteString

	mov edx,OFFSET buffer
	mov ecx,SIZEOF buffer
	call ReadString
	mov al,buffer
	JMP switch
switch:
	CMP al, -1
	JE endcase

	case1:	
		;addition,+

			CMP al,'+'
			JNE case2
			
			PUSH esi
			CMP stackindex,0
			jl nopop1
			mov esi,stackindex
			mov eax,numstack[esi]
			sub stackindex,4
			jmp endpop1
			nopop1: stc
			endpop1:
				pop esi
			
			PUSH esi
			CMP stackindex,0
			jl nopop2
			mov esi,stackindex
			mov ebx,numstack[esi]
			sub stackindex,4
			jmp endpop2
			nopop2: stc
			endpop2:
				pop esi

			ADD eax,ebx

			JMP PUSH1
			
	case2:
		;subtraction,-

			CMP al,'-'
			JNE case3	

			PUSH esi
			CMP stackindex,0
			jl nopop3
			mov esi,stackindex
			mov ebx,numstack[esi]
			sub stackindex,4
			jmp endpop3
			nopop3: stc
			endpop3:
				pop esi
			
			PUSH esi
			CMP stackindex,0
			jl nopop4
			mov esi,stackindex
			mov eax,numstack[esi]
			sub stackindex,4
			jmp endpop4
			nopop4: stc
			endpop4:
				pop esi

			SUB eax,ebx
			JMP PUSH1

			mov edx, OFFSET Answer
			call WriteString
			JMP target
	case3:
		;multiply,*
		
			CMP al,'*'
			JNE case4
			PUSH esi
			CMP stackindex,0
			jl nopop5
			mov esi,stackindex
			mov eax,numstack[esi]
			sub stackindex,4
			jmp endpop5
			nopop5: stc
			endpop5:
				pop esi
			
			PUSH esi
			CMP stackindex,0
			jl nopop6
			mov esi,stackindex
			mov ebx,numstack[esi]
			sub stackindex,4
			jmp endpop6
			nopop6: stc
			endpop6:
				pop esi

			MUL ebx
			JMP PUSH1
			mov edx, OFFSET Answer
			call WriteString
			JMP target
	case4:
		;division,/
		
			CMP al,'/'
			JNE case5
			mov edx,0
			mov ecx,0
			PUSH esi
			CMP stackindex,0
			jl nopop7
			mov esi,stackindex
			mov ecx,numstack[esi]
			sub stackindex,4
			jmp endpop7
			nopop7: stc
			endpop7:
				pop esi
			
			PUSH esi
			CMP stackindex,0
			jl nopop8
			mov esi,stackindex
			mov eax,numstack[esi]
			sub stackindex,4
			jmp endpop8
			nopop8: stc
			endpop8:
				pop esi
			
			DIV ecx
			
			call DumpRegs
			JMP PUSH1
	case5:
		; exchange top two elements,X
		
			CMP al,'X'

			JNE case6
			
			PUSH esi
			CMP stackindex,0
			jl nopopX1
			mov esi,stackindex
			mov eax,numstack[esi]
			sub stackindex,4
			jmp endpopX1
			nopopX1: stc
			endpopX1:
				pop esi
			PUSH esi
			CMP stackindex,0
			jl nopopX2
			mov esi,stackindex
			mov ebx,numstack[esi]
			sub stackindex,4
			jmp endpopX2
			nopopX2: stc
			endpopX2:
				pop esi
			PUSH esi 
			CMP stackindex,(stacksize-1)*4
			JGE nopushX3
			add stackindex,4
			mov esi,stackindex
			mov numstack[esi],eax
			mov edx, OFFSET Prompt3
					call WriteString
					mov edx, OFFSET numstack
					call WriteInt
					call Crlf
			add stackindex,4
			mov esi,stackindex
			mov eax,ebx
			mov numstack[esi],eax
			mov edx, OFFSET Prompt3
					call WriteString
					mov edx, OFFSET numstack
					call WriteInt
					call Crlf
			jmp endpushX3
			
			nopushX3: stc
					jmp target

			endpushX3:
					pop esi
					jmp target
	case6:
		;negate the top element stack,N
		
			CMP al,'N'
			JNE case7
				
				PUSH esi
				cmp stackindex,0
				jl endC
				mov esi,stackindex
				Neg eax
				sub stackindex,4
				cmp stackindex,0
				Pop esi
				jmp target

	case7:
		;Roll Stack Up,U
		
			CMP al,'U'
			JNE case8

 
 				mov esi,stackindex
				MOV ECX, ESI

;HOLD FIRST ITEM
				mov EBX,numstack[esi]
LOOP1U:
				SUB ESI, 4
				CMP ESI, 0
				JL LOOP2U

;MOVE EVERYTHING ONTO SYSTEM STACKhich
				mov eax,numstack[esi]
				push eax
				jMP loop1U

;EVERYTHING WAS PUSHED ONTO THE SYSTEM STACK
;POP THE LAST AND HOLD
LOOP2U:
				ADD ESI, 4
				MOV NUMSTACK[ESI],EBX				
LOOP3U:
				ADD ESI, 4
				Cmp esi,ecx
				Jg loop4U
				pop eax
				mov numstack[esi],eax
				JMP LOOP3U
LOOP4U: 
				jmp target
	case8:
		;Roll Stack Down,D
		
			CMP al,'D'
			JNE case9
				mov esi,stackindex
				MOV ECX, ESI

;MOVE EVERYTHING ONTO SYSTEM STACK
				loop1D:
				mov eax,numstack[esi]
				push eax
				SUB ESI, 4
				CMP ESI, 0
				jGE loop1D
;EVERYTHING WAS PUSHED ONTO THE SYSTEM STACK
;POP THE LAST AND HOLD
				POP EBX

;MOVE EVERYTHING (EXCEPT LAST ITEM) FROM SYSTEM STACK BACK TO STACK
				ADD ESI, 4
				loop2d:
				pop eax
				mov numstack[esi],eax
				ADD ESI, 4
				Cmp esi,ecx
				JL loop2d
;PUT LAST ITEM ON TOIP OF STACK
				MOV NUMSTACK[ESI],EBX				

				jmp target




	case9:
		;View entire stack,V
		
			CMP al,'V'	
			JNE case10
				mov ecx,stackindex
				loop1:
				PUSH esi
				cmp ecx,0
				jl endV
				mov esi,ecx
				mov eax,numstack[esi]
				mov temp,eax
				mov edx ,OFFSET temp
				call WriteInt
				call Crlf
				sub ecx,4
				cmp ecx,0
				
				jge loop1
			endV:	
				POP esi 
				jmp target
	
	


	case10:
		;Clear Stack,C
		
			CMP al,'C'
			JNE case11

			
				loop2:
				PUSH esi
				cmp stackindex,0
				jl endC
				mov esi,stackindex
				mov eax,0
				mov numstack[esi],eax
				mov edx ,OFFSET numstack
				call WriteInt
				call Crlf
				sub stackindex,4
				cmp stackindex,0

				
				jge loop2
			endC:	
				POP esi 
				jmp target

	case11:
		;Quit program,Q
		
			CMP al,'Q'
			JNE case12
			JE endcase

	case12:
		;Enter the number onto the stack,ENTER
		
			;CMP al,' '
			;JNE endcase
			mov edx,OFFSET buffer
			mov ecx,eax
			call ParseInteger32	
			add countd,1
		PUSH1:
			
			PUSH esi 
			CMP stackindex,(stacksize-1)*4
			JGE nopush
			add stackindex,4
			mov esi,stackindex
			mov numstack[esi],eax
			jmp endpush
			
			nopush: stc
					jmp target

			endpush:
					pop esi
					mov edx, OFFSET Prompt2
					call WriteString
					mov edx, OFFSET numstack
					call WriteInt
					call Crlf
					jmp target
endcase:

exit

main endp
end main
