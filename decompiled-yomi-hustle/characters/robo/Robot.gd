extends Fighter

const MAX_ARMOR_PIPS = 1

var armor_pips = 1

func _ready():
	pass

func init(pos = null):
	.init(pos)
	armor_pips = 1

func on_got_hit():
	if armor_pips > 0:
		armor_pips -= 1

func has_armor():
	return armor_pips > 0

func incr_combo():
	if combo_count == 0:
		armor_pips += 1
		if armor_pips > MAX_ARMOR_PIPS:
			armor_pips = MAX_ARMOR_PIPS
	.incr_combo()
	pass













