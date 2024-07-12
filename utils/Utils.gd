
class_name Utils

static func RotateToBasis(v: Vector3,b: Basis) -> Vector3:
		return b.z*v.z + b.x*v.x +b.y*v.y
