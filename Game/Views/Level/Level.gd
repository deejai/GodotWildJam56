extends Node2D

@onready var player_dropper: Dropper = $PlayerDropper
@onready var enemy_dropper: Dropper = $EnemyDropper

@onready var enemy_timer: Timer = $EnemyTimer
@onready var monster_button_timer: Timer = $MonsterButtonTimer

@onready var monster_button: TextureButton = $GUILayer/CreateMonsterButton

var player_hp: float = 100.0
var enemy_hp: float = 100.0

@onready var player_hpbar: TextureProgressBar = $PlayerHPBar
@onready var enemy_hpbar: TextureProgressBar = $EnemyHPBar

var main_menu_scene: PackedScene = load("res://Game/Views/MainMenu/MainMenu.tscn")
var game_over_scene: PackedScene = load("res://Game/Views/GameOver/GameOver.tscn")
var you_win_scene: PackedScene = load("res://Game/Views/YouWin/YouWin.tscn")

@onready var help_sprite = $OverlayLayer/HelpSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_dropper.alliance = Main.ALLIANCE.ENEMY
	enemy_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enemy_hp <= 0.0:
		get_tree().change_scene_to_packed(you_win_scene)
	elif player_hp <= 0.0:
		get_tree().change_scene_to_packed(game_over_scene)

func _on_red_button_pressed():
	if player_dropper.push_drop(Monster.TYPE.RED):
		$AddDropSound.play()

func _on_green_button_pressed():
	if player_dropper.push_drop(Monster.TYPE.GREEN):
		$AddDropSound.play()

func _on_blue_button_pressed():
	if player_dropper.push_drop(Monster.TYPE.BLUE):
		$AddDropSound.play()

func _on_reset_dropper_button_pressed():
	player_dropper.reset_dropper()

func _on_create_monster_button_pressed():
	var monster = player_dropper.produce_monster()

	if monster == null:
		return

	monster.position = player_dropper.position + Vector2(0, 128)
	add_child(monster)

	player_dropper.reset_dropper()

	monster_button.disabled = true
	monster_button.modulate.a = 0.5
	monster_button_timer.start()

func _on_enemy_timer_timeout():
	var monster = enemy_dropper.produce_monster()

	if monster == null:
		enemy_dropper.push_drop(Monster.TYPE.values().pick_random())
		return

	monster.position = enemy_dropper.position + Vector2(0, 128)
	add_child(monster)

	enemy_dropper.reset_dropper()

func _on_player_goal_body_entered(body):
	if body is Monster:
		var damage = 10.0 if body.alliance == Main.ALLIANCE.ENEMY else 5.0
		player_hp = max(0.0, player_hp - damage)
		player_hpbar.value = player_hp

		body.die()

func _on_enemy_goal_body_entered(body):
	if body is Monster:
		var damage = 10.0 if body.alliance == Main.ALLIANCE.PLAYER else 5.0
		enemy_hp = max(0.0, enemy_hp - damage)
		enemy_hpbar.value = enemy_hp

		body.die()

func _on_monster_button_timer_timeout():
	monster_button.disabled = false
	monster_button.modulate.a = 1.0

func _input(event: InputEvent):
	if event is InputEventMouseButton or event is InputEventKey:
		help_sprite.visible = false

func _on_help_button_pressed():
	help_sprite.visible = true

func _on_quit_button_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)
