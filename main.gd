extends Node2D

@onready var level: Node2D = $Level
@onready var hud: CanvasLayer = $HUD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	hud.set_inventory(level.player.inventory)
	
	level.change_depth.connect(hud.update_depth)
