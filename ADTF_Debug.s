.include "ADTF_Debug_gen.s"
.file "ADTF_Debug.s"

.text
.global get_function_name
.global print_hex

print_tables:
	frame
	
	call_3 print_table, $function_table, function_table_size, $function_table_txt
	print $newline
	call_3 print_table, $event_table, event_table_size, $event_table_txt
	print $newline
	call_3 print_table, $option_table, option_table_size, $option_table_txt
	
	leave
	ret

print_table:
	frame
	#arg0 = table pointer
	#arg1 = table size
	#arg2 = table name char*
	
	movl 12(%ebp), %ebx
	movl $0, %esi
	
	println 16(%ebp)
	LD0_start:
		cmpl %ebx, %esi
		jge	LD0_end
		
		print $four_space
		call_2 get_table_record, 8(%ebp), %esi
		pushl %eax	#save 1 - record ptr
		
		call_2 get_member, %eax, $0
		pushl %eax 	#save 2 - entry name
		print %eax
		
		popl %eax	#restore 2
		call_1 str_len, %eax
		call_2 pad_spaces, %eax, $35
		
		popl %eax	#restore 1
		call_2 get_member, %eax, $1
		call_1 print_hex, %eax
		
		print $newline
		
		incl %esi
		jmp LD0_start
	LD0_end:
	
	leave
	ret
	
pad_spaces:
	frame
	#arg0 = number of spaces not to print
	#arg1 = max spaces
	
	pushl %esi				#save esi, to restore later
	
	movl 8(%ebp), %esi
	
	LD1_start:
		cmpl 12(%ebp), %esi
		jge LD1_end	
		print $space
		incl %esi
		jmp LD1_start
	LD1_end:
	
	popl %esi
	
	leave
	ret
	
print_hex:
	frame
	#arg 0 = number
	
	print $zero_x;
	
	pushl %esi
	pushl %ebx
	
	movl $1, %esi	
	LD3_start:	
		cmpl $9, %esi
		jge LD3_end
		
		movl 8(%ebp), %eax
		shift_by roll, %esi, %eax, $4, i
		andl $0xF, %eax
		
		movl $hex_table, %ebx
		leal (%ebx,%eax,2), %eax
		print %eax
	
		incl %esi
		jmp LD3_start
	LD3_end:
	
	popl %ebx
	popl %esi
	
	leave
	ret
	
debug_out:
	frame
	#arg0 = pointer
	#arg1 = char* to value
	
	print $left_bracket
	print 12(%ebp)
	print $colon
	call_1 print_hex, 8(%ebp)
	print $right_bracket
	
	leave
	ret

get_function_name:
	frame
	#arg0 = function pointer
	
	call_3 get_name_from_table, $function_table, function_table_size, 8(%ebp)
	
	leave
	ret
	
get_event_name:
	frame
	#arg0 = event pointer
	
	call_3 get_name_from_table, $event_table, event_table_size, 8(%ebp)
	
	leave
	ret
	
get_option_name:
	frame
	#arg0 = option pointer
	
	call_3 get_name_from_table, $option_table, option_table_size, 8(%ebp)
	
	leave
	ret
	
get_table_record:
	frame
	#arg0 = table pointer
	#arg1 = index
	
	pushl %esi
	
	movl 12(%ebp), %esi
	shll $1, %esi
	movl 8(%ebp), %eax
	leal (%eax,%esi,4), %eax
	
	popl %esi
	
	leave
	ret
	
get_name_from_table:
	frame
	#arg0 = table pointer
	#arg1 = table length
	#arg2 = function pointer
	#return = char* to function name, or to string "unknown"
	
	pushl %ebx
	pushl %esi
	
	movl 12(%ebp), %ebx
	pushl 8(%ebp)
	movl $0, %esi
	
	LD2_start:	
		cmpl %ebx, %esi
		jge	LD2_fail
		
		call_2 get_table_record, 8(%ebp), %esi
		movl %eax, %edx
		call_2 get_member, %edx, $1
		cmpl 16(%ebp), %eax
		je LD2_return
		incl %esi
		jmp LD2_start
	LD2_return:
		call_2 get_member, %edx, $0
		jmp LD2_final
	LD2_fail:
		movl $unknown, %eax
	LD2_final:
	
	addl $4, %esp
	popl %esi
	popl %ebx
	
	leave
	ret
	
print_iteration:
	frame
	#arg0 = iterator
	#arg1 = bound
	
	print $iteration
	printNum 8(%ebp)
	print $of
	printNum 12(%ebp)
	print $newline
	
	call pause
	
	leave
	ret
	
.data

left_bracket: .string "["
right_bracket: .string "]"
colon: .string " @ "
of: .string " of "
zero_x: .string "0x"

unknown: .string "unknown"
function_table_txt: .string "Functions:"
event_table_txt: .string "Events:"
option_table_txt: .string "Options:"

hex_table: .string "0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"

