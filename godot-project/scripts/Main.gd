extends Node2D

@onready var player = $Player
@onready var worm = $Worm
@onready var score_label = $UI/ScoreLabel
@onready var health_label = $UI/HealthLabel

func _ready():
	Global.game_active = true
	_setup_ui()
	
	# Connect signals
	player.shoot_bullet.connect(_on_player_shoot)
	worm.segment_destroyed.connect(_on_segment_destroyed)

func _setup_ui():
	var theme = Theme.new()
	var font = ThemeDB.fallback_font
	
	# Retro pixel font effect
	var label_style = StyleBoxFlat.new()
	label_style.bg_color = Color(0.0, 0.0, 0.0, 0.8)
	label_style.border_width_left = 2
	label_style.border_width_right = 2
	label_style.border_width_top = 2
	label_style.border_width_bottom = 2
	label_style.border_color = Color(0.2, 0.8, 0.2)
	
	theme.set_stylebox("normal", "Label", label_style)
	theme.set_color("font_color", "Label", Color(0.2, 0.8, 0.2))
	theme.default_font = font
	
	score_label.theme = theme
	health_label.theme = theme

func _process(_delta):
	# Update UI
	score_label.text = "SCORE: %06d" % Global.score
	health_label.text = "HEALTH: %d" % Global.player_health
	
	# Check victory condition
	if worm.segments.size() <= 0:
		Global.game_active = false
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")

func _on_player_shoot(bullet_scene, position, direction):
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.direction = direction
	add_child(bullet)

func _on_segment_destroyed():
	Global.add_score(100)