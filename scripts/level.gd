extends Node2D

const FILL_PERCENTAGE: float = 0.4 
const ROCK_SCENE= preload("res://scenes/rock.tscn")

@export var rock_types: Array[RockData] = []
@onready var rock_container: Node2D = $RockContainer
@onready var current_map: Node2D = $Map
@onready var player: Player = $Playersssawaw

var current_depth : int = 1	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_rocks()
	_postion_objects()

func _postion_objects() -> void:
	var player_spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.reset(player_spawn.position)
func _generate_rocks() -> void:	
	#clear exisitng rocks
	for child in rock_container.get_children():
		child.queue_free()
	
	# get tile map layers from current map
	var ground_layer: TileMapLayer = current_map.get_node("Ground")
	var props_layer: TileMapLayer = current_map.get_node("Props")
	var ground_cells := ground_layer.get_used_cells()
	var available_cells := []
	
	for cell in ground_cells:
		# get the tile data for this specific coordinate
		var tile_data = ground_layer.get_cell_tile_data(cell)
		
		# check if there are any props in the way
		# get cell source id retunrs -1 if the cell is empty
		if props_layer.get_cell_source_id(cell) != -1:
			continue
			
			#checks if this tile has the spawn_rocks property is set to true 
		if tile_data and tile_data.get_custom_data("can_spawn_rocks") == true:
			available_cells.append(cell)
			
	available_cells.shuffle()
	var num_rocks:= int(available_cells.size()* FILL_PERCENTAGE)
	var valid_rocks : Array[RockData] = []
	for rock in rock_types:
		if current_depth >= rock.min_depth:
			valid_rocks.append(rock)
			
				
	for i in range(num_rocks):
		var cell = available_cells[i]
		var rock = ROCK_SCENE.instantiate()
		
		
		rock.data = get_random_rock(valid_rocks)
		
		#get local position from tilemap
		var local_pos = ground_layer.map_to_local(cell)
		
		rock.global_position = local_pos
		rock_container.add_child(rock)
		
func get_random_rock(options: Array[RockData]) -> RockData:
	var total_weight: int = 0
	for rock in options:
		total_weight += rock.rarity
		
		
	var roll = randi_range(0, total_weight -1)
	var current_sum :int = 0
	for rock in options:
		current_sum += rock.rarity
		if roll< current_sum:
			return rock 
			
	return options[0] # fallback to stone if nothing 
