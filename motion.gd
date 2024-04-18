extends CharacterBody2D

var speed = 500
@onready var child = $AnimatedSprite2D
@onready var data_manager = get_node("/root/Game/DataManager")
@export var quest: QuestResource

signal load_interior(location: int, player: Node)

var enterable
func _ready() -> void:
	var instance := quest.instantiate()
	Questify.start_quest(instance)
	Questify.quest_completed.connect(func(_quest: QuestResource):
		print('quest completed hell yea'))
	Questify.quest_objective_completed.connect(func(_quest: QuestResource, _objective: QuestObjective):
		print('we did it we did it')
	)
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
func _enter_tree():
	enterable = false
func _on_area_2d_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.collision_layer == 2&&enterable:
		if area.get_parent().get_parent().has_meta("DoorLocation"):
			var location = area.get_parent().get_parent().get_meta("DoorLocation")
			emit_signal("load_interior", location, self)
		
			enterable = false
	
func _on_area_2d_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.collision_layer == 2:
		enterable = true

func _on_area_2d_mouse_entered():
	data_manager.set_value("go", true)
