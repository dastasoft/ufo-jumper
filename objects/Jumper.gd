extends Area2D

signal captured
signal died

onready var trail = $Trail/Points

var velocity = Vector2(100, 0)
var jump_speed = 1000
var target = null
var trail_length = 15
var min_jump_pitch = 1.0
var max_jump_pitch = 3.0


func _unhandled_input(event):
	if target and event is InputEventScreenTouch and event.pressed:
		jump()


func jump():
	target.implode()
	target = null
	velocity = transform.x * jump_speed
	
	if settings.enable_sound:
		$Jump.play()


func _on_Jumper_area_entered(area):
	target = area
	velocity = Vector2.ZERO
	emit_signal("captured", area)
	
	if settings.enable_sound:
		$Capture.play()


func _physics_process(delta):
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	trail.add_point(position)
	if target:
		transform = target.orbit_position.global_transform
	else:
		position += velocity * delta


func die():
	target = null
	queue_free()


func increase_jump_pitch(bonus = 1):
	$Jump.pitch_scale = clamp(bonus / 10.0 + 0.9, min_jump_pitch, max_jump_pitch)


func _on_VisibilityNotifier2D_screen_exited():
	if !target:
		emit_signal("died")
		die()
