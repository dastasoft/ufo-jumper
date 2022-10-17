extends CanvasLayer

export var scroll_speed = 0.2
onready var stars_background = $StarsBackground


func _ready():
	stars_background.material.set_shader_param("scroll_speed", scroll_speed)
