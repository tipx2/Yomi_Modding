extends CharacterState

const LASSO_SCENE = preload("res://characters/swordandgun/projectiles/Lasso.tscn")
const LASSO_LIFT = 6
const THROW_SPEED = 14

var lasso_hit = false
var hit_cancelled = false
var lasso_hit_frame = 0

onready var ANIM_LENGTH = anim_length

func _enter():
	anim_length = ANIM_LENGTH
	lasso_hit = false
	hit_cancelled = false

	lasso_hit_frame = 0
	fallback_state = "Wait"

func _frame_7():
	var obj = host.spawn_object(LASSO_SCENE, 16, - 16)
	host.lasso_projectile = obj.obj_name
	obj.apply_force_relative(THROW_SPEED, - LASSO_LIFT)
	var vel = host.get_vel()
	obj.apply_force(vel.x, vel.y)
	obj.connect("lasso_hit", self, "on_lasso_hit")

func on_lasso_hit(_opponent):
	if not active:
		return 
	lasso_hit = true
	lasso_hit_frame = current_tick
	var opp_pos = host.opponent.get_hurtbox_center()
	var obj = host.objs_map[host.lasso_projectile]
	obj.set_pos(opp_pos.x, opp_pos.y)
	queue_state_change("LassoHit")


func _tick():
	if host.lasso_projectile:
		var obj = host.objs_map[host.lasso_projectile]
		if not obj.is_connected("lasso_hit", self, "on_lasso_hit"):
			obj.connect("lasso_hit", self, "on_lasso_hit")
	
	host.apply_grav()
	host.apply_fric()
	host.apply_forces()

func _exit():
	if host.lasso_projectile and not lasso_hit:
		if host.objs_map[host.lasso_projectile]:
			host.objs_map[host.lasso_projectile].disable()
		host.lasso_projectile = null
