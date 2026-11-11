extends Node2D
## Input actions (defined in Project Settings -> Input Map):
##   place_dynamic  - Left mouse   : place a dynamic body
##   place_static   - Right mouse  : place a static body
##   shape_circle   - 1            : select circle
##   shape_box      - 2            : select box
##   pause          - Space        : pause / resume
##   clear          - C            : remove all bodies

var shape = PhysBody.ShapeType.CIRCLE
var paused = false
static var world = PhysWorld.new()
var rot = 0;

func _ready() -> void:
	var screen_size := get_viewport_rect().size;
	var floor_height := 40.0;
	var floor_pos := Vector2(screen_size.x / 2, screen_size.y - floor_height / 2);
	world.bodies.append(PhysBody.create_box(floor_pos, screen_size.x, floor_height, true));
	world.bottom_y = screen_size.y + 200;


func _physics_process(_delta: float) -> void:
	if !paused:
		world.step(_delta)
	queue_redraw();


func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("shape_box"):
		shape = PhysBody.ShapeType.BOX;
	elif _event.is_action_pressed("shape_circle"):
		shape = PhysBody.ShapeType.CIRCLE;
	elif _event.is_action_pressed("place_static"):
		var pos = get_global_mouse_position();
		if shape == PhysBody.ShapeType.CIRCLE:
			world.bodies.append(PhysBody.create_circle(pos, 50, true));
		else:
			var box = PhysBody.create_box(pos, 50, 50, true);
			box.rotation = rot;
			box.update_shape();
			world.bodies.append(box);
	elif _event.is_action_pressed("place_dynamic"):
		var pos = get_global_mouse_position();
		if shape == PhysBody.ShapeType.CIRCLE:
			world.bodies.append(PhysBody.create_circle(pos, 50, false));
		else:
			var box = PhysBody.create_box(pos, 50, 50, false);
			box.rotation = rot;
			box.update_shape();
			world.bodies.append(box);
	elif _event.is_action_pressed("clear"):
		world.bodies.clear();
		_ready();
	elif _event.is_action_pressed("pause"):
		if paused:
			paused = false;
		else:
			paused = true;
	elif _event.is_action_pressed("rotate_placement"):
		rot += PI / 12;


func _draw() -> void:
	for body in world.bodies:
		if body.shape_type == PhysBody.ShapeType.CIRCLE:
			draw_circle(body.position, body.radius, body.color, true);
			draw_circle(body.position, body.radius, Color.BLACK, false, 2, true);
		if body.shape_type == PhysBody.ShapeType.BOX:
			draw_colored_polygon(body.world_vertices, body.color);
			var outline: PackedVector2Array = body.world_vertices.duplicate();
			outline.append(outline[0]);
			draw_polyline(outline, Color.BLACK, 2, true);
	for manifold in world.debug_manifolds:
		for contact in manifold.contacts:
			draw_circle(contact, 4, Color.YELLOW);
			draw_line(contact, contact + manifold.normal * 30, Color.GREEN, 2);
