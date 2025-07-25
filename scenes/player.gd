extends CharacterBody2D

const Weapon = preload("res://weapon.gd")
var current_weapon := Weapon.new("Default Gun", 0.7, 100, 0.1, false)
var fire_timer := 0.0

const SPEED := 200.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 600.0
const CROSSHAIR_RADIUS := 24.0

@onready var projectile_scene = preload("res://Projectile.tscn")
@onready var spawn_point = $ProjectileSpawn
@onready var sprite = $AnimatedSprite2D
@onready var crosshair_node = $CrosshairNode
@onready var crosshair_sprite = $CrosshairNode/Crosshair
@onready var audio = $AudioStreamPlayer2D

var is_reloading := false
var reload_timer := 0.0
var air_shots_remaining := current_weapon.max_air_shots
var just_recoiled := false
var last_aim_direction := Vector2.RIGHT
var must_land_to_reload := false

func _physics_process(delta: float) -> void:
	# Handle reload cooldown
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0.0:
			if is_on_floor():
				is_reloading = false
				air_shots_remaining = current_weapon.max_air_shots
			else:
				must_land_to_reload = true

	# Fire rate cooldown
	fire_timer = max(0.0, fire_timer - delta)

	# Shooting logic (if not reloading)
	var should_fire := false
	if not is_reloading:
		if current_weapon.is_automatic:
			should_fire = Input.is_action_pressed("shoot") and fire_timer == 0.0
		else:
			should_fire = Input.is_action_just_pressed("shoot") and fire_timer == 0.0

	if should_fire:
		var grounded = is_on_floor()
		var can_fire_in_air = air_shots_remaining > 0

		if grounded or can_fire_in_air:
			fire_timer = current_weapon.fire_rate

			var p = projectile_scene.instantiate()
			p.global_position = crosshair_node.global_position
			get_tree().current_scene.add_child(p)

			var launch_direction = last_aim_direction.normalized()
			var projectile_speed = p.speed
			p.launch(launch_direction)
			audio.play()

			# Recoil
			var recoil_vector = -launch_direction * projectile_speed * current_weapon.recoil_multiplier
			velocity = recoil_vector

			if not grounded:
				air_shots_remaining -= 1

			if air_shots_remaining <= 0:
				is_reloading = true
				reload_timer = 0.8
				if not grounded:
					must_land_to_reload = true

			just_recoiled = true

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Aiming input
	var aim_vector := Vector2(
	Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
	Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
)
	if aim_vector.length() > 0:
		last_aim_direction = aim_vector.normalized()

	# Crosshair positioning and rotation
	crosshair_node.global_position = global_position + last_aim_direction * CROSSHAIR_RADIUS
	crosshair_node.rotation = last_aim_direction.angle()  # rotate the Node2D

	# Jump
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Movement
	#if not just_recoiled and is_on_floor():
	#	var direction := Input.get_axis("ui_left", "ui_right")
	#	if direction:
	#		velocity.x = direction * SPEED
	#	else:
	#		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animation
	var direction := Input.get_axis("ui_left", "ui_right")
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

	# Reset recoil flag
	just_recoiled = false

	# Final air shot reset logic
	if is_on_floor():
		if must_land_to_reload:
			is_reloading = false
			air_shots_remaining = current_weapon.max_air_shots
			must_land_to_reload = false
		elif not is_reloading:
			air_shots_remaining = current_weapon.max_air_shots

	# Apply horizontal friction when grounded and not recoiling
	if is_on_floor() and not just_recoiled:
		var friction := 800.0  # Higher = stops faster
		if abs(velocity.x) < friction * delta:
			velocity.x = 0
		else:
			velocity.x -= sign(velocity.x) * friction * delta


	# Apply movement
	move_and_slide()
