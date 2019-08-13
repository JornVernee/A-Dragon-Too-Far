.include "ADTF_Ev_Op_text.s"
.file "ADTF_Ev_Op.s"

.data

make_op glbl, travel, ev_travel, travel_populate_options
make_op glbl, in_game_menu, ev_in_game_menu, exec_save_event
make_op glbl, back_ev, 0, exec_op_back_to_saved
make_op glbl, exit, 0, exec_exit

make_special_event main_menu, 2, ev_main_menu_op_new_game, ev_main_menu_op_load, ev_glbl_op_exit	
	make_op main_menu, new_game, ev_story
	make_op main_menu, load, 0, load_game
	
make_msg story, ev_ask_ironman
make_yesno_event ask_ironman, 0, 0, exec_yes_ironman, exec_no_ironman

make_special_event in_game_menu, 2, ev_in_game_menu_op_print_map, ev_in_game_menu_op_print_stats, ev_in_game_menu_op_help, ev_in_game_menu_op_save, ev_glbl_op_exit, ev_glbl_op_back_ev	
	make_op in_game_menu, print_map, ev_print_map
	make_op in_game_menu, print_stats, ev_print_character_stats
	make_op in_game_menu, help, ev_print_help
	make_op in_game_menu, save, ev_save_game
	
make_pseudo print_character_stats, print_character_stats, ev_in_game_menu
make_pseudo print_help, print_help, ev_in_game_menu
make_pseudo save_game, save_game, ev_in_game_menu
make_pseudo print_map, print_map, ev_in_game_menu

make_special_event travel, 2, ev_travel_op_north, ev_travel_op_east, ev_travel_op_south, ev_travel_op_west, ev_glbl_op_back_ev
	make_op travel, north, 0
	make_op travel, east, 0
	make_op travel, south, 0
	make_op travel, west, 0
	
make_msg travel_invalid, ev_travel
	
make_1op_std_event shack, ev_contemplate
make_msg contemplate, ev_shack
