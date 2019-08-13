.include "ADTF_Macros.s"
.include "ADTF_Ev_Op.s" 
.include "ADTF_Map.s"
.include "ADTF_Inventory.s"

.ifdef DEBUG
.include "ADTF_Debug.s"
.endif

.file "ADTF_Revive.s"
#Note to self
# arg0 is at 8(%ebp)
# arg1 at 12(%ebp)
# etc.

#FIXME: Saves are almost always version incompatible,
#This could be avoided by having current/saved/next event as strings, not pointers
.data
	persisted_data:
	saved_event: .long 0
	current_event: .long 0
	next_event: .long 0
	cur_x: .long 0
	cur_y: .long 0
	fame: .long 0
	moves: .long 0
	is_iron_man: .long 0
	persisted_data_length: .long . - persisted_data
	
	op_table: .skip (10 * 4)
.text
.global _main

_main:
	frame
	
	.ifdef DEBUG
	call print_tables
	.endif
	
	movl $ev_main_menu, next_event
	
	L0_start:
		call clr
		
		movl next_event, %eax
		movl %eax, current_event
		
		.ifdef DEBUG
		call_1 get_event_name, current_event
		call_2 debug_out, current_event, %eax
		println $newline
		.endif
		
	load_ev_flag current_event
	jmp_table $L0_switch_table, %eax
	
	#TODO: add handler for pseudo events
	L0_event_handler:
		call_2 get_member, current_event, $1
		println %eax
		print $newline
	
		movl current_event, %eax		
		call_3 print_options, $op_table, %eax, $1
		jmp L0_pick_op
		L0_nonstd:
		movl current_event, %eax
		call_3 print_options, $op_table, %eax, $0
		L0_pick_op:
		
		pushl %eax
		print $newline
		popl %eax
		
		incl %eax
		call_2 get_num_between, $1, %eax
		decl %eax
		
		call_2 get_member $op_table, %eax
		
		pushl %eax
		call_1 call_if_not_zero, 8(%eax)
		popl %eax
		
		movl 4(%eax), %eax
		movl %eax, next_event	#load next event
		
		jmp L0_end
	L0_msg_handler:
		call_2 get_member, current_event, $1
		println %eax
		print $newline
		call pause
		
		movl current_event, %eax	#load current event
		
		pushl %eax
		call_1 call_if_not_zero, 12(%eax)
		popl %eax
		
		movl 8(%eax), %eax
		movl %eax, next_event	#load next event
		jmp L0_end
	L0_pseudo:	
		call_2 get_member, current_event, $1
		call *%eax
		
		call_2 get_member, current_event, $2
		movl %eax, next_event
		
		print $newline
		call pause
		jmp L0_end
	L0_end:
	.ifdef DEBUG
	print $next_event_is
	call_1 get_event_name, next_event
	println %eax
	.endif
	jmp L0_start
	
	movl $0, %eax
	leave
	ret

clr:
	frame

	.ifndef DEBUG
	call clear_screen
	.else
	println $devider
	.endif
	
	leave
	ret
	
print_option_and_store:
	frame
	#arg0 = option pointer
	#arg1 = index
	#arg2 = global option table pointer
	
	printI 12(%ebp)
	
	#get text
	call_2 get_member, 8(%ebp), $0	
	
	.ifdef DEBUG
	print %eax
	print $space
	call_1 get_option_name, 8(%ebp)
	call_2 debug_out, 8(%ebp), %eax
	print $newline
	.else
	println %eax
	.endif
	
	#store in global table
	call_3 set_member, 16(%ebp), 12(%ebp), 8(%ebp)
	
	leave
	ret
	
print_options:
	frame
	#arg0 = global option table pointer
	#arg1 = current event pointer
	#arg2 = boolean, if std event
	#return = number of printed options
	
	movl 12(%ebp), %eax		#load event pointer
	movl $0, %esi			#iteration index
	
	pushl %eax				#save eax
	
	L1_start:
		load_ev_opcount (%esp)
		cmpl %eax, %esi
		jge L1_test_std
		
		load_op (%esp), %esi	#load option
		call_3 print_option_and_store, %eax, %esi, 8(%ebp)		
		
		incl %esi
		jmp L1_start
	L1_test_std:
		cmpl $0, 16(%ebp)
		je L1_end
		
		call_3 print_option_and_store, $ev_glbl_op_in_game_menu, %esi, 8(%ebp)		
		incl %esi
		
		call_3 print_option_and_store, $ev_glbl_op_travel, %esi, 8(%ebp)		
		incl %esi
	L1_end:		
		movl %esi, %eax		#return total number of printed options
	
	leave
	ret
	
