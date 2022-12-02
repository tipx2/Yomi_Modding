extends PlayerExtra

onready var bomb_button = $"%BombButton"


func _ready():
	bomb_button.connect("toggled", self, "_on_bomb_button_toggled")


func _on_bomb_button_toggled(_on):
	emit_signal("data_changed")

func show_options():
	bomb_button.hide()
	bomb_button.set_pressed_no_signal(false)

	if fighter.bomb_thrown:
		bomb_button.show()

func get_extra():
	var extra = {
		"explode":bomb_button.pressed
	}
	return extra

func reset():
	bomb_button.set_pressed_no_signal(false)
