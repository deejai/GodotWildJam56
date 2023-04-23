extends RigidBody2D

var lifespan: float = 3.0
var alliance: Main.ALLIANCE = Main.ALLIANCE.PLAYER
var throw_impulse: Vector2 = Vector2(1,-2).normalized() * 400

@onready var shake_timer: Timer = $ShakeTimer

@onready var blast_area: Area2D = $BlastArea
@onready var blast_area_collision: CollisionShape2D = $BlastArea/CollisionShape2D

@onready var spawn_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
var death_player: AudioStreamPlayer2D = load("res://Game/Utils/2DSelfDestructPlayer.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player.play()

	death_player.stream = load("res://Assets/SFX/harsh-explode.mp3")

	if alliance == Main.ALLIANCE.ENEMY:
		throw_impulse.x *= -1.0
		collision_layer = 0b10 | Main.get_alliance_collision_mask(Main.ALLIANCE.PLAYER)
		collision_mask = 0b10 | Main.get_alliance_collision_mask(Main.ALLIANCE.PLAYER)
	else:
		collision_layer = 0b10 | Main.get_alliance_collision_mask(Main.ALLIANCE.ENEMY)
		collision_mask = 0b10 | Main.get_alliance_collision_mask(Main.ALLIANCE.ENEMY)

	apply_central_impulse(throw_impulse)
	apply_torque_impulse(100.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifespan -= delta
	if lifespan <= 0.0:
		var affected_enemies = blast_area.get_overlapping_bodies().filter(func(body): return body is Monster and body.alliance != alliance)
		for enemy_body in affected_enemies:
			var enemy: Monster = enemy_body
			var blast_radius = blast_area_collision.shape.radius
			var blast_power = 1000.0

			# from center of blast to edge, blast power reduces from 100% to 50%
			enemy.apply_central_impulse(
				position.direction_to(enemy.position) * blast_power * (blast_radius - position.distance_to(enemy.position)/2) / blast_radius
			)
			enemy.receive_damage(30.0)

		death_player.position = position
		get_parent().add_child(death_player)
		queue_free()

func _on_shake_timer_timeout():
	apply_central_impulse(Vector2.RIGHT.rotated(2*PI*randf()) * 200.0)
