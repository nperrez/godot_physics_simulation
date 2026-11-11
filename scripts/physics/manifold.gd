class_name Manifold
extends RefCounted

enum CollisionType {CC, CB, BB}

var body_a: PhysBody
var body_b: PhysBody
var normal: Vector2
var depth: float
var contacts: PackedVector2Array
var collision_type: CollisionType

func _init(a, b, n, d, ct) -> void:
	body_a = a;
	body_b = b;
	normal = n;
	depth = d;
	collision_type = ct;
