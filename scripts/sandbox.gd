extends Node2D
## The sandbox: handles user input (placing bodies) and draws the simulation.
##
## This script deliberately contains NO physics. It owns a PhysWorld and asks it
## to step forward every physics tick. Godot's built-in physics engine is not used.
##
## Input actions (defined in Project Settings -> Input Map):
##   place_dynamic  - Left mouse   : place a dynamic body
##   place_static   - Right mouse  : place a static body
##   shape_circle   - 1            : select circle
##   shape_box      - 2            : select box
##   pause          - Space        : pause / resume
##   clear          - C            : remove all bodies


func _ready() -> void:
	# Milestone 1: create the world and a static floor here.
	pass


func _physics_process(_delta: float) -> void:
	# Milestone 2: step the world here (unless paused), then queue_redraw().
	pass


func _unhandled_input(_event: InputEvent) -> void:
	# Milestone 1: react to the input actions listed above.
	pass


func _draw() -> void:
	# Milestone 1: draw every body here.
	pass
