class_name MovingKeepPlatform
extends AnimatableBody2D

var point_a: Vector2 = Vector2.ZERO
var point_b: Vector2 = Vector2.ZERO
var travel_time: float = 2.2
var elapsed: float = 0.0
var platform_size: Vector2 = Vector2(170,26)

func setup(a: Vector2, b: Vector2, seconds: float = 2.2, size_value: Vector2 = Vector2(170,26)) -> MovingKeepPlatform:
    point_a = a
    point_b = b
    travel_time = maxf(0.4,seconds)
    platform_size = size_value
    global_position = point_a
    z_index = 1
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
    elapsed += delta
    var phase: float = fmod(elapsed/travel_time,2.0)
    var t: float = phase if phase <= 1.0 else 2.0-phase
    t = t*t*(3.0-2.0*t)
    global_position = point_a.lerp(point_b,t)

func _draw() -> void:
    draw_rect(Rect2(-platform_size*0.5,platform_size),Color("#35464d"))
    draw_line(Vector2(-platform_size.x*0.42,-2),Vector2(platform_size.x*0.42,-2),Color("#6b858c"),3.0)
    draw_circle(Vector2(-platform_size.x*0.36,0),4.0,Color("#6eb8ca"))
    draw_circle(Vector2(platform_size.x*0.36,0),4.0,Color("#6eb8ca"))
