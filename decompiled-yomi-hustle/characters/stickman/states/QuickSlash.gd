extends SuperMove

const MOVE_DISTANCE = 120

var hitboxes = []
var move_dir

var dist = MOVE_DISTANCE
var start_pos_x
var start_pos_y

func _enter():
	dist = MOVE_DISTANCE
	hitboxes = []
	for child in get_children():
		if child is Hitbox:
			hitboxes.append(child)
			child.x = 0
			child.y = 0
	if data:
		move_dir = xy_to_dir(data.x, data.y)

	else :
		move_dir = {"x":str(host.get_facing_int()), "y":"0"}
		
	var move_vec = fixed.normalized_vec_times(move_dir.x, move_dir.y, "20")

	host.apply_force(move_vec.x, fixed.div(move_vec.y, "2"))































func _frame_1():
	var start_pos = host.get_pos().duplicate()
	start_pos_x = start_pos.x
	start_pos_y = start_pos.y

func _frame_4():
	pass


func _frame_5():

	host.move_directly(0, - 2)


	var move_vec = fixed.normalized_vec_times(move_dir.x, move_dir.y, str(MOVE_DISTANCE))


	host.move_directly(move_vec.x, move_vec.y)
	host.update_data()
	
	var end_pos = host.get_pos().duplicate()
	if start_pos_x != null and start_pos_y != null and end_pos.x != null and end_pos.y != null:
		for i in range(hitboxes.size()):
			var ratio = fixed.div(str(i), str(hitboxes.size()))
			hitboxes[i].x = fixed.round(fixed.sub(fixed.lerp_string(str(start_pos_x), str(end_pos.x), ratio), str(host.get_pos().x))) * host.get_facing_int()
			hitboxes[i].y = fixed.round(fixed.sub(fixed.lerp_string(str(start_pos_y), str(end_pos.y), ratio), str(host.get_pos().y))) - 16
	
	move_vec.x = end_pos.x - start_pos_x
	move_vec.y = end_pos.y - start_pos_y
	var pos = host.get_pos_visual()
	var particle_dir = Vector2(float(move_vec.x), float(move_vec.y)).normalized()
	host.spawn_particle_effect(preload("res://characters/stickman/QuickSlashEffect.tscn"), Vector2(start_pos_x, start_pos_y - 13), particle_dir)
	host.update_data()

func _frame_6():
	host.reset_momentum()
	var move_vec = fixed.normalized_vec_times(move_dir.x, move_dir.y, "10")
	host.apply_force(move_vec.x, fixed.mul(move_dir.y, "1.0"))
	host.apply_force("0", "-1")



func _tick():
	if current_tick > 6:
		if host.is_grounded():
			queue_state_change("Landing", 2)
	host.apply_grav()
	host.apply_fric()
	host.apply_forces_no_limit()
