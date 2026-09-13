class_name WoodsProp
extends Node2D

var prop_kind: String = "tree"
var size_scale: float = 1.0
var glow: bool = false
var time: float = 0.0

func setup(kind: String, at: Vector2, scale_value: float = 1.0, glowing: bool = false) -> WoodsProp:
    prop_kind = kind
    global_position = at
    size_scale = scale_value
    glow = glowing
    z_index = -2
    return self

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE*size_scale)
    match prop_kind:
        "tree":
            draw_polygon(
                PackedVector2Array([Vector2(-28,0),Vector2(28,0),Vector2(18,-190),Vector2(-17,-190)]),
                PackedColorArray([Color("#1a2929")])
            )
            draw_line(Vector2(-4,-120),Vector2(-92,-170),Color("#1a2929"),16.0)
            draw_line(Vector2(7,-150),Vector2(96,-214),Color("#1a2929"),14.0)
            draw_circle(Vector2(-82,-176),42.0,Color("#18312d"))
            draw_circle(Vector2(78,-218),46.0,Color("#16302b"))
            draw_circle(Vector2(8,-220),62.0,Color("#19362f"))
        "mushrooms":
            for i: int in range(5):
                var x: float = -34.0+float(i)*17.0
                var h: float = 14.0+float((i*7)%13)
                draw_line(Vector2(x,0),Vector2(x,-h),Color("#b5a9a0"),3.0)
                var c: Color = Color("#78d9b0") if i%2==0 else Color("#9a7fe2")
                draw_circle(Vector2(x,-h),7.0,c)
                draw_circle(Vector2(x,-h),13.0,Color(c.r,c.g,c.b,0.08+0.03*sin(time*2.0+float(i))))
        "stone":
            draw_polygon(
                PackedVector2Array([Vector2(-42,0),Vector2(38,0),Vector2(29,-72),Vector2(-28,-80)]),
                PackedColorArray([Color("#374244")])
            )
            draw_line(Vector2(-10,-58),Vector2(10,-30),Color("#76c7a7"),4.0)
            draw_line(Vector2(10,-30),Vector2(0,-12),Color("#76c7a7"),4.0)
            if glow:
                draw_arc(Vector2(0,-38),36.0,0.0,TAU,20,Color(0.35,0.86,0.66,0.18+0.06*sin(time*2.4)),3.0)
        "lantern":
            draw_line(Vector2(0,0),Vector2(0,-88),Color("#3c4546"),6.0)
            draw_rect(Rect2(-11,-90,22,28),Color("#283234"))
            draw_circle(Vector2(0,-76),7.0,Color("#c9ef9e"))
            draw_circle(Vector2(0,-76),22.0,Color(0.66,0.95,0.56,0.06+0.02*sin(time*3.0)))
