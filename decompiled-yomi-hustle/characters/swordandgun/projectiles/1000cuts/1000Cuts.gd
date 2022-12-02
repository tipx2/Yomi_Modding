extends BaseProjectile





var total_ticks = 0


func _ready():
	if creator_name:
		creator = objs_map[creator_name]
