extends BaseProjectile

const ACCEL_SPEED = "0.30"
const FRIC = "0.04"
const DIRECT_MOVE_SPEED = "3.0"
const PUSH_SPEED_LIMIT = "8"

const ORB_DART_SCENE = preload("res://characters/wizard/projectiles/OrbDart.tscn")
const LOCK_PARTICLE = preload("res://characters/wizard/projectiles/orb/OrbSpawnParticle.tscn")
const DISABLE_PARTICLE = preload("res://characters/wizard/projectiles/orb/OrbSpawnParticle.tscn")
const PUSH_PARTICLE = preload("res://characters/wizard/projectiles/orb/OrbSpawnParticle.tscn")
const PUSH_TICKS = 30

var triggered_attacks = {}

var frozen = false
var locked = false

var push_ticks = 0
var push_dir = null

func _ready():
	pass

func get_target_pos():
	var local_pos = obj_local_center(creator)
	return {
		"x":local_pos.x - creator.get_facing_int() * 30, 
		"y":local_pos.y - 12
	}

func lock():
	reset_momentum()
	locked = true
	push_ticks = 0
	spawn_particle_effect_relative(LOCK_PARTICLE)
	play_sound("Lock")

func unlock():
	locked = false
	spawn_particle_effect_relative(LOCK_PARTICLE)
	play_sound("Unock")

func get_travel_dir():
	if creator:
		var local_pos = get_target_pos()
		return fixed.normalized_vec(str(local_pos.x), str(local_pos.y))

func travel_towards_creator():
	var travel_dir = get_travel_dir()
	if travel_dir:
		var force = fixed.vec_mul(travel_dir.x, travel_dir.y, ACCEL_SPEED)

		if get_pos().y == 0:
			var vel = get_vel()
			set_vel(vel.x, fixed.mul(vel.y, "-1"))
			if push_dir:
				push_dir.y = "0"
		apply_x_fric(FRIC)
		apply_y_fric(FRIC)
		apply_force(force.x, force.y)
		if push_ticks > 0:
			if push_dir != null:
				apply_force(fixed.div(push_dir.x, "10"), fixed.div(push_dir.y, "10"))
			limit_speed(PUSH_SPEED_LIMIT)
			apply_forces_no_limit()
		else :
			apply_forces()
		if get_pos().y > - 5:
			apply_force("0", "-" + ACCEL_SPEED)
		var direct_movement = fixed.vec_mul(travel_dir.x, travel_dir.y, DIRECT_MOVE_SPEED)
		var local_pos = get_target_pos()
		if fixed.lt(fixed.vec_len(str(local_pos.x), str(local_pos.y)), "1.5"):
			move_directly(local_pos.x, local_pos.y)
		set_facing(get_object_dir(creator.opponent))

func attempt_triggered_attack():
	if triggered_attacks.has(current_tick):
		attack(triggered_attacks[current_tick])
		triggered_attacks.erase(current_tick)

func trigger_attack(attack_type, attack_delay):
	triggered_attacks[current_tick + attack_delay] = attack_type

func attack(attack_type):
	match attack_type:
		"OrbDart":
			spawn_orb_dart()

func push(fx, fy):
	play_sound("Push")

	push_ticks = PUSH_TICKS
	push_dir = FixedVec2String.new(fx, fy)

	spawn_particle_effect_relative(PUSH_PARTICLE)

func disable():
	.disable()
	creator.orb_projectile = null
	spawn_particle_effect_relative(DISABLE_PARTICLE)

func spawn_orb_dart():
	var local_pos = obj_local_center(creator.opponent)
	var dir = fixed.normalized_vec(str(local_pos.x), str(local_pos.y))
	spawn_object(ORB_DART_SCENE, 0, 0, true, {"dir":dir})
	play_sound("Shoot")
