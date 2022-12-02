extends CharacterState

export  var release = false

const RELEASE_MODIFIER = "1.35"

func _frame_1():
	if not release:
		var vel = host.get_vel()
		host.stored_momentum_x = vel.x
		host.stored_momentum_y = vel.y
		host.reset_momentum()
		host.storing_momentum = true
	else :
		host.reset_momentum()
		host.storing_momentum = false
		host.set_vel(fixed.mul(host.stored_momentum_x, RELEASE_MODIFIER), fixed.mul(host.stored_momentum_y, RELEASE_MODIFIER))

func _tick():
	if not release:
		host.apply_fric()
		host.apply_grav()
		host.apply_forces()
	else :
		host.apply_forces_no_limit()

func is_usable():
	if not release:
		return .is_usable() and not host.storing_momentum
	return .is_usable() and host.storing_momentum
