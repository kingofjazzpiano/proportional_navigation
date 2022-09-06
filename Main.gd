extends Node2D

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = not get_tree().paused
