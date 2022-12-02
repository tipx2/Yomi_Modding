extends DefaultFireball
const ATTACH_DISTANCE = "16"




var attach_frames = 0

func _frame_0():
	attach_frames = 0

func _tick():
	if host.attached:
		host.set_facing(host.creator.opponent.get_facing_int())
		var pos = host.creator.opponent.get_hurtbox_center()
		host.set_pos(pos.x, pos.y)
	else :
		host.update_grounded()
		var pos = host.get_pos()
		var opp_pos = host.creator.opponent.get_hurtbox_center()
		var opp:Fighter = host.creator.opponent
		if fixed.lt(fixed.vec_dist(str(pos.x), str(pos.y), str(opp_pos.x), str(opp_pos.y)), ATTACH_DISTANCE):
			attach_frames += 1
		else :
			attach_frames = 0
		if attach_frames > 2:
			if not opp.invulnerable and not opp.projectile_invulnerable:
				host.attached = true
	if current_tick > 120:
		host.big_explode()
