class_name TerrainLoader

var MAX_VARIATION_COUNT := 15

var root := "res://"

var images := {}

var terrains := {}
var base_overlays := {}
var decorations := {}
var transitions := {}
var wall_segments := {}
var wall_towers := {}

var terrain_builder := TerrainBuilder.new()
var decoration_graphic_builder := TerrainDecorationGraphicBuilder.new()
var transition_graphic_builder := TerrainTransitionGraphicBuilder.new()
var terrain_graphic_builder := TerrainGraphicBuilder.new()

var wall_segment_builder := CastleWallSegmentGraphicBuilder.new()
var wall_tower_builder := CastleWallTowerGraphicBuilder.new()

func load_terrain() -> void:
	_load()


func open_path(path: String) -> void:
	images = {}
	root = path

	for file_data in Loader.load_dir(root, ["png", "tres"]):
		var semi_path : String = file_data.path.replace(root, "")
		semi_path = semi_path.replace("." + semi_path.get_extension(), "")

		if semi_path.begins_with("/"):
			semi_path.erase(0, 1)

		images[semi_path] = file_data.data

#	print(images)


func new_base(name: String, code: String, layer: int, type: Array, image_stem: String, offset := Vector2()) -> void:
	var terrain := terrain_builder\
		.new_terrain()\
		.with_name(name)\
		.with_code(code)\
		.with_layer(layer)\
		.with_type(type)\
		.with_graphic(terrain_graphic_builder\
			.new_graphic()\
			.with_texture(images[image_stem])\
			.with_offset(offset)\
			.with_variations(_load_base_variations(image_stem))\
			.build())\
		.build()

	terrains[terrain.code] = terrain


func new_base_overlay(code: String, image_stem: String, offset := Vector2()) -> void:
	var base_overlay := decoration_graphic_builder\
		.new_graphic()\
		.with_code(code)\
		.with_offset(offset)\
		.with_image_stem(image_stem)\
		.with_texture(images[image_stem])\
		.with_variations(_load_base_variations(image_stem))\
		.build()

	base_overlays[code] = base_overlay


func new_overlay(name: String, code: String, type: Array, image_stem: String, offset := Vector2()) -> void:
	var terrain := terrain_builder\
		.new_terrain()\
		.with_name(name)\
		.with_code(code)\
		.with_type(type)\
		.with_graphic(terrain_graphic_builder\
			.new_graphic()\
			.with_texture(images[image_stem])\
			.with_offset(offset)\
			.build())\
		.build()

	terrains[terrain.code] = terrain


func new_village(name: String, code: String, type: Array, image_stem: String) -> void:
	var terrain := terrain_builder\
		.new_terrain()\
		.with_name(name)\
		.with_code(code)\
		.with_type(type)\
		.with_gives_income(true)\
		.with_heals(true)\
		.with_graphic(terrain_graphic_builder\
			.new_graphic()\
			.with_texture(images[image_stem])\
			.build())\
		.build()

	terrains[terrain.code] = terrain


func new_castle(name: String, code: String, type: Array, image_stem: String, offset := Vector2()) -> void:
	var terrain := terrain_builder\
		.new_terrain()\
		.with_name(name)\
		.with_code(code)\
		.with_type(type)\
		.with_rectuit_onto(true)\
		.with_graphic(terrain_graphic_builder\
			.new_graphic()\
			.with_texture(images[image_stem])\
			.with_offset(offset)\
			.build())\
		.build()

	terrains[terrain.code] = terrain


func new_keep(name: String, code: String, type: Array, image_stem: String, offset := Vector2()) -> void:
	var terrain := terrain_builder\
		.new_terrain()\
		.with_name(name)\
		.with_code(code)\
		.with_type(type)\
		.with_rectuit_onto(true)\
		.with_recruit_from(true)\
		.with_graphic(terrain_graphic_builder\
			.new_graphic()\
			.with_texture(images[image_stem])\
			.with_offset(offset)\
			.build())\
		.build()

	terrains[code] = terrain


func new_transition(code, include: Array, exclude: Array, image_stem: String) -> void:

	if code is String:

		var transition := transition_graphic_builder\
			.new_graphic()\
			.with_image_stem(image_stem)\
			.with_textures(_load_transitions(code, image_stem))\
			.include(include)\
			.exclude(exclude)\
			.build()

		if not transitions.has(code):
			transitions[code] = []

		transitions[code].append(transition)

	elif code is Array:

		for c in code:

			var transition := transition_graphic_builder\
				.new_graphic()\
				.with_image_stem(image_stem)\
				.with_textures(_load_transitions(c, image_stem))\
				.include(include)\
				.exclude(exclude)\
				.build()

			if not transitions.has(c):
				transitions[c] = []
			transitions[c].append(transition)


func new_decoration(code: String, image_stem: String, offset := Vector2()) -> void:
	var decoration := decoration_graphic_builder\
		.new_graphic()\
		.with_code(code)\
		.with_offset(offset)\
		.with_image_stem(image_stem)\
		.with_texture(images[image_stem])\
		.with_variations(_load_base_variations(image_stem))\
		.build()

	decorations[code] = decoration


func new_castle_wall_segment(code, include: Array, exclude: Array, image_stem: String, flag: String, offset := Vector2()) -> void:

	var segment := wall_segment_builder\
		.new_graphic()\
		.with_code(code)\
		.with_texture(images[image_stem + "-" + flag])\
		.with_offset(offset)\
		.include(include)\
		.exclude(exclude)\
		.build()

	if not wall_segments.has(code):
		wall_segments[code] = {}

	wall_segments[code][flag] = segment


func new_castle_wall_tower(code, include: Array, exclude: Array, image_stem: String, offset := Vector2()) -> void:

	var tower := wall_tower_builder\
		.new_graphic()\
		.with_code(code)\
		.with_texture(images[image_stem])\
		.with_offset(offset)\
		.include(include)\
		.exclude(exclude)\
		.build()

	wall_towers[code] = tower


func _load_base_variations(image_stem: String) -> Array:
	var textures := []

	for i in range(2, MAX_VARIATION_COUNT + 1):
		var variation = image_stem + str(i)

		if images.has(variation):
			textures.append(images[variation])

	return textures


func _load_transitions(code: String, image_stem: String) -> Dictionary:
	var directions := [ "-n", "-ne", "-se", "-s", "-sw", "-nw"]
	var textures := {}

	for key in images:
		for dir in directions:

			if key.begins_with(image_stem + dir):
				var texture = images[key]
				var key_flags = key.replace(image_stem, "")
				textures[key_flags] = images[key]

	return textures


func _load() -> void:
	pass
