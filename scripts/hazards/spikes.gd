extends Area2D

func _on_spikes_body_entered(body):
	if body is player:
		get_tree().reload_current_scene()
