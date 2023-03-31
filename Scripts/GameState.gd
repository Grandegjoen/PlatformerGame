extends Node

var player_respawn_point = 1
var lightning_available = false
var warp_available = false

var number_of_levels = 20
var current_level: int
var playing_bonus = false
var level_data = []
var player_name: String = "Nameless"
var current_save: String
var next_level: String
var levels: Array # Save data and such

func ready_next_level():
	next_level = "res://Levels/Level" + str(current_level + 1) + ".tscn"

# For save game / Load game
func new_game(first_attempt):
	var file = File.new()
	if file.file_exists("user://save_data/save_data.dat") and first_attempt:
		return false
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir("save_data")
	for x in range(1, number_of_levels+1):
		var level = {
			"level": x,
			"best_time": 0,
			"unlocked": false
		}
		levels.append(level)
	levels[0]["unlocked"] = true
	return true

func save_game():
	var file = File.new()
	file.open("user://save_data/save_data.dat", File.WRITE)
	file.store_var(levels)
	file.close()

func load_game():
	level_data.clear()
	var file = File.new()
	if (!file.file_exists("user://save_data/save_data.dat")):
		return false
	file.open("user://save_data/save_data.dat", File.READ)
	levels = file.get_var()
	print(levels)
	file.close()
	return true
		

func update_data(level, best_time, bonus, bonus_level):
	print(level)
	print(best_time)
	print(current_level)
	if levels[level-1]["best_time"] == 0:
		levels[level-1]["best_time"] = best_time
		levels[level].unlocked = true
		save_game()
	elif levels[level-1]["best_time"] < best_time:
		levels[level-1]["best_time"] = best_time
		save_game()
