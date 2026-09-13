class_name ArcaneMirror
extends Node2D

var mirror_id: String = "first"
var orientation: int = 0
var target_orientation: int = 1
var target: Hero
var pulse: float = 0.0

func setup(id: String, at: Vector2, correct_orientation: int, hero: Hero = null) -> ArcaneMirror:
    mirror_id = id
    global_position = at
    target_orientation = posmod(correct_orientation,4)
    target = hero
    z_index = 4
    add_to_group("arcane_mirrors")
    return self

func _process(delta: float) -> void:
    pulse += delta
    if not is_instance_valid(target):
        var candidate: Node = get_tree().get_first_node_in_group("player_hero")
        if candidate is Hero:
            target = candidate as Hero
    queue_redraw()

func is_player_near() -> bool:
    return is_instance_valid(target) and global_position.distance_to(target.global_position) <= 115.0

func rotate_clockwise() -> void:
    orientation = posmod(orientation+1,4)
    queue_redraw()

func is_correct() -> bool:
    return orientation == target_orientation

func direction_name() -> String:
    var names: Array[String] = ["UP","RIGHT","DOWN","LEFT"]
    return names[orientation]

func _dir() -> Vector2:
    var directions: Array[Vector2] = [
        Vector2(0,-1),
        Vector2(1,0),
        Vector2(0,1),
        Vector2(-1,0)
    ]
    return directions[orientation]

func _draw() -> void:
    draw_set_transform(Vector2(0,8),0.0,Vector2(1.3,0.28))
    draw_circle(Vector2.ZERO,22.0,Color(0,0,0,0.23))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

    draw_rect(Rect2(-24,-26,48,26),Color("#3c3344"))
    draw_line(Vector2(0,-26),Vector2(0,-82),Color("#66566d"),6.0)

    var d: Vector2 = _dir()
    var c: Color = Color("#c58ee5") if not is_correct() else Color("#f0d482")
    draw_set_transform(Vector2(0,-72),float(orientation)*PI*0.5,Vector2.ONE)
    draw_polygon(
        PackedVector2Array([Vector2(-22,-7),Vector2(22,-7),Vector2(18,7),Vector2(-18,7)]),
        PackedColorArray([Color("#d6d2d8")])
    )
    draw_line(Vector2(-18,0),Vector2(18,0),c,3.0)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

    var beam_end: Vector2 = Vector2(0,-72)+d*72.0
    draw_line(Vector2(0,-72),beam_end,Color(c.r,c.g,c.b,0.22),4.0)
    draw_circle(beam_end,5.0,Color(c.r,c.g,c.b,0.30))
    draw_circle(Vector2(0,-72),34.0,Color(c.r,c.g,c.b,0.06+0.03*sin(pulse*2.7)))

    # Correct mirrors use the same confirmation language as Storm Vanes.
    if is_correct():
        draw_circle(Vector2(0,-121),18.0,Color(0.72,0.97,0.86,0.10))
        draw_arc(Vector2(0,-121),18.0,0.0,TAU,24,Color("#b7f7db"),2.5)
        draw_line(Vector2(-9,-122),Vector2(-2,-114),Color("#b7f7db"),4.0)
        draw_line(Vector2(-2,-114),Vector2(11,-130),Color("#b7f7db"),4.0)

    if is_player_near():
        draw_arc(Vector2(0,-122),11.0,0.0,TAU,18,Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-127),Vector2(-4,-117),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-127),Vector2(4,-127),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-122),Vector2(3,-122),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-117),Vector2(4,-117),Color("#f0d082"),2.0)
