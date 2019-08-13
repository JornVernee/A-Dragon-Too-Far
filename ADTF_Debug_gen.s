.file "ADTF_Debug_gen.s"
.data
function_table:
	.long n__main                   ,_main
	.long n_clr                     ,clr
	.long n_print_option_and_store  ,print_option_and_store
	.long n_print_options           ,print_options
	.long n_travel_populate_option  ,travel_populate_option
	.long n_save_game               ,save_game
	.long n_load_game               ,load_game
	.long n_travel_populate_options ,travel_populate_options
	.long n_print_character_stats   ,print_character_stats
	.long n_print_help              ,print_help
	.long n_on_travel_north         ,on_travel_north
	.long n_on_travel_east          ,on_travel_east
	.long n_on_travel_south         ,on_travel_south
	.long n_on_travel_west          ,on_travel_west
	.long n_exec_save_event         ,exec_save_event
	.long n_exec_op_back_to_saved   ,exec_op_back_to_saved
	.long n_exec_exit               ,exec_exit
	.long n_ironman_final           ,ironman_final
	.long n_exec_yes_ironman        ,exec_yes_ironman
	.long n_exec_no_ironman         ,exec_no_ironman
function_table_size: .long (((. - function_table) / 4) / 2)

n__main: .string "_main"
n_clr: .string "clr"
n_print_option_and_store: .string "print_option_and_store"
n_print_options: .string "print_options"
n_travel_populate_option: .string "travel_populate_option"
n_save_game: .string "save_game"
n_load_game: .string "load_game"
n_travel_populate_options: .string "travel_populate_options"
n_print_character_stats: .string "print_character_stats"
n_print_help: .string "print_help"
n_on_travel_north: .string "on_travel_north"
n_on_travel_east: .string "on_travel_east"
n_on_travel_south: .string "on_travel_south"
n_on_travel_west: .string "on_travel_west"
n_exec_save_event: .string "exec_save_event"
n_exec_op_back_to_saved: .string "exec_op_back_to_saved"
n_exec_exit: .string "exec_exit"
n_ironman_final: .string "ironman_final"
n_exec_yes_ironman: .string "exec_yes_ironman"
n_exec_no_ironman: .string "exec_no_ironman"

event_table:
	.long n_ev_main_menu             ,ev_main_menu
	.long n_ev_story                 ,ev_story
	.long n_ev_ask_ironman           ,ev_ask_ironman
	.long n_ev_in_game_menu          ,ev_in_game_menu
	.long n_ev_print_character_stats ,ev_print_character_stats
	.long n_ev_print_help            ,ev_print_help
	.long n_ev_save_game             ,ev_save_game
	.long n_ev_print_map             ,ev_print_map
	.long n_ev_travel                ,ev_travel
	.long n_ev_travel_invalid        ,ev_travel_invalid
	.long n_ev_shack                 ,ev_shack
	.long n_ev_contemplate           ,ev_contemplate
event_table_size: .long (((. - event_table) / 4) / 2)

n_ev_main_menu: .string "ev_main_menu"
n_ev_story: .string "ev_story"
n_ev_ask_ironman: .string "ev_ask_ironman"
n_ev_in_game_menu: .string "ev_in_game_menu"
n_ev_print_character_stats: .string "ev_print_character_stats"
n_ev_print_help: .string "ev_print_help"
n_ev_save_game: .string "ev_save_game"
n_ev_print_map: .string "ev_print_map"
n_ev_travel: .string "ev_travel"
n_ev_travel_invalid: .string "ev_travel_invalid"
n_ev_shack: .string "ev_shack"
n_ev_contemplate: .string "ev_contemplate"

option_table:
	.long n_ev_glbl_op_travel              ,ev_glbl_op_travel
	.long n_ev_glbl_op_in_game_menu        ,ev_glbl_op_in_game_menu
	.long n_ev_glbl_op_back_ev             ,ev_glbl_op_back_ev
	.long n_ev_glbl_op_exit                ,ev_glbl_op_exit
	.long n_ev_main_menu_op_new_game       ,ev_main_menu_op_new_game
	.long n_ev_main_menu_op_load           ,ev_main_menu_op_load
	.long n_ev_ask_ironman_op_yes          ,ev_ask_ironman_op_yes
	.long n_ev_ask_ironman_op_no           ,ev_ask_ironman_op_no
	.long n_ev_in_game_menu_op_print_map   ,ev_in_game_menu_op_print_map
	.long n_ev_in_game_menu_op_print_stats ,ev_in_game_menu_op_print_stats
	.long n_ev_in_game_menu_op_help        ,ev_in_game_menu_op_help
	.long n_ev_in_game_menu_op_save        ,ev_in_game_menu_op_save
	.long n_ev_travel_op_north             ,ev_travel_op_north
	.long n_ev_travel_op_east              ,ev_travel_op_east
	.long n_ev_travel_op_south             ,ev_travel_op_south
	.long n_ev_travel_op_west              ,ev_travel_op_west
	.long n_ev_shack_op_1                  ,ev_shack_op_1
option_table_size: .long (((. - option_table) / 4) / 2)

n_ev_glbl_op_travel: .string "ev_glbl_op_travel"
n_ev_glbl_op_in_game_menu: .string "ev_glbl_op_in_game_menu"
n_ev_glbl_op_back_ev: .string "ev_glbl_op_back_ev"
n_ev_glbl_op_exit: .string "ev_glbl_op_exit"
n_ev_main_menu_op_new_game: .string "ev_main_menu_op_new_game"
n_ev_main_menu_op_load: .string "ev_main_menu_op_load"
n_ev_ask_ironman_op_yes: .string "ev_ask_ironman_op_yes"
n_ev_ask_ironman_op_no: .string "ev_ask_ironman_op_no"
n_ev_in_game_menu_op_print_map: .string "ev_in_game_menu_op_print_map"
n_ev_in_game_menu_op_print_stats: .string "ev_in_game_menu_op_print_stats"
n_ev_in_game_menu_op_help: .string "ev_in_game_menu_op_help"
n_ev_in_game_menu_op_save: .string "ev_in_game_menu_op_save"
n_ev_travel_op_north: .string "ev_travel_op_north"
n_ev_travel_op_east: .string "ev_travel_op_east"
n_ev_travel_op_south: .string "ev_travel_op_south"
n_ev_travel_op_west: .string "ev_travel_op_west"
n_ev_shack_op_1: .string "ev_shack_op_1"

