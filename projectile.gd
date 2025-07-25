extends Area2D

@export var speed := 500.0
var direction := Vector2.ZERO
var velocity := Vector2.ZERO

# Connect signals when the projectile is ready.
func _ready() -> void:
	# Connect to body_entered and area_entered only if they aren’t already wired up.
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta: float) -> void:
	# Move the projectile according to its velocity.
	position += velocity * delta

func launch(dir: Vector2):
	direction = dir.normalized()
	velocity = direction * speed

func _on_body_entered(_body = null) -> void:
	# Remove the projectile if it hits a physics body (e.g. an enemy).
	queue_free()

func _on_area_entered(_area = null) -> void:
	# Remove the projectile if it hits an area (e.g. the TileMap’s colliders).
	queue_free()
