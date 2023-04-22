extends RigidBody2D

class_name Monster

enum TYPE {RED=0, GREEN=1, BLUE=2}

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

var head_type: TYPE
var body_type: TYPE
var leg_type: TYPE

@onready var head_sprite := $HeadSprite
@onready var body_sprite := $BodySprite
@onready var leg_sprite := $LegSprite

@onready var collision_shape := $CollisionShape2D
@onready var collision_capsule: CapsuleShape2D

func _ready():
	collision_capsule = CapsuleShape2D.new()
	collision_capsule.radius = 28
	collision_shape.shape = collision_capsule
	
	update_monster()

func _process(delta):
	pass

func update_monster():
	collision_shape.position.y = (leg_heights[leg_type] - head_heights[head_type]) / 2.0
	collision_capsule.height = head_heights[head_type] + (16*4) + leg_heights[leg_type]

	head_sprite.set_frame_and_progress(head_type, 0.0)
	body_sprite.set_frame_and_progress(body_type, 0.0)
	leg_sprite.set_frame_and_progress(leg_type, 0.0)

func randomize_parts():
	head_type = TYPE.values().pick_random()
	body_type = TYPE.values().pick_random()
	leg_type = TYPE.values().pick_random()

	update_monster()
