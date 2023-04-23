class_name Main

enum ALLIANCE {PLAYER, ENEMY}

static func get_alliance_collision_mask(alliance: ALLIANCE):
	if alliance == ALLIANCE.PLAYER:
		return 0b100
	else:
		return 0b1000
