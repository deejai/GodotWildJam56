extends Area2D

@export var lifespan: float
@export var x_speed: float
@export var y_speed: float
@export var sprite: Sprite2D
@export var type: TYPE

enum TYPE {BULLHORN, VENOM}

var alliance: Main.ALLIANCE = Main.ALLIANCE.PLAYER

@export var spawn_player: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player.play()

	if alliance == Main.ALLIANCE.ENEMY:
		sprite.flip_h = true
		x_speed *= -1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lifespan -= delta
	if lifespan <= 0:
		queue_free()

	position.x += x_speed * delta

	y_speed += 200 * delta
	position.y += y_speed * delta

	var enemy_bodies = get_overlapping_bodies().filter(func(body): return body is Monster and body.alliance != alliance)
	if len(enemy_bodies) > 0:
		var enemy_body: Monster = enemy_bodies[0]
		match(type):
			TYPE.BULLHORN:
				enemy_body.receive_damage(15.0)
			TYPE.VENOM:
				enemy_body.receive_damage(5.0)
				enemy_body.poison()

		queue_free()
