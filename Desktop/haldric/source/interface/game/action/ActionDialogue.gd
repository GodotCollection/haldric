extends Control
class_name ActionDialogue

var buttons := []


signal move_selected(loc)
signal skill_selected(skill)
signal recruit_selected(loc)
signal recall_selected(loc)

var DIR = {
	"N": Vector2(0, -96),
	"NE": Vector2(72, -48),
	"NW": Vector2(-72, -48),
	"SE": Vector2(72, 48),
	"SW": Vector2(-72, 48),
	"S": Vector2(0, 96),
}


func update_info(loc: Location, side: Side) -> bool:
	clear()
	var recruit_loc = null
	var can_recruit = false
	if loc.castle and loc.unit and side.leaders.has(loc.unit):
		can_recruit = true
	elif side.has_castle_loc(loc):
		can_recruit = true
		recruit_loc = loc
	if can_recruit:
		var recruit_button := ActionButton.instance()
		recruit_button.connect("pressed", self, "_on_recruit_pressed", [ recruit_loc ])
		get_tree().current_scene.add_child(recruit_button)
		buttons.append(recruit_button)
		recruit_button.rect_global_position = loc.position + DIR["S"]
		recruit_button.text = "RE"
		recruit_button.tooltip = "Recruit Units. Your leader has to be on a keep"

		var recall_button := ActionButton.instance()
		recall_button.connect("pressed", self, "_on_recall_pressed", [ recruit_loc ])
		get_tree().current_scene.add_child(recall_button)
		buttons.append(recall_button)
		recall_button.rect_global_position = loc.position + DIR["SW"]
		recall_button.text = "RA"
		recall_button.tooltip = "Recall Units. Your leader has to be on a keep"
	if loc.unit:
		var i := 0
		for skill in loc.unit.get_skills():
			var button = ActionButton.instance()
			button.connect("pressed", self, "_on_skill_pressed", [ skill ])
			get_tree().current_scene.add_child(button)
			buttons.append(button)
			button.rect_global_position = loc.position + DIR[DIR.keys()[i]]
			button.text = "SK"
			button.tooltip = skill.alias + "\n" + skill.description

			i += 1

			if not skill.is_usable():
				button.text = "(%d)" % skill.cooldown
				button.disabled = true
	return !buttons.empty()

func clear() -> void:
	"""
	for child in get_children():
		remove_child(child)
		child.queue_free()
	"""
	for button in buttons:
		get_tree().current_scene.remove_child(button)
		button.queue_free()

	buttons = []


func _on_skill_pressed(skill: Skill) -> void:
	clear()
	emit_signal("skill_selected", skill)


func _on_move_pressed(loc: Location) -> void:
	clear()
	emit_signal("move_selected", loc)


func _on_recruit_pressed(loc: Location) -> void:
	clear()
	emit_signal("recruit_selected", loc)

func _on_recall_pressed(loc: Location) -> void:
	clear()
	emit_signal("recall_selected", loc)
