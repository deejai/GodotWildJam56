extends Node2D

@onready var playerDropper: Dropper = $PlayerDropper
@onready var enemyDropper: Dropper = $EnemyDropper

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_red_button_pressed():
	if playerDropper.push_drop(Monster.TYPE.RED):
		$AddDropSound.play()

func _on_green_button_pressed():
	if playerDropper.push_drop(Monster.TYPE.GREEN):
		$AddDropSound.play()

func _on_blue_button_pressed():
	if playerDropper.push_drop(Monster.TYPE.BLUE):
		$AddDropSound.play()

func _on_reset_dropper_button_pressed():
	playerDropper.reset_dropper()

func _on_create_monster_button_pressed():
	var monster = playerDropper.produce_monster()

	if monster == null:
		return

	monster.position = playerDropper.position + Vector2(0, 128)
	add_child(monster)

	playerDropper.reset_dropper()
