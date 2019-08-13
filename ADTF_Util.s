.include "ADTF_Macros.s"

.file "ADTF_Util.s"

.text
.global str_equals
.global get_member
.global set_member
.global is_between
.global mem_cpy
.global str_len
.global str_cpy
.global str_cat
.global get_num
.global get_num_between
.global call_if_not_zero

str_equals:
	frame
	#arg 0 = str ptr 1
	#arg 1 = str ptr 2
	#return = boolean, if equal
	#Note: assuming 1 byte per char
	
	call_1 str_len, 8(%ebp)
	movl %eax, %ebx
	call_1 str_len, 12(%ebp)
	cmpl %eax, %ebx
	jne LU0_fail
	
	pushl %esi	#save
	
	movl $0, %esi
	
	LU0_start:		
		movl 8(%ebp), %eax
		movl 12(%ebp), %ebx
		movb (%eax,%esi,1), %al
		cmpb %al, (%ebx,%esi,1)
		jne LU0_fail
		cmpb %al, terminator
		je LU0_succes
		incl %esi
		jmp LU0_start
	LU0_fail:
		movl $0, %eax
		jmp LU0_end
	LU0_succes:
		movl $1, %eax
	LU0_end:
	
	popl %esi	#restore
	
	leave
	ret

str_len:
	frame
	#arg0 = char*
	#return = length in chars (- terminator)
	#Note: assuming 1 byte per char
	
	pushl %esi
	pushl %ebx
	
	movl $0, %esi
	movl 8(%ebp), %ebx
	
	LU2_start:		
		movl 8(%ebp), %ebx
		movb (%ebx,%esi,1), %al
		cmpb terminator, %al
		je LU2_end
		incl %esi
		jmp LU2_start
	LU2_end:
	movl %esi, %eax
	
	popl %ebx
	popl %esi
	
	leave
	ret
	
#Note, stack memory buffer pointer should be passed after subbing
mem_cpy:
	frame
	#arg0 = source
	#arg1 = destination
	#arg2 = length in bytes
	
	#potential optimization: copy 4 bytes at a time, untill less than 4 are left
	
	pushl %esi
	pushl %ebx
	
	movl $0, %esi
	
	LU3_start:
		cmpl 16(%ebp), %esi
		jge LU3_end
		movl 8(%ebp), %ebx
		movb (%ebx,%esi,1), %al
		movl 12(%ebp), %ebx
		movb %al, (%ebx,%esi,1)
		incl %esi
		jmp LU3_start
	LU3_end:
	
	popl %ebx
	popl %esi
	
	leave
	ret
	
str_cpy:
	frame
	#arg0 = char* 1
	#arg1 = target buffer (in lack of dynamic allocation)
	#return = length of string (as per str_len)
	
	call_1 str_len, 8(%ebp)
	pushl %eax
	addl $1, %eax			#for terminator
	call_3 mem_cpy, 8(%ebp), 12(%ebp), %eax
	popl %eax
	
	leave
	ret
	
str_cat:
	frame
	#arg0 = char* 1
	#arg1 = char* 2
	#arg2 = target buffer (in lack of dynamic allocation)
	
	call_2 str_cpy, 8(%ebp), 16(%ebp)
	movl 16(%ebp), %ebx
	addl %eax, %ebx		#add str_len(arg0) to buffer ptr
	call_2 str_cpy, 12(%ebp), %ebx
	
	leave
	ret

get_member:
	frame
	#arg0 = stuct pointer
	#arg1 = member index
	#return = member value
	
	pushl %ebx
	
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	movl (%eax,%ebx,4), %eax
	
	popl %ebx
	
	leave
	ret
	
set_member:
	frame
	#arg0 = stuct pointer
	#arg1 = member index
	#arg2 = value to set_member
	
	pushl %ebx
	pushl %ecx
	
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	movl 16(%ebp), %ecx
	movl %ecx, (%eax,%ebx,4)
	
	popl %ecx
	popl %ebx
	
	leave
	ret
	
is_between:
	frame
	#arg0 = number
	#arg1 = lower bound inclusive
	#arg2 = upper bound exclusive
	#return = boolean, if was between
	
	movl 8(%ebp), %eax
	cmpl 12(%ebp), %eax
	jl LU1_fail	
	movl 8(%ebp), %eax
	cmpl 16(%ebp), %eax
	jge LU1_fail
	jmp LU1_succes
	
	LU1_fail:
	movl $0, %eax
	jmp LU1_end
	
	LU1_succes:
	movl $1, %eax
	LU1_end:
	
	leave
	ret
	
get_num:
	frame
	
	print $num_query
	
	subl $4, %esp
	call_1 scan_number, %esp
	movl (%esp), %eax
	addl $4, %esp
	
	leave
	ret
	
get_num_between:
	frame
	#arg0 = lower bound inclusive
	#arg1 = upper bound exclusive

	jmp LU4_start
	LU4_retry:
		println $invalid_number
	LU4_start:
		call get_num
		cmpl 8(%ebp), %eax
		jl LU4_retry
		cmpl 12(%ebp), %eax
		jge LU4_retry
	LU4_end:
	
	leave
	ret

call_if_not_zero:
	frame
	#arg0 = pointer to call
	
	cmpl $0, 8(%ebp)
	je LU5_skip
	.ifdef DEBUG
	print $calling
	call_1 get_function_name, 8(%ebp)
	println %eax
	.endif	
	call *8(%ebp)
	
	LU5_skip:
	leave
	ret
	
.data
calling: .string "Calling: "
invalid_number: .string "Invalid number"
num_query: .string "Input a number: "
