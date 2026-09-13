class_name PhasePlatform
extends AnimatableBody2D

signal sfx_requested(id: String, volume_db: float, pitch: float)

var platform_size: Vector2 = Vector2(170,26)
var phase_offset: float = 0.0
var period: float = 3.0
var solid_time: float = 1.75
var elapsed: float = 0.0
var solid: bool = true
var collision_shape: CollisionShape2D
var last_state: bool = true

func setup(at: Vector2, size_value: Vector2 = Vector2(170,26), offset: float = 0.0) -> PhasePlatform:
    global_position = at
    platform_size = size_value
    phase_offset = offset
    z_index = 2
    return self

func _ready() -> void:
    collision_layer = 4
    collision_mask = 0
    elapsed = phase_offset
    collision_shape = CollisionShape2D.new()
    var rect: RectangleShape2D = RectangleShape2D.new()
    rect.size = platform_size
    collision_shape.shape = rect
    add_child(collision_shape)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    var cycle: float = fmod(elapsed,period)
    solid = cycle < solid_time
    if solid != last_state:
        last_state = solid
        collision_shape.set_deferred("disabled",not solid)
        sfx_requested.emit("phase_shift",-15.0,1.10 if solid else 0.86)
    queue_redraw()

func _draw() -> void:
    var cycle: float = fmod(elapsed,period)
    var edge_warning: bool = solid and cycle > solid_time-0.45
    var alpha: float = 0.88 if solid else 0.18
    if edge_warning:
        alpha = 0.44+0.28*absf(sin(elapsed*18.0))

    draw_rect(
        Rect2(Vector2(-platform_size.x*0.5,-platform_size.y*0.5),platform_size),
        Color(0.28,0.22,0.36,alpha)
    )
    draw_line(
        Vector2(-platform_size.x*0.42,-2),
        Vector2(platform_size.x*0.42,-2),
        Color(0.68,0.42,0.84,alpha),
        3.0
    )
    for i: int in range(4):
        var x: float = -platform_size.x*0.32+float(i)*(platform_size.x*0.22)
        draw_circle(Vector2(x,0),3.0,Color(0.78,0.52,0.92,alpha))
