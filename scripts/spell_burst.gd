class_name SpellBurst
extends Node2D

var radius: float = 100.0
var tint: Color = Color.WHITE
var life: float = 0.34
var elapsed: float = 0.0

func setup(at: Vector2, target_radius: float, color: Color) -> SpellBurst:
    global_position = at
    radius = target_radius
    tint = color
    return self

func _ready() -> void:
    z_index = 8
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    queue_redraw()
    if elapsed >= life:
        queue_free()

func _draw() -> void:
    var t: float = clampf(elapsed / life, 0.0, 1.0)
    var r: float = lerpf(radius * 0.12, radius, t)
    var alpha: float = 0.72 * (1.0 - t)
    draw_circle(Vector2.ZERO, r * 0.42, Color(tint.r,tint.g,tint.b,alpha * 0.18))
    draw_arc(Vector2.ZERO, r, 0, TAU, 52, Color(tint.r,tint.g,tint.b,alpha), 5.0)
    draw_arc(Vector2.ZERO, r * 0.72, 0, TAU, 42, Color(1.0,1.0,1.0,alpha * 0.46), 2.0)
