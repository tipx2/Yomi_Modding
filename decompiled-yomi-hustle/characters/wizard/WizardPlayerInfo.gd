extends PlayerInfo

onready var hover_bar = $"%HoverBar"

func set_fighter(fighter):
	.set_fighter(fighter)
	if player_id == 2:
		$"%HoverBar".fill_mode = TextureProgress.FILL_RIGHT_TO_LEFT
		$HBoxContainer.alignment = BoxContainer.ALIGN_END

func _process(delta):
	if is_instance_valid(fighter):
		hover_bar.value = fighter.hover_left / float(fighter.HOVER_AMOUNT)
		hover_bar.modulate.a = 0.25 if fighter.hover_left <= fighter.HOVER_MIN_AMOUNT else 1.0
	
		hover_bar.tint_progress = Color("64d26b") if not fighter.hovering else Color("ff333d")
