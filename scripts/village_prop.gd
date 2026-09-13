class_name VillageProp
extends Node2D

var prop_type: String = "house"
var prop_scale: float = 1.0
var warm: bool = false

func setup(kind: String, at: Vector2, size_scale: float = 1.0, has_warm_light: bool = false) -> VillageProp:
    prop_type = kind
    global_position = at
    prop_scale = size_scale
    warm = has_warm_light
    scale = Vector2.ONE * prop_scale
    return self

func _ready() -> void:
    z_index = -10
    queue_redraw()

func _draw() -> void:
    match prop_type:
        "chapel":
            _draw_chapel()
        "cart":
            _draw_cart()
        "lamp":
            _draw_lamp()
        "well":
            _draw_well()
        _:
            _draw_house()

func _draw_house() -> void:
    draw_rect(Rect2(-72,-118,144,118), Color("#141b24"))
    draw_polygon(PackedVector2Array([Vector2(-84,-118),Vector2(0,-178),Vector2(84,-118)]), PackedColorArray([Color("#101720")]))
    draw_rect(Rect2(-14,-62,28,62), Color("#0a0f16"))
    draw_rect(Rect2(-50,-90,24,28), Color("#2a2130"))
    draw_rect(Rect2(28,-90,24,28), Color("#2a2130"))
    if warm:
        draw_rect(Rect2(-47,-87,18,22), Color(0.95,0.61,0.25,0.48))
        draw_rect(Rect2(31,-87,18,22), Color(0.95,0.61,0.25,0.34))
    draw_line(Vector2(-72,-4),Vector2(72,-4),Color("#28343c"),4.0)

func _draw_chapel() -> void:
    draw_rect(Rect2(-78,-154,156,154), Color("#111923"))
    draw_polygon(PackedVector2Array([Vector2(-90,-154),Vector2(0,-218),Vector2(90,-154)]), PackedColorArray([Color("#0e151e")]))
    draw_rect(Rect2(-20,-78,40,78),Color("#080c12"))
    draw_circle(Vector2(0,-126),18,Color("#221d2c"))
    draw_line(Vector2(0,-218),Vector2(0,-252),Color("#28323a"),5.0)
    draw_line(Vector2(-13,-239),Vector2(13,-239),Color("#28323a"),4.0)
    if warm:
        draw_circle(Vector2(0,-126),13,Color(0.78,0.44,0.90,0.26))

func _draw_cart() -> void:
    draw_rect(Rect2(-55,-34,110,30),Color("#49392d"))
    draw_line(Vector2(45,-19),Vector2(92,-43),Color("#5b4939"),6.0)
    draw_circle(Vector2(-34,3),17,Color("#17191d"))
    draw_circle(Vector2(34,3),17,Color("#17191d"))
    draw_arc(Vector2(-34,3),17,0,TAU,20,Color("#6b5948"),4.0)
    draw_arc(Vector2(34,3),17,0,TAU,20,Color("#6b5948"),4.0)

func _draw_lamp() -> void:
    draw_line(Vector2(0,0),Vector2(0,-102),Color("#303a41"),6.0)
    draw_line(Vector2(0,-98),Vector2(24,-98),Color("#303a41"),4.0)
    draw_rect(Rect2(15,-96,18,28),Color("#1a2026"))
    draw_circle(Vector2(24,-82),12,Color(0.97,0.60,0.22,0.24 if warm else 0.08))
    draw_circle(Vector2(24,-82),5,Color("#efaa4f") if warm else Color("#6b5360"))

func _draw_well() -> void:
    draw_rect(Rect2(-42,-32,84,32),Color("#293139"))
    draw_arc(Vector2(0,-30),42,PI,TAU,24,Color("#53606a"),7.0)
    draw_line(Vector2(-36,-28),Vector2(-36,-88),Color("#4e4034"),6.0)
    draw_line(Vector2(36,-28),Vector2(36,-88),Color("#4e4034"),6.0)
    draw_line(Vector2(-42,-86),Vector2(42,-86),Color("#4e4034"),6.0)
