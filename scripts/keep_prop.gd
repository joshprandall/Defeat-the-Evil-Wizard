class_name KeepProp
extends Node2D

var prop_kind: String = "torch"
var size_scale: float = 1.0
var time: float = 0.0

func setup(kind: String, at: Vector2, scale_value: float = 1.0) -> KeepProp:
    prop_kind = kind
    global_position = at
    size_scale = scale_value
    z_index = -1
    return self

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE*size_scale)
    match prop_kind:
        "torch":
            draw_line(Vector2(0,0),Vector2(0,-82),Color("#475157"),6.0)
            draw_polygon(
                PackedVector2Array([Vector2(-9,-83),Vector2(9,-83),Vector2(6,-101),Vector2(-6,-101)]),
                PackedColorArray([Color("#39454a")])
            )
            var pulse: float = 0.8+0.2*sin(time*7.0)
            draw_circle(Vector2(0,-105),8.0,Color("#70c6df"))
            draw_circle(Vector2(0,-105),25.0,Color(0.30,0.72,0.92,0.055*pulse))
        "statue":
            draw_rect(Rect2(-30,-18,60,18),Color("#394448"))
            draw_polygon(
                PackedVector2Array([Vector2(-18,-20),Vector2(18,-20),Vector2(13,-105),Vector2(-13,-105)]),
                PackedColorArray([Color("#424e52")])
            )
            draw_circle(Vector2(0,-119),17.0,Color("#465358"))
            draw_line(Vector2(0,-82),Vector2(38,-44),Color("#566267"),7.0)
            draw_line(Vector2(38,-44),Vector2(47,-13),Color("#566267"),5.0)
        "arch":
            draw_line(Vector2(-58,0),Vector2(-58,-150),Color("#344348"),18.0)
            draw_line(Vector2(58,0),Vector2(58,-150),Color("#344348"),18.0)
            draw_arc(Vector2(0,-148),58.0,PI,TAU,24,Color("#344348"),18.0)
        "rubble":
            draw_polygon(
                PackedVector2Array([Vector2(-52,0),Vector2(-35,-32),Vector2(-8,-18),Vector2(15,-45),Vector2(52,0)]),
                PackedColorArray([Color("#3a474b")])
            )
            draw_line(Vector2(-28,-17),Vector2(25,-30),Color("#526166"),3.0)
