.include "ADTF_Macros.s"

.file "ADTF_test.s"

.text
.global _main

_main:
	frame
	
	call test_str_len
	call test_str_equal
	call test_mem_cpy
	call test_str_cpy
	call test_str_cat
	
	movl $0, %eax
	leave
	ret

test_str_len:
	frame
	
	call_1 str_len, $str_1
	call_3 assert_number_equal, %eax, $3, $str_ass_2
	
	call_1 str_len, $str_4
	call_3 assert_number_equal, %eax, $6, $str_ass_3
	
	println $test_str_len_passed
	
	leave
	ret
	
test_str_equal:
	frame
	
	call_2 str_equals, $str_1, $str_2
	call_2 assert_true, %eax, $str_eq_1
	
	call_2 str_equals, $str_1, $str_3
	call_2 assert_false, %eax, $str_eq_2
	
	println $test_str_equal_passed
	
	leave
	ret
	
test_mem_cpy:
	frame
	
	pushl $0xDEADBEEF
	subl $4, %esp
	leal 4(%esp), %eax
	leal (%esp), %ebx
	call_3 mem_cpy, %eax, %ebx, $4
	
	movl 4(%esp), %eax
	movl (%esp), %ebx	
	call_3 assert_number_equal, %eax, %ebx, $str_ass_1
	
	println $test_mem_cpy_passed
	
	leave
	ret
	
test_str_cpy:
	frame
	
	call_2 str_cpy, $str_1, $buffer
	call_2 str_equals, $str_1, $buffer
	call_2 assert_true, %eax, $str_eq_1
	
	println $test_str_cpy_passed
	
	leave
	ret
	
test_str_cat:
	frame
	
	call_3 str_cat, $str_1, $str_3, $buffer
	call_2 str_equals, $str_5, $buffer
	call_2 assert_true, %eax, $str_eq_1
	
	println $test_str_cat_passed
	
	leave
	ret

assert_false:
	frame
	#arg0 = boolean
	#args1 = msg
	
	pushl 8(%ebp)
	negl (%esp)
	call_2 assert_true, (%esp), 12(%ebp)	
	
	leave
	ret	

assert_true:
	frame
	#arg0 = boolean
	#args1 = msg
	
	cmpl $0, 8(%ebp)
	je LT0_fail
	jmp LT0_succes
	LT0_fail:
	call_2 print_assert_and_exit, 12(%ebp), $1
	LT0_succes:
	
	leave
	ret
	
assert_number_equal:
	frame
	#arg0 = number 1
	#arg1 = number 2
	#arg2 = msg
	
	movl 8(%ebp), %eax
	cmpl %eax, 12(%ebp)
	jne LT1_fail
	jmp LT1_succes
	LT1_fail:
	call_2 print_assert_and_exit, 16(%ebp), $2
	LT1_succes:
	
	leave
	ret
	
print_assert_and_exit:
	frame
	#arg0 = message
	#arg1 = exit code
	
	print $assert_err
	print 8(%ebp)
	call_1 exit, 12(%ebp)
	
	leave
	ret
	
.data
buffer: .skip 50

test_string: .string "Test"

test_str_len_passed: .string "test_str_len passed!"
test_str_equal_passed: .string "test_str_equal passed!"
test_mem_cpy_passed: .string "test_mem_cpy passed!"
test_str_cpy_passed: .string "test_str_cpy passed!"
test_str_cat_passed: .string "test_str_cat passed!"

assert_err: .string "Assertiong error on: "

str_eq_1: .string "Bla == Bla"
str_eq_2: .string "Bla != Blo"
str_ass_1: .string "0xDEADBEEF == 0xDEADBEEF"
str_ass_2: .string "len(Bla) == 3"
str_ass_3: .string "len(Blaaaa) == 6"

str_1: .string "Bla"
str_2: .string "Bla"
str_3: .string "Blo"
str_4: .string "Blaaaa"
str_5: .string "BlaBlo"
	