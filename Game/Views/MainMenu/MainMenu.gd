extends Node2D

var level_scene := preload("res://Game/Views/Level/Level.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_new_game_button_pressed():
	get_tree().change_scene_to_packed(level_scene)

func _on_options_button_pressed():
	pass # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit()
