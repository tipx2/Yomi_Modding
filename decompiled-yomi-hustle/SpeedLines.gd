tool 

extends Control
const NUM_LINES = 100
const LINE_MIN_SIZE = 20
const LINE_MAX_SIZE = 200
const TICK_DIV = 100.0
const SPEED = 1
const CAMERA_SPEED_DIVISOR = 16.0
const MIN_INTENSITY = 0.05




export  var dir = Vector2()
export  var intensity = 100.0
export  var noise:OpenSimplexNoise
export  var noise2:OpenSimplexNoise
export  var on = false
export (float, EASE) var intensity_easing = 0
var speed = 0.0
var center = Vector2(320, 180)
var tick = 0

func set_direction(dir):
	self.dir = - dir

func set_speed(speed):
	
	intensity = pow(lerp(intensity, clamp(abs(speed) / CAMERA_SPEED_DIVISOR, MIN_INTENSITY, 1.0), 0.95), 2)
	self.speed = speed


func get_line_x(num):
	var t = tick / TICK_DIV * speed
	return noise.get_noise_2d(num, t) * 640
	
func get_line_y(num):
	var t = tick / TICK_DIV * speed
	return noise2.get_noise_2d(num, t) * 360

func get_variation(num):
	return noise2.get_noise_1d(num)

func _physics_process(delta):
	update()
	tick += 1

func _draw():

	if on and intensity > 0.25:
		dir = dir.normalized()
		
		for i in range(NUM_LINES):
			var variation = get_variation(NUM_LINES - i)

			var x = get_line_x(i)
			var y = get_line_y(i)
		
			var pos = Vector2(x, y) + (tick * dir * (speed * abs(intensity)))
			pos.x = fposmod(pos.x, 640)
			pos.y = fposmod(pos.y, 360)
			var distance_to_center = Vector2(abs(pos.x - center.x) / 400, abs(pos.y - center.y) / 200)


			var line_intensity = intensity * variation * ease(distance_to_center.length(), intensity_easing)
			var line_size = lerp(LINE_MIN_SIZE, LINE_MAX_SIZE, line_intensity)
			var start = pos - dir * line_size / 2.0
			var end = pos + dir * line_size / 2.0
	
			var color = Color.white
			color.a = max(line_intensity, 0)
			draw_line(start, end, color, 1.5 + line_intensity)
