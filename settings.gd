extends Node

var score_file = "user://highscore.save"
var settings_file = "user://settings.save"
var enable_sound = true
var enable_music = true

var circles_per_level = 5

func _ready():
	load_settings()

static func rand_weighted(weights):
	var sum = 0
	for weight in weights:
		sum += weight
	
	var num = rand_range(0, sum)
	for i in weights.size():
		if num < weights[i]:
			return i
		num -= weights[i]

func save_settings():
	var f = File.new()
	f.open(settings_file, File.WRITE)
	f.store_var(enable_sound)
	f.store_var(enable_music)
	f.close()

func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)
		var _enable_sound = f.get_var()
		if _enable_sound != null:
			enable_sound = _enable_sound

		var _enable_music = f.get_var()
		if _enable_music != null:
			enable_music = _enable_music
		f.close()
