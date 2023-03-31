extends Node2D

export var lock_id = ""


func unlock():
	$AnimationPlayer.playback_speed = 1.5
	$AnimationPlayer.play("Open")

# Called when the node enters the scene tree for the first time.
func _ready():
	$StaticBody2D/CollisionPolygon2D.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
