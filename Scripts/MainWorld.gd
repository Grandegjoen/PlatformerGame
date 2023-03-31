extends Node

func _ready():
	$TotalTime.visible = false
	$TimeLabel.text = ""
	var all_levels_best_time = true
	var count = 0
	for x in $Buttons.get_children():
		x.connect("pressed", self, "btn_pressed", [count])
		x.get_node("Level").text = "Level " + str(count + 1)
		if game_state.levels[count]["unlocked"] == false:
			all_levels_best_time = false
			x.disabled = true
			x.get_node("BestTime").text = ""
		if game_state.levels[count]["best_time"] > 0:
			x.get_node("BestTime").text = "Best Time: " + str(game_state.levels[count]["best_time"]) + "s"
		else:
			all_levels_best_time = false
			x.get_node("BestTime").text = ""
		count += 1
	if all_levels_best_time == true:
		best_time()

func best_time():
	var time: int
	for x in game_state.levels:
		time += x["best_time"]
	$TimeLabel.text = "Total Time:\n" + str(time) + "s"
	$TotalTime.visible = true

func btn_pressed(level):
	print(level)
	if game_state.levels[level]["unlocked"] == true:
		get_tree().change_scene("res://Levels/Level" + str(level+1) + ".tscn")

