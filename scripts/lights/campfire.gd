extends Area2D

signal player_entered_campfire
signal player_exited_campfire

func _on_campfire_body_entered(body):
	if body is player:
		emit_signal("player_entered_campfire")

func _on_campfire_body_exited(body):
	if body is player:
		emit_signal("player_exited_campfire")
