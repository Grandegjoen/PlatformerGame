extends Node2D

onready var player_scene = preload("res://Scenes/Player/Player.tscn")
export var bonus_level = false
export var current_level = 1

var time_started

func _ready():
	var player = player_scene.instance()
	place_player(player)
	add_child(player)
	time_started = OS.get_ticks_msec()
	game_state.current_level = current_level
	if not bonus_level:
		game_state.ready_next_level()

func place_player(player):
	var player_respawn_point = game_state.player_respawn_point
	var spawn_point = get_node("RespawnPoints/" + str(player_respawn_point))
	player.position = spawn_point.global_position
