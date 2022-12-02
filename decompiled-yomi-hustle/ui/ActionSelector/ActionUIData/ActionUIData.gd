extends Control

signal data_changed()

export  var display_offset = Vector2()

var facing = - 1

func _ready():
	for child in get_children():
		if child.has_signal("data_changed"):
			child.connect("data_changed", self, "emit_signal", ["data_changed"])

func get_data():
	var children = get_children()
	if children.size() == 1:
		return children[0].get_data()
	elif children.size() == 0:
		return null
	else :
		var data = {}
		for child in children:
			data[child.name] = child.get_data()
		return data

func set_facing(facing:int):
	for child in get_children():
		if child.get("facing") != null:
			child.facing = facing
			if child.has_method("init"):
				child.init()

func get_facing():
	for child in get_children():
		if child.get("facing"):
			return child.facing
	return null

func init():
	for child in get_children():
		if child.has_method("init"):
			child.init()
