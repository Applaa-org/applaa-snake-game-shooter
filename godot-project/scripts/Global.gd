extends Node

var score: int = 0
var player_health: int = 3
var game_active: bool = false

func add_score(points: int):
	score += points

func reset_game():
	score = 0
	player_health = 3
	game_active = false

func take_damage():
	player_health -= 1
	if player_health <= 0:
		game_active = false
		get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")