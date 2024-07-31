extends Control

@onready var rows := %Rows

var leaderboard = AutoloadVariables.leaderboard
var data := {}

func _ready() -> void:
	update_leaderboard(AutoloadVariables.player_name, PopupUserName.player_time, PopupUserName.elapsed_time)

func update_leaderboard(username: String, time: String, seconds: int ):
	data = {"name": username, "time_string": time, "seconds": seconds}
	leaderboard.append(data)
	leaderboard.sort_custom(Callable(self, "sort_by_time"))
	data["color"] = set_color()
	for entry in leaderboard:
		var name_label = Label.new()
		var time_label = Label.new()
		
		set_label(name_label, entry, "name")
		set_label(time_label, entry, "time_string")
		
		var data_row = HBoxContainer.new()
		data_row.add_child(name_label)
		data_row.add_child(time_label)
		
		rows.add_child(data_row)

func set_label(label: Label, leaderboard_entry, entry_string: String) -> void:
	label.size_flags_horizontal = SIZE_EXPAND
	label.text = leaderboard_entry[entry_string]
	label.label_settings = LabelSettings.new()
	label.label_settings.font_color = leaderboard_entry["color"]

func set_color() -> Color:
	if (PopupUserName.elapsed_time >= 5):
		return Color(0.588, 0.224, 0.341)
	elif (PopupUserName.elapsed_time == 4):
		return Color(0.753, 0.753, 0.753)
	elif (PopupUserName.elapsed_time == 3):
		return Color(1, 0.761, 0.486)
	else:
		return Color(0.627, 0.698, 0.776)


func sort_by_time(a, b):
	return a["seconds"] < b["seconds"]


func _on_add_entry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/popup.tscn")
