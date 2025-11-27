extends Control

func _ready():
	$VBoxContainer/ScoreLabel.text = "FINAL SCORE: %06d" % Global.score
	
	# Connect button signals
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	
	# Set up retro styling
	_setup_theme()

func _setup_theme():
	var theme = Theme.new()
	var font = ThemeDB.fallback_font
	
	# Button styling
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.8, 0.2)
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.border_width_top = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color(0.1, 0.4, 0.1)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	
	theme.set_stylebox("normal", "Button", button_style)
	
	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.3, 1.0, 0.3)
	theme.set_stylebox("hover", "Button", hover_style)
	
	var pressed_style = button_style.duplicate()
	pressed_style.bg_color = Color(0.1, 0.6, 0.1)
	theme.set_stylebox("pressed", "Button", pressed_style)
	
	# Label styling
	var label_color = Color(0.2, 0.8, 0.2)
	theme.set_color("font_color", "Label", label_color)
	
	theme.default_font = font
	self.theme = theme

func _on_restart_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()