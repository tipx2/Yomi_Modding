extends CanvasLayer

onready var p1_action_buttons = $"%P1ActionButtons"
onready var p2_action_buttons = $"%P2ActionButtons"

signal singleplayer_started()
signal multiplayer_started()
signal loaded_replay(match_data)
signal received_synced_time()




var game
var turns_taken = {
	1:false, 
	2:false
}

var turn_time = 30

var p1_turn_time = 30
var p2_turn_time = 30

var draw_bg_circle = false

var lock_in_tick = - INF

const DISCORD_URL = "https://discord.gg/yomi"
const TWITTER_URL = "https://twitter.com/YomiHustle"
const IVY_SLY_URL = "https://twitter.com/ivy_sly_"
const ITCH_URL = "https://ivysly.itch.io/yomi-hustle"
const MIN_TURN_TIME = 5.0

onready var lobby = $Lobby
onready var direct_connect_lobby = $DirectConnectLobby
onready var p1_turn_timer = $"%P1TurnTimer"
onready var p2_turn_timer = $"%P2TurnTimer"

var p1_synced_time = null
var p2_synced_time = null

var game_started = false
var timer_sync_tick = - 1
var actionable = false

var forfeit_pressed = false

var actionable_time = 0

var received_synced_time = false

var quit_on_rematch = true

func _ready():
	$"%SingleplayerButton".connect("pressed", self, "_on_singleplayer_pressed")
	$"%MultiplayerButton".connect("pressed", self, "_on_multiplayer_pressed")
	$"%SteamMultiplayerButton".connect("pressed", self, "_on_steam_multiplayer_pressed")
	$"%CustomizeButton".connect("pressed", self, "_on_customize_pressed")
	$"%DirectConnectButton".connect("pressed", self, "_on_direct_connect_button_pressed")
	$"%RematchButton".connect("pressed", self, "_on_rematch_button_pressed")
	$"%QuitButton".connect("pressed", self, "_on_quit_button_pressed")
	$"%QuitToMainMenuButton".connect("pressed", self, "_on_quit_button_pressed")
	$"%ForfeitButton".connect("pressed", self, "_on_forfeit_button_pressed")
	$"%QuitProgramButton".connect("pressed", self, "_on_quit_program_button_pressed")
	$"%ResumeButton".connect("pressed", self, "pause")
	$"%ReplayButton".connect("pressed", self, "_on_view_replays_button_pressed")
	$"%ReplayCancelButton".connect("pressed", self, "_on_replay_cancel_pressed")
	$"%OpenReplayFolderButton".connect("pressed", self, "open_replay_folder")
	$"%P1ActionButtons".connect("turn_ended", self, "end_turn_for", [1])
	$"%P2ActionButtons".connect("turn_ended", self, "end_turn_for", [2])
	$"%ShowAutosavedReplays".connect("pressed", self, "_on_view_replays_button_pressed")
	$"%DiscordButton".connect("pressed", OS, "shell_open", [DISCORD_URL])
	$"%IvySlyLinkButton".connect("pressed", OS, "shell_open", [IVY_SLY_URL])
	$"%TwitterButton".connect("pressed", OS, "shell_open", [TWITTER_URL])
	$"%ItchButton".connect("pressed", OS, "shell_open", [ITCH_URL])
	$"%VersionLabel".text = "version " + Global.VERSION
	$"%ResetZoomButton".connect("pressed", self, "_on_reset_zoom_pressed")
	Network.connect("player_turns_synced", self, "on_player_actionable")
	Network.connect("player_turn_ready", self, "_on_player_turn_ready")
	Network.connect("turn_ready", self, "_on_turn_ready")
	Network.connect("sync_timer_request", self, "_on_sync_timer_request")
	Network.connect("check_players_ready", self, "check_players_ready")
	Network.connect("force_open_action_buttons", self, "on_player_actionable")
		
	SteamLobby.connect("join_lobby_success", self, "_on_join_lobby_success")
	
	p1_turn_timer.connect("timeout", self, "_on_turn_timer_timeout", [1])
	p2_turn_timer.connect("timeout", self, "_on_turn_timer_timeout", [2])
	for lobby in [$"%Lobby", $"%DirectConnectLobby", SteamLobby]:
		lobby.connect("quit_on_rematch", $"%RematchButton", "hide")
		lobby.connect("quit_on_rematch", self, "set", ["quit_on_rematch", true])
	$"%HelpButton".connect("pressed", self, "toggle_help_screen")
	$"%OptionsBackButton".connect("pressed", $"%OptionsContainer", "hide")
	$"%OptionsButton".connect("pressed", $"%OptionsContainer", "show")
	$"%PauseOptionsButton".connect("pressed", $"%OptionsContainer", "show")
	$"%MusicButton".set_pressed_no_signal(Global.music_enabled)
	$"%MusicButton".connect("toggled", self, "_on_music_button_toggled")


	$"%FullscreenButton".set_pressed_no_signal(Global.fullscreen)
	$"%FullscreenButton".connect("toggled", self, "_on_fullscreen_button_toggled")
	$"%HitboxesButton".set_pressed_no_signal(Global.show_hitboxes)
	$"%HitboxesButton".connect("toggled", self, "_on_hitboxes_button_toggled")
	$"%PlaybackControls".set_pressed_no_signal(Global.show_playback_controls)
	$"%PlaybackControls".connect("toggled", self, "_on_playback_controls_button_toggled")



	$NetworkSyncTimer.connect("timeout", self, "_on_network_timer_timeout")
	quit_on_rematch = false
	if SteamLobby.LOBBY_ID != 0:
		yield (get_tree(), "idle_frame")

		_on_join_lobby_success()
	$"%HelpScreen".hide()







	
