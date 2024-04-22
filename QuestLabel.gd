extends RichTextLabel

func _ready():
	Questify.quest_completed.connect(func(_quest: QuestResource):
		text="Story completed"
	)
	Questify.quest_objective_completed.connect(func(quest: QuestResource, _objective: QuestObjective):
		if quest.get_active_objectives().size() > 0:
			text=quest.get_active_objectives()[0].description
	)
	Questify.quest_started.connect(func(quest: QuestResource):
		print(quest)
		text=quest.get_active_objectives()[0].description
	)

func _process(_delta):
	pass
