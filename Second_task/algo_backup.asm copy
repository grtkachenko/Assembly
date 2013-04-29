extern _printf
extern _exit

section .text
align 16
global _IDCT
_IDCT:
    sub esp, 8
	push text
	call _printf
	add esp, 12
    ret

global _FDCT
_FDCT:
    rdtsc
    mov edi, eax
 	

;_____________________________________________________	
 	mov eax, helpa
 	mov ebx, _0000
 	mov cx, 16
 	loopzerohelpa:
 		movups xmm0, [ebx]
 		movups [eax], xmm0
 		add eax, 16
 		dec cx
	 	jnz loopzerohelpa

;_____________________________________________________
	mov eax, [esp + 4] 
	mov ebx, precalcD
	mov esi, helpa
	mov cx, 8
	row_loop_dct:
		mov dx, 8
		
		help_row_loop:
			; helpa[dx][cx] += scal_mul(a[cx], precalD[dx])
			movss xmm2, [esi]
			
			movups xmm0, [eax]
			movups xmm1, [ebx]
			dpps xmm0, xmm1, 0xff
			addps xmm2, xmm0
			

			movups xmm0, [eax + 16]
			movups xmm1, [ebx + 16]
			dpps xmm0, xmm1, 0xff
			addps xmm2, xmm0
			movss [esi], xmm2

			add esi, 32
			add ebx, 32
			dec dx
			cmp dx, 0
			jne help_row_loop

		add eax, 32
		sub esi, 252
		sub ebx, 256
		dec cx
		jnz row_loop_dct

;_____________________________________________________
 	mov eax, [esp + 8]
	mov ebx, _0000
 	mov cx, 16
 	loopzeroans:
 		movups xmm0, [ebx]
 		movntps [eax], xmm0
 		add eax, 16
 		dec cx
	 	jnz loopzeroans
;_____________________________________________________
	mov eax, helpa
	mov ebx, precalcD
	mov esi, [esp + 8]

	mov dx, 8
	col_loop_dct:
		mov cx, 8
		help_col_loop:
			;a[u][j] += helpa[j][i] * precalcD[u][i];
			movss xmm2, [esi]

			movups xmm0, [eax]
			movups xmm1, [ebx]
			dpps xmm0, xmm1, 0xff
			addps xmm2, xmm0
			

			movups xmm0, [eax + 16]
			movups xmm1, [ebx + 16]
			dpps xmm0, xmm1, 0xff
			addps xmm2, xmm0
			movss [esi], xmm2

			add esi, 32
			add ebx, 32
			dec cx
			jnz help_col_loop

		add eax, 32
		sub esi, 252
		sub ebx, 256
		dec dx
		cmp dx, 0
		jne col_loop_dct
		 	

;_____________________________________________________


	
	rdtsc
    sub eax, edi
     	
    sub esp, 4
    push eax
    push format_d
    call _printf
    add esp, 12
    
    ret
section .data
	helpa times 64 dd 0.0
	    
section .rodata
	precalcD dd 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000 
		 	 dd 0.17337998, 0.14698445, 0.09821187, 0.03448742, -0.03448742, -0.09821187, -0.14698445, -0.17337998 
		 	 dd 0.16332037, 0.06764951, -0.06764951, -0.16332037, -0.16332037, -0.06764951, 0.06764951, 0.16332037 
		 	 dd 0.14698445, -0.03448742, -0.17337998, -0.09821187, 0.09821187, 0.17337998, 0.03448742, -0.14698445 
		 	 dd 0.12500000, -0.12500000, -0.12500000, 0.12500000, 0.12500000, -0.12500000, -0.12500000, 0.12500000 
		 	 dd 0.09821187, -0.17337998, 0.03448742, 0.14698445, -0.14698445, -0.03448742, 0.17337998, -0.09821187 
		 	 dd 0.06764951, -0.16332037, 0.16332037, -0.06764951, -0.06764951, 0.16332037, -0.16332037, 0.06764951 
		 	 dd 0.03448742, -0.09821187, 0.14698445, -0.17337998, 0.17337998, -0.14698445, 0.09821187, -0.03448742
	
	precalcI dd 1.41421356, 1.38703985, 1.30656296, 1.17587560, 1.00000000, 0.78569496, 0.54119610, 0.27589938 
		 	 dd 1.41421356, 1.17587560, 0.54119610, -0.27589938, -1.00000000, -1.38703985, -1.30656296, -0.78569496
			 dd 1.41421356, 0.78569496, -0.54119610, -1.38703985, -1.00000000, 0.27589938, 1.30656296, 1.17587560 
			 dd 1.41421356, 0.27589938, -1.30656296, -0.78569496, 1.00000000, 1.17587560, -0.54119610, -1.38703985 
			 dd 1.41421356, -0.27589938, -1.30656296, 0.78569496, 1.00000000, -1.17587560, -0.54119610, 1.38703985 
			 dd 1.41421356, -0.78569496, -0.54119610, 1.38703985, -1.00000000, -0.27589938, 1.30656296, -1.17587560 
			 dd 1.41421356, -1.17587560, 0.54119610, 0.27589938, -1.00000000, 1.38703985, -1.30656296, 0.78569496
			 dd 1.41421356, -1.38703985, 1.30656296, -1.17587560, 1.00000000, -0.78569496, 0.54119610, -0.27589938 

	_0000 dd 0.0, 0.0, 0.0, 0.0
	_1 dd 3.1, 3.1, 3.1, 3.1
	_16 dd 16.0	

		text db "Hello, world ASSEMBLER!", 10, 0
	format_f db "%f", 0
    format_d db "%d", 10, 0
	format_s db "%s", 0			 
	end
