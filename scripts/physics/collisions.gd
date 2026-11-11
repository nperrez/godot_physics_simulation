class_name Collisions
extends RefCounted

static func circle_circle(a: PhysBody, b: PhysBody) -> Manifold:
	var delta = b.position - a.position;
	var radii = a.radius + b.radius;
	if delta.length_squared() >= radii*radii:
		return null;
	
	var dist = delta.length();
	if dist == 0:
		dist = Vector2(0, -1);
	var normal = delta / dist;
	var depth = radii - dist;
	return Manifold.new(a, b, normal, depth);

static func detect(a: PhysBody, b: PhysBody) -> Manifold:
	if a.shape_type == PhysBody.ShapeType.CIRCLE && b.shape_type == PhysBody.ShapeType.CIRCLE:
		return circle_circle(a, b);
	return null;

static func find_contacts(m: Manifold) -> void:
	m.contacts = [m.body_a.position + m.normal * m.body_a.radius]
