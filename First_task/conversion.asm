extern _printf
extern _scanf
extern _exit


section .text
global _main

; ebp is for flags (in this order: space - 1, plus - 2, minus - 4, zero - 8)
; edi - length

parse_flags_string:	
	xor ebx, ebx
	xor edx, edx
	mov esi, [esp + 4]
	cycle_flags_string:
		mov ch, [esi]
		cmp ch, ' '
		jne not_space
		or ebx, 1
		jmp bit_is_setted
		not_space:
		cmp ch, '+'
		jne not_plus
		or ebx, 2
		jmp bit_is_setted
		not_plus:
		cmp ch, '-'
		jne not_minus
		or ebx, 4
		jmp bit_is_setted
		not_minus:
		cmp ch, '0'
		jne not_zero
		or ebx, 8
		jmp bit_is_setted
		not_zero:
		;it means, that it is the length
		cycle_length:
			mov ch, [esi]
			cmp ch, 0
			je everything_is_parsed
			xchg eax, edx
			mov ecx, 10
			mul ecx
			xchg eax, edx
			xor eax, eax
			mov al, [esi]
			sub al, '0'
			add edx, eax
			inc esi
			jmp cycle_length
		bit_is_setted:
		inc esi
		cmp ch, 0
		jne cycle_flags_string
	everything_is_parsed:	
	mov edi, edx
	mov ebp, ebx
	ret

get_string_length:
	; push the length to ecx
	mov esi, [esp + 4]
	push eax
	push ebx
	mov ecx, -1
	cycle_string_length:
		inc ecx
		mov bh, [esi]
		inc esi
		cmp bh, 0
		jne cycle_string_length

	pop ebx
	pop eax
	ret	

reverse_string:
	mov esi, [esp + 4]
	push esi
	;get string length to ecx
	sub esp, 8
	push esi
	call get_string_length
	add esp, 12
	pop esi
	mov edx, esi
	add edx, ecx
	dec edx
	cycle_reverse_string:
		cmp ecx, 1
		jle final_cycle_reverse
		push ebx
		mov bl, [esi]
		mov bh, [edx]
		mov [esi], bh
		mov [edx], bl
		pop ebx
		inc esi
		sub ecx, 2
		dec edx
		jmp cycle_reverse_string
	final_cycle_reverse:
	ret

make_to_lower_case:
	mov esi, [esp + 4]
	push eax
	push ebx
	cycle_make_to_lower_case:
		mov bh, [esi]
		cmp bh, 0
		je final_cycle_make_to_lower_case
		or bh, 0x20
		mov [esi], bh
		inc esi
		jmp cycle_make_to_lower_case
	final_cycle_make_to_lower_case:
	pop ebx
	pop eax
	ret		

incorrect_number_of_arguments:
	sub esp, 8
	push number_args_error
	call _printf
	add esp, 12
	sub esp, 12
	call _exit

multiply_on_sixteen:
	mov esi, [esp + 4]
	push esi
	; if we have a classic order in input
	sub esp, 4
	push esi
	call reverse_string
	add esp, 8
	pop esi
	xor dx, dx ; remainer
	cycle_multiply:
		mov bl, [esi]
		cmp bl, 0
		je finish_cycle_multiply
		xor ebx, ebx
		mov bl, [esi]
		sub bl, '0'
		mov al, bl
		mov bl, 16
		mul bl
		add dx, ax
		mov ax, dx
		mov bl, 10
		div bl
		add ah, '0'
		mov [esi], ah
		mov dl, al
		inc esi
		jmp cycle_multiply
	finish_cycle_multiply:
	cmp dx, 0
	je not_need_to_add_remainer_to_the_string
	cmp dx, 10
	jl one_digit_remainer
	mov ax, dx
	mov bl, 10
	div bl
	add ah, '0'
	mov [esi], ah
	mov ah, '1'
	mov [esi + 1], ah
	jmp not_need_to_add_remainer_to_the_string
	one_digit_remainer:
	add dx, '0'
	mov [esi], dx
	not_need_to_add_remainer_to_the_string:
	; if we need to reverse string to output
	sub esp, 8
	push total_ans_string
	call reverse_string
	add esp, 12
	ret

