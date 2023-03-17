extends Node2D

func _ready():
	VisualServer.set_default_clear_color(Color.lightslategray)

func _process(delta):
	if Input.is_action_just_pressed("reset"): get_tree().reload_current_scene()
