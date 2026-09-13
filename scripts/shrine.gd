class_name CheckpointShrine
extends Node2D

var active := false
var pulse := 0.0

func setup(at: Vector2) -> CheckpointShrine:
    global_position = at
    z_index = 4
    return self

func activate() -> void:
    active = true
    pulse = 1.0
    queue_redraw()

func _process(delta: float) -> void:
    if active:
        pulse += delta * 2.2
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(-34, -15, 68, 15), Color("#202a31"))
    draw_rect(Rect2(-25, -44, 50, 30), Color("#34404a"))
    draw_polygon(PackedVector2Array([Vector2(-18,-44), Vector2(0,-68), Vector2(18,-44)]), PackedColorArray([Color("#44515b")]))
    var rune_color := Color("#65727a")
    var glow_alpha := 0.0
    if active:
        rune_color = Color("#8ce6d5")
        glow_alpha = 0.24 + 0.12 * sin(pulse)
        draw_circle(Vector2(0, -39), 34.0 + 4.0 * sin(pulse), Color(0.42, 0.95, 0.82, glow_alpha))
    draw_circle(Vector2(0, -39), 10.0, rune_color)
    draw_line(Vector2(-7,-39), Vector2(7,-39), Color("#132026"), 2.0)
    draw_line(Vector2(0,-46), Vector2(0,-32), Color("#132026"), 2.0)
