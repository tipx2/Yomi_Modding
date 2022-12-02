extends ObjectState

const FREE_AFTER_TICKS = 60

export  var _c_Projectile_Dir = 0
export  var move_speed = "15.0"

export  var _c_Homing_Options = 0
export  var homing = false
export  var homing_turn_speed = "3.0"
export  var homing_accel = "1.0"
export  var max_homing_speed = "10"
export  var start_homing = false
export  var lifetime = 99999

var hit_something = false
var hit_something_tick = 0

func _frame_1():
	hit_something = false
	hit_something_tick = 0
	host.set_grounded(false)
	if homing:
		if start_homing:
			var dir = data["dir"]
			var move_vec = fixed.normalized_vec_times(str(dir.x), str(dir.y), move_speed)
			host.apply_force(move_vec.x, move_vec.y)
		else :
			host.apply_force_relative(move_speed, "0.01")

func _tick():
	var pos = host.get_pos()
	host.update_grounded()
	if current_tick > 1 and not hit_something and host.is_grounded() or pos.x < - host.stage_width or pos.x > host.stage_width:
		fizzle()
		host.hurtbox.width = 0
		host.hurtbox.height = 0
		pass
	if current_tick > lifetime:
		fizzle()
		host.hurtbox.width = 0
		host.hurtbox.height = 0
	elif not hit_something:
		var dir
		if not homing:
			dir = data["dir"]
			var move_vec = fixed.normalized_vec_times(str(dir.x), str(dir.y), move_speed)
	
			host.move_directly(move_vec.x, move_vec.y)
			host.sprite.rotation = float(fixed.vec_to_angle(dir.x, dir.y))
		else :
			var target = host.obj_local_center(host.creator.opponent)
			var vel = host.get_vel()
			var current = fixed.normalized_vec(vel.x, vel.y)
			var desired = fixed.normalized_vec(str(target.x), str(target.y))
			var steering_x = fixed.sub(desired.x, current.x)
			var steering_y = fixed.sub(desired.y, current.y)
			var steer_force = fixed.normalized_vec_times(steering_x, steering_y, homing_turn_speed)
			var force_x = fixed.mul(current.x, homing_accel)
			var force_y = fixed.mul(current.y, homing_accel)
			if not fixed.eq(vel.x, "0"):
				host.set_facing(1 if fixed.gt(vel.x, "0") else - 1)
			host.apply_force(force_x, force_y)
			host.apply_force(steer_force.x, steer_force.y)
			host.apply_forces()
			
			host.update_data()
			var new_vel = host.get_vel()
			if fixed.gt(fixed.vec_len(new_vel.x, new_vel.y), max_homing_speed):
				var clamped_vel = fixed.normalized_vec_times(new_vel.x, new_vel.y, max_homing_speed)
				host.set_vel(clamped_vel.x, clamped_vel.y)
			host.sprite.rotation = float(fixed.vec_to_angle(fixed.mul(new_vel.x, str(host.get_facing_int())), new_vel.y))

func _got_parried():
	if homing:
		fizzle()

func fizzle():
	hit_something = true
	host.disable()
	terminate_hitboxes()
	hit_something_tick = current_tick

func _on_hit_something(_obj, _hitbox):
	fizzle()
