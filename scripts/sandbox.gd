extends Node2D
## Input actions (defined in Project Settings -> Input Map):
##   place_dynamic  - Left mouse   : place a dynamic body
##   place_static   - Right mouse  : place a static body
##   shape_circle   - 1            : select circle
##   shape_box      - 2            : select box
##   pause          - Space        : pause / resume
##   clear          - C            : remove all bodies

var bodies: Array[PhysBody]
var shape = PhysBody.ShapeType.CIRCLE
var paused = false

func _ready() -> void:
	var screen_size := get_viewport_rect().size;
	var floor_height := 40.0;
	var floor_pos := Vector2(screen_size.x / 2, screen_size.y - floor_height / 2);
	bodies.append(PhysBody.create_box(floor_pos, screen_size.x, floor_height, true));


func _physics_process(_delta: float) -> void:
	queue_redraw();


func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("shape_box"):
		shape = PhysBody.ShapeType.BOX;
	elif _event.is_action_pressed("shape_circle"):
		shape = PhysBody.ShapeType.CIRCLE;
	elif _event.is_action_pressed("place_static"):
		var pos = get_global_mouse_position();
		if shape == PhysBody.ShapeType.CIRCLE:
			bodies.append(PhysBody.create_circle(pos, 100, true));
		else:
			bodies.append(PhysBody.create_box(pos, 100, 100, true));
	elif _event.is_action_pressed("place_dynamic"):
		var pos = get_global_mouse_position();
		if shape == PhysBody.ShapeType.CIRCLE:
			bodies.append(PhysBody.create_circle(pos, 100, false));
		else:
			bodies.append(PhysBody.create_box(pos, 100, 100, false));
	elif _event.is_action_pressed("clear"):
		bodies.clear();
		_ready();


func _draw() -> void:
	for body in bodies:
		if body.shape_type == PhysBody.ShapeType.CIRCLE:
			draw_circle(body.position, body.radius, body.color, true);
			draw_circle(body.position, body.radius, Color.BLACK, false, 2, true);
		if body.shape_type == PhysBody.ShapeType.BOX:
			draw_colored_polygon(body.world_vertices, body.color);
			draw_polyline(body.world_vertices, Color.BLACK, 2, true);
