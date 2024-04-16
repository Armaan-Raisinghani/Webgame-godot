extends CharacterBody2D

var speed = 500
@onready var child = $AnimatedSprite2D

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
	direction = direction.normalized()
	position += direction * speed * delta
	rotation = direction.angle()
	if direction.length() > 0:
		child.play()
	else:
		child.stop()
	
	move_and_slide()
func _on_area_2d_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.collision_layer == 2:
		set_process(!is_processing())
