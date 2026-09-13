class_name WorldGate
extends StaticBody2D

var gate_id: String = ""
var gate_size: Vector2 = Vector2(48,180)
var opened: bool = false
var collision_shape: CollisionShape2D

func setup(id_value: String, at: Vector2, size_value: Vector2 = Vector2(48,180)) -> WorldGate:
    gate_id = id_value
    global_position = at
    gate_size = size_value
    collision_layer = 4
    collision_mask = 0
    return self

func _ready() -> void:
    collision_shape = CollisionShape2D.new()
    var rect: RectangleShape2D = RectangleShape2D.new()
    rect.size = gate_size
    collision_shape.shape = rect
    add_child(collision_shape)
    queue_redraw()

func open_gate() -> void:
    if opened:
        return
    opened = true
    if is_instance_valid(collision_shape):
        collision_shape.disabled = true
    var tween: Tween = create_tween()
    tween.tween_property(self,"modulate:a",0.0,0.35)
    tween.tween_callback(queue_free)

func _draw() -> void:
    draw_rect(Rect2(-gate_size*0.5,gate_size),Color("#25222b"))
    for y: int in range(int(-gate_size.y*0.5)+12,int(gate_size.y*0.5),28):
        draw_line(Vector2(-gate_size.x*0.5+6,y),Vector2(gate_size.x*0.5-6,y),Color("#8d6f55"),4.0)
    draw_circle(Vector2(0,0),9.0,Color("#b38bdf"))
