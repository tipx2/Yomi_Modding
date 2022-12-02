extends BaseObj

class_name BaseProjectile

export  var immunity_susceptible = true
export  var deletes_other_projectiles = true



func disable():
	sprite.hide()
	disabled = true
	for hitbox in get_active_hitboxes():
		hitbox.deactivate()
	stop_particles()
