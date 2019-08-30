.include "ADTF_Macros.s"
.file "ADTF_Kernel_C_Unix.s"

#I thought the following might be platform specific.
#I searched around for how to use win32 interupts, but they are platform specific too.
#I was adviced to use the API (e.g. through calls to _system)
#
#If you want to port this game, you should re-implement the below functions
#I tried to keep things simple

.text
.global	print_string
.global print_number
.global scan_number
.global exit
.global pause
.global clear_screen
.global save_bytes
.global load_bytes
.global print_error

print_string:
	frame
	#arg0 = string ptr
	
	call_1 printf, 8(%ebp)
	
	leave
	ret
	
print_number:
	frame
	#arg0 = number
	
	call_2 printf, $number_format, 8(%ebp)
	
	leave
	ret
	
scan_number:
	frame
	#arg0 = buffer ptr
	
	call_2 scanf, $number_format, 8(%ebp)
	
	leave
	ret
	
exit:
	frame
	#arg0 = exit code
	
	call_1 exit, 8(%ebp)
	
	leave
	ret
	
pause:
	frame
	
	call_1 printf, $pause_string
	
	leave
	ret
	
clear_screen:
	frame
	
	leave
	ret
	
save_bytes:
	frame
	#arg0 = source pointer
	#arg1 = source length (in bytes)
	#arg2 = destination file name
	#return = if succesful
	
	call_2 fopen, 16(%ebp), $write_txt
	cmpl $0, %eax
	je LK1_fail
	pushl %eax	#save 1 - file pointer
	
	call_4 fwrite 8(%ebp), $1, 12(%ebp), %eax
	pushl %eax	#save 2 - bytes written
	
	movl 4(%esp), %eax
	call_1 fclose, %eax
	
	popl %eax	#restore 2	
	cmpl 12(%ebp), %eax
	jne LK1_fail
		movl $1, %eax
		jmp LK1_end
	LK1_fail:
		call print_error
		movl $0, %eax
	LK1_end:
	
	leave
	ret
	
load_bytes:
	frame
	#arg0 = destination pointer
	#arg1 = destination length (in bytes)
	#arg2 = source file name
	#return = if succesful
	
	call_2 fopen, 16(%ebp), $read_txt
	cmpl $0, %eax
	je LK2_fail
	pushl %eax	#save 1 - file pointer
	
	call_4 fread 8(%ebp), $1, 12(%ebp), %eax
	pushl %eax	#save 2 - bytes written
	
	movl 4(%esp), %eax
	call_1 fclose, %eax
	
	popl %eax	#restore 2	
	cmpl 12(%ebp), %eax
	jne LK2_fail
		movl $1, %eax
		jmp LK2_end
	LK2_fail:
		call print_error
		movl $0, %eax
	LK2_end:
	
	leave
	ret

print_error:
	frame
	#arg0 = text to prepend
	
	call_1 perror, 8(%ebp)
	
	leave
	ret
	
.data
write_txt: .string "w"
read_txt: .string "r"
cls: .string "cls"
number_format: .string "%d"
pause_string: .string "============================="	
	