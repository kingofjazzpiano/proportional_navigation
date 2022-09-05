extends Sprite

var velocity: Vector2 = Vector2.ZERO
var speed: float = 30.0
onready var target_point: Vector2 = global_position


func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	get_input(delta)
	
	velocity = velocity.rotated(rotation)
	position += velocity * speed * delta
	
#	if position.distance_to(target_point) > speed * delta:
#		velocity = position.direction_to(target_point)
#	position += velocity * speed * delta
#	rotation = velocity.angle()
	

func get_input(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse"):
		target_point = get_global_mouse_position()

	if Input.is_action_pressed("w"):
		velocity = Vector2.RIGHT
	elif Input.is_action_pressed("s"):
		velocity = Vector2.LEFT

	if Input.is_action_pressed("a"):
		rotation -= (PI / 6.0) * delta
	if Input.is_action_pressed("d"):
		rotation += (PI / 6.0) * delta
		