func _on_music_button_toggled(on):
	Global.set_music_enabled(on)
	Global.save_options()

func _on_fullscreen_button_toggled(on):
	Global.set_fullscreen(on)

func _on_hitboxes_button_toggled(on):
	Global.set_hitboxes(on)

func _on_playback_controls_button_toggled(on):
	Global.set_playback_controls(on)

func toggle_help_screen():
	$"%HelpScreen".visible = not $"%HelpScreen".visible

func _on_join_lobby_success():
	$"%HudLayer".hide()
	$"%SteamLobbyList".hide()
	$"%SteamLobby".show()
	$"%GameUI".hide()
	$"%MainMenu".hide()

func _on_view_replays_button_pressed():
	load_replays()
	$"%MainMenu".hide()

func _on_forfeit_button_pressed():
	if is_instance_valid(game) and not game.game_finished:
		var player_id = Network.player_id
		game.get_player(player_id).on_action_selected("Forfeit", null, null)
		Network.forfeit()
		forfeit_pressed = true
		actionable = false
	$"%PausePanel".hide()

func _on_opponent_disconnected():
	if is_instance_valid(game) and not game.game_finished:
		game.get_player((game.my_id % 2) + 1).on_action_selected("Forfeit", null, null)
		Network.forfeit(true)
		forfeit_pressed = true
		actionable = false
	$"%PausePanel".hide()

func _on_customize_pressed():
	$"%MainMenu".hide()
	$"%CustomizationScreen".show()
	pass

func load_replays():
	$"%ReplayWindow".show()
	for child in $"%ReplayContainer".get_children():
		child.free()
	var replay_map = ReplayManager.load_replays($"%ShowAutosavedReplays".pressed)
	var buttons = []
	for key in replay_map:
		var button = preload("res://ui/ReplayWindow/ReplayButton.tscn").instance()
		button.text = key
		button.path = replay_map[key]["path"]
		button.modified = replay_map[key]["modified"]
		button.connect("pressed", self, "_on_replay_button_pressed", [button.path])
		buttons.append(button)
	buttons.sort_custom(self, "sort_replays")
	for button in buttons:
		$"%ReplayContainer".add_child(button)

func _on_reset_zoom_pressed():
	if is_instance_valid(game):
		game.reset_zoom()

func set_turn_time(time):

	p1_turn_time = time * 60
	p2_turn_time = time * 60
	turn_time = time * 60
	p1_turn_timer.wait_time = p1_turn_time
	p2_turn_timer.wait_time = p2_turn_time

func sort_replays(a, b):
	return a.modified > b.modified

func _on_replay_button_pressed(path):
	var match_data = ReplayManager.load_replay(path)
	emit_signal("loaded_replay", match_data)
	$"%ReplayWindow".hide()

