extends Control

class_name ButtonCategoryContainer

onready var action_data_container = $"%ActionDataContainer"
onready var action_data_panel_container = $"%ActionDataPanelContainer"
onready var button_container = $"%ButtonContainer"

var label_text = ""
var selected_button_text = ""
var active_button = null

var game = null
var player_id = null




func init(name):
	label_text = name
	$"%Label".text = label_text







func any_buttons_visible():
	for button in $"%ButtonContainer".get_children():
		if button.visible:
			return true
	return false

















func add_button(button):
	$"%ButtonContainer".add_child(button)
	button.connect("mouse_entered", self, "on_button_mouse_entered", [button])
	button.connect("mouse_exited", self, "on_button_mouse_exited")


func refresh():
	for button in $"%ButtonContainer".get_children():
		if button.is_pressed():
			on_button_mouse_entered(button)
			$"%Label".modulate = Color.cyan
			active_button = button
			selected_button_text = button.action_title
			return 
	$"%Label".text = label_text
	$"%Label".modulate = Color.white
	$"%Label".modulate.a = 0.25


func on_button_mouse_entered(button):
	$"%Label".text = button.action_title
	if button.action_title == selected_button_text:
		return 
	$"%Label".modulate = Color.green

func on_button_mouse_exited():
	refresh()

func show_data_container():
	$"%ActionDataPanelContainer".show()



	
func hide_data_container():
	$"%ActionDataPanelContainer".hide()














