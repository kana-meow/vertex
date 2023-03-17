extends Area2D

signal player_entered_spike

func _on_spikes_body_entered(body):
	if body is player:
		emit_signal("player_entered_spike")