func _on_replay_cancel_pressed():
	get_tree().reload_current_scene()












func will_forfeit():
	return not SteamLobby.SPECTATING and Network.multiplayer_active and is_instance_valid(game) and not game.game_finished and not game.forfeit and not ReplayManager.playback and not forfeit_pressed

func can_quit():
	return true


func reset_ui():
	$"%HudLayer".hide()
	p1_turn_timer.stop()
	p2_turn_timer.stop()
	$"%P1TurnTimerBar".hide()
	$"%P1TurnTimerLabel".hide()
	$"%P2TurnTimerBar".hide()
	$"%P2TurnTimerLabel".hide()
	$"%GameUI".hide()
	$"%ChatWindow".hide()
	$"%PostGameButtons".hide()
	$"%OpponentDisconnectedLabel".hide()
	forfeit_pressed = false
	actionable = false

func _on_quit_button_pressed():
	if will_forfeit():
		_on_forfeit_button_pressed()
	else :
		if can_quit():
			if not Network.steam:
				Network.stop_multiplayer()
				get_tree().reload_current_scene()
			else :
				SteamLobby.quit_match()
				Network.stop_multiplayer()
				get_tree().reload_current_scene()

func _on_quit_program_button_pressed():
	get_tree().quit()

func _on_sync_timer_request(id, time):
	if id == 1:
		var paused = p1_turn_timer.paused
		p1_turn_timer.start(time)
		p1_turn_timer.paused = paused
		received_synced_time = true
		emit_signal("received_synced_time")
	elif id == 2:
		var paused = p2_turn_timer.paused
		p2_turn_timer.start(time)
		p2_turn_timer.paused = paused
		received_synced_time = true
		emit_signal("received_synced_time")

func sync_timer(player_id):
	if Network.multiplayer_active:
		if player_id == Network.player_id:
			print("syncing timer")
			var timer = p1_turn_timer
			if player_id == 2:
				timer = p2_turn_timer
			Network.sync_timer(player_id, timer.time_left)

func id_to_action_buttons(player_id):
	if player_id == 1:
		return $"%P1ActionButtons"
	else :
		return $"%P2ActionButtons"

func init(game):
	forfeit_pressed = false
	if not ReplayManager.playback:
		$PostGameButtons.hide()
		$"%RematchButton".disabled = false
	self.game = game
	setup_action_buttons()
	if Network.multiplayer_active or SteamLobby.SPECTATING:
		game.connect("playback_requested", self, "_on_game_playback_requested")
		$"%P1TurnTimerLabel".show()
		$"%P2TurnTimerLabel".show()
		$"%ChatWindow".show()
	game_started = false
	timer_sync_tick = - 1
	lock_in_tick = - INF

func _on_player_turn_ready(player_id):
	lock_in_tick = game.current_tick
	if player_id != Network.player_id or SteamLobby.SPECTATING:
		$"%TurnReadySound".play()

	turns_taken[player_id] = true
	if player_id == 1:
		$"%P1TurnTimerBar".hide()

		p1_turn_timer.paused = true

	elif player_id == 2:
		$"%P2TurnTimerBar".hide()

		p2_turn_timer.paused = true
	
func _on_rematch_button_pressed():
	Network.request_rematch()
	$"%RematchButton".disabled = true

func _on_game_playback_requested():
	if Network.multiplayer_active and not ReplayManager.resimulating:
		$PostGameButtons.show()
		if not quit_on_rematch:
			$"%RematchButton".show()
		Network.rematch_menu = true

func on_game_started():
	lobby.hide()
	$"%SteamLobby".hide()
	$MainMenu.hide()

func _on_singleplayer_pressed():
	emit_signal("singleplayer_started")

func _on_direct_connect_button_pressed():
	direct_connect_lobby.show()
	$"%MainMenu".hide()

func _on_multiplayer_pressed():
	lobby.show()
	$"%MainMenu".hide()
	
func _on_steam_multiplayer_pressed():
	$"%SteamLobbyList".show()
	$"%MainMenu".hide()
	

func _on_turn_ready():
	$"%P1TurnTimerBar".hide()
	$"%P2TurnTimerBar".hide()
	actionable = false


	
	var turns_taken = {
		1:false, 
		2:false
	}


