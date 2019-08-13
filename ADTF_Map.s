.file "ADTF_Map.s"

# short_name, long_name, event_ptr, is_discovered
.macro map_entry name:req
	.long shrt_\()\name, lng_\()\name, ev_\()\name, 0
.endm
.macro map_strings ev_name:req long_name:req short_name:req
shrt_\()\ev_name: .string "\short_name"
lng_\()\ev_name: .string "\long_name"
.endm

.macro map_record_getter member_name:req member_index:req
get_map_\()\member_name:
	frame
	#arg0 = x
	#arg1 = y
	#return = member
	
	call_3 get_map_record_member, 8(%ebp), 12(%ebp), \member_index
	leave
	ret
.endm

.text
is_in_map_bounds:
	frame
	#arg0 = x
	#arg1 = y
	#return = boolean, is in bounds
	
	call_3 is_between, 8(%ebp), $0, map_size_x
	cmpl $0, %eax
	je LM2_false
	call_3 is_between, 12(%ebp), $0, map_size_y
	cmpl $0, %eax
	je LM2_false
	movl $1, %eax
	jmp LM2_end
	LM2_false:
	movl $0, %eax
	LM2_end:
	
	leave
	ret
	
get_map_record_ptr:
	frame
	#arg0 = x
	#arg1 = y
	#return = pointer to event, or 0
	
	pushl %esi	#save
	
	movl 12(%ebp), %esi 	#load y
	imul map_size_y, %esi	#mul with map size
	addl 8(%ebp), %esi		#add x
	shll $2, %esi			#mul eax by 4 (4 entries per record)
	movl $map_table, %eax
	leal (%eax, %esi, 4), %eax
	
	popl %esi	#restore
	
	leave
	ret	

#get_map_...
map_record_getter short_name, $0
map_record_getter long_name, $1
map_record_getter event_ptr, $2
map_record_getter is_discovered, $3

get_map_record_member:
	frame
	#arg0 = x
	#arg1 = y
	#arg2 = member index
	#return = pointer to member
	
	call_2 get_map_record_ptr, 8(%ebp), 12(%ebp)
	call_2 get_member, %eax, 16(%ebp)
	
	leave
	ret
	
set_discovered:
	frame
	#arg0 = x
	#arg1 = y
	
	call_2 get_map_record_ptr, 8(%ebp), 12(%ebp)
	call_3 set_member, %eax, $3, $1
	
	leave
	ret
	
#pseudo message event
print_map:
	frame
	
	pushl $0
	pushl $0
	
	LM3_start:
		movl map_size_y, %eax
		cmpl %eax, 4(%esp)
		jge LM3_end
		
		movl $0, (%esp)		
		LM3_i_start:
			movl map_size_x, %eax
			cmpl %eax, (%esp)
			jge LM3_i_end
			
			movl (%esp), %eax
			movl 4(%esp), %ebx
			call_2 get_map_is_discovered, %eax, %ebx
			cmpl $0, %eax
			je LM3_i_unknown
				movl (%esp), %eax
				movl 4(%esp), %ebx
				call_2 get_map_short_name %eax, %ebx
				print %eax
				jmp LM3_i_continue
			LM3_i_unknown:
				print $map_undiscovered
			LM3_i_continue:
			
			movl (%esp), %eax
			incl %eax
			cmpl map_size_x, %eax
			jge LM3_i_incl
				print $map_x_devider		
			LM3_i_incl:
				incl (%esp)	
				jmp LM3_i_start
		LM3_i_end:
		
		print $newline
		
		movl 4(%esp), %eax
		incl %eax
		cmpl map_size_y, %eax
		jge LM3_incl
		
		movl $0, (%esp)		
		LM3_j_start:
			movl map_size_x, %eax
			cmpl %eax, (%esp)
				jge LM3_j_end
				
				print $map_y_devider
				
				movl (%esp), %eax
				incl %eax
				cmpl map_size_x, %eax
				jge LM3_j_incl
					print $map_y_spaces		
			LM3_j_incl:
				print $newline
				incl (%esp)
			jmp LM3_j_start
		LM3_j_end:
		
	LM3_incl:
		incl 4(%esp)
		jmp LM3_start
	LM3_end:
	
	leave
	ret
	
.data
map_index_out_of_bounds: .string "Map index out of bounds"

map_size_x: .long 1
map_size_y: .long 1

map_x_devider: .string "-----"
map_y_devider: .string " | "
map_y_spaces: .string "     "
map_undiscovered: .string " ? "

map_table:
	map_entry shack
map_table_size: .long ((. - map_table) / 4) / 4

map_strings shack, Shack, shk
