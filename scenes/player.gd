extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 1200.0
const CROSSHAIR_RADIUS := 64.0

@onready var projectile_scene = preload("res://Projectile.tscn")
@onready var spawn_point = $ProjectileSpawn
@onready var sprite = $AnimatedSprite2D
@onready var crosshair = $Crosshair

var last_aim_direction := Vector2.RIGHT  # default aim direction if stick is idle

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Aiming input (controller stick only)
	var aim_vector := Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)

	if aim_vector.length() > 0:
		last_aim_direction = aim_vector.normalized()

	# Update crosshair based on last valid aim direction
	crosshair.global_position = global_position + last_aim_direction * CROSSHAIR_RADIUS
	crosshair.rotation = last_aim_direction.angle() + PI / 2

	# Jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Shooting
	if Input.is_action_just_pressed("shoot"):
		var p = projectile_scene.instantiate()
		p.global_position = spawn_point.global_position
		p.direction = last_aim_direction
		get_tree().current_scene.add_child(p)

	# Horizontal movement input
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Sprite flip and animation
	if not is_on_floor():
		sprite.play("jump")
	elif direction < 0:
		sprite.flip_h = true
		sprite.play("walk_right")
	elif direction > 0:
		sprite.flip_h = false
		sprite.play("walk_right")
	else:
		sprite.play("idle")

	# Apply movement
	move_and_slide()
