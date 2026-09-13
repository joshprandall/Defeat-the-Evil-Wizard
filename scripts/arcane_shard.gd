class_name ArcaneShard
extends Area2D

signal collected(shard_id: String, value: int)

var shard_id: String = ""
var value: int = 1
var base_y: float = 0.0
var phase: float = 0.0
var taken: bool = false

func setup(at: Vector2, id: String, shard_value: int = 1) -> ArcaneShard:
    global_position = at
    shard_id = id
    value = shard_value
    return self

func _ready() -> void:
    collision_layer = 0
    collision_mask = 1
    z_index = 4
    add_to_group("arcane_shards")
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var circle: CircleShape2D = CircleShape2D.new()
    circle.radius = 18.0
    shape_node.shape = circle
    add_child(shape_node)
    body_entered.connect(_on_body_entered)
    base_y = global_position.y
    phase = global_position.x * 0.013
    queue_redraw()

func _process(delta: float) -> void:
    if taken:
        return
    phase += delta * 2.35
    global_position.y = base_y + sin(phase) * 6.0
    rotation = sin(phase * 0.63) * 0.10
    queue_redraw()

func _on_body_entered(body: Node) -> void:
    if taken or not (body is Hero):
        return
    taken = true
    monitoring = false
    collision_mask = 0
    collected.emit(shard_id, value)
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(1.65,1.65), 0.22)
    tween.tween_property(self, "modulate:a", 0.0, 0.22)
    tween.chain().tween_callback(queue_free)

func _draw() -> void:
    var pulse: float = 0.82 + sin(phase * 1.4) * 0.12
    draw_circle(Vector2.ZERO, 26.0, Color(0.27,0.72,1.0,0.08 * pulse))
    draw_circle(Vector2.ZERO, 18.0, Color(0.39,0.79,1.0,0.13 * pulse))
    var diamond: PackedVector2Array = PackedVector2Array([
        Vector2(0,-15), Vector2(11,0), Vector2(0,15), Vector2(-11,0)
    ])
    draw_colored_polygon(diamond, Color("#71d5ff"))
    draw_polyline(PackedVector2Array([Vector2(0,-15),Vector2(11,0),Vector2(0,15),Vector2(-11,0),Vector2(0,-15)]), Color("#d7f5ff"), 2.0)
    draw_line(Vector2(-5,-2), Vector2(6,-7), Color(1,1,1,0.72), 2.0)
