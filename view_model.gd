extends Camera3D

@onready var fpsrig = $fpsrig
@onready var animation_player = $fpsrig/shotgun/animation_player

var damage = 10
const MAX_CAM_SHAKE = 0.3

var speed = 10
var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump = 10
var full_contact = false

var mouse_sensitivity = 0.03

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

@onready var head = $Head
@onready var ground_check = $GroundCheck
@onready var anim_player = $AnimationPlayer
@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

	if event.is_action_pressed("shoot"):
		animation_player.play("fire")

	if event.is_action_pressed("reload"):
		animation_player.play("reload")

	if event.is_action_pressed("use"):
		shotgun_in_use = !shotgun_in_use
		if shotgun_in_use:
			animation_player.play("put_away")
		else:
			animation_player.play("pull_up")

func fire():
	if Input.is_action_pressed("fire"):
		if not anim_player.is_playing():
			camera.translation = lerp(camera.translation,
									  Vector3(randf_range(MAX_CAM_SHAKE, -MAX_CAM_SHAKE),
											  randf_range(MAX_CAM_SHAKE, -MAX_CAM_SHAKE), 0), 0.5)
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("eye"):
					target.health -= damage
		anim_player.play("fire")

func _physics_process(delta):
	fire()
	direction = Vector3()
	h_velocity.y += gravity * delta

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y

var bullet = load("res://bullet.tscn")
var instance

var shotgun_in_use = true

func _process(delta):
	fpsrig.position.x = lerp(fpsrig.position.x, 0.0, delta * 5)
	fpsrig.position.y = lerp(fpsrig.position.y, 0.0, delta * 5)

	if Input.is_action_pressed("shoot"):
		if !animation_player.is_playing():
			animation_player.play("fire")
			instance = bullet.instantiate()
			instance.transform.basis = fpsrig.global_transform.basis
			get_parent().add_child(instance)

func sway(sway_amount):
	fpsrig.position.x -= sway_amount.x * 0.00005
	fpsrig.position.y += sway_amount.y * 0.00005  # Corrected usage of sway_amount.y