add_small_number_to_big_number:
	mov esi, [esp + 4]
	mov edx, [esp + 8]
	push edx 
	push esi
	; if we have a classic order in input
	push esi
	call reverse_string
	add esp, 4
	pop esi
	pop edx ; remainer
	mov ecx, total_ans_string
	cycle_big_add:
		mov bl, [esi]
		cmp bl, 0
		je finish_cycle_big_add
		mov bl, [esi]
		sub bl, '0'
		mov ax, dx
		add al, bl
		xor bl, bl
		mov bl, 10
		div bl
		
		add ah, '0'
		mov [ecx], ah
		
		mov dl, al
		inc esi
		inc ecx
		jmp cycle_big_add
	finish_cycle_big_add:
	cmp dx, 0
	je not_need_to_add_rem_to_add
	add dx, '0'
	mov [ecx], dx
	not_need_to_add_rem_to_add:
	; if we need to reverse string to output
	sub esp, 8
	push total_ans_string
	call reverse_string
	add esp, 12
	ret

convert_positive_dexnumber_to_decimal:
	mov eax, total_ans_string
	mov bl, '0'
	mov [eax], bl
	mov esi, [esp + 4]
	cycle_convert_positive_dexnumber_to_decimal:
		mov bl, [esi]
		cmp bl, 0
		je finish_cycle_convert_positive_dexnumber_to_decimal
		push esi
		mov eax, total_ans_string
		sub esp, 4
		push eax
		call multiply_on_sixteen
		add esp, 8
		pop esi
		xor ebx, ebx
		mov bl, [esi]
		cmp bl, 'a'
		jl is_not_letter
		sub bl, 39
		is_not_letter:
		sub bl, '0'
		push esi
		mov eax, total_ans_string
		push ebx
		push eax
		call add_small_number_to_big_number
		add esp, 8
		pop esi
		inc esi
		jmp cycle_convert_positive_dexnumber_to_decimal
	finish_cycle_convert_positive_dexnumber_to_decimal:
	ret

parse_input_number:
	mov esi, [esp + 4]
	mov bl, [esi]
	cmp bl, '-'
	jne not_have_minus
	mov ecx, sign
	mov [ecx], bl
	inc esi
	not_have_minus:
	mov ecx, input_number

	cycle_parse_input_number:
		mov bl, [esi]
		cmp bl, 0
		je final_cycle_parse_input_number
		mov [ecx], bl
		inc esi
		inc ecx
		jmp cycle_parse_input_number
	
	final_cycle_parse_input_number:

	mov eax, input_number
	sub esp, 8
	push eax
	call make_to_lower_case
	add esp, 12
	mov eax, input_number
	sub esp, 8
	push eax
	call get_string_length
	add esp, 12

	cmp ecx, 32
	jne not_negative
	mov eax, input_number
	mov bl, [eax]
	cmp bl, '8'
	jge is_negative
	jmp not_negative
	is_negative:
	
	mov ecx, sign
	mov bl, [ecx]
	cmp bl, '-'
	je need_to_set_plus
	mov bl, '-'
	mov [ecx], bl
	jmp final_setting_sign
	need_to_set_plus:
	mov bl, '+'
	mov [ecx], bl
	final_setting_sign:

	mov ecx, input_number
	cycle_inverse_number:
		mov bl, [ecx]
		cmp bl, 0
		je final_cycle_inverse_number
		cmp bl, 'a'
		jl not_letter_in_cur_pos
		sub bl, 39
		not_letter_in_cur_pos:

		sub bl, '0'
		mov dl, 15
		sub dl, bl
		cmp dl, 10
		jl set_not_letter
		add dl, 39
		add dl, '0'
		jmp final_setting_letter_in_inverse
		set_not_letter:
		add dl, '0'
		final_setting_letter_in_inverse:
		 
		mov [ecx], dl

		inc ecx
		jmp cycle_inverse_number
	
	final_cycle_inverse_number:
	
	mov eax, input_number
	sub esp, 8
	push eax
	call get_string_length
	add esp, 12

	mov edx, input_number
	add edx, ecx
	dec edx
	cycle_add_one:
		mov bl, [edx]
		cmp bl, 0
		je final_cycle_add_one
		cmp bl, 'f'
		je is_f_here
		add bl, 1
		cmp bl, ':'
		jne not_need_to_set_a_here
		mov bl, 'a'
		not_need_to_set_a_here:
		mov [edx], bl
		jmp final_cycle_add_one		

		is_f_here:
		mov bl, '0'
		mov [edx], bl
		dec edx
		jmp cycle_add_one
	final_cycle_add_one
	not_negative:
	ret

