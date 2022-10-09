extends Sprite

onready var reaction_timer: Node = $ReactionTimer
onready var player: Node = get_node("/root/Main/Player")

onready var debug_line_1 = get_node("/root/Main/DebugPanel/VBoxContainer/Label1")
onready var debug_line_2 = get_node("/root/Main/DebugPanel/VBoxContainer/Label2")
onready var debug_line_3 = get_node("/root/Main/DebugPanel/VBoxContainer/Label3")
onready var debug_line_4 = get_node("/root/Main/DebugPanel/VBoxContainer/Label4")
onready var debug_line_5 = get_node("/root/Main/DebugPanel/VBoxContainer/Label5")
onready var debug_line_6 = get_node("/root/Main/DebugPanel/VBoxContainer/Label6")
onready var debug_line_7 = get_node("/root/Main/DebugPanel/VBoxContainer/Label7")
onready var debug_line_8 = get_node("/root/Main/DebugPanel/VBoxContainer/Label8")
onready var debug_line_9 = get_node("/root/Main/DebugPanel/VBoxContainer/Label9")
onready var debug_line_10 = get_node("/root/Main/DebugPanel/VBoxContainer/Label10")

const MAX_REACTION_TIME = 2.5
const DEAD_ZONE_LIMIT = 50

enum { LEFT, RIGHT, STRAIGHT }
enum { FORWARD, BACKWARD, STABLE }

var player_rotation_state: int = STRAIGHT
var old_player_rotation_state: int = STRAIGHT
var rotation_state: int = STRAIGHT

var player_direction_state: int = STABLE
var old_player_direction_state: int = STABLE
var direction_state: int = STABLE

var direction: Vector2
var speed: float = 0.0  # скорость по локальной оси X
var acceleration: float = 1.05  # постоянное ускорение движения
var max_forward_speed: float = 130.0  # максимальная скорость вперёд
var max_backward_speed: float = -100.0  # максимальная скорость назад

# TODO: player.rotation_acceleration player.current_rotation_speed
var max_rotation_speed: float = 0.4  # максимальная скорость поворота Rad/s
var rotation_acceleration: float = 0.01  # постоянное ускорение при повороте
var current_rotation_speed: float = 0.0 # текущяя скорость вращения Rad/s


func _physics_process(delta: float) -> void:
	old_player_rotation_state = player_rotation_state
	
	if Input.is_action_pressed("a"):
		player_rotation_state = LEFT
	elif Input.is_action_pressed("d"):
		player_rotation_state = RIGHT
	else:
		player_rotation_state = STRAIGHT

	old_player_direction_state = player_direction_state
	
	if Input.is_action_pressed("w"):
#		debug_line_1.text = "direction_state: FORWARD"
		player_direction_state = FORWARD
	elif Input.is_action_pressed("s"):
#		debug_line_1.text = "direction_state: BACKWARD"
		player_direction_state = BACKWARD
	else:
#		debug_line_1.text = "direction_state: STAND"
		player_direction_state = STABLE
		
	if (old_player_rotation_state != player_rotation_state or old_player_direction_state != player_direction_state)\
			and reaction_timer.is_stopped():
		reaction_timer.start(rand_range(0.0, MAX_REACTION_TIME))
	
#	debug_line_2.text = "player.speed: " + str(player.speed)
#	debug_line_3.text = "speed: " + str(speed)
	
	if reaction_timer.is_stopped():
		rotation = player.rotation
		rotation_state = player_rotation_state
		position = player.position  # + Vector2(0, -200)
		direction_state = player_direction_state
	
	calculate_speed()
	calculate_rotation(delta)
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	
func calculate_rotation(delta: float) -> void:
	if rotation_state == LEFT:
		current_rotation_speed = max(current_rotation_speed - rotation_acceleration, -max_rotation_speed)
	elif rotation_state == RIGHT:
		current_rotation_speed = min(current_rotation_speed + rotation_acceleration, max_rotation_speed)
	elif rotation_state == STRAIGHT and current_rotation_speed:
		current_rotation_speed = lerp(current_rotation_speed, 0, abs(rotation_acceleration / current_rotation_speed))
	rotation += current_rotation_speed * delta
	

func calculate_speed() -> void:
	if direction_state == FORWARD:
		speed += acceleration
	elif direction_state == BACKWARD:
		speed -= acceleration
	# Если скорость меньше DEAD_ZONE_LIMIT, судно остановится, как и игрок
	elif speed and abs(speed) < DEAD_ZONE_LIMIT:
		speed = lerp(speed, 0, abs(acceleration / speed))
	speed = clamp(speed, max_backward_speed, max_forward_speed)
