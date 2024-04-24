class_name DataManager extends Node

signal data_changed(key: String, value: Variant)

var data := {"bart_talked": true, "need_sleep_job": true, "sleep_job": true, "job_start": true, "worked_count": 6, "work_3": true}

func _ready() -> void:
	Questify.condition_query_requested.connect(
		func(type: String, key: String, value: Variant, requester: QuestCondition):
			if type == "variable":
				if get_value(key) == value:
					requester.set_completed(true))

func set_value(key: String, value: Variant) -> void:
	data[key] = value
	data_changed.emit(key, value)
	
func get_value(key: String) -> Variant:
	if data.has(key):
		return data[key]
	return null
