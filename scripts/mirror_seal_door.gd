class_name MirrorSealDoor
extends StaticBody2D

var door_size: Vector2 = Vector2(66,900)
var opened: bool = false
var collision_shape: CollisionShape2D
var time: float = 0.0

func setup(at: Vector2, size_value: Vector2 = Vector2(66,900)) -> MirrorSealDoor:
    global_position = at
    door_size = size_value
    z_index = 3
    return self

func _ready() -> void:
    collision_layer = 4
    collision_mask = 0
    collision_shape = CollisionShape2D.new()
    var rect: RectangleShape2D = RectangleShape2D.new()
    rect.size = door_size
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
    tween.tween_property(self,"modulate:a",0.0,0.8)
    tween.tween_property(self,"position:y",position.y-210.0,0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.chain().tween_callback(queue_free)

func _draw() -> void:
    if opened:
        return
    draw_rect(Rect2(-door_size*0.5,door_size),Color("#241d2c"))
    for y: int in range(-392,393,58):
        var pulse: float = 0.13+0.07*sin(time*2.5+float(y)*0.018)
        draw_circle(Vector2(0,float(y)),13.0,Color(0.66,0.34,0.83,pulse))
        draw_line(Vector2(-8,float(y)-8),Vector2(8,float(y)+8),Color("#b387ce"),2.0)
        draw_line(Vector2(8,float(y)-8),Vector2(-8,float(y)+8),Color("#b387ce"),2.0)
