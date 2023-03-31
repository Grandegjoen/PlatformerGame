extends Area2D


var available = true

func _ready():
	pass # Replace with function body.

func picked_up():
	if !available:
		print("Not available!")
	else:
		get_parent().get_node("Lightning").visible = false
		available = false
		yield(get_tree().create_timer(5), "timeout")
		get_parent().get_node("Lightning").visible = true
		available = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
