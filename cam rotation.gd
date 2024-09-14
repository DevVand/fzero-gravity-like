extends Node3D

var mouse_sensitivity = 0.3
var camera_angle_x = 0

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		var change_in_y = event.relative.y * mouse_sensitivity
		if camera_angle_x + change_in_y > -50 and camera_angle_x + change_in_y < 50:
			camera_angle_x += change_in_y
			rotate_x(deg_to_rad(change_in_y))
	
