extends Area2D

@export var speed := 600.0
var direction := Vector2.ZERO
var velocity := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#position += direction * speed * delta
	
	#Apply gravity
	velocity.y += gravity * delta
	#Move projectile
	position += velocity * delta

func launch(direction: Vector2):
	#Set initial velocity
	velocity = direction.normalized() * speed

func _on_body_entered(body: Node2D) -> void:
	queue_free()
