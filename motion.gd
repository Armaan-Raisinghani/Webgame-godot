extends CharacterBody2D

var speed = 500
@onready var child = $AnimatedSprite2D
@onready var data_manager = get_node("/root/Game/DataManager")
@export var quest: QuestResource
@export var Balloon: PackedScene
@export var SmallBalloon: PackedScene
@export var dialogue_resource: DialogueResource

signal load_interior(location: int, player: Node)

var enterable

func _ready() -> void:
	var instance := quest.instantiate()
	Questify.start_quest(instance)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

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
			enterable = false
			emit_signal("load_interior", location, self)
			
	if area.collision_layer == 16:
		show_dialogue('tavern')
		child.stop()
		set_process(false)
	if area.collision_layer == 32:
		get_node("/root/Game/Indoor/CanvasLayer/SleepText").show()
	if area.collision_layer == 64:
		show_dialogue('asi')
		child.stop()
		set_process(false)
	if area.collision_layer == 128:
		get_node("/root/Game/Indoor/CanvasLayer/SleepText").show()
	if area.collision_layer == 256:
		show_dialogue('may')
		child.stop()
		set_process(false)
	
func _on_area_2d_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.collision_layer == 2:
		enterable = true
	if area.collision_layer == 32:
		get_node("/root/Game/Indoor/CanvasLayer/SleepText").hide()
	if area.collision_layer == 128:
		get_node("/root/Game/Indoor/CanvasLayer/SleepText").hide()

func _on_dialogue_ended(_resource: DialogueResource):
	set_process(true)
	child.play()
func show_dialogue(key: String) -> void:
	assert(dialogue_resource != null, "\"dialogue_resource\" property needs a to point to a DialogueResource.")
	var is_small_window: bool = ProjectSettings.get_setting("display/window/size/viewport_width") < 400
	DialogueManager.show_dialogue_balloon_scene(SmallBalloon if is_small_window else Balloon, dialogue_resource, key)
func _unhandled_input(event):
	var area2d = self.get_children().filter(func(c): return c.name == "Area2D")[0]
	if event.is_action_pressed("ui_accept") and area2d.get_overlapping_areas().any(func(area): return area.collision_layer == 32):
		set_process(false)
		get_node("/root/Game/Indoor/CanvasLayer/AnimationPlayer").play("new_animation")
		await get_tree().create_timer(3).timeout
		if Data.get_value("need_sleep_job"):
			Data.set_value("sleep_job", true)
		Data.set_value("worked_today", false)
		set_process(true)
	if event.is_action_pressed("ui_accept") and area2d.get_overlapping_areas().any(func(area): return area.collision_layer == 128):
		if not Data.get_value("worked_today"):
			set_process(false)
			get_node("/root/Game/Indoor/CanvasLayer/AnimationPlayer").play("new_animation")
			await get_tree().create_timer(3).timeout
			Data.set_value("worked_today", true)
			
			if Data.get_value("worked_count"):
				Data.set_value("worked_count", Data.get_value("worked_count") + 1)
			else:
				Data.set_value("worked_count", 1)
			if Data.get_value("worked_count") == 3:
				Data.set_value("work_3", true)
				show_dialogue('work_sus_1')
			if Data.get_value("worked_count") == 7:
				Data.set_value("work_7", true)
				show_dialogue('work_sus_2')
			set_process(true)

		else:
			get_node("/root/Game/Indoor/CanvasLayer/SleepText").text = "[center]You've already worked today.[/center]"
			var timeout = get_tree().create_timer(1.5)
			await timeout.timeout
			if has_node("/root/Game/Indoor/CanvasLayer/SleepText"):
				get_node("/root/Game/Indoor/CanvasLayer/SleepText").text = "[center]Press Enter to work[/center]"
