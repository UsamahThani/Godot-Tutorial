extends Node2D

signal hover_in
signal hover_out
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set random card for sprite2D
	set_random_texture()
	# All card must be a child of CardManager
	get_parent().connect_card_signals(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hover_in", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hover_out", self)

func set_random_texture():
	var folder_path = "res://assets/white/"
	var files = DirAccess.get_files_at(folder_path)
	# Filter only PNG files
	var png_files: Array = []
	
	for name in files:
		if name.to_lower().ends_with(".png"):
			png_files.append(name)
	
	if png_files.is_empty():
		push_warning("No PNG files found in: " + folder_path)
		return
	
	var random_file = png_files[randi() % png_files.size()]
	var texture_path = folder_path + random_file
	sprite_2d.texture = load(texture_path)
