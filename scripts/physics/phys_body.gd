class_name PhysBody
extends RefCounted

# Units: pixels, seconds, radians. 100 px = 1m.

enum ShapeType { CIRCLE, BOX }

const DENSITY: float = 0.001

var shape_type: ShapeType = ShapeType.CIRCLE

# for circles
var radius: float = 0.0

# for rectangles
var width: float = 0.0
var height: float = 0.0

# position of center
var position: Vector2 = Vector2.ZERO

var rotation: float = 0.0

# px/s
var linear_velocity: Vector2 = Vector2.ZERO

# rad/s
var angular_velocity: float = 0.0

var mass: float = 0.0
var inv_mass: float = 0.0

var inertia: float = 0.0
var inv_inertia: float = 0.0

# bounciness
var restitution: float = 0.2

var friction: float = 0.5

var is_static: bool = false

# rectangle corners relative to center
var local_vertices: PackedVector2Array = PackedVector2Array()

# rectangle corners in world space
var world_vertices: PackedVector2Array = PackedVector2Array()

# axis alignes bounding box
var aabb: Rect2 = Rect2()

var color: Color = Color.WHITE


static func create_circle(pos: Vector2, circle_radius: float, static_body: bool) -> PhysBody:
	var circle := PhysBody.new();
	circle.shape_type = ShapeType.CIRCLE;
	circle.position = pos;
	circle.radius = circle_radius;
	circle.is_static = static_body;
	if circle.is_static:
		circle.color = Color.RED;
	else:
		circle.color = Color.BLUE;
	circle.compute_mass_properties();
	circle.update_shape();
	return circle;

static func create_box(pos: Vector2, box_width: float, box_height: float, static_body: bool) -> PhysBody:
	var box := PhysBody.new();
	box.shape_type = ShapeType.BOX;
	box.position = pos;
	box.width = box_width;
	box.height = box_height;
	box.is_static = static_body;
	if box.is_static:
		box.color = Color.RED;
	else:
		box.color = Color.BLUE;
	box.local_vertices.append(Vector2(-box_width/2, -box_height/2));
	box.local_vertices.append(Vector2(box_width/2, -box_height/2));
	box.local_vertices.append(Vector2(box_width/2, box_height/2));
	box.local_vertices.append(Vector2(-box_width/2, box_height/2));
	box.compute_mass_properties();
	box.update_shape();
	return box;

func compute_mass_properties() -> void:
	match shape_type:
		ShapeType.CIRCLE:
			mass = DENSITY * PI * radius * radius
			inertia = 0.5 * mass * radius * radius
		ShapeType.BOX:
			mass = DENSITY * width * height
			inertia = mass * (width * width + height * height) / 12.0

	if is_static or mass <= 0.0:
		inv_mass = 0.0
		inv_inertia = 0.0
	else:
		inv_mass = 1.0 / mass
		inv_inertia = 1.0 / inertia

func update_shape() -> void:
	match shape_type:
		ShapeType.CIRCLE:
			var top_left = position - Vector2(radius, radius);
			var size = Vector2(2 * radius, 2 * radius);
			aabb = Rect2(top_left, size);
		ShapeType.BOX:
			world_vertices.resize(local_vertices.size());
			for i in range(local_vertices.size()):
				world_vertices[i] = position + local_vertices[i].rotated(rotation);
				
			var box_aabb := Rect2(world_vertices[0], Vector2.ZERO);
			for i in range(world_vertices.size()):
				box_aabb = box_aabb.expand(world_vertices[i]);
			aabb = box_aabb;
