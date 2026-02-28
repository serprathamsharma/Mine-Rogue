extends CharacterBody2D


const SPEED = 100.0
var is_mining: bool = false 
var hitbox_offset: Vector2
var last_direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

func _ready() ->  void:
	hitbox_offset = hitbox.position # Initialise hitbox offset 

func _physics_process(_delta: float) -> void:
	
	#handle mining input
	if Input.is_action_just_pressed("use_pickaxe"):
		use_pickaxe()
		#skip movement if mining
	if is_mining:
		velocity=Vector2.ZERO
		return 
		
	process_movement()
	process_animation()
	move_and_slide()

# MOVEMENTS AND ANIMATIONS 
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_position()
	else:
		velocity = Vector2.ZERO

func process_animation() -> void:
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)


func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")
		

# HITBOX 
func update_hitbox_position() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	if last_direction == Vector2.LEFT:
		hitbox.position = Vector2(-x, y)
	elif last_direction == Vector2.RIGHT:
		hitbox.position = Vector2(x , y)


# MINING
func use_pickaxe() -> void:
	is_mining = true
	play_animation("swing_pickaxe", last_direction)
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_mining:
		is_mining = false
	
