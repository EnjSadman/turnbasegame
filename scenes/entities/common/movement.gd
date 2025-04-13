extends Node2D

var _tilemap_layer_ref: TileMapLayer
var _parent_node : CharacterBody2D

@export var move_duration: float = 0.2 # Time between animation start - end
@export var input_delay_after_move: float = 0.1 # Blocked input after move done

var current_map_coords: Vector2i = Vector2i.ZERO # Entity position in TileMap coords
var is_moving: bool = false
var can_accept_input: bool = true
var input_delay_timer: Timer = null
var target_map_coords: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var grid_node = get_tree().get_first_node_in_group("main_grid");
	_parent_node = get_parent();
	
	# Search for the tile map, on which entity is going to move
	if grid_node is TileMapLayer:
		_tilemap_layer_ref = grid_node
	else:
		push_error("Movement script could not find a TileMapLayer node in group 'world_tilemap'!")
	
	# Search and assigning value for parent
	if not _parent_node:
		push_error("Movement script could not find a Parent node")
	
	var start_map_coords = Vector2i(0, 0)
	initialize_position(start_map_coords)

	# Setup the optional input delay timer
	if input_delay_after_move > 0:
		input_delay_timer = Timer.new()
		input_delay_timer.one_shot = true
		input_delay_timer.wait_time = input_delay_after_move
		input_delay_timer.timeout.connect(_on_input_delay_timeout)
		add_child(input_delay_timer)
		
func initialize_position(map_coords: Vector2i):
	if not _tilemap_layer_ref: return
	current_map_coords = map_coords
	
	if not _parent_node:
		return
	# Get the pixel position of the center of the target hex cell
	_parent_node.global_position = _tilemap_layer_ref.map_to_local(current_map_coords)
	print("Player initialized at map coords: ", current_map_coords, " pixel pos: ", global_position)

func _on_input_delay_timeout():
	"""Called by the timer after the short delay (if enabled)."""
	can_accept_input = true
	
func attempt_move_in_direction(direction_enum: int):
	"""Calculates target hex and initiates move if valid."""
	if not _tilemap_layer_ref: return
	
	if not _parent_node:
		push_error("Movement component has no parent!")
		return

	target_map_coords = _tilemap_layer_ref.get_neighbor_cell(current_map_coords, direction_enum)

	if not is_valid_move_target(target_map_coords):
		print("Move blocked: Target ", target_map_coords, " is invalid or out of bounds.")
		return 

	# --- Start the movement tween ---
	var target_pixel_position = _tilemap_layer_ref.map_to_local(target_map_coords)

	is_moving = true
	can_accept_input = false # Prevent checking input again until move (and delay) finishes
	
	var tween = create_tween()
	tween.tween_property(_parent_node, "global_position", target_pixel_position, move_duration)
	tween.finished.connect(on_move_finished.bind(target_map_coords, direction_enum))


func is_valid_move_target(map_coords: Vector2i) -> bool:
	"""Checks if the target map coordinate is within bounds and walkable."""
	if not _tilemap_layer_ref: return false

	var source_id = _tilemap_layer_ref.get_cell_source_id(map_coords)
	if source_id == -1:
		return false
		
	var target_title_data : TileData = _tilemap_layer_ref.get_cell_tile_data(map_coords)
	
	if target_title_data:
		var is_passable : bool = target_title_data.get_custom_data("passable")
		if not is_passable:
			return false

	# If all checks pass, the move is valid
	return true


func on_move_finished(finished_coords: Vector2i, original_direction: int):
	"""Called by the tween when movement animation completes."""
	is_moving = false
	global_position = _tilemap_layer_ref.map_to_local(finished_coords)
	
	current_map_coords = finished_coords
	
	var current_tile_data: TileData = _tilemap_layer_ref.get_cell_tile_data(current_map_coords)
	var continue_sliding: bool = false
	
	if current_tile_data:
		if current_tile_data.get_custom_data("slippery"):
			continue_sliding = true
			
		if continue_sliding:
			attempt_move_in_direction(original_direction)
		else:
			is_moving = false
			if input_delay_timer and input_delay_after_move > 0:
				input_delay_timer.start()
			else:
				can_accept_input = true

	# Handle input delay
	if input_delay_timer and input_delay_after_move > 0:
		input_delay_timer.start()
	else:
		can_accept_input = true # Allow next input check immediately

func long_movement(final_coords: Vector2i):
	var astar = AStar2D.new()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
