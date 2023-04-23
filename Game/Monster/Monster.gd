extends RigidBody2D

class_name Monster

enum TYPE {RED=0, GREEN=1, BLUE=2}

var alliance: Main.ALLIANCE = Main.ALLIANCE.PLAYER

var bullhorn_scene: PackedScene = preload("res://Game/Projectiles/BullHorn.tscn")
var venom_scene: PackedScene = preload("res://Game/Projectiles/Venom.tscn")
var egg_scene: PackedScene = preload("res://Game/Projectiles/Egg.tscn")

var head_heights := {
	TYPE.RED: 15 * 4,
	TYPE.GREEN: 10 * 4,
	TYPE.BLUE: 15 * 4,
}

var leg_heights := {
	TYPE.RED: 10 * 4,
	TYPE.GREEN: 12 * 4,
	TYPE.BLUE: 16 * 4,
}

var move_impulses := {
	TYPE.RED: Vector2(2, -1).normalized() * 200.0,
	TYPE.GREEN: Vector2(1, -2).normalized() * 350.0,
	TYPE.BLUE: Vector2(1, -4).normalized() * 650.0,
}

var move_cooldowns := {
	TYPE.RED: 0.45,
	TYPE.GREEN: 1.5,
	TYPE.BLUE: 4.0,
}

var shoot_cooldowns := {
	TYPE.RED: 2.0,
	TYPE.GREEN: 2.0,
	TYPE.BLUE: 2.0,
}

var shoot_functions := {
	TYPE.RED: func():
		var horns = [bullhorn_scene.instantiate(), bullhorn_scene.instantiate()]
		for horn in horns:
			horn.position = head_sprite.global_position
			horn.alliance = alliance
			horn.modulate = get_alliance_modulate(alliance)
			get_parent().add_child(horn)
		horns[0].position.y -= 32
		horns[1].position.y -= 16,
	TYPE.GREEN: func():
		var venom = venom_scene.instantiate()
		venom.position = head_sprite.global_position + Vector2(0, 16)
		venom.alliance = alliance
		venom.modulate = get_alliance_modulate(alliance)
		get_parent().add_child(venom),
	TYPE.BLUE: func():
		var egg = egg_scene.instantiate()
		egg.position = head_sprite.global_position + Vector2(0, 16)
		egg.alliance = alliance
		egg.modulate = get_alliance_modulate(alliance)
		get_parent().add_child(egg),
}

var head_type: TYPE
var body_type: TYPE
var leg_type: TYPE

@onready var head_sprite := $HeadSprite
@onready var body_sprite := $BodySprite
@onready var leg_sprite := $LegSprite

@onready var collision_shape := $CollisionShape2D
@onready var collision_capsule: CapsuleShape2D

@onready var move_timer: Timer = $MoveTimer
@onready var shoot_timer: Timer = $ShootTimer

@onready var grounded_ray: RayCast2D = $GroundedRay

var hp: float = 100.0
@onready var hp_bar: TextureProgressBar = $HPBar

var death_player_scene: PackedScene = load("res://Game/Utils/2DSelfDestructPlayer.tscn")

@onready var venom_particles: GPUParticles2D = $VenomParticles
var poison_timer: float = 0.0

func _ready():
	collision_capsule = CapsuleShape2D.new()
	collision_capsule.radius = 28
	collision_shape.shape = collision_capsule

	update_monster()

func _process(delta):
	if body_type == TYPE.BLUE:
		heal(delta * 7.0)

	if poison_timer > 0.0:
		receive_damage(min(poison_timer, delta) * 9.0, true)

	poison_timer = max(0.0, poison_timer - delta)
	if poison_timer <= 0.0:
		venom_particles.emitting = false

func update_monster():
	collision_shape.position.y = (leg_heights[leg_type] - head_heights[head_type]) / 2.0
	collision_capsule.height = head_heights[head_type] + (16*4) + leg_heights[leg_type]
	grounded_ray.position.y = 28 + leg_heights[leg_type]

	head_sprite.set_frame_and_progress(head_type, 0.0)
	body_sprite.set_frame_and_progress(body_type, 0.0)
	leg_sprite.set_frame_and_progress(leg_type, 0.0)

	shoot_timer.wait_time = shoot_cooldowns[head_type] * (.9 + .2 * randf())
	move_timer.wait_time = move_cooldowns[leg_type] * (.9 + .2 * randf())

	if alliance == Main.ALLIANCE.ENEMY:
		head_sprite.flip_h = true
		body_sprite.flip_h = true
		leg_sprite.flip_h = true
		hp_bar.tint_progress.g = 0
		hp_bar.tint_progress.r = 1

	collision_layer |= Main.get_alliance_collision_mask(alliance)
	collision_mask |= Main.get_alliance_collision_mask(alliance)

func randomize_parts():
	head_type = TYPE.values().pick_random()
	body_type = TYPE.values().pick_random()
	leg_type = TYPE.values().pick_random()

	update_monster()

func _on_move_timer_timeout():
	if grounded_ray.is_colliding():
		var move_impulse: Vector2 = move_impulses[leg_type] * (0.5 if poison_timer > 0.0 else 1.0)
		if alliance == Main.ALLIANCE.ENEMY:
			move_impulse.x *= -1
		apply_central_impulse(move_impulse)

func _on_shoot_timer_timeout():
	shoot_functions[head_type].call()

func get_alliance_modulate(alliance: Main.ALLIANCE):
	if alliance == Main.ALLIANCE.PLAYER:
		return Color(0.95, 1.0, 0.95)
	else:
		return Color(1.0, 0.9, 0.9)

func receive_damage(amount: float, ignore_resistance: bool = false):
	hp = max(0.0, hp - amount * (1.0 if ignore_resistance else(0.8 if body_type == Monster.TYPE.GREEN else 1.3 if body_type == Monster.TYPE.BLUE else 1.0)))
	hp_bar.value = hp
	if hp == 0.0:
		die()

func heal(amount: float):
	hp = min(100.0, hp + amount)
	hp_bar.value = hp

func poison():
	poison_timer += 2.0
	venom_particles.emitting = true

func die():
	var death_player = death_player_scene.instantiate()
	death_player.position = position
	get_parent().add_child(death_player)
	queue_free()
