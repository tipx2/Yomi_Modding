extends VBoxContainer

signal settings_changed(settings)

var start_color: = Color.white
var end_color: = Color.white

onready var settings_map = {
	$"%Particle Amount":"amount", 
	$"%Particle Lifetime":"lifetime", 
	$"%InFront":"in_front", 
	$"%Local":"local_coords", 
	$"%Shape":"shape", 
	$"%Speed Scale":"speed_scale", 
	$"%Explosiveness":"explosiveness", 
	$"%Lifetime Randomness":"lifetime_randomness", 
	$"%Direction":"direction", 
	$"%Direction Spread":"spread", 
	$"%Gravity X":"gravity_x", 
	$"%Gravity Y":"gravity_y", 
	$"%Rect Size X":"rect_size_x", 
	$"%Rect Size Y":"rect_size_y", 
	$"%Initial Velocity":"initial_velocity", 
	$"%Initial Velocity Randomness":"initial_velocity_random", 
	$"%Linear Accel":"linear_accel", 
	$"%Linear Accel Randomness":"linear_accel_random", 
	$"%Radial Accel":"radial_accel", 
	$"%Radial Accel Randomness":"radial_accel_random", 
	$"%Tangential Accel":"tangential_accel", 
	$"%Tangential Accel Randomness":"tangential_accel_random", 
	$"%Orbit Velocity":"orbit_velocity", 
	$"%Orbit Velocity Randomness":"orbit_velocity_random", 
	$"%Explosiveness":"explosiveness", 
	$"%Start Scale":"start_scale", 
	$"%End Scale":"end_scale", 
	$"%Scale Randomness":"scale_amount_random", 
	$"%StartColor":"start_color", 
	$"%EndColor":"end_color", 
	$"%Start Alpha":"start_alpha", 
	$"%End Alpha":"end_alpha", 
	$"%X Offset":"x_offset", 
	$"%Y Offset":"y_offset", 
	
}

func _ready():
	$"%Shape".max_value = CustomTrailParticle.get_shapes().size() - 1
	for node in settings_map:
		if node.has_signal("value_changed"):
			node.connect("value_changed", self, "_setting_value_changed")
		if node.has_signal("toggled"):
			node.connect("toggled", self, "_setting_value_changed")
		if node.has_signal("data_changed"):
			node.connect("data_changed", self, "_setting_value_changed")
		if node.has_signal("color_changed"):
			node.connect("color_changed", self, "_setting_value_changed")
		pass
	pass

func _setting_value_changed(_value = null):
	emit_signal("settings_changed", get_settings())

func set_start_color(start_color):
	self.start_color = start_color
	_setting_value_changed()

func set_end_color(end_color):
	self.end_color = end_color
	_setting_value_changed()

func get_settings():
	var map = {
		"start_color":$"%StartColor".current_color, 
		"end_color":$"%EndColor".current_color, 
	}

	for settings_node in settings_map:
		var value
		if settings_node is SettingsSlider:
			value = settings_node.get_data()
		elif settings_node is XYPlot:
			value = settings_node.get_value_float()
		elif settings_node.get("pressed") != null:
			value = settings_node.pressed
		elif settings_node is SpinBox:
			value = settings_node.value
		if value != null:
			map[settings_map[settings_node]] = value
	return map
