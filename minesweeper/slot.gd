extends MarginContainer

signal pressed_button()

var pos : Vector2 = Vector2.ZERO

@onready var color_rect : ColorRect = $ColorRect
@onready var number : Label = $Number



func _on_button_button_down():
	emit_signal("pressed_button",self,true)

func numbered(mines_around : int):
	number.show()
	number.text = str(mines_around)
	var color
	match(mines_around):
		1:
			color = Color.DODGER_BLUE
		2:
			color = Color.LAWN_GREEN
		3:
			color = Color.FIREBRICK
		4:
			color = Color.DARK_BLUE
		5:
			color = Color.DARK_RED
		6:
			color = Color.CYAN
		7:
			color = Color.BLUE_VIOLET
		8:
			color = Color.DARK_GOLDENROD
	number.add_theme_color_override("font_color",color)
	color_rect.color = Color(Color.BLACK)

func clicked():
	color_rect.color = Color(Color.BLACK)

func deactivate_button():
	$Button.disabled = true

func show_bomb():
	$bomb.show()
