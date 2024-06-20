extends CharacterBody3D

@export var ray: RayCast3D 

@onready var currentLine = $"../Path3D" as Path3D
@export var currentPath: PathFollow3D 




var dir: Vector3

@export var acceleration: float
var gVelocity: Vector3
var linearVelocity: float

var lVelocity: float = 0
@export var friction: float = .95

@export var rAcceleration: float
var rSpeed: float
@export var rFriction: float = .8

@export var gravity:float = 20
@export var mass: float = 1
@export var maxSpeed: float
@export var groundMagnetDist: float = 1

@export var groundMagnetRotSpeed: float = 10
@export var groundMagnetHeighSpeed: float = 10
# Called when the node enters the scene tree for the first time.
var curve:Curve3D
var state: Callable
var delta: float 


func _ready():
	#currentPath = get_tree().current_scene.get_node("Path3D/PathFollow3D")
	#currentLine = get_tree().current_scene.get_node("$../track")
	

	curve = currentLine.curve
	state = onTrack

func _process(delta):
	
	if get_slide_collision_count() > 0:
		state=onCrash
	self.delta=delta
	state.call()

func onTrack():
	#dir=Vector3.ZERO
	if ray.is_colliding(): 
		var i:Vector2 = Input.get_vector("left","right","reverse","acel")
		lVelocity += acceleration * i.y
	#	velocity+=transform.basis.z * acceleration * i.y
		rSpeed+=(-rAcceleration*i.x)*delta
		
		var p: Vector3 = ray.get_collision_point()
		var desiredPos: Vector3 = p + transform.basis.y * groundMagnetDist
		
		var pDist: float = position.distance_to(p)
		var dist: float = (desiredPos.distance_to(position))
	
		var n:Vector3 =  ray.get_collision_normal()
		var t: Transform3D = transform
		var rDif: float = 1+abs(basis.y.angle_to(n) )*10
		var lerpR: float = (rDif *groundMagnetRotSpeed)*delta
		var lerpV: float = ( (1+dist)**groundMagnetHeighSpeed)*delta
		
		var poffset = curve.get_closest_point( position )
		var normal = (poffset - global_position).normalized() as Vector3
		#rotation = normal
		#
		
		t.basis.y = n
		t.basis.x = -t.basis.z.cross(n)
		t.basis = t.basis.orthonormalized()
		
		transform.basis = basis.slerp(t.basis,lerpR).orthonormalized() #transform.interpolate_with(t,lerpV)
		
		position = position.lerp(desiredPos, lerpV)
		velocity = basis.z * lVelocity
		move_and_collide((velocity)*delta)
		rotate(transform.basis.y.normalized(),rSpeed)
		rSpeed*=rFriction
	#	velocity*=friction+(1-friction if i.length()<.1 else 0)
		
		lVelocity*=friction+(1-friction if i.length()<.1 else 0)
		#speed*=friction
	else:
		_on_GetOffTrack()

func offTrack():
	
	var i:Vector2 = Input.get_vector("left","right","reverse","acel")
	lVelocity += acceleration * i.y if i.y<0 else 0 
#	velocity+=transform.basis.z * acceleration * i.y
	rSpeed+=(rAcceleration*i.x)*delta*.85
	
	velocity+=Vector3.DOWN * gravity
	move_and_collide((velocity)*delta)
	rotate(transform.basis.z.normalized(),rSpeed)
	
	rotate(transform.basis.x.normalized(), i.y *delta)
	rSpeed*=rFriction
	
	
	pass
signal crashed

func onCrash():
	lVelocity=0
	velocity=Vector3.ZERO
	crashed.emit()
	state=onCrash


signal getOnTrack
func _on_GetOnTrack():
	getOnTrack.emit()
	state = onTrack
	
signal getOffTrack
func _on_GetOffTrack():
	getOffTrack.emit()
	state = offTrack
	
		#transform.origin.lerp( (p + transform.basis.y * groundMagnetDist), lerpV ) #* groundMagnetLerp * delta)


#		rgbd.apply_central_force( transform.basis.y * groundMagnet * delta)
#	rgbd.apply_impulse(transform.basis.z * delta / speed * rgbd.mass)
 

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
