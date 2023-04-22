extends Node2D

class_name Dropper

var drops: Array[Monster.TYPE] = []

var drop_sprites : Array[AnimatedSprite2D] = []

var monster_scene: PackedScene = preload("res://Game/Monster/Monster.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	drop_sprites.push_back($DropSprite1)
	drop_sprites.push_back($DropSprite2)
	drop_sprites.push_back($DropSprite3)
	
	update_dropper()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func push_drop(type: Monster.TYPE):
	if len(drops) >= 3:
		return false
	
	drops.push_back(type)

	update_dropper()
	
	return true

func update_dropper():
	for i in range(len(drops)):
		drop_sprites[i].visible = true
		drop_sprites[i].set_frame_and_progress(drops[i], 0.0)
	
	for i in range(len(drops), 3):
		drop_sprites[i].visible = false

func reset_dropper():
	drops = []
	update_dropper()

func produce_monster():
	if len(drops) != 3:
		return null

	var monster = monster_scene.instantiate()
	print(drops)
	monster.head_type = drops[0]
	monster.body_type = drops[1]
	monster.leg_type = drops[2]

	return monster
