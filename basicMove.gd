extends CharacterBody3D

@export var maxSpeed: float = 50

@export var acc: float = 150

@export var gravDir: Vector3

@export var grav: float = 30
var rVel: Vector3
@export var rAcc: Vector3 = Vector3(1,1.5,0)
@export var rFriction: Vector3 = Vector3(.85,.7,0)

var vel: Vector3
@export var friction: float = .95


@export var targetGroundPos: Node3D
@export var groundRaycast: RayCast3D
@export var animation_player: AnimationPlayer
var extForces = Vector3.ZERO
var state="air"
@onready var gpu_particles_3d = $GPUParticles3D

func _physics_process(delta):
	var i:Vector2 = Input.get_vector("right","left","reverse","acel")
	var dir = (Vector3(i.x, 0, i.y)).normalized()
	var part = gpu_particles_3d.process_material as ParticleProcessMaterial

	
	if dir or state == "air":
		#part.direction = -vel.normalized()
		#part.initial_velocity_min = vel.length() *.1
		gpu_particles_3d.lifetime=1
	else:
		gpu_particles_3d.lifetime=4
		#part.initial_velocity_max = 0
		
	gpu_particles_3d.process_material=part
	
	match state:
		"air":
			#extForces -= Vector3.UP * grav * delta
			extForces += gravDir * grav * delta
			rVel.z -= i.x * rAcc.z * delta
			#rVel.y += i.x * rAcc.y * delta
			rVel.x -= i.y * rAcc.x * delta
			#vel.y *=friction
			#vel.y -= grav * delta
			
			
			if groundRaycast.is_colliding():
				goToGround()
		"ground":
			if Input.is_action_just_pressed("jump"):
				
				vel.y = maxSpeed*.5
				goToAir()
			if groundRaycast.is_colliding():
				
				if dir:
					#vel.x += i.x * acc * delta
					vel.z += i.y * acc * delta
				rVel.y += i.x * rAcc.y * delta
				
				#rVel.y *= rFriction.y
				vel.x *= friction
				vel.z *= friction
				var n = groundRaycast.get_collision_normal()
				var xform: Transform3D = align_with_y(global_transform, n)
				global_transform = global_transform.interpolate_with(xform, .05)
				#transform.basis = basis.slerp(xform.basis,.5).orthonormalized()
				#xform.basis = xform.basis.orthonormalized()
				position = position.lerp(targetGroundPos.global_position,.25)
			else:
				goToAir()
	if Input.is_action_just_pressed("boost"):
		vel.z = min(vel.z*2,maxSpeed*2)
	
	rVel *= rFriction
	
	velocity = Utils.RotateToBasis(vel,basis)
	velocity +=  extForces 
	velocity = min(velocity.length(),maxSpeed) * velocity.normalized()

	rotate(basis.x, -rVel.x) #pitch
	rotate(basis.y, rVel.y) #yaw
	rotate(basis.z, rVel.z) #roll
	move_and_slide()
	
func goToAir():
	
	gravDir = Utils.RotateToBasis(Vector3.DOWN,basis).normalized()
	extForces = Utils.RotateToBasis(vel,basis)
	vel = Vector3.ZERO
	state="air"
	rVel.x = rVel.x
	animation_player.play(state)

func goToGround():
	
	vel = extForces
	extForces = Vector3.ZERO
	
	extForces = Vector3.ZERO
	vel.y=0
	var n = groundRaycast.get_collision_normal()
	var xform: Transform3D = align_with_y(global_transform, n)
	global_transform = global_transform.interpolate_with(xform, .65)
	state="ground"
	animation_player.play(state)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
