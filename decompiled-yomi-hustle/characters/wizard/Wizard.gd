extends Fighter

const ORB_SCENE = preload("res://characters/wizard/projectiles/orb/Orb.tscn")
const ORB_PARTICLE_SCENE = preload("res://characters/wizard/projectiles/orb/OrbSpawnParticle.tscn")

const HOVER_AMOUNT = 1200
const HOVER_MIN_AMOUNT = 50
const HOVER_VEL_Y_POS_MODIFIER = "0.70"
const HOVER_VEL_Y_NEG_MODIFIER = "0.94"
const ORB_SUPER_DRAIN = 2
const FAST_FALL_SPEED = "5"
const ORB_PUSH_SPEED = "10.5"

var hover_left = 0
var hover_drain_amount = 5
var hover_gain_amount = 9
var hover_gain_amount_air = 2
var hovering = false
var ghost_started_hovering = false
var fast_falling = false

var orb_projectile
var can_flame_wave = true
var can_vile_clutch = true

onready var liftoff_sprite = $"%LiftoffSprite"

func init(pos = null):
	.init(pos)
	hover_left = HOVER_AMOUNT / 4
	if infinite_resources:
		hover_left = HOVER_AMOUNT
	
func apply_grav():
	if fast_falling:
		apply_grav_custom(FAST_FALL_SPEED, FAST_FALL_SPEED)
	if not hovering:
		.apply_grav()

func apply_grav_fast_fall():
	move_directly("0", FAST_FALL_SPEED)

func apply_grav_custom(grav:String, fall_speed:String):
	if not hovering:
		.apply_grav_custom(grav, fall_speed)

func spawn_orb():
		var orb = spawn_object(ORB_SCENE, - 10, - 56)
		spawn_particle_effect_relative(ORB_PARTICLE_SCENE, Vector2( - 10, - 56))
		orb_projectile = orb.obj_name

func tick():
	.tick()
	if hitlag_ticks <= 0:
		if is_grounded():
			hovering = false
			fast_falling = false
		if hovering:
			if current_state().busy_interrupt_type == CharacterState.BusyInterrupt.Hurt:
				hovering = false
			else :
				var vel = get_vel()
				var modifier = HOVER_VEL_Y_POS_MODIFIER
				if fixed.lt(vel.y, "0"):
					modifier = HOVER_VEL_Y_NEG_MODIFIER
				set_vel(vel.x, fixed.mul(vel.y, modifier))
				if hover_left > 0:
					if not infinite_resources:
						hover_left -= hover_drain_amount
						if hover_left <= 0:
							hovering = false
							hover_left = 0
		if fast_falling:
			if current_state().busy_interrupt_type == CharacterState.BusyInterrupt.Hurt:
				fast_falling = false
		else :
			hover_left += hover_gain_amount if is_grounded() else hover_gain_amount_air
			if hover_left > HOVER_AMOUNT:
				hover_left = HOVER_AMOUNT
	if orb_projectile:
		use_super_meter(ORB_SUPER_DRAIN)
		if super_meter == 0 and supers_available == 0:
			objs_map[orb_projectile].disable()

func process_extra(extra):
	.process_extra(extra)
	if current_state() is CharacterHurtState:
		return 
	if can_hover():
		if extra.has("hover"):
			if is_ghost and ghost_started_hovering:
				hovering = true
			else :
				if not hovering and extra["hover"]:
					play_sound("FastFall")
				hovering = extra["hover"]
				if hovering and is_ghost:
					ghost_started_hovering = true
	else :
		hovering = false
	if can_fast_fall():
		fast_falling = false
		if extra.has("fast_fall"):
			if extra["fast_fall"]:
				if extra["fast_fall"] and not fast_falling:
					play_sound("FastFall")
					set_vel(get_vel().x, FAST_FALL_SPEED)
				fast_falling = extra["fast_fall"]
	else :
		fast_falling = false
	if extra.has("orb_push") and orb_projectile:
		if not (extra.orb_push.x == 0 and extra.orb_push.y == 0):
			var force = fixed.normalized_vec_times(str(extra.orb_push.x), str(extra.orb_push.y), ORB_PUSH_SPEED)
			objs_map[orb_projectile].push(force.x, force.y)

func can_fast_fall():
	return not is_grounded()
func can_hover():
	return not is_grounded() and hover_left > HOVER_MIN_AMOUNT
