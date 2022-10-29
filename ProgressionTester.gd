extends Node2D

var Circle = preload("res://objects/Circle.tscn")
var font = preload("res://assets/fonts/kenney_future.tres")
var level
var last_circle_position
var level_markers = []
var is_first_planet = true
var spawn_chance_ratio = 2


func _ready():
	randomize()
	last_circle_position = $Camera2D.position
	level = 0
	for i in 100:
		is_first_planet = i == 0
		if i % 5 == 0:
			level += 1
			level_markers.append(last_circle_position)
		spawn_circle()
	update()


func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= 15
	if Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += 15
	if Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= 15
	if Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += 15


func spawn_circle(_position=null):
	var c = Circle.instance()
	if !_position:
		var x = rand_range(-150, 150)
		var y = rand_range(-500, -400)
		_position = last_circle_position + Vector2(x, y)
	add_child(c)
	c.init(_position, level)
	last_circle_position = _position
	
	if !is_first_planet:
		var spawn_chance = clamp(level-spawn_chance_ratio, 0, 9) / 10.0
		if randf() < spawn_chance:
			c.spawn_asteroid()


func _draw():
	var l = 1
	for pos in level_markers:
		var s = Vector2(pos.x-480, pos.y-200)
		var e = Vector2(pos.x-80, pos.y-200)
		draw_line(s, e, Color(1, 1, 1), 15)
		draw_string(font, s - Vector2(0, 50), str(l), Color(1, 1, 1))
		l += 1
