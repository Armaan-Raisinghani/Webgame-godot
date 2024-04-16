extends Node2D

var mainscene = preload ("res://main.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.get_child(0).add_child.call_deferred(mainscene)
	if not mainscene.is_node_ready():
		await mainscene.ready
	var body = get_node("/root/Game/Main/Player/CharacterBody2D")
	body.load_interior.connect(load_interior)

func load_interior(location, player):
	if location >= 1:
		var interior = load("res://indoor_" + str(location) + ".tscn").instantiate()
		get_tree().root.get_child(0).add_child.call_deferred(interior)
		player.disconnect("load_interior", load_interior)
		get_tree().root.get_child(0).remove_child.call_deferred(mainscene)
		if not interior.is_node_ready():
			await interior.ready
		var body = get_node("/root/Game/Indoor"+str(location) + "/Player/CharacterBody2D")
		body.load_interior.connect(load_interior)
	else:
		var remove = get_tree().root.get_child(0).get_child(0)
		get_tree().root.get_child(0).remove_child.call_deferred(remove)
		remove.queue_free()
		await remove.tree_exited
		get_tree().root.get_child(0).add_child.call_deferred(mainscene)
		await mainscene.tree_entered
		print(get_tree().root.get_child(0).get_child(0).name)
		var body = get_node("/root/Game/Main/Player/CharacterBody2D")
		body.load_interior.connect(load_interior)
			
func _process(_delta):
	pass
