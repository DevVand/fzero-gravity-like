extends AnimationPlayer

func _play(anim: String):
	stop(false)
	play(anim)


func _playWorse(body:Node3D, anim: String):
	stop(false)
	play(anim)
