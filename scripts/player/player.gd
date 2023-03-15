extends KinematicBody2D

class_name player

var velocity = Vector2.ZERO
var fast_fall = false

export(int) var max_speed = 100
export(int) var jump_height = -120
export(int) var jump_release = -50
export(int) var fast_fall_height = 20
export(int) var fast_fall_speed = 40
export(int) var acceleration = 15
export(int) var friction = 15
export(int) var gravity = 5

func _physics_process(delta):
	apply_gravity()
	
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("key_d") - Input.get_action_strength("key_a")
	
	if input.x == 0:
		apply_friction()
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.playing = false
	else:
		apply_acceleration(input.x)
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.playing = true
		
		if input.x < 0:
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
	
	if is_on_floor():
		fast_fall = false
		
		if Input.is_action_just_pressed("key_space"):
			velocity.y = jump_height
	else:
		$AnimatedSprite.animation = "jump"
		$AnimatedSprite.playing = false
		
		$CollisionShape2D.scale.y = 0.8
		
		if Input.is_action_just_released("key_space") and velocity.y < jump_release:
			velocity.y = jump_release
		
		if velocity.y > fast_fall_height and not fast_fall:
			velocity.y += fast_fall_speed
			fast_fall = true
	
	var was_in_air = not is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor() and was_in_air:
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.frame = 1
		
		$CollisionShape2D.scale.y = 1

func apply_gravity():
	velocity.y += gravity
	velocity.y = min(velocity.y, 150)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, friction)

func apply_acceleration(strength):
	velocity.x = move_toward(velocity.x, max_speed * strength, acceleration)
