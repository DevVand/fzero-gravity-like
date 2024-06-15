extends RayCast3D


@onready var body_3d = $".." as CharacterBody3D

func _ready():
	pass # Replace with function body.


func _process(delta):
	var dir:Vector3 = Vector3(body_3d.velocity.x,0,body_3d.velocity.z)
	look_at((body_3d.global_position - dir)*20)
