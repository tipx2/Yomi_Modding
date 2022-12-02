extends Control





onready var user_list = $"%UserList"

var users = []
var matches = {}
var selected_user = null

var handshake_made = false


func _ready():
	SteamLobby.connect("lobby_data_update", self, "_on_lobby_data_update")
	SteamLobby.connect("received_challenge", self, "_on_received_challenge")
	SteamLobby.connect("retrieved_lobby_members", self, "_on_retrieved_lobby_members", [], CONNECT_DEFERRED)
	SteamLobby.connect("challenge_declined", self, "_on_challenge_declined")
	SteamLobby.connect("challenger_cancelled", self, "_on_challenger_cancelled")
	$"%BackButton".connect("pressed", self, "_on_back_button_pressed")
	$"%StartButton".connect("pressed", self, "_on_start_button_pressed")
	$"%ChallengeCancelButton".connect("pressed", self, "_on_challenge_cancelled")
	$"%ChallengeAcceptButton".connect("pressed", self, "_on_challenge_accept_pressed")
	$"%ChallengeDeclineButton".connect("pressed", self, "_on_challenge_decline_pressed")

	$"%GameSettingsPanelContainer".init(false)
	_on_retrieved_lobby_members(SteamLobby.LOBBY_MEMBERS)
	yield (get_tree(), "idle_frame")
	if SteamLobby.REMATCHING_ID != 0:
		SteamLobby._setup_game_vs(SteamLobby.REMATCHING_ID)
	handshake_made = false


func _on_lobby_data_update(steam_id, member_id, success):
	if Steam.getLobbyOwner(SteamLobby.LOBBY_ID) == SteamYomi.STEAM_ID:
		$"%GameSettingsPanelContainer".enable()
		$"%GameSettingsPanelContainer".update_lobby_data()
	SteamLobby._get_Lobby_Members()

func _on_challenge_accept_pressed():
	SteamLobby.accept_challenge()
	$"%ChallengeDialogScreen".hide()

func _on_challenge_decline_pressed():
	SteamLobby.decline_challenge()
	$"%ChallengeDialogScreen".hide()

func _on_received_challenge(steam_id):
	$"%ChallengeLabel".text = Steam.getFriendPersonaName(steam_id) + " has challenged you."
	$"%ChallengeDialogScreen".show()

func _on_challenge_cancelled():
	SteamLobby.cancel_challenge()
	$"%SendChallengeDialogScreen".hide()

func _on_user_challenge_pressed():
	$"%SendChallengeDialogScreen".show()

func show():
	.show()
	init()

func init():
	$"%LoadingLobbyRect".hide()
	Steam.setLobbyMemberData(SteamLobby.LOBBY_ID, "status", "idle")
	if Steam.getLobbyOwner(SteamLobby.LOBBY_ID) != SteamYomi.STEAM_ID:
		SteamLobby.request_match_settings()
		$"%LobbyLabel".text = Steam.getLobbyData(SteamLobby.LOBBY_ID, "name")
		$"%GameSettingsPanelContainer".init(false)
		$"%GameSettingsPanelContainer".disable()
		if not handshake_made:
			$"%LoadingLobbyRect".show()
			yield (SteamLobby, "received_match_settings")
			$"%LoadingLobbyRect".hide()
			handshake_made = true
	else :
		$"%GameSettingsPanelContainer".init(false)
		$"%GameSettingsPanelContainer"._on_received_match_settings(SteamLobby.MATCH_SETTINGS, true)






func _on_challenge_declined():
	$"%ChallengeDialogScreen".hide()
	$"%SendChallengeDialogScreen".hide()

func _on_start_button_pressed():
	if selected_user:
		SteamLobby.challenge_user(selected_user)

func _on_challenger_cancelled():
	$"%ChallengeDialogScreen".hide()

func _on_retrieved_lobby_members(members):
	$"%LobbyLabel".text = Steam.getLobbyData(SteamLobby.LOBBY_ID, "name")
	users.clear()
	for child in $"%UserList".get_children():
		child.free()
	
	matches.clear()
	for child in $"%MatchList".get_children():
		child.free()

	for member in members:
		var user_scene = preload("res://ui/SteamLobby/LobbyUser.tscn").instance()
		$"%UserList".add_child(user_scene)
		user_scene.init(member)
		user_scene.connect("challenge_pressed", self, "_on_user_challenge_pressed")

		print("updating members")
		users.append(member)
		
		if member.status == "fighting" and member.opponent_id != 0 and member.player_id != 0:
			if not (member.opponent_id in matches):
				var opponent
				for potential_opponent in members:
					if potential_opponent.steam_id == member.opponent_id:
						opponent = potential_opponent
						break
				if opponent:

					if opponent.opponent_id == 0 or opponent.player_id == 0:
						continue
					var p1 = opponent if opponent.player_id == 1 else member
					var p2 = opponent if p1 == member else member
					matches[member.steam_id] = {
						"p1":p1, 
						"p2":p2, 
					}

	for match_ in matches.values():
		print("updating matches")
		var match_scene = preload("res://ui/SteamLobby/LobbyMatch.tscn").instance()
		match_scene.connect("spectate_requested", self, "_on_spectate_requested")
		$"%MatchList".add_child(match_scene)
		match_scene.init(match_.p1, match_.p2)
	
	for child in $"%UserList".get_children():
		child.update_avatar()
		yield (child, "avatar_loaded")

	if Steam.getLobbyOwner(SteamLobby.LOBBY_ID) == SteamYomi.STEAM_ID:
		$"%GameSettingsPanelContainer".enable()

func _on_spectate_requested(player):
	SteamLobby.request_spectate(player.steam_id)
	pass

func _on_back_button_pressed():
	Network.stop_multiplayer(true)
	get_tree().reload_current_scene()