travel_populate_option:
	frame
	#arg0 = x
	#arg1 = y
	#arg2 = option ptr
	#arg3 = text template
	#arg4 = on_exit if known
	
	call_2 is_in_map_bounds, 8(%ebp), 12(%ebp)
	cmpl $0, %eax
	je L4_unknown

		call_2 get_map_event_ptr, 8(%ebp), 12(%ebp)	
		call_3 set_member, 16(%ebp), $1, %eax
		call_3 set_member, 16(%ebp), $2, 24(%ebp)
		call_2 get_map_long_name, 8(%ebp), 12(%ebp)
		pushl %eax
		call_2 get_member, 16(%ebp), $0
		popl %ebx
		call_3 str_cat, 20(%ebp), %ebx, %eax
		jmp L4_end
	L4_unknown:
		call_3 set_member, 16(%ebp), $1, $ev_travel_invalid
		call_3 set_member, 16(%ebp), $2, $0		#null out on_exit
		call_2 get_member, 16(%ebp), $0
		call_3 str_cat, 20(%ebp), $txt_wasteland, %eax
	L4_end:
	
	leave
	ret	

save_game:
	frame
	
	movl persisted_data_length, %eax
	addl inventory_length, %eax	
	subl %eax, %esp #create buffer
	pushl %esp		#save 1 - buffer pointer
	pushl %eax		#save 2 - bytes to write
	
	movl 4(%esp), %eax
	call_3 mem_cpy, $persisted_data, %eax, persisted_data_length
	
	movl 4(%esp), %eax
	addl persisted_data_length, %eax
	call_3 mem_cpy, $inventory, %eax, inventory_length
	
	popl %eax		#restore 2
	popl %ebx		#restore 1
	call_3 save_bytes, %ebx, %eax, $stream
	
	cmpl $0, %eax
	je L7_fail
		println $save_success_text
		jmp L7_end
	L7_fail:
		call_1 print_error, $save_fail_text
	L7_end:
	
	leave
	ret
	
load_game:
	frame
	
	call clr
	
	movl persisted_data_length, %eax
	addl inventory_length, %eax	
	subl %eax, %esp #create buffer
	pushl %esp		#save 1 - buffer pointer
	
	movl (%esp), %ebx
	call_3 load_bytes, %ebx, %eax, $stream
	
	cmpl $0, %eax
	je L8_fail
		println $load_success_text
		
		movl (%esp), %eax
		call_3 mem_cpy, %eax, $persisted_data, persisted_data_length
		
		popl %eax	#restore 1
		addl persisted_data_length, %eax
		call_3 mem_cpy, %eax, $inventory, inventory_length
		
		call_3 set_member, $ev_main_menu_op_load, $1, saved_event
		jmp L8_end
	L8_fail:
		call_1 print_error, $load_fail_text	
		call_3 set_member, $ev_main_menu_op_load, $2, $ev_main_menu
	L8_end:
	
	print $newline
	call pause
	
	leave
	ret

#here follow some void() functions that are fired by options and messages. (in lack of lambdas/anonymous functions)
travel_populate_options:
	frame
	
	call exec_save_event
	
	movl cur_y, %eax
	decl %eax
	call_5 travel_populate_option, cur_x, %eax, $ev_travel_op_north, $txt_north_template, $on_travel_north
	
	movl cur_x, %eax
	incl %eax
	call_5 travel_populate_option, %eax, cur_y, $ev_travel_op_east, $txt_east_template, $on_travel_east
	
	movl cur_y, %eax
	incl %eax
	call_5 travel_populate_option, cur_x, %eax, $ev_travel_op_south, $txt_south_template, $on_travel_south
	
	movl cur_x, %eax
	decl %eax
	call_5 travel_populate_option, %eax, cur_y, $ev_travel_op_west, $txt_west_template, $on_travel_west
	
	leave
	ret
	
