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
	return Manifold.new(a, b, normal, depth, Manifold.CollisionType.CC);
	
static func box_box(a: PhysBody, b: PhysBody) -> Manifold:
	var best_depth = INF;
	var best_axis = Vector2.ZERO;
	for vs in [a.world_vertices, b.world_vertices]:
		for i in range(vs.size()):
			var edge = vs[(i + 1) % vs.size()] - vs[i];
			var axis = Vector2(-edge.y, edge.x).normalized();
			var pa = project_vertices(a.world_vertices, axis);
			var pb = project_vertices(b.world_vertices, axis);
			if pa.y < pb.x || pb.y < pa.x:
				return null;
			var overlap = min(pa.y, pb.y) - max(pa.x, pb.x);
			if overlap < best_depth:
				best_depth = overlap;
				best_axis = axis;
	
	if (b.position - a.position).dot(best_axis) < 0:
		best_axis = -best_axis
	return Manifold.new(a, b, best_axis, best_depth, Manifold.CollisionType.BB);
	
static func circle_box(circle: PhysBody, box: PhysBody) -> Manifold:
	var best_depth = INF;
	var best_axis = Vector2.ZERO;
	for vs in [circle.world_vertices, box.world_vertices]:
		for i in range(vs.size()):
			var edge = vs[(i + 1) % vs.size()] - vs[i];
			var axis = Vector2(-edge.y, edge.x).normalized();
			var p_circle = project_circle(circle.position, circle.radius, axis);
			var p_box = project_vertices(box.world_vertices, axis);
			if p_circle.y < p_box.x || p_box.y < p_circle.x:
				return null;
			var overlap = min(p_circle.y, p_box.y) - max(p_circle.x, p_box.x);
			if overlap < best_depth:
				best_depth = overlap;
				best_axis = axis;
	
	var closest_corner = box.world_vertices[closest_vertex_index(circle.position, box.world_vertices)];
	var axis = (closest_corner - circle.position).normalized();
	var p_circle = project_circle(circle.position, circle.radius, axis);
	var p_box = project_vertices(box.world_vertices, axis);
	if p_circle.y < p_box.x || p_box.y < p_circle.x:
		return null;
	var overlap = min(p_circle.y, p_box.y) - max(p_circle.x, p_box.x);
	if overlap < best_depth:
		best_depth = overlap;
		best_axis = axis;
	
	if (box.position - circle.position).dot(best_axis) < 0:
		best_axis = -best_axis
	return Manifold.new(circle, box, best_axis, best_depth, Manifold.CollisionType.CB);

static func detect(a: PhysBody, b: PhysBody) -> Manifold:
	if a.shape_type == PhysBody.ShapeType.CIRCLE && b.shape_type == PhysBody.ShapeType.CIRCLE:
		return circle_circle(a, b);
	elif a.shape_type == PhysBody.ShapeType.CIRCLE && b.shape_type == PhysBody.ShapeType.BOX:
		return circle_box(a, b);
	elif a.shape_type == PhysBody.ShapeType.BOX && b.shape_type == PhysBody.ShapeType.CIRCLE:
		return circle_box(b, a);
	elif a.shape_type == PhysBody.ShapeType.BOX && b.shape_type == PhysBody.ShapeType.BOX:
		return box_box(a, b);
	return null;

static func find_contacts(m: Manifold) -> void:
	if m.collision_type == Manifold.CollisionType.CC:
		m.contacts = [m.body_a.position + m.normal * m.body_a.radius]
	
	elif m.collision_type == Manifold.CollisionType.CB:
		var point = Vector2.ZERO;
		var dist = INF;
		var vertices = m.body_b.world_vertices.duplicate();
		vertices.append(vertices[0]);
		var edge_points: Array[PackedVector2Array];
		for i in range(vertices.size() - 1):
			edge_points.append([vertices[i + 1], vertices[i]]);
		for i in range(edge_points.size()):
			var p = closest_point_on_segment(m.body_a.position, edge_points[i][0], edge_points[i][1]);
			if m.body_a.position.distance_squared_to(p) < dist:
				dist = m.body_a.position.distance_squared_to(p);
				point = p;
		m.contacts = [point];
	
	elif m.collision_type == Manifold.CollisionType.BB:
		var best = INF;
		var c1 = null;
		var c2 = null;
		
		var verts_a = m.body_a.world_vertices;
		var verts_b = m.body_b.world_vertices;
		for pair in [[verts_a, verts_b], [verts_b, verts_a]]:
			var points: PackedVector2Array = pair[0];
			var other: PackedVector2Array = pair[1];
			
			for p in points:
				for i in range(other.size()):
					var e0 := other[i];
					var e1 := other[(i + 1) % other.size()]
					var cp = closest_point_on_segment(p, e0, e1);
					var dist = p.distance_squared_to(cp);
					if absf(dist - best) < 0.01 and !cp.is_equal_approx(c1):
						c2 = cp;
					elif dist < best:
						best = dist;
						c1 = cp;
						c2 = null;
		
		if c2 == null:
			m.contacts = [c1];
		else:
			m.contacts = [c1, c2];

static func project_vertices(vertices: PackedVector2Array, axis: Vector2) -> Vector2:
	var low = INF;
	var high = -INF;
	for v in vertices:
		var p = v.dot(axis);
		low = min(low, p);
		high = max(high, p);
	return Vector2(low, high);
	
static func project_circle(center: Vector2, radius: float, axis: Vector2) -> Vector2:
	var p = center.dot(axis);
	return Vector2(p - radius, p + radius);

static func closest_vertex_index(point: Vector2, vertices: PackedVector2Array) -> int:
	var closest = -1;
	var dist = INF;
	for i in range(vertices.size()):
		var pv = (vertices[i] - point).length_squared();
		if pv < dist:
			dist = pv;
			closest = i;
	return closest;
	
static func closest_point_on_segment(p: Vector2, a:Vector2, b:Vector2) -> Vector2:
	var ab = b - a;
	var t = clamp((p -a).dot(ab) / ab.length_squared(), 0, 1);
	return a + ab * t;
