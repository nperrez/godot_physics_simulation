class_name Manifold
extends RefCounted

var body_a: PhysBody
var body_b: PhysBody
var normal: Vector2
var depth: float
var contacts: PackedVector2Array
var contact_count: int

func _init(a, b, n, d) -> void:
	body_a = a;
	body_b = b;
	normal = n;
	depth = d;
	
