class_name StormGate
extends StaticBody2D

var gate_size: Vector2 = Vector2(64,900)
var opened: bool = false
var collision_shape: CollisionShape2D
var time: float = 0.0

func setup(at: Vector2, size_value: Vector2 = Vector2(64,900)) -> StormGate:
    global_position = at
    gate_size = size_value
    z_index = 3
    return self

func _ready() -> void:
    collision_layer = 4
    collision_mask = 0
    collision_shape = CollisionShape2D.new()
    var rect: RectangleShape2D = RectangleShape2D.new()
    rect.size = gate_size
    collision_shape.shape = rect
    add_child(collision_shape)
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func open_gate() -> void:
    if opened:
        return
    opened = true
    collision_shape.set_deferred("disabled",true)
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self,"modulate:a",0.0,0.85)
    tween.tween_property(self,"position:y",position.y-220.0,0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.chain().tween_callback(queue_free)

func _draw() -> void:
    if opened:
        return
    draw_rect(Rect2(-gate_size*0.5,gate_size),Color("#302a33"))
    for y: int in range(-390,391,56):
        var glow: float = 0.13+0.06*sin(time*2.8+float(y)*0.02)
        draw_circle(Vector2(0,float(y)),12.0,Color(0.84,0.35,0.22,glow))
        draw_arc(Vector2(0,float(y)),9.0,0.0,TAU,16,Color("#bd6b54"),2.0)
