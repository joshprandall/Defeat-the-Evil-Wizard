class_name StonePlatform
extends StaticBody2D

var size := Vector2(400.0, 48.0)
var body_color := Color("#27323b")
var edge_color := Color("#6d8c78")

func setup(center: Vector2, platform_size: Vector2, color := Color("#27323b")) -> StonePlatform:
    position = center
    size = platform_size
    body_color = color
    collision_layer = 4
    collision_mask = 0
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    add_child(shape)
    queue_redraw()
    return self

func _draw() -> void:
    var r := Rect2(-size * 0.5, size)
    draw_rect(r, body_color)
    draw_rect(Rect2(r.position, Vector2(r.size.x, 5.0)), edge_color)
    var step := 64.0
    var x := r.position.x + 16.0
    while x < r.end.x:
        draw_line(Vector2(x, r.position.y + 8), Vector2(x + 20, r.position.y + 24), Color(0.12,0.16,0.18,0.7), 2.0)
        x += step
