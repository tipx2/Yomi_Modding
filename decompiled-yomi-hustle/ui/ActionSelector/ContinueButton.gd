extends Button

signal was_pressed(action)
signal data_changed()

var action_name = ""
var action_title = ""

var data_node = null
var container = null
var reversible = false

func setup(name, title, texture = null):
	action_name = name
	action_title = title
	text = title

func set_pressed(on):
	pressed = on
	update_color(on)
	
func is_pressed():
	return pressed

func set_player_id(_player_id):
	pass

func get_disabled():
	return disabled

func set_data_node(node):
	data_node = node
	if node:
		node.connect("data_changed", self, "emit_signal", ["data_changed"])

func get_data():
	if data_node:
		return data_node.get_data()
	return null

func _ready():
	connect("pressed", self, "on_pressed")


	connect("toggled", self, "on_toggled")

func update_color(on):
	if on:
		modulate = Color.cyan
	else :
		modulate = Color.white

func set_pressed_no_signal(on):
	update_color(on)

func on_toggled(on):

	pass
		

func on_pressed():
	emit_signal("was_pressed", action_name)

