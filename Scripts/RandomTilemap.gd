tool
extends TileMap

export(bool) var lock_pattern = false
export(int) var random_int = 0 setget tilemap_randomization
export(int) var minimum = 0
export(int) var maximum = 0

func tilemap_randomization(random_input: int):
	if lock_pattern:
		return
	
	random_int = random_input
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if Engine.is_editor_hint():
		for cell_position in get_used_cells():
			var num: int = 0
			if random_int != 0:
				num = rng.randi_range(minimum, maximum)
			set_cellv(cell_position, num)


