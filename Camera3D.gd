extends Camera3D

@export var offset: Vector3 

@export var target: Node3D

@export var targetView: Node3D

@export var lerpSpeed: float = 10

#initial fov
var initialFov: float = 65
#fovChange
@export var fovChange: float = .4
# Called when the node enters the scene tree for the first time.
func _ready():
	initialFov = fov
	top_level=true
	offset = Vector3.ZERO # position - target.position 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var d:float= abs(global_position.distance_to(target.global_position + offset))
	global_position= global_position.lerp(target.global_position + offset,lerpSpeed*delta)
	look_at(targetView.global_position, targetView.basis.y)
	#change fov based of offset distance
	fov = min(130, initialFov + d*fovChange)

