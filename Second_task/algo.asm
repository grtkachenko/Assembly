extern _printf
extern _exit

section .text
global _IDCT
_IDCT:
    rdtsc
    mov [start], eax
;__________________________________________________
    mov eax, [esp + 4] 
    mov edi, [esp + 12]
    mov esi, [esp + 8]
    mov ebx, precalcI
    big_loop_idct:
;_________________________
	push esi
	mov esi, helpa
	mov cx, 8
	row_loop_idct:
		movaps xmm0, [eax]
		mov dx, 8
		movaps xmm3, [eax + 16]

		help_row_loop_idct:
			; helpa[dx][cx] += scal_mul(a[cx], precalD[dx])
			add esi, 32
			movaps xmm2, [ebx]
			dpps xmm2, xmm0, 0xff
			
			dec dx
			movaps xmm4, [ebx + 16]
			dpps xmm4, xmm3, 0xff
			addps xmm2, xmm4
			movss [esi - 32], xmm2
			
			add ebx, 32
			cmp dx, 0
			jne help_row_loop_idct

		add eax, 32
		sub esi, 252
		sub ebx, 256
		dec cx
		jnz row_loop_idct
	pop esi

;_________________________
	push eax
	mov eax, helpa
	mov dx, 8
	col_loop_idct:
		movaps xmm0, [eax]
		mov cx, 8
		movaps xmm3, [eax + 16]
		help_col_loop_idct:
			;a[u][j] += helpa[j][i] * precalcD[u][i];
			movaps xmm2, [ebx]
			dpps xmm2, xmm0, 0xff
			add esi, 32
			
			movaps xmm4, [ebx + 16]
			dpps xmm4, xmm3, 0xff
			addps xmm2, xmm4
			movss [esi - 32], xmm2
			
			add ebx, 32
			dec cx
			jnz help_col_loop_idct

		add eax, 32
		sub esi, 252
		sub ebx, 256
		dec dx
		cmp dx, 0
		jne col_loop_idct
	add esi, 224
	pop eax

;_________________________

    dec edi
    cmp edi, 0
    jne big_loop_idct
;__________________________________________________
	
	rdtsc
	mov edi, [start]
    sub eax, edi
     	
    sub esp, 4
    push eax
    push format_d
    call _printf
    add esp, 12
    ret

;=================================================================================================================================================================
global _FDCT
_FDCT:
    rdtsc
    mov [start], eax
;__________________________________________________
    mov eax, [esp + 4] 
    mov edi, [esp + 12]
    mov esi, [esp + 8]
    mov ebx, precalcD
    big_loop_fdct:
;_________________________
	push esi
	mov esi, helpa
	mov cx, 8
	row_loop_dct:
		movaps xmm0, [eax]
		mov dx, 8
		movaps xmm3, [eax + 16]

		help_row_loop:
			add esi, 32
			movaps xmm2, [ebx]
			dpps xmm2, xmm0, 0xff
			
			dec dx
			movaps xmm4, [ebx + 16]
			dpps xmm4, xmm3, 0xff
			addps xmm2, xmm4
			movss [esi - 32], xmm2
			
			add ebx, 32
			cmp dx, 0
			jne help_row_loop

		add eax, 32
		sub esi, 252
		sub ebx, 256
		dec cx
		jnz row_loop_dct
	pop esi

;_________________________
	push eax
	mov eax, helpa
	mov dx, 8
	col_loop_dct:
		movaps xmm0, [eax]
		mov cx, 8
		movaps xmm3, [eax + 16]
		help_col_loop:
			movaps xmm2, [ebx]
			dpps xmm2, xmm0, 0xff
			add esi, 32
			
			movaps xmm4, [ebx + 16]
			dpps xmm4, xmm3, 0xff
			addps xmm2, xmm4
			movss [esi - 32], xmm2
			
			add ebx, 32
			dec cx
			jnz help_col_loop

		add eax, 32
		sub esi, 252
		sub ebx, 256
		dec dx
		cmp dx, 0
		jne col_loop_dct
	add esi, 224
	pop eax

;_________________________

    dec edi
    cmp edi, 0
    jne big_loop_fdct
;__________________________________________________
	
	rdtsc
	mov edi, [start]
    sub eax, edi
     	
    sub esp, 4
    push eax
    push format_d
    call _printf
    add esp, 12
    
    ret

section .data
	helpa times 64 dd 0.
	start dw 0

section .rodata
	align 16
	precalcD dd 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000, 0.12500000 
		 	 dd 0.17337998, 0.14698445, 0.09821187, 0.03448742, -0.03448742, -0.09821187, -0.14698445, -0.17337998 
		 	 dd 0.16332037, 0.06764951, -0.06764951, -0.16332037, -0.16332037, -0.06764951, 0.06764951, 0.16332037 
		 	 dd 0.14698445, -0.03448742, -0.17337998, -0.09821187, 0.09821187, 0.17337998, 0.03448742, -0.14698445 
		 	 dd 0.12500000, -0.12500000, -0.12500000, 0.12500000, 0.12500000, -0.12500000, -0.12500000, 0.12500000 
		 	 dd 0.09821187, -0.17337998, 0.03448742, 0.14698445, -0.14698445, -0.03448742, 0.17337998, -0.09821187 
		 	 dd 0.06764951, -0.16332037, 0.16332037, -0.06764951, -0.06764951, 0.16332037, -0.16332037, 0.06764951 
		 	 dd 0.03448742, -0.09821187, 0.14698445, -0.17337998, 0.17337998, -0.14698445, 0.09821187, -0.03448742
	
	align 16
	precalcI dd 1.00000000, 1.38703985, 1.30656296, 1.17587560, 1.00000000, 0.78569496, 0.54119610, 0.27589938 
			 dd 1.00000000, 1.17587560, 0.54119610, -0.27589938, -1.00000000, -1.38703985, -1.30656296, -0.78569496
			 dd 1.00000000, 0.78569496, -0.54119610, -1.38703985, -1.00000000, 0.27589938, 1.30656296, 1.17587560
			 dd 1.00000000, 0.27589938, -1.30656296, -0.78569496, 1.00000000, 1.17587560, -0.54119610, -1.38703985 
			 dd 1.00000000, -0.27589938, -1.30656296, 0.78569496, 1.00000000, -1.17587560, -0.54119610, 1.38703985
			 dd 1.00000000, -0.78569496, -0.54119610, 1.38703985, -1.00000000, -0.27589938, 1.30656296, -1.17587560
			 dd 1.00000000, -1.17587560, 0.54119610, 0.27589938, -1.00000000, 1.38703985, -1.30656296, 0.78569496 
			 dd 1.00000000, -1.38703985, 1.30656296, -1.17587560, 1.00000000, -0.78569496, 0.54119610, -0.27589938

    format_d db "%d", 10, 0
	end
