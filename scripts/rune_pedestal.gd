class_name RunePedestal
extends Node2D

var rune_id: String = "bell"
var display_name: String = "BELL"
var target: Hero
var activated: bool = false
var pulse: float = 0.0
var feedback_time: float = 0.0
var feedback_good: bool = true

func setup(id: String, at: Vector2, hero: Hero) -> RunePedestal:
    rune_id = id
    display_name = id.to_upper()
    global_position = at
    target = hero
    z_index = 4
    add_to_group("labyrinth_runes")
    return self

func _process(delta: float) -> void:
    pulse += delta
    feedback_time = maxf(0.0,feedback_time-delta)
    if not is_instance_valid(target):
        var candidate: Node = get_tree().get_first_node_in_group("player_hero")
        if candidate is Hero:
            target = candidate as Hero
    queue_redraw()

func is_player_near() -> bool:
    if not is_instance_valid(target):
        return false
    return global_position.distance_to(target.global_position) <= 110.0

func set_activated(value: bool) -> void:
    activated = value
    feedback_good = value
    feedback_time = 0.45
    queue_redraw()

func reject() -> void:
    feedback_good = false
    feedback_time = 0.55
    queue_redraw()

func _draw() -> void:
    draw_set_transform(Vector2(0,8),0.0,Vector2(1.25,0.28))
    draw_circle(Vector2.ZERO,24.0,Color(0,0,0,0.24))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

    draw_polygon(
        PackedVector2Array([Vector2(-31,0),Vector2(31,0),Vector2(24,-18),Vector2(-24,-18)]),
        PackedColorArray([Color("#3a3547")])
    )
    draw_rect(Rect2(-18,-70,36,52),Color("#302c3d"))

    var c: Color = Color("#d7b65d")
    if rune_id == "moon":
        c = Color("#7fc9ed")
    elif rune_id == "crown":
        c = Color("#bd83e3")

    if activated:
        c = c.lightened(0.22)

    var glow_alpha: float = 0.10+0.04*sin(pulse*2.6)
    if activated:
        glow_alpha = 0.28+0.08*sin(pulse*3.6)
    if feedback_time > 0.0 and not feedback_good:
        c = Color("#ef6868")
        glow_alpha = 0.34

    draw_circle(Vector2(0,-47),28.0,Color(c.r,c.g,c.b,glow_alpha))
    draw_arc(Vector2(0,-47),22.0,0.0,TAU,22,c,3.0)

    if rune_id == "bell":
        draw_arc(Vector2(0,-49),10.0,PI,TAU,12,c,3.0)
        draw_line(Vector2(-10,-49),Vector2(-13,-36),c,3.0)
        draw_line(Vector2(10,-49),Vector2(13,-36),c,3.0)
        draw_line(Vector2(-13,-36),Vector2(13,-36),c,3.0)
        draw_circle(Vector2(0,-33),2.5,c)
    elif rune_id == "moon":
        draw_arc(Vector2(0,-47),12.0,-PI*0.55,PI*0.55,14,c,4.0)
    else:
        draw_line(Vector2(-13,-38),Vector2(-10,-57),c,3.0)
        draw_line(Vector2(-10,-57),Vector2(0,-46),c,3.0)
        draw_line(Vector2(0,-46),Vector2(10,-57),c,3.0)
        draw_line(Vector2(10,-57),Vector2(13,-38),c,3.0)
        draw_line(Vector2(-13,-38),Vector2(13,-38),c,3.0)

    if is_player_near() and not activated:
        draw_arc(Vector2(0,-92),11.0,0.0,TAU,18,Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-97),Vector2(-4,-87),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-97),Vector2(4,-97),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-92),Vector2(3,-92),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-87),Vector2(4,-87),Color("#f0d082"),2.0)
