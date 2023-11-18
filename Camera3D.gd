extends Camera3D

@export var offset: Vector3 

@export var target: Node3D

@export var targetView: Node3D

@export var lerpSpeed: float = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level=true
	offset = Vector3.ZERO # position - target.position 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var d:float= position.distance_to(target.global_position + offset)
	var lerpV:float = ( ((1+d*.2))+lerpSpeed ) * delta
	position = position.lerp(target.global_position + offset,lerpV)
	look_at(targetView.position, targetView.basis.y)

