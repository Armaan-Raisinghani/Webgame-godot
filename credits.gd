extends Node2D

const section_time := 2.0
const line_time := 0.3
const base_speed := 100
const speed_up_multiplier := 10.0
const title_color := Color.BLUE_VIOLET

var scroll_speed := base_speed
var speed_up := false

@onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"You got so close, but this is past mending. You got the BAD ending." if Data.get_value("bad_ending") else "You got the GOOD ending",
	],[
		"A game by Armaan Raisinghani"
	],[
		"Programming",
		"Armaan Raisinghani",
	],[
		"Art",
		"Armaan Raisinghani",
		"Divyansh Khurana"
	],[
		"Writing", "Armaan Raisinghani"
	],[
		"Tools used",
		"Developed with Godot Engine",
		"Pixel art created using Pixilart",
		"Tilesheet created using gamedeveloperstudio.com",
	],[
		"Special thanks",
		"Everyone who kept me motivated to go on",
		"Everyone who listened to me whine about bugs",
		"And you, for playing this game"
	]
]
func _process(delta):
	@warning_ignore("shadowed_variable")
	var scroll_speed = base_speed * delta
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.global_position.y -= scroll_speed
			if l.global_position.y < - l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()

func finish():
	if not finished:
		finished = true
		get_tree().quit()

func add_line():
	var new_line = line.duplicate()
	new_line.show()
	new_line.text = section.pop_front()
	lines.append(new_line)
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false
