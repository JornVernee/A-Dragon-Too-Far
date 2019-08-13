.file "ADTF_Macros.s"

#pritning macros
.macro print sym:req
	call_1 print_string, "\sym"
.endm
.macro println sym:req
	print "\sym"
	print $newline
.endm
.macro printNum sym:req
	call_1 print_number, "\sym"
.endm
.macro printNumln sym:req
	call_1 print_number, "\sym"
	print $newline
.endm
.macro printI reg:req
	pushl \reg
	incl \reg
	printNum \reg
	print $dotSpace
	popl \reg
.endm
.macro scanNum buf:req
	call_1 scan_number, "\buf"
.endm

#general macros
.macro frame
	pushl %ebp
	movl %esp, %ebp
.endm
.macro jmp_table tbl_ptr:req offset:req
	movl \offset, %esi
	movl \tbl_ptr, %eax
	movl (%eax,%esi,4), %eax
	jmp *%eax
.endm

#event management macros
.macro load_ev_flag event_ptr:req
	movl \event_ptr, %eax
	movl (%eax), %eax
.endm
.macro load_ev_opcount event_ptr:req
	movl \event_ptr, %eax
	movl 8(%eax), %eax
.endm
.macro load_op event_ptr:req offset_reg:req store=%eax
	movl \event_ptr, \store
	leal 12(\store), \store 			#option array base
	movl (\store, \offset_reg, 4), %eax	#get option ptr
.endm

.macro make_op parent:req name:req next:req on_exit=0 text
.ifb \text
.set text, ev_\()\parent\()_op_\()\name\()_text
.endif
ev_\()\parent\()_op_\()\name:
	.long text
	.long \next
	.long \on_exit
.endm
.macro make_msg name:req next:req on_exit=0
ev_\()\name:	
	.long 1
	.long ev_\()\name\()_text
	.long \next
	.long \on_exit
.endm
.macro make_yesno_event name:req next_yes:req, next_no:req, next_yes_exec=0, next_no_exec=0
ev_\()\name:	
	.long 2
	.long ev_\()\name\()_text
	.long 2
	.long ev_\()\name\()_op_yes
	.long ev_\()\name\()_op_no
	
	ev_\()\name\()_op_yes:
		.long ev_glbl_op_yes_text
		.long \next_yes
		.long \next_yes_exec
	
	ev_\()\name\()_op_no:
		.long ev_glbl_op_no_text
		.long \next_no
		.long \next_no_exec	
.endm
.macro make_1op_std_event name:req, next:req, op_exec=0
ev_\name:	
	.long 0
	.long ev_\name\()_text
	.long 1
	.long ev_\name\()_op_1
	
	make_op \name, 1, \next, \op_exec
.endm

.macro make_special_event, name:req, type:req, op_names:vararg
ev_\name:
	.long \type
	.long ev_\name\()_text
	.ifnb \op_names
		argc=0
		.irp arg, \op_names; argc = argc + 1; .endr
		.long argc
		.irp arg, \op_names
		.long \arg
		.endr
	.else
		.long 0
	.endif
.endm

.macro make_event name:req, type:req, op_names:vararg
ev_\name:
	.long \type
	.long ev_\name\()_text	
	.ifnb \op_names
		argc=0
		.irp arg, \op_names; argc = argc + 1; .endr
		.long argc
		.irp arg, \op_names
		.long ev_\name\()_op_\arg
		.endr
	.else
		.long 0
	.endif
.endm

.macro make_pseudo name:req, exec:req, next:req
ev_\name:
	.long 3
	.long \exec
	.long \next
.endm

.macro make_std_event name:req, op_names:vararg
	make_event \name, 0, \op_names
.endm
.macro make_non_std_event name:req, op_names:vararg
	make_event \name, 2, \op_names
.endm

#can only shift by constants :/
.macro shift_by inst:req reg_by:req reg_target:req bits:req macro_flag:req
	pushl $0	
	LM_\()\macro_flag\()_start:
		cmpl \reg_by, (%esp)
		jge LM_\()\macro_flag\()_end
		\inst \bits, \reg_target
		incl (%esp)
		jmp LM_\()\macro_flag\()_start
	LM_\()\macro_flag\()_end:		
	addl $4, %esp
.endm

#call macros, bascially ensure that argument pop is correct
#can also provide args left to right
.macro call_1 f:req arg0:req
	pushl \arg0
	call \f
	addl $4, %esp
.endm
#pushing right to left
.macro call_2 f:req arg0:req arg1:req
	pushl \arg1
	pushl \arg0
	call \f
	addl $8, %esp
.endm
.macro call_3 f:req arg0:req arg1:req arg2:req
	pushl \arg2
	pushl \arg1
	pushl \arg0
	call \f
	addl $12, %esp
.endm
.macro call_4 f:req arg0:req arg1:req arg2:req arg3:req
	pushl \arg3
	pushl \arg2
	pushl \arg1
	pushl \arg0
	call \f
	addl $16, %esp
.endm
.macro call_5 f:req arg0:req arg1:req arg2:req arg3:req arg4:req
	pushl \arg4
	pushl \arg3
	pushl \arg2
	pushl \arg1
	pushl \arg0
	call \f
	addl $20, %esp
.endm
.macro args_list parg1, pargs:vararg
	.ifnb \parg1
		args_list \pargs
		push \parg1
	.endif
.endm
.macro callf f:req args:vararg
    argc=0
    .ifnb \args
        .irp arg,\args; argc=argc+1; .endr
		args_list \args
    .endif
    call \f
	.ifnb \args
	addl $(argc*4), %esp
	.endif
.endm

#some getters/setters
.macro get_event_text ptr:req
	call_2 get_member, "\ptr", $0
.endm
.macro get_event_type ptr:req
	call_2 get_member, "\ptr", $1
.endm
.macro get_option_text ptr:req
	call_2 get_member, "\ptr", $0
.endm
.macro get_option_next_event ptr:req
	call_2 get_member, "\ptr", $1
.endm
.macro get_option_on_exit ptr:req
	call_2 get_member, "\ptr", $2
.endm
	
.data
hyphen: .string " - "
tab: .string "\t"
four_space: .string "    "
dotSpace: .string ". "
newline: .string "\n"
space: .string " "
test_string: .string "Test"
terminator: .string ""
iteration: .string "Iteration: "