format_ans:
	sub esp, 8
	push total_ans_string
	call reverse_string
	add esp, 12

	sub esp, 8
	push total_ans_string
	call get_string_length
	add esp, 12

	cmp ecx, 1
	jne not_zero_number

	mov bl, [total_ans_string]
	cmp bl, '0'
	jne not_zero_number
	mov bl, '+'
	mov [sign], bl

	not_zero_number:

	mov bl, [sign]
	cmp bl, '+'
	je go_is_positive
	mov eax, total_ans_string
	add eax, ecx
	mov [eax], bl
	jmp finish_sign_format
	go_is_positive:
	push ebp
	and ebp, 2
	cmp ebp, 2
	je have_plus_sign
	pop ebp
	push ebp
	and ebp, 1
	cmp ebp, 1
	je have_space_sign
	pop ebp
	mov bl, 0
	mov [sign], bl
	jmp finish_sign_format
	
	have_plus_sign:
	pop ebp
	mov eax, total_ans_string
	add eax, ecx
	mov bl, '+'
	mov [eax], bl
	mov [sign], bl
	jmp finish_sign_format

	have_space_sign:
	pop ebp
	mov eax, total_ans_string
	add eax, ecx
	mov bl, ' '
	mov [eax], bl
	mov [sign], bl
	jmp finish_sign_format
	finish_sign_format:
	
	sub esp, 8
	push total_ans_string
	call get_string_length
	add esp, 12
	cmp edi, ecx
	jle finish_all_formatting

	push ebp
	and ebp, 4
	cmp ebp, 4
	je have_minus_for_formatting
	pop ebp
	push ebp
	and ebp, 8
	cmp ebp, 8
	je have_zero_for_formatting
	pop ebp
	mov edx, total_ans_string
	add edx, ecx
	sub edi, ecx
	add_spaces_to_string_format:
		mov bl, ' '
		mov [edx], bl
		inc edx
		dec edi
		cmp edi, 0
		jne add_spaces_to_string_format

	jmp finish_all_formatting
	have_minus_for_formatting:
	pop ebp
	push ecx
	sub esp, 4
	push total_ans_string
	call reverse_string
	add esp, 8
	pop ecx
	mov edx, total_ans_string
	add edx, ecx
	sub edi, ecx
	minus_add_spaces_to_string_format:
		mov bl, ' '
		mov [edx], bl
		inc edx
		dec edi
		cmp edi, 0
		jne minus_add_spaces_to_string_format

	jmp not_need_to_final_reverse
	have_zero_for_formatting:
	pop ebp
	mov edx, total_ans_string
	add edx, edi
	dec edx
	mov bl, [sign]
	mov [edx], bl
	mov edx, total_ans_string
	add edx, ecx
	sub edi, ecx

	mov bl, [sign]
	cmp bl, 0
	je not_have_any_sign
	dec edx
	not_have_any_sign:

	add_zeros_to_string_format:
		mov bl, '0'
		mov [edx], bl
		inc edx
		dec edi
		cmp edi, 0
		jne add_zeros_to_string_format
	jmp finish_all_formatting

	finish_all_formatting:
	sub esp, 8
	push total_ans_string
	call reverse_string
	add esp, 12

	not_need_to_final_reverse:


	ret

_main:
	mov eax, [esp + 4] ; argc
	cmp eax, 3
	jg incorrect_number_of_arguments
	cmp eax, 1
	jle incorrect_number_of_arguments
	cmp eax, 2
	je one_argument
	
	mov eax, [esp + 8] ; argv
	mov eax, [eax + 4] ; argv[0]
	sub esp, 8
	push eax
	call parse_flags_string
	add esp, 12


	mov eax, [esp + 8] ; argv
	mov eax, [eax + 8] ; argv[1]
	sub esp, 8
	push eax
	call parse_input_number
	add esp, 12
	jmp finish_args
	one_argument:
	mov eax, [esp + 8] ; argv
	mov eax, [eax + 4] ; argv[0]
	sub esp, 8
	push eax
	call parse_input_number
	add esp, 12

	finish_args:
	sub esp, 8
	push input_number
	call convert_positive_dexnumber_to_decimal
	add esp, 12

	sub esp, 8
	push total_ans_string
	call format_ans
	add esp, 12

	sub esp, 4
	push total_ans_string
	push format_output
	call _printf
	add esp, 12
	
	sub esp, 12
	call _exit


section .data
	total_ans_string times 1000 db 0, 0
	input_number times 1000 db 0, 0
	sign db "+"
section .rodata
	format_output db "%s", 0
	format_int_output db "%d", 0
	number_args_error db "Incorrect number of arguments", 0
	end