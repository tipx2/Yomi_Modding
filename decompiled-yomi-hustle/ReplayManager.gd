extends Node


var frames = {
	1:{}, 
	2:{}, 
	"finished":false, 
}

var playback = false setget set_playback

var resimulating = false
var play_full = false
var resim_tick = null

func set_playback(p):
	playback = p

func init():
	frames = {
		1:{}, 
		2:{}, 
		"finished":false, 
	}

func frame_ids():
	return [1, 2]

func cut_replay(last_frame):
	for id in frame_ids():
		for frame in frames[id].keys():
			if frame > last_frame:
				frames[id].erase(frame)

func get_last_action_tick(id):
	var frame_numbers:Array = frames[id].keys()
	frame_numbers.sort()
	return frame_numbers[ - 1]

func get_last_action(id):
	var frame_numbers:Array = frames[id].keys()
	frame_numbers.sort()
	return frames[id][frame_numbers[ - 1]]

func undo(cut = true):
	if resimulating:
		return 
	var last_frame = 0
	var last_id = 1
	for id in frame_ids():
		for frame in frames[id].keys():
			if frame > last_frame:
				last_frame = frame
				last_id = id
	var other_id = 1 if last_id == 2 else 2
	if cut:
		frames[last_id].erase(last_frame)
		frames[other_id].erase(last_frame)
	resimulating = true
	playback = true
	resim_tick = (last_frame - 2) if cut else - 1
	
func generate_mp_replay_name(p1:String, p2:String):
	return p1 + "_v_" + p2 + "_" + generate_replay_name()

func generate_replay_name():
	var time = Time.get_datetime_dict_from_system()
	var strings = [str(time.year), str(time.month), str(time.day), str(time.hour), str(time.minute)]
	var string = ""
	for s in strings:
		string += s
		string += "-"
	string += str(time.second)
	return string

func save_replay_mp(match_data, p1, p2):
	save_replay(match_data, generate_mp_replay_name(p1, p2), true)



func save_replay(match_data:Dictionary, file_name = "", autosave = false):
	if file_name == "":
		file_name = generate_replay_name()
	file_name = Utils.filter_filename(file_name)
	
	var data = match_data.duplicate(true)
	data["frames"] = frames

	var dir = Directory.new()
	if not dir.dir_exists("user://replay"):
		dir.make_dir("user://replay")
	if not dir.dir_exists("user://replay/autosave"):
		dir.make_dir("user://replay/autosave")
	var file = File.new()

	print(file_name)
	file.open("user://replay/" + ("autosave/" if autosave else "") + file_name + ".replay", File.WRITE)
	file.store_var(data, true)
	file.close()
	return file_name + ".replay"

func load_replays(autosave = true):
	var dir = Directory.new()
	var files = []
	var _directories = []
	if not dir.dir_exists("user://replay"):
		dir.make_dir("user://replay")
	if not dir.dir_exists("user://replay/autosave"):
		dir.make_dir("user://replay/autosave")
	dir.open("user://replay")
	dir.list_dir_begin(false, true)

	Global.add_dir_contents(dir, files, _directories, autosave)
	var replay_paths = {}
	for path in files:
		var file = File.new()
		var modified = file.get_modified_time(path)
		var data = {
			"path":path, 
			"modified":modified, 
		}
		if ".replay" in path:
			replay_paths[path.split("/")[ - 1].split(".")[0]] = data
	return replay_paths

func load_replay(path):
	var file = File.new()
	file.open(path, File.READ)
	var data:Dictionary = file.get_var()
	frames = data.frames
	var match_data = data.duplicate(true)
	match_data.erase("frames")
	return match_data

func force_ints(dict):
	for key in dict:
		if dict[key] is float:
			dict[key] = int(dict[key])
		if dict[key] is Dictionary:
			force_ints(dict[key])
