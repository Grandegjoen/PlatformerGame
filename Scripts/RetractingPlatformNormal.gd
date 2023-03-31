extends Node2D

export var speed = 1
onready var animation_player = $AnimationPlayer

func _ready():
	var animation = animation_player.get_animation("Move")
	animation_player.playback_speed = speed
	pass
