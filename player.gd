extends CharacterBody3D


var current_speed = 5.0

const walking_speed = 5.0
const sprinting_speed = 8.0

const JUMP_VELOCITY = 4.5


@onready var viewmodelcamera = $head/Camera3D/SubViewportContainer/SubViewport/viewmodelcamera

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sense = 0.1

@onready var head = $head
@onready var camera = $head/Camera3D

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		viewmodelcamera.sway(Vector2(event.relative.x,event.relative.y))


func _physics_process(delta):
	$head/Camera3D/SubViewportContainer/SubViewport/viewmodelcamera.global_transform = camera.global_transform
	
	if Input.is_action_pressed("sprint"):
		current_speed = sprinting_speed
	else:
		current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if global_position.y < -5:
		game_over()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
			

	move_and_slide()

func game_over ():
	get_tree().reload_current_scene()
	
