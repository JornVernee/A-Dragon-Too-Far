.file "ADTF_Inventory.s"

.text

#can not remove right now

add_inventory_item:
	frame
	#arg0 = value (pointer to string)
	
	call_3 set_member, $inventory, inventory_cursor, 8(%ebp)
	incl inventory_cursor
	
	leave
	ret

has_inventory_item:
	frame
	#arg0 = string pointer
	
	pushl %esi
	movl $0, %esi
	
	LI0_start:
		cmpl inventory_cursor, %esi
		jge LI0_end	
		call_2 get_member, $inventory, %esi
		call_2 str_equals, %eax, 8(%ebp)
		cmpl $1, %eax
		je LI0_succes
		
		incl %esi
		jmp LI0_start
	LI0_end:
		movl $0, %eax #false
		jmp LI0_final
	LI0_succes:
		movl $1, %eax #true
	LI0_final:
	
	popl %esi
	
	leave
	ret

print_inventory:
	frame
	
	println $inventory_txt
	
	pushl %esi
	movl $1, %esi
	
	LI1_start:
		cmpl inventory_cursor, %esi
		jge LI1_end
	
		call_2 get_member, $inventory, %esi
		cmpl $0, %eax
		je LI1_skip
		println %eax
		LI1_skip:
	
		incl %esi
		jmp LI1_start
	LI1_end:
	
	popl %esi
	
	leave
	ret

.data
inventory_txt: .string "Inventory:"

inventory_cursor: .long 0	#also size
inventory: .long (10 * 4)	#room for 10 items
inventory_length: .long . - inventory
