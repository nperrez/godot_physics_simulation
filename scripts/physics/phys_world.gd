class_name PhysWorld
extends RefCounted

var bodies: Array[PhysBody]
const gravity = Vector2(0, 981)
var bottom_y: float
var debug_manifolds: Array[Manifold]

func step(dt) -> void:
	debug_manifolds.clear();
	for body in bodies:
		if !body.is_static:
			if body.position.y > bottom_y:
				bodies.erase(body);
			body.linear_velocity = body.linear_velocity + gravity * dt;
			body.position = body.position + body.linear_velocity * dt;
			body.update_shape();
			
	for i in range(bodies.size()):
		for j in range(i + 1, bodies.size()):
			var a = bodies[i];
			var b = bodies[j];
			if a.is_static && b.is_static:
				continue;
			if !a.aabb.intersects(b.aabb):
				continue;
			var m = Collisions.detect(a, b);
			if m == null:
				continue;
			_separate(m);
			Collisions.find_contacts(m);
			_resolve(m);
			debug_manifolds.append(m);

func _separate(m: Manifold) -> void:
	var a = m.body_a;
	var b = m.body_b;
	var total_inv_mass = a.inv_mass + b.inv_mass;
	if total_inv_mass == 0:		#both bodies static
		return
	a.position -= m.normal * m.depth * (a.inv_mass / total_inv_mass);
	b.position += m.normal * m.depth * (b.inv_mass / total_inv_mass);
	a.update_shape();
	b.update_shape();

func _resolve(m: Manifold) -> void:
	var a = m.body_a;
	var b = m.body_b;
	var n = m.normal;
	var v_rel = b.linear_velocity - a.linear_velocity;
	var vn = v_rel.dot(n);
	if vn > 0:
		return
	
	var e = min(a.restitution, b.restitution);
	var j = -(1 + e) * vn / (a.inv_mass + b.inv_mass);
	
	a.linear_velocity -= n * j * a.inv_mass;
	b.linear_velocity += n * j * b.inv_mass;
