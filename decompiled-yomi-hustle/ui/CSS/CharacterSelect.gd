extends Control

var buttons = []

signal match_ready(data)

var pressed_button = null
var hovered_characters = {}
var selected_characters = {}
var selected_styles = {
			1:null, 
			2:null
		}
var singleplayer = true
var current_player = 1
var network_match_data = {}

func _ready():
	$"%GoButton".connect("pressed", self, "go")
	$"%ShowSettingsButton".connect("toggled", self, "_on_show_settings_toggled")
	$"%QuitButton".connect("pressed", self, "quit")
	Network.connect("character_selected", self, "_on_network_character_selected")
	Network.connect("match_locked_in", self, "_on_network_match_locked_in")
	init()

func _on_network_character_selected(player_id, character, style = null):
	selected_characters[player_id] = character
	selected_styles[player_id] = style
	if Network.is_host() and player_id == Network.player_id:
		$"%GameSettingsPanelContainer".hide()
	if selected_characters[1] != null and selected_characters[2] != null:

		if Network.is_host():
			Network.rpc_("send_match_data", get_match_data())

func _on_network_match_locked_in(match_data):
	network_match_data = match_data
	if SteamLobby.LOBBY_ID != 0 and SteamLobby.OPPONENT_ID != 0:
		Steam.setLobbyMemberData(SteamLobby.LOBBY_ID, "character", match_data.selected_characters[SteamLobby.PLAYER_SIDE].name)
	go()

func _on_show_settings_toggled(on):
	$"%GameSettingsPanelContainer".visible = on

func init(singleplayer = true):
	if Network.steam:
		$"%QuitButton".hide()
	for button in buttons:
		button.disabled = false


	$"%GoButton".disabled = true
	$"%GoButton".show()
	self.singleplayer = singleplayer
	$"%GameSettingsPanelContainer".init(singleplayer)


	$"%SelectingLabel".text = "P1 SELECT YOUR CHARACTER" if singleplayer else "SELECT YOUR CHARACTER"
	$"%P1Display".init()
	$"%P2Display".init()
	if Network.steam:
		$"%GameSettingsPanelContainer".hide()

	selected_styles = {
		1:null, 
		2:null
	}
	
	hovered_characters = {
		1:null, 
		2:null, 
	}

	selected_characters = {
		1:null, 
		2:null
	}
	
	current_player = 1 if singleplayer else Network.player_id
	
	if not singleplayer:
		if current_player == 1:
			$"%P2Display".set_enabled(false)
		else :
			$"%P1Display".set_enabled(false)
		$"%GoButton".hide()
	pressed_button = null
	buttons = []
	for child in $"%CharacterButtonContainer".get_children():
		child.queue_free()
	for name in Global.name_paths:
		var button = preload("res://ui/CSS/CharacterButton.tscn").instance()
		button.character_scene = load(Global.name_paths[name])
		$"%CharacterButtonContainer".add_child(button)
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS

		button.text = name
		buttons.append(button)
		if not button.is_connected("pressed", self, "_on_button_pressed"):
			button.connect("pressed", self, "_on_button_pressed", [button])
			button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])

func get_character_data(button):
	var data = {}
	var scene = button.character_scene.instance()
	data["name"] = scene.name
	scene.free()
	return data

func get_display_data(button):
	var data = {}
	var scene = button.character_scene.instance()
	data["name"] = scene.name
	data["portrait"] = scene.character_portrait
	scene.free()
	return data

func _on_button_mouse_entered(button):
	var data = get_display_data(button)
	display_character(current_player, data)
	pass

func display_character(id, data):
	var display = $"%P1Display" if id == 1 else $"%P2Display"
	display.load_character_data(data)

func _on_button_pressed(button):
	for button in buttons:
		button.set_pressed_no_signal(false)

	var data = get_character_data(button)
	var display_data = get_display_data(button)
	display_character(current_player, display_data)
	selected_characters[current_player] = data
	if singleplayer and current_player == 1:
		current_player = 2
		$"%SelectingLabel".text = "P2 SELECT YOUR CHARACTER"
	else :
		for button in buttons:
			button.disabled = true
		if singleplayer:
			$"%GoButton".disabled = false
	if not singleplayer:
		Network.select_character(data, $"%P1Display".selected_style if current_player == 1 else $"%P2Display".selected_style)

func quit():
	if Network.multiplayer_active:
		Network.stop_multiplayer()
	get_tree().reload_current_scene()

func get_match_data():
	if singleplayer:
		selected_styles = {
			1:$"%P1Display".selected_style, 
			2:$"%P2Display".selected_style
		}
	var data = {
		"singleplayer":singleplayer, 
		"selected_characters":selected_characters, 
		"selected_styles":selected_styles, 

	}
	if SteamLobby.LOBBY_ID != 0 and SteamLobby.MATCH_SETTINGS:
		data.merge(SteamLobby.MATCH_SETTINGS)
	else :
		data.merge($"%GameSettingsPanelContainer".get_data())
	return data

func go():
	if not singleplayer:
		emit_signal("match_ready", network_match_data)
	else :
		emit_signal("match_ready", get_match_data())
	hide()
