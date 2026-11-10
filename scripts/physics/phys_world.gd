class_name PhysWorld
extends RefCounted

var bodies: Array[PhysBody]
const gravity = Vector2(0, 981)
var bottom_y: float

func step(dt) -> void:
	for body in bodies:
		if !body.is_static:
			if body.position.y > bottom_y:
				bodies.erase(body);
			body.linear_velocity = body.linear_velocity + gravity * dt;
			body.position = body.position + body.linear_velocity * dt;
			body.update_shape();
