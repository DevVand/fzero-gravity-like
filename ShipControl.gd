extends StaticBody3D

@export var ray: RayCast3D 
@export var currentLine: Path3D 


var dir: Vector3



@export var acceleration: float
@export var friction: float = .95

var gVelocity: Vector3
var velocity: Vector3
var linearVelocity: float

var rSpeed: float

@export var rAcceleration: float
@export var rFriction: float = .8

@export var groundMagnetDist: float = 1

@export var groundMagnetLerpRotation: float = 10
@export var groundMagnetLerpHeigh: float = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	pass

		#transform.origin.lerp( (p + transform.basis.y * groundMagnetDist), lerpV ) #* groundMagnetLerp * delta)


#		rgbd.apply_central_force( transform.basis.y * groundMagnet * delta)
#	rgbd.apply_impulse(transform.basis.z * delta / speed * rgbd.mass)
 
func _process(delta):
	
	#dir=Vector3.ZERO
	var i:Vector2 = Input.get_vector("left","right","reverse","acel")
	linearVelocity += acceleration * i.y
#	velocity+=transform.basis.z * acceleration * i.y
	rSpeed+=(-rAcceleration*i.x)*delta
	
	var curve:Curve3D= currentLine.curve
	
	var offset = curve.get_closest_offset( position )
	var point_1 = curve.sample_baked( offset, true )
	var point_2 = curve.sample_baked( offset + 0.01, true )
	
	var direction : Vector3 = ( point_2 - point_1 ).normalized()
	var p: Vector3 = ray.get_collision_point()
	var desiredPos: Vector3 = curve.get_closest_point(position) + transform.basis.y * groundMagnetDist
			
	
	var pDist: float = position.distance_to(p)
	var dist: float = (desiredPos.distance_to(position))

	var n:Vector3 =  ray.get_collision_normal()
	var t: Transform3D = transform
	var rDif: float = 1+abs(basis.y.angle_to(n) )*10
	var lerpR: float = ( (rDif) *groundMagnetLerpRotation)*delta
	var lerpV: float = ( ((1+dist)*10)+groundMagnetLerpHeigh)*delta
	t.basis.y = curve.sample_baked_up_vector(offset)
	t.basis.x = -t.basis.z.cross(n)
	t.basis = t.basis.orthonormalized()
	
	transform.basis = basis.slerp(t.basis,lerpR) #transform.interpolate_with(t,lerpV)
	
	position = position.lerp(desiredPos, lerpV)
	
	velocity = direction*  linearVelocity #basis.z *
	move_and_collide((velocity)*delta)
	rotate(transform.basis.y.normalized(),rSpeed)
	rSpeed*=rFriction
#	velocity*=friction+(1-friction if i.length()<.1 else 0)
	
	linearVelocity*=friction+(1-friction if i.length()<.1 else 0)
	#speed*=friction

#func _unhandled_input(event):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_up"):
#			speed+=acceleration
#		if event.is_action_pressed("ui_down"):
#			speed-=acceleration
#		if event.is_action_pressed("ui_right"):
#			rSpeed+=(rotationAcceleration)
#		if event.is_action_pressed("ui_left"):
#			rSpeed-=(rotationAcceleration)
		

