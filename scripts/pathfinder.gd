extends AStar2D

func _compute_cost(from_id: int, to_id: int) -> float:
	var cost_float = 1
	var to_tile_data = get_tile_data(to_id)
	var entity_properties = get_entity_properties()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
