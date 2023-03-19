extends KinematicBody2D

class_name player

enum { move, climb }

var state = move

var velocity = Vector2.ZERO
var fast_fall = false

var buffered_jump = false
var coyote_jump = false

export(int) var max_speed = 100
export(int) var acceleration = 15
export(int) var friction = 15

export(int) var gravity = 5
export(int) var fast_fall_height = 20
export(int) var fast_fall_speed = 40
export(int) var jump_height = -120
export(int) var jump_release = -50

export(int) var climb_speed = 60

export(int) var max_health = 6
var health = max_health

var hp_green = preload("res://scenes/player/health bar green.tres")
var hp_yellow = preload("res://scenes/player/health bar yellow.tres")
var hp_red = preload("res://scenes/player/health bar red.tres")

func _ready():
	$AnimatedSprite.animation = "idle"

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	
	if input.x < 0:
		$AnimatedSprite.flip_h = true
	elif input.x > 0:
		$AnimatedSprite.flip_h = false
	
	match state:
		move: move_state(input)
		climb: climb_state(input)
	
	if Input.is_action_just_pressed("reset"):
		position.x = 136
		position.y = 132
	
	if health <= 0: 
		get_tree().reload_current_scene()
		health = max_health
	
	$"health bar/ProgressBar".value = health
	$"health bar/ProgressBar".max_value = max_health
	
	if $"health bar/ProgressBar".value == $"health bar/ProgressBar".max_value:
		$"health bar/ProgressBar".theme = hp_green
	elif $"health bar/ProgressBar".max_value / $"health bar/ProgressBar".value < 2:
		$"health bar/ProgressBar".theme = hp_yellow
	else:
		$"health bar/ProgressBar".theme = hp_red

func move_state(input):
	if is_on_ladder() and Input.is_action_pressed("up"): state = climb
	
	apply_gravity()
	
	if input.x == 0:
		apply_friction()
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.playing = false
	else:
		apply_acceleration(input.x)
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.playing = true
	
	if is_on_floor() or coyote_jump:
		fast_fall = false
		
		if Input.is_action_just_pressed("jump") or buffered_jump:
			velocity.y = jump_height

			buffered_jump = false
	else:
		$AnimatedSprite.animation = "jump"
		$AnimatedSprite.playing = false
		
		$CollisionShape2D.scale.y = 0.8
		
		if Input.is_action_just_released("jump") and velocity.y < jump_release:
			velocity.y = jump_release
		
		if velocity.y > fast_fall_height and not fast_fall:
			velocity.y += fast_fall_speed
			fast_fall = true

		if Input.is_action_just_pressed("jump"):
			buffered_jump = true
			$JumpBuffer.start()
	
	var was_in_air = not is_on_floor()

	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor() and was_in_air:
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.frame = 1
		
		$CollisionShape2D.scale.y = 1
	
	var just_left_ground = not is_on_floor() and was_on_floor

	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		$CoyoteTime.start()

func climb_state(input):
	if not is_on_ladder(): state = move
	
	$AnimatedSprite.animation = "idle"
	
	velocity = input * climb_speed
	velocity = move_and_slide(velocity, Vector2.UP)

func is_on_ladder():
	if not $RayCast2D.is_colliding():
		return false
	
	var collider = $RayCast2D.get_collider()
	
	if not collider is ladder:
		return false
	
	return true

func apply_gravity():
	velocity.y += gravity
	velocity.y = min(velocity.y, 150)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, friction)

func apply_acceleration(strength):
	velocity.x = move_toward(velocity.x, max_speed * strength, acceleration)

func _on_JumpBuffer_timeout():
	buffered_jump = false

func _on_CoyoteTime_timeout():
	coyote_jump = false
	
func take_damage():
	if $IFrames.is_stopped():
		health -= 1
		$IFrames.start()
		$AnimatedSprite.modulate.a = .5

func _on_IFrames_timeout():
	$AnimatedSprite.modulate.a = 1

func heal():
	if health > max_health: health = max_health
	elif health == max_health: pass
	else: health += 1

func _on_HealCooldown_timeout():
	heal()

func _on_spikes_player_entered_spike():
	velocity.y = jump_height * 1.25
	take_damage()

func _on_campfire_player_entered_campfire():
	$HealCooldown.start()

func _on_campfire_player_exited_campfire():
	$HealCooldown.stop()
