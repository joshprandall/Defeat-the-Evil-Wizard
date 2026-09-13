class_name ArcaneElevator
extends AnimatableBody2D

var point_a: Vector2
var point_b: Vector2
var travel_time: float = 2.8
var timer: float = 0.0
var platform_size: Vector2 = Vector2(190,28)

func setup(a: Vector2, b: Vector2, seconds: float = 2.8, size_value: Vector2 = Vector2(190,28)) -> ArcaneElevator:
    point_a = a
    point_b = b
    global_position = a
    travel_time = maxf(0.8,seconds)
    platform_size = size_value
    z_index = 2
    return self

func _ready() -> void:
    collision_layer = 4
    collision_mask = 0
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var rect: RectangleShape2D = RectangleShape2D.new()
    rect.size = platform_size
    shape_node.shape = rect
    add_child(shape_node)
    queue_redraw()

func _physics_process(delta: float) -> void:
    timer += delta
    var t: float = (sin(timer*TAU/(travel_time*2.0)-PI*0.5)+1.0)*0.5
    global_position = point_a.lerp(point_b,t)
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2(-platform_size.x*0.5,-platform_size.y*0.5),platform_size),Color("#3e334a"))
    draw_line(Vector2(-platform_size.x*0.42,-2),Vector2(platform_size.x*0.42,-2),Color("#8c62a7"),3.0)
    draw_circle(Vector2.ZERO,11.0,Color(0.63,0.34,0.76,0.24))
    draw_arc(Vector2.ZERO,9.0,0.0,TAU,18,Color("#a178bd"),2.0)
