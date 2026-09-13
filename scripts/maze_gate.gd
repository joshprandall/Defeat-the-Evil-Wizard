class_name MemoryGate
extends StaticBody2D

var gate_size: Vector2 = Vector2(58,900)
var opened: bool = false
var glow_time: float = 0.0
var collision_shape: CollisionShape2D

func setup(at: Vector2, size_value: Vector2 = Vector2(58,900)) -> MemoryGate:
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
    glow_time += delta
    queue_redraw()

func open_gate() -> void:
    if opened:
        return
    opened = true
    if is_instance_valid(collision_shape):
        collision_shape.set_deferred("disabled",true)
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self,"modulate:a",0.0,0.75)
    tween.tween_property(self,"position:y",position.y-180.0,0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.chain().tween_callback(queue_free)

func _draw() -> void:
    if opened:
        return
    draw_rect(Rect2(-gate_size*0.5,gate_size),Color("#292536"))
    for y: int in range(-390,391,54):
        draw_circle(Vector2(0,float(y)),11.0,Color(0.61,0.42,0.83,0.10+0.05*sin(glow_time*2.7+float(y)*0.02)))
        draw_arc(Vector2(0,float(y)),9.0,0.0,TAU,16,Color("#8d6ab2"),2.0)