#pseudo message event
print_character_stats:
	frame
	
	print $moves_txt
	printNumln moves
	
	print $fame_txt
	printNumln moves
	
	print $is_iron_man_txt
	cmpl $0, is_iron_man
	je L5_fail
	println $true_txt
	jmp L5_end
	L5_fail:
	println $false_txt
	L5_end:
	
	print $newline	
	call print_inventory
	
	leave
	ret
	
#pseudo message event
print_help:
	frame
	
	println $help1Txt
	println $help2Txt
	println $help3Txt
	println $help4Txt
	println $help5Txt
	
	leave
	ret

on_travel_north:
	frame
	
	incl moves
	decl cur_y
	call_2 set_discovered, cur_x, cur_y
	
	leave
	ret
	
on_travel_east:
	frame
	
	incl moves
	incl cur_x
	call_2 set_discovered, cur_x, cur_y
	
	leave
	ret	
	
on_travel_south:
	frame
	
	incl moves
	incl cur_y
	call_2 set_discovered, cur_x, cur_y
	
	leave
	ret	
	
on_travel_west:
	frame
	
	incl moves
	decl cur_x
	call_2 set_discovered, cur_x, cur_y
	
	leave
	ret	
	
exec_save_event:
	frame
	
	movl current_event, %eax
	movl %eax, saved_event
	
	leave
	ret

exec_op_back_to_saved:
	frame
	
	call_3 set_member, $ev_glbl_op_back_ev, $1, saved_event
	
	leave
	ret
	
exec_exit:
	frame
	
	call_1 exit, $0
	
	leave
	ret

ironman_final:
	frame
	#arg0 = op pointer
	
	call_2 set_discovered, $0, $0
	call_2 get_map_event_ptr, $0, $0
	call_3 set_member, 8(%ebp), $1, %eax
	
	leave
	ret
	
exec_yes_ironman:
	frame
	
	movl $1, is_iron_man
	call_1 ironman_final, $ev_ask_ironman_op_yes
	
	leave
	ret

exec_no_ironman:
	frame
	
	movl $0, is_iron_man
	call_1 ironman_final, $ev_ask_ironman_op_no
	
	leave
	ret
	
.data
L0_switch_table:
	.long L0_event_handler
	.long L0_msg_handler
	.long L0_nonstd
	.long L0_pseudo

txt_north_template: .string "North - "
txt_south_template: .string "South - "
txt_east_template: .string "East - "
txt_west_template: .string "West - "
txt_wasteland: .string "wasteland"

save_success_text: .string "Save successful"
save_fail_text: .string "Save fail"
load_success_text: .string "Load successful"
load_fail_text: .string "Load failed"

moves_txt: .string "Moves: "
fame_txt: .string "Fame: "
is_iron_man_txt: .string "Is iron man: "
true_txt: .string "True"
false_txt: .string "False"

stream: .string "J:/testsave"

#help screen
help1Txt: .string "How to play this game you ask? Well let me tell you: \n"
help2Txt: .string "When you start a new game you will be put in the starting location. You will be presented with some options, this is called an 'event'. \n"
help3Txt: .string "You progress through the game by finishing events, this is done by choosing one of the options. Upon completion of an event you will either travel, get an item or die. Some events require you to have certain items to be able to complete them with a good outcome (not dieing). \n"
help4Txt: .string "You can check your inventory through the in-game menu option which will be available at standard events. When you select character stats from the in-game menu, the player name, their inventory and their score (expressed in number of moves and fame) will be printed on the screen. \n"
help5Txt: .string "The travel option is also accessable at standard events. During traveling it might be usefull to know that option 1 is North, option 2 is East, option 3 is South and option 4 is West. If 'wasteland' is an option this means that their is no location to travel to. \n"

#event struct layout:
#	text
#	message event flag	(will be 0)
#	option count
# 	option table...
#
#message event layout:
#	text
#	message event flag 	(will be 1)
#	next event
#	onExit routine
#option layout:
#	text
#	next event
#	onExit routine

#event types:
#	0	std
#	1	message
#	2	non-std

next_event_is: .string "Next event is: "
event_at: .string "Event at: "
devider: .string "================================================="
