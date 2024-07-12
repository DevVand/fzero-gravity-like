extends CharacterBody3D

@export var acc: float = 150
var vel: Vector3
@export var friction: float = .95

@export var tAcc: float = 1.5
var tVel: float
@export var tFriction: float = .7

@export var rAcc: float = 1.5
var rVel: float
@export var rFriction: float = .7


# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var grav: float = 10

@export var targetGroundPos: Node3D
@export var groundRaycast: RayCast3D
@export var animation_player: AnimationPlayer

var state="air"

func _physics_process(delta):
	var i:Vector2 = Input.get_vector("right","left","reverse","acel")
	var dir = (transform.basis * Vector3(i.x, 0, i.y)).normalized()
	
	match state:
		"air":
			vel -= Vector3.UP * grav * delta
			rVel -= i.x * rAcc * delta
			rotate(basis.z, rVel)
			rVel *= rFriction
			if groundRaycast.is_colliding():
				goToGround()
		"ground":
			if groundRaycast.is_colliding():
				if dir:
					#vel.x += i.x * acc * delta
					vel.z += i.y * acc * delta
				tVel += i.x * tAcc * delta
				rotate(basis.y, tVel)
				tVel *= rFriction
				vel.x *= friction
				vel.z *= friction
				var n = groundRaycast.get_collision_normal()
				var xform: Transform3D = align_with_y(global_transform, n)
				global_transform = global_transform.interpolate_with(xform, .15)
				#transform.basis = basis.slerp(xform.basis,.5).orthonormalized()
				#xform.basis = xform.basis.orthonormalized()
				position = position.lerp(targetGroundPos.global_position,.25)
			else:
				goToAir()
	velocity += Utils.RotateToBasis(vel,basis)
	move_and_slide()
	velocity = Vector3.ZERO
func goToAir():
	state="air"
	animation_player.play(state)

func goToGround():
	vel.y=0
	var n = groundRaycast.get_collision_normal()
	var xform: Transform3D = align_with_y(global_transform, n)
	global_transform = global_transform.interpolate_with(xform, .8)
	state="ground"
	animation_player.play(state)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
