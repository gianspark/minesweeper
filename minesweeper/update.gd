extends Node

@export var grid_size_x : int = 1
@export var grid_size_y : int = 1
@export var mines : int = 1

func _ready():
	$"../VBoxContainer/Grid".columns = grid_size_x
