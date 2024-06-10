extends RayCast3D

var wasColliding:bool = false
signal enteredColision
signal exitedColision
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding() && !wasColliding:
		enteredColision.emit()
		wasColliding=is_colliding()
	elif !is_colliding() && wasColliding:
		exitedColision.emit()
		wasColliding=is_colliding()
