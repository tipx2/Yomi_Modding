extends CharacterState

export  var GROUNDED_LIFT = "-15.0"
export  var AERIAL_LIFT = "-7.0"


func _frame_7():
	var vel = host.get_vel()
	host.set_vel(vel.x, "0")
	host.apply_force_relative("0", GROUNDED_LIFT if host.is_grounded() else AERIAL_LIFT)

func _tick():
	host.update_grounded()
	if current_tick > 6:
		host.apply_grav()
