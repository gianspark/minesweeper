extends Control

const SLOT = preload("res://slot.tscn")
@onready var buscaminas_update = $BuscaminasUpdate
@onready var grid = $VBoxContainer/Grid

enum mine_state{EMPTY = 0,MINE = 1,CLICKED = 2, NUMBERED = 3}

var mines : Dictionary = {} #{Vector2 : [node,state]}

var total_mines : int = 0
var total_empty_blocks : int = 0

func _ready():
	create_new_game()

func create_new_game():
	
	get_viewport().size = Vector2i(132,160)
	
	mines.clear()
	total_mines = 0
	total_empty_blocks = 0
	waiting_list.clear()
	
	
	for i in grid.get_children():
		i.queue_free()
	
	get_viewport().size += Vector2i(0,36*buscaminas_update.grid_size_y)
	
	if(buscaminas_update.grid_size_x>=4):
		get_viewport().size += Vector2i(36*(buscaminas_update.grid_size_x-4)+4,0)
	
	get_window().move_to_center()
	
	var mine_states : Array = []
	
	buscaminas_update.mines = clamp(buscaminas_update.mines,0,buscaminas_update.grid_size_x*buscaminas_update.grid_size_y)
	
	for i in buscaminas_update.mines:
		mine_states.append(mine_state.MINE)
		total_mines+=1
	for i in buscaminas_update.grid_size_x*buscaminas_update.grid_size_y-buscaminas_update.mines:
		mine_states.append(mine_state.EMPTY)
		total_empty_blocks+=1
	
	mine_states.shuffle()
	
	for y in buscaminas_update.grid_size_y:
		for x in buscaminas_update.grid_size_x:
			var new_slot = SLOT.instantiate()
			grid.add_child(new_slot)
			new_slot.connect("pressed_button",verify_slot)
			mines[Vector2(x,y)] = [new_slot,mine_states.pop_back()]
			new_slot.pos = Vector2(x,y)



var waiting_list : Array = []

func verify_slot(slot : MarginContainer,boolean : bool):
	var dict_data = mines[slot.pos]
	match(dict_data[1] as int):
		3,2:
			return
		1:
			end_game(false)
		0:
			total_empty_blocks-=1
			check_around(slot,boolean)
	if(boolean):
		verify_end()

func check_around(slot,boolean):
	
	var mines_around : int = 0
	var aux_waiting_list : Array = []
	
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			if(x == 0 and y == 0):
				continue
			var vector = Vector2(x,y) + slot.pos
			if(vector.x<0 or vector.x>buscaminas_update.grid_size_x-1):
				continue
			if(vector.y<0 or vector.y>buscaminas_update.grid_size_y-1):
				continue
			
			var around_slot = mines[vector]
			
			aux_waiting_list.append(around_slot[0])
			
			if(around_slot[1] == 1):
				mines_around+=1
	
	var update_state : Array = mines[slot.pos]
	
	if(mines_around!=0):
		update_state[1] = mine_state.NUMBERED
		slot.numbered(mines_around)
		return
	
	update_state[1] = mine_state.CLICKED
	slot.clicked()
	
	for aux in aux_waiting_list:
		
		var slot_verify_state = mines[aux.pos]
		
		if(!waiting_list.has(aux) and slot_verify_state[1] == 0):
			waiting_list.append(aux)
	if(!boolean):
		return
	for s in waiting_list:
		var slot_verify_state = mines[s.pos]
		verify_slot(s,false)
	waiting_list.clear()

func RESET_BUTTON():
	create_new_game()

func end_game(boolean : bool):
	for slot in grid.get_children():
		slot.deactivate_button()
		var aux_state = mines[slot.pos]
		if(aux_state[1]==1):
			slot.show_bomb()
	if(boolean):
		print("ganaste")
	else:
		print("perdiste")

func verify_end():
	if(total_empty_blocks == 0):
		end_game(true)
