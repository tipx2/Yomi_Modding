extends Window

const MOVE_SPEED = 0.15 * 60
var STEAM_URL = "https://store.steampowered.com/app/2212330/Yomi_Hustle/"




var dir = Vector2(1, 1)


func _ready():
	$"%ShowButton".connect("pressed", self, "queue_free")
	$"%StoreButton".connect("pressed", OS, "shell_open", [STEAM_URL])
	pass




func _on_LabelBlink_timeout():
	if $"%Title".modulate.a == 0.0:
		$"%Title".modulate.a = 1.0
	else :
		$"%Title".modulate.a = 0.0

func _process(delta):
	rect_position += MOVE_SPEED * dir * delta
	var viewport_size = get_viewport_rect().size
	if rect_global_position.x < 0:
		dir.x = - dir.x
		rect_global_position.x = 0
	if rect_global_position.y < 0:
		dir.y = - dir.y
		rect_global_position.y = 0
	if rect_global_position.x + rect_size.x > viewport_size.x:
		dir.x = - dir.x
		rect_global_position.x = viewport_size.x - rect_size.x
	if rect_global_position.y + rect_size.y > viewport_size.y:
		dir.y = - dir.y
		rect_global_position.y = viewport_size.y - rect_size.y
