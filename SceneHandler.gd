extends Node2D

var mainscene = preload ("res://main.tscn").instantiate()
var interiors := {}
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Game").add_child.call_deferred(mainscene)
	if not mainscene.is_node_ready():
		await mainscene.ready
	var body = get_node("/root/Game/Main/Player/CharacterBody2D")
	body.load_interior.connect(load_interior)

func load_interior(location, player):
	if location == 6:
		return
	if location == 4 and not Data.get_value("job_start"):
		print('rejeccting 4')
		return
	if location == 5 and not Data.get_value("work_7"):
		return
	if location >= 1:
		var to_remove: Node
		if has_node("/root/Game/Main"):
			to_remove = get_node("/root/Game/Main")
		else:
			to_remove = get_node("/root/Game/Indoor")
		var interior: Node2D
		if location in interiors:
			interior = interiors[location]
		else:
			interior = load("res://indoor_" + str(location) + ".tscn").instantiate()

		get_node("/root/Game").remove_child.call_deferred(to_remove)
		if not has_node("/root/Game/Main"):
			var current = get_node("/root/Game/Indoor/").get_meta("indoor")
			if current != null:
				interiors[current] = to_remove
		if to_remove.is_inside_tree():
			await to_remove.tree_exited
		player.disconnect("load_interior", load_interior)

		get_node("/root/Game").add_child.call_deferred(interior)
		if not interior.is_inside_tree():
			await interior.tree_entered
		var body = get_node("/root/Game/Indoor/Player/CharacterBody2D")
		body.load_interior.connect(load_interior)
	else:
		var remove = get_node("/root/Game/Indoor")
		var loc = remove.get_meta("indoor")
		if loc != null:
			interiors.erase(loc)
		remove.queue_free()
		await remove.tree_exited
		get_node("/root/Game").add_child.call_deferred(mainscene)
		await mainscene.tree_entered
		var body = get_node("/root/Game/Main/Player/CharacterBody2D")
		
		body.load_interior.connect(load_interior)
			
func _process(_delta):
	pass
