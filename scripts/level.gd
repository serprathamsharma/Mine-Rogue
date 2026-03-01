extends Node2D

const FILL_PERCENTAGE: float = 0.4
const LADDER_CHANCE: float = 1.2
const ROCK_SCENE= preload("res://scenes/rock.tscn")
const LADDER_SCENE = preload("res://scenes/ladder.tscn")
const MAPS = [
	preload("res://scenes/levels/map_1.tscn"),
	preload("res://scenes/levels/map_2.tscn"),
	preload("res://scenes/levels/map_3.tscn"),
]

@export var rock_types: Array[RockData] = []

@onready var rock_container: Node2D = $RockContainer
@onready var ore_container: Node2D = $OreContainer
@onready var current_map: Node2D = $Map
@onready var player: Player = $Player
@onready var level: Node2D = $"."


var last_map_index: int
var current_depth : int = 1
var down_ladder: Area2D
var rocks_remaining: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_map()

func setup_map() -> void:
	_clear_map()
	_generate_map()
	_generate_rocks()
	_position_objects() 

func _clear_map() -> void:
	#removes old map
	if current_map:
		current_map.queue_free()
		current_map = null
	#deletes any ladders
	if down_ladder:
		down_ladder.queue_free()
		down_ladder = null
	#clear exisitng rocks
	for child in rock_container.get_children():
		child.queue_free()
	#dedletes any ores
	for ore in ore_container.get_children():
		ore.queue_free()

func _generate_map() -> void:
	#pick a random map
	var new_index = randi_range(0, MAPS.size() -1)
	#keep picking new map
	while new_index == last_map_index:
		new_index = randi_range(0, MAPS.size() -1)
	last_map_index = new_index
	current_map = MAPS[new_index].instantiate()
	level.add_child(current_map)
	

func _position_objects() -> void:
	var player_spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.reset(player_spawn.position)

func _generate_rocks() -> void:
	
	
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
	rocks_remaining = num_rocks
	
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
		rock.broken.connect(_on_rock_broken)
		
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

func _on_rock_broken(pos: Vector2) -> void:
	rocks_remaining -= 1
	if down_ladder != null:
		return
	var drop_ladder := randf() < LADDER_CHANCE
	if drop_ladder or rocks_remaining ==0:
		_create_down_ladder(pos)

func _create_down_ladder(pos: Vector2) -> void:
	down_ladder = LADDER_SCENE.instantiate()
	down_ladder.position = pos
	add_child(down_ladder)
	down_ladder.ladder_used.connect(_on_down_ladder_used)
	
func _on_down_ladder_used() -> void:
	current_depth += 1
	setup_map()
