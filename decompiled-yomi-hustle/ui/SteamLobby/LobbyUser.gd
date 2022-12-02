extends Panel

signal challenge_pressed()
signal avatar_loaded()

var member

func _ready():
	Steam.connect("avatar_loaded", self, "_loaded_Avatar")
	$"%ChallengeButton".connect("pressed", self, "on_challenge_pressed")

func init(member):

	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, member.steam_id)
	$"%Username".text = member.steam_name
	self.member = member
	$"%OwnerIcon".visible = false
	$"%ChallengeButton".hide()
	if SteamYomi.STEAM_ID != member.steam_id:
		$"%ChallengeButton".show()
	if Steam.getLobbyOwner(SteamLobby.LOBBY_ID) == member.steam_id:
		$"%OwnerIcon".visible = true
	var status = Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, member.steam_id, "status")
	if status != "idle":
		$"%ChallengeButton".disabled = true
		$"%ChallengeButton".text = status
		if status == "fighting":
			$"%ChallengeButton".text = "fighting " + Steam.getFriendPersonaName(int(Steam.getLobbyMemberData(SteamLobby.LOBBY_ID, member.steam_id, "opponent_id")))

func update_avatar():
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, member.steam_id)

func on_challenge_pressed():
	if member:
		emit_signal("challenge_pressed")
		SteamLobby.challenge_user(member)

func _loaded_Avatar(id:int, size:int, buffer:PoolByteArray)->void :
	if id != member.steam_id:
		return 
	print("Avatar for user: " + str(id))
	print("Size: " + str(size))
	
	var AVATAR = Image.new()
	var AVATAR_TEXTURE:ImageTexture = ImageTexture.new()
	AVATAR.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)
	
	AVATAR_TEXTURE.create_from_image(AVATAR)
	
	$"%AvatarIcon".set_texture(AVATAR_TEXTURE)
	emit_signal("avatar_loaded")
