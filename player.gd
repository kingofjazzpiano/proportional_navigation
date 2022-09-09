extends Sprite

var velocity: Vector2 = Vector2.ZERO
var max_speed: float = 100.0
var speed: float = 0.0
var acceleration: float = 0.5


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	get_input(delta)
	
	velocity = Vector2.RIGHT.rotated(rotation)
	position += velocity * speed * delta


func get_input(delta: float) -> void:
	if Input.is_action_pressed("w"):
		speed += acceleration
	elif Input.is_action_pressed("s"):
		speed -= acceleration
	speed = clamp(speed, 0, +max_speed)

	if Input.is_action_pressed("a"):
		rotation -= (PI / 6.0) * delta
	if Input.is_action_pressed("d"):
		rotation += (PI / 6.0) * delta
		
