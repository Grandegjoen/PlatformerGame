extends Node

export var time_between_disappearance = 2.0

func _ready():

	print("Ready!")
	print(get_child_count())
	if get_child_count() == 0:
		print("Returning!")
		return

	print("Made it here!")
	for x in get_children():
			x.get_node("Platform").frame = 1
			x.get_node("Collision").disabled = true
	while true:
		for x in get_children():
			x.get_node("Platform").frame = 0
			x.get_node("Collision").disabled = false
			yield(get_tree().create_timer(time_between_disappearance), "timeout")
			x.get_node("Platform").frame = 1
			x.get_node("Collision").disabled = true

