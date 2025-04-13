extends Node2D

var movement_script: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_script = get_parent().get_node("Movement")
	if not movement_script:
		push_error("Could not find movement node")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not movement_script:
		push_error("Could not find movement script")
		return
		
	if not movement_script._tilemap_layer_ref: return # Safety check

	# Only check for new movement input if NOT currently moving AND input is allowed
	if not movement_script.is_moving and movement_script.can_accept_input:
		# Determine the *intended* direction based on input
		var move_direction_enum = -1 # Use TileSet.CellNeighbor constants

		if Input.is_action_pressed("Right"):
			# Adjust as needed! Examples:
			# move_direction_enum = TileSet.CellNeighbor.RIGHT
			move_direction_enum = TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE
			# move_direction_enum = TileSet.CellNeighbor.TOP_RIGHT
		elif Input.is_action_pressed("Left"):
			# Adjust as needed! Examples:
			# move_direction_enum = TileSet.CellNeighbor.LEFT
			move_direction_enum = TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
			# move_direction_enum = TileSet.CellNeighbor.BOTTOM_LEFT
		elif Input.is_action_pressed("TopLeft"):
			# Adjust based on your layout (Pointy/Flat Top, Offset Axis)
			# Example for Pointy Top, Odd-Q offset might use these:
			move_direction_enum = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_SIDE # Or BOTTOM_LEFT
		elif Input.is_action_pressed("TopRight"):
			# Adjust based on your layout
			# Example for Pointy Top, Odd-Q offset might use these:
			move_direction_enum = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_SIDE
		elif Input.is_action_pressed("BottomLeft"):
			# Adjust based on your layout
			# Example for Pointy Top, Odd-Q offset might use these:
			move_direction_enum = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE # Or TOP_RIGHT
		elif Input.is_action_pressed("BottomRight"):
			# Adjust based on your layout
			# Example for Pointy Top, Odd-Q offset might use these:
			move_direction_enum = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE # Or TOP_RIGHT# Or TOP_RIGHT

		# If a valid direction enum was found, attempt the move
		if move_direction_enum != -1:
			# Pass the correct enum value (which is an integer)
			movement_script.attempt_move_in_direction(move_direction_enum)
	if not movement_script._tilemap_layer_ref: return
