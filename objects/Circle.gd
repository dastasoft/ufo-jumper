extends Area2D

signal full_orbit

var Asteroid = preload("res://objects/Asteroid.tscn")

onready var orbit_position = $Pivot/OrbitPosition
onready var move_tween = $MoveTween
onready var asteroid_orbit_position = $Pivot2/AsteroidOrbitPosition

enum MODES {STATIC, LIMITED}

var radius = 120
var rotation_speed = PI
var asteroid_rotation_speed = PI
var mode = MODES.STATIC
var move_range = 0
var move_speed = 2.0
var num_orbits = 3
var current_orbits = 0
var orbit_start = null
var jumper = null
var move_chance_ratio = 5


func init(_position, level = 1):
	var _mode = settings.rand_weighted([10, level - 1])
	set_mode(_mode)
	
	position = _position
	
	var move_chance = clamp(level - move_chance_ratio, 0, 9) / 10.0
	if randf() < move_chance:
		move_range = max(25, 100 * rand_range(0.75, 1.25) * move_chance) * pow(-1, randi() % 2)
		move_speed = max(2.5 - ceil(level / 5) * 0.25, 0.75)

	var small_chance = min(0.9, max(0, (level - 10) / 20.0))
	if randf() < small_chance:
		radius = max(50, radius - level * rand_range(0.75, 1.25))

	$Sprite.texture = load("res://assets/images/planets/planet0%s.png" % str(randi() % 10))
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape.radius = radius

	var img_size = $Sprite.texture.get_size().x / 2
	$Sprite.scale = Vector2(1, 1) * radius / img_size
	orbit_position.position.x = radius
	rotation_speed *= pow(-1, randi() % 2)
	asteroid_rotation_speed *= pow(-1, randi() % 5)
	set_tween()


func spawn_asteroid():
	var asteroid = Asteroid.instance()
	
	var multiplier = pow(-1, randi() % 2)
	var positions = [Vector2(170 * multiplier, 0 * multiplier), Vector2(0 * multiplier, 170 * multiplier)]
	$Pivot2/AsteroidOrbitPosition.position = positions[randi() % 2]
	$Pivot2/AsteroidOrbitPosition.add_child(asteroid)


func set_mode(_mode):
	mode = _mode
	match mode:
		MODES.STATIC:
			$Label.hide()
		MODES.LIMITED:
			$Label.text = str(num_orbits)
			$Label.show()


func _process(delta):
	$Pivot.rotation += rotation_speed * delta
	$Pivot2.rotation += asteroid_rotation_speed * delta
	if jumper:
		check_orbits()
		update()


func check_orbits():
	if abs($Pivot.rotation - orbit_start) > 2 * PI:
		current_orbits += 1
		emit_signal("full_orbit")
		
		if mode == MODES.LIMITED:
			if settings.enable_sound:
				$Beep.play()
		
			$Label.text = str(num_orbits - current_orbits)
			if current_orbits >= num_orbits:
				jumper.die()
				jumper = null
				implode()
		orbit_start = $Pivot.rotation


func implode():
	jumper = null
	$AnimationPlayer.play("implode")
	yield($AnimationPlayer, "animation_finished")
	queue_free()


func capture(target):
	current_orbits = 0
	jumper = target
	$AnimationPlayer.play("capture")
	$Pivot.rotation = (jumper.position - position).angle()
	orbit_start = $Pivot.rotation


func set_tween(_object=null, _key=null):
	if move_range == 0:
		return
	move_range *= -1
	move_tween.interpolate_property(self, "position:x", position.x, position.x + move_range, move_speed, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	move_tween.start()