func open_replay_folder():
	var folder = ProjectSettings.globalize_path("user://replay")
	OS.shell_open(folder)

func end_turn_for(player_id):
	$"%TurnReadySound".play()
	turns_taken[player_id] = true
	if player_id == Network.player_id:
		sync_timer(player_id)
	if player_id == 1:
		$"%P1TurnTimerBar".hide()

		p1_turn_timer.paused = true

	elif player_id == 2:
		$"%P2TurnTimerBar".hide()

		p2_turn_timer.paused = true

func setup_action_buttons():
	$"%P1ActionButtons".init(game, 1)
	$"%P2ActionButtons".init(game, 2)
	
func check_players_ready():
	if is_instance_valid(game):
		if game.is_waiting_on_player():
			if lock_in_tick != game.current_tick:
				on_player_actionable()

func _on_network_timer_timeout():
	if Network.multiplayer_active:
		if not Network.turn_synced:
			if is_instance_valid(game):
				if game.player_actionable and lock_in_tick != game.current_tick and not actionable:
					Network.rpc_("check_players_ready")

func on_player_actionable():
	if actionable and (Network.multiplayer_active and not Network.undo and not Network.auto):
		return 
	while is_instance_valid(game) and not game.game_paused:
		yield (get_tree(), "idle_frame")
	Network.undo = false
	Network.auto = false
	actionable = true
	actionable_time = 0





	if Network.multiplayer_active or SteamLobby.SPECTATING:

		while not (Network.can_open_action_buttons):
			yield (get_tree(), "physics_frame")

		print("starting turn timer")

		if not game_started:

			p1_turn_timer.start()
			p2_turn_timer.start()
			game_started = true
		else :
			if p1_turn_timer.time_left < MIN_TURN_TIME:
				p1_turn_timer.start(MIN_TURN_TIME)
			if p2_turn_timer.time_left < MIN_TURN_TIME:
				p2_turn_timer.start(MIN_TURN_TIME)

		p1_turn_timer.paused = false
		p2_turn_timer.paused = false






		$"%P1TurnTimerBar".show()
		$"%P2TurnTimerBar".show()



	$"%P1ActionButtons".activate()
	$"%P2ActionButtons".activate()
	$"%AdvantageLabel".text = ""




func _on_turn_timer_timeout(player_id):
		if player_id == 1:
			if Network.player_id == player_id:
				$"%P1ActionButtons".timeout()
				p1_turn_timer.wait_time = MIN_TURN_TIME
				p1_turn_timer.start()
				p1_turn_timer.paused = true
		else :
			if Network.player_id == player_id:
				$"%P2ActionButtons".timeout()
				p1_turn_timer.wait_time = MIN_TURN_TIME
				p1_turn_timer.start()
				p1_turn_timer.paused = true
func pause():
	$"%PausePanel".visible = not $"%PausePanel".visible
	if $"%PausePanel".visible:
		if will_forfeit():
			$"%QuitToMainMenuButton".hide()
			$"%ForfeitButton".show()
		else :
			$"%QuitToMainMenuButton".show()
			$"%ForfeitButton".hide()
		$"%SaveReplayButton".disabled = false
		$"%SaveReplayButton".text = "save replay"
		$"%SaveReplayLabel".text = ""

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_ENTER:
				if Network.multiplayer_active and is_instance_valid(game):
					$"%ChatWindow".show()
					$"%ChatWindow".line_edit_focus()
			if event.scancode == KEY_F1:
				visible = not visible
				$"../HudLayer/HudLayer".visible = not $"../HudLayer/HudLayer".visible









	if event is InputEventMouseButton:
		if event.pressed:
			$"%ChatWindow".unfocus_line_edit()

func time_convert(time_in_sec):
	var seconds = time_in_sec % 60
	var minutes = (time_in_sec / 60) % 60
	var hours = (time_in_sec / 60) / 60

	
	if hours >= 1:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	return "%02d:%02d" % [minutes, seconds]

