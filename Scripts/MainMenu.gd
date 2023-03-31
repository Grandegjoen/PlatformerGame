extends Node

func _ready():
	var dir = Directory.new()
	dir.open("user://save_data/")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			pass
#			files.append(file)
	dir.list_dir_end()


func _on_NewGame_pressed():
	$CanvasLayer/NewGame.visible = true
	$CanvasLayer/Default.visible = false
	get_tree().change_scene("res://Levels/World.tscn")


func _on_LoadGame_pressed():
	game_state.load_game()
	get_tree().change_scene("res://Levels/World.tscn")


func _on_NewGameBtn_pressed():
	if game_state.new_game(true):
		get_tree().change_scene("res://Levels/World.tscn")
	else:
		$OverwritePrompt.visible = true


func _on_LoadGameBtn_pressed():
	if game_state.load_game():
		get_tree().change_scene("res://Levels/World.tscn")


func _on_Overwrite_pressed():
	if game_state.new_game(false):
		get_tree().change_scene("res://Levels/World.tscn")
	


func _on_CancelOverwrite_pressed():
	$OverwritePrompt.visible = false
