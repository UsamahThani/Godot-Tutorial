extends Node2D

const COLLISION_MASK_CARD = 1
var screen_size
var card_being_dragged
var is_hovering_on_card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
			clamp(mouse_pos.y, 0, screen_size.y))

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# Raycast check for the card
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag()

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# Loop through the rest of the cards checjing for a higer z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func connect_card_signals(card):
	card.connect("hover_in", on_hovered_in_card)
	card.connect("hover_out", on_hovered_out_card)
	
func on_hovered_in_card(card):
	if !is_hovering_on_card:
		highlight_card(card, true)
	
func on_hovered_out_card(card):
	highlight_card(card, false)
	# Check if hovered off card straight on to another card
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false

func highlight_card(card, hovered):
	#var t = get_tree().create_tween()
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
		#card.modulate = "#16a5ed"
		#t.tween_property(card, "scale", Vector2(1.05, 1.05), 0.15)
		#t.tween_property(card, "modulate", Color("#16a5ed"), 0.15)
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
		#card.modulate = "#fff"
		#t.tween_property(card, "scale", Vector2(1, 1), 0.15)
		#t.tween_property(card, "modulate", Color("#fff"), 0.15)

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1, 1)

func finish_drag():
	card_being_dragged = Vector2(1.05, 1.05)
	card_being_dragged = null
