extends RobotState

const MOVE_AMOUNT = 10






func _ready():
	pass

func _frame_6():
	self_interruptable = false
	host.move_directly_relative(MOVE_AMOUNT, 0)




func _frame_8():
	host.play_sound("Step")

func _frame_9():
	self_interruptable = true
	var camera = host.get_camera()
	if camera:
		camera.bump(Vector2.UP, 10, 6 / 60.0)
