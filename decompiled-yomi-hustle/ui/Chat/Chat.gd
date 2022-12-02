extends Window






var showing = false


func _ready():
	$"%ShowButton".connect("pressed", self, "toggle")
	$"%LineEdit".connect("message_ready", self, "on_message_ready")
	Network.connect("chat_message_received", self, "on_chat_message_received")
	SteamLobby.connect("chat_message_received", self, "on_steam_chat_message_received")
	if static_:
		$"%ShowButton".hide()
	SteamLobby.connect("user_joined", self, "_on_user_joined")
	SteamLobby.connect("user_left", self, "_on_user_left")


func _on_user_joined(user):
	god_message(user + " joined.")

func _on_user_left(user):
	god_message(user + " left.")


func line_edit_focus():
	$"%LineEdit".grab_focus()

func on_chat_message_received(player_id:int, message:String):
	var color = "ff333d" if player_id == 2 else "1d8df5"
	
	var text = ProfanityFilter.filter(("<[color=#%s]" % [color]) + Network.pid_to_username(player_id) + "[/color]>: " + message)
	var node = RichTextLabel.new()
	node.bbcode_enabled = true
	node.append_bbcode(text)
	node.fit_content_height = true
	if not (player_id == Network.player_id):
		$"ChatSound".play()
	$"%MessageContainer".call_deferred("add_child", node)
	yield (get_tree(), "idle_frame")
	yield (get_tree(), "idle_frame")
	$"%ScrollContainer".scroll_vertical = 1874919424

func god_message(message:String):
	$"ChatSound".play()
	var node = RichTextLabel.new()
	var text = ProfanityFilter.filter(":: " + message)
	node.bbcode_enabled = true
	node.append_bbcode(text)
	node.fit_content_height = true
	$"%MessageContainer".call_deferred("add_child", node)
	yield (get_tree(), "idle_frame")
	yield (get_tree(), "idle_frame")
	$"%ScrollContainer".scroll_vertical = 1874919424

func on_steam_chat_message_received(steam_id:int, message:String):
	if not SteamLobby.can_get_messages_from_user(steam_id):
		return 
	var color = "ff333d" if (steam_id == SteamYomi.STEAM_ID) else "1d8df5"
	var steam_name = Steam.getFriendPersonaName(steam_id)
	
	var text = ProfanityFilter.filter(("<[color=#%s]" % [color]) + steam_name + "[/color]>: " + message)
	var node = RichTextLabel.new()
	node.bbcode_enabled = true
	node.append_bbcode(text)
	node.fit_content_height = true
	if not (steam_id == SteamYomi.STEAM_ID):
		$"ChatSound".play()
	
	$"%MessageContainer".call_deferred("add_child", node)
	yield (get_tree(), "idle_frame")
	yield (get_tree(), "idle_frame")
	$"%ScrollContainer".scroll_vertical = 1874919424

func unfocus_line_edit():
	$"%LineEdit".release_focus()

func on_message_ready(message):
	$"%TooLongLabel".hide()
	if Network.multiplayer_active or SteamLobby.SPECTATING:
		if len(message) < 1000:
			$"%LineEdit".clear()
			send_message(message)
		else :
			$"%TooLongLabel".show()
			$"%TooLongLabel".text = "message too long (" + str(len(message)) + "/1000)"

func send_message(message):
	if not Network.steam:
		Network.rpc_("send_chat_message", [Network.player_id, message])
	else :
		SteamLobby.send_chat_message(message)

func toggle():
	visible = not visible