func _process(delta):
	if not p1_turn_timer.is_paused():

			var bar = $"%P1TurnTimerBar"
			bar.value = p1_turn_timer.time_left / turn_time
			if p1_turn_timer.time_left < 5:
				bar.visible = Utils.wave( - 1, 1, 0.064) > 0
	if not p2_turn_timer.is_paused():

			var bar = $"%P2TurnTimerBar"
			bar.value = p2_turn_timer.time_left / turn_time
			if p2_turn_timer.time_left < 5:
				bar.visible = Utils.wave( - 1, 1, 0.064) > 0
	$"%P1TurnTimerLabel".text = time_convert(int(floor(p1_turn_timer.time_left)))
	$"%P2TurnTimerLabel".text = time_convert(int(floor(p2_turn_timer.time_left)))





	if Input.is_action_just_pressed("pause"):
		pause()

	var advantage_label = $"%AdvantageLabel"

	var ghost_game = get_parent().ghost_game
	if is_instance_valid(ghost_game) and is_instance_valid(game):
		if game.game_paused:
			var you_id = 1
			var opponent_id = 2
			if Network.multiplayer_active:
				you_id = Network.player_id
				opponent_id = (you_id % 2) + 1
			var you = ghost_game.get_player(you_id)
			var opponent = ghost_game.get_player(opponent_id)
			if you.ghost_ready_tick != null and opponent.ghost_ready_tick != null:
				var advantage = opponent.ghost_ready_tick - you.ghost_ready_tick
				if advantage >= 0:
					advantage_label.set("custom_colors/font_color", Color("64d26b"))
					advantage_label.text = "frame advantage: +" + str(advantage)
				else :
					advantage_label.set("custom_colors/font_color", Color("ff333d"))
					advantage_label.text = "frame advantage: " + str(advantage)
		else :
			advantage_label.text = ""
	$"%P1SuperContainer".rect_min_size.y = 50 if not p1_action_buttons.visible else 0
	$"%P2SuperContainer".rect_min_size.y = 50 if not p2_action_buttons.visible else 0
	$"%TopInfo".visible = is_instance_valid(game) and not ReplayManager.playback and game.is_waiting_on_player() and not Network.multiplayer_active and not game.game_finished and not Network.rematch_menu
	$"%TopInfoMP".visible = is_instance_valid(game) and not ReplayManager.playback and game.is_waiting_on_player() and Network.multiplayer_active and not game.game_finished and not Network.rematch_menu
	$"%TopInfoReplay".visible = is_instance_valid(game) and ReplayManager.playback and not game.game_finished and not Network.rematch_menu
	$"%HelpButton".visible = is_instance_valid(game) and game.game_paused
	$"%ResetZoomButton".visible = is_instance_valid(game) and game.camera_zoom != 1.0 and game.game_paused
	if is_instance_valid(game) and not Network.multiplayer_active:
		$"%ReplayControls".show()
	else :
		$"%ReplayControls".hide()


	$"%SoftlockResetButton".visible = false
	if Network.multiplayer_active and is_instance_valid(game):
		var my_action_buttons = p1_action_buttons if Network.player_id == 1 else p2_action_buttons
		$"%SoftlockResetButton".visible = ( not my_action_buttons.visible or my_action_buttons.get_node("%SelectButton").disabled) and actionable_time > 5 and not (game.game_finished or ReplayManager.playback) and not SteamLobby.SPECTATING
		if not $"%SoftlockResetButton".visible:
			$"%SoftlockResetButton".disabled = false

		if not my_action_buttons.visible or my_action_buttons.get_node("%SelectButton").disabled:
			actionable_time += delta
		else :
			actionable_time = 0

func set_lobby_settings(settings):
	$"%CharacterSelect".lobby_match_settings = settings
	pass

func start_timers():
	yield (get_tree().create_timer(0.25), "timeout")
	if actionable:
		p1_turn_timer.paused = false
		p2_turn_timer.paused = false

func _on_SoftlockResetButton_pressed():
	Network.rpc_("send_chat_message", [Network.player_id, "-- wants to resync."])
	Network.request_softlock_fix()
	$"%SoftlockResetButton".disabled = true
	pass



func _on_ClearParticlesButton_pressed():
	if is_instance_valid(game):
		for particle in game.effects:
			particle.hide()
		if game.get_player(1).aura_particle:
			game.get_player(1).aura_particle.restart()
		if game.get_player(2).aura_particle:
			game.get_player(2).aura_particle.restart()
	pass
