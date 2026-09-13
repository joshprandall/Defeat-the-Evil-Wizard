class_name StormVane
extends Node2D

var vane_id: String = "east"
var target_orientation: int = 1
var orientation: int = 0
var target: Hero
var pulse: float = 0.0

func setup(id: String, at: Vector2, correct_orientation: int, hero: Hero = null) -> StormVane:
    vane_id = id
    global_position = at
    target_orientation = posmod(correct_orientation,4)
    target = hero
    z_index = 4
    add_to_group("storm_vanes")
    return self

func _process(delta: float) -> void:
    pulse += delta
    if not is_instance_valid(target):
        var candidate: Node = get_tree().get_first_node_in_group("player_hero")
        if candidate is Hero:
            target = candidate as Hero
    queue_redraw()

func is_player_near() -> bool:
    return is_instance_valid(target) and global_position.distance_to(target.global_position) <= 175.0

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
    var near: bool = is_player_near()
    var correct: bool = is_correct()
    var d: Vector2 = _dir()
    var main: Color = Color("#8fe8c7") if correct else Color("#f0c96f")
    var glow_alpha: float = 0.10+0.055*sin(pulse*3.2)
    if near:
        glow_alpha += 0.13+0.05*sin(pulse*7.0)

    # Ground interaction halo so the vane cannot read as background decoration.
    draw_set_transform(Vector2(0,7),0.0,Vector2(1.75,0.34))
    draw_circle(Vector2.ZERO,31.0,Color(main.r,main.g,main.b,0.07 if not near else 0.16))
    draw_arc(Vector2.ZERO,34.0,0.0,TAU,28,Color(main.r,main.g,main.b,0.18 if not near else 0.55),3.0)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

    # Pedestal.
    draw_polygon(
        PackedVector2Array([
            Vector2(-35,0),Vector2(35,0),Vector2(27,-28),Vector2(-27,-28)
        ]),
        PackedColorArray([Color("#514a50")])
    )
    draw_line(Vector2(-27,-28),Vector2(27,-28),Color("#81777d"),3.0)
    draw_circle(Vector2(0,-14),7.0,Color(main.r,main.g,main.b,0.28))

    # Tall mast.
    draw_line(Vector2(0,-28),Vector2(0,-112),Color("#8a8185"),8.0)
    draw_line(Vector2(0,-30),Vector2(0,-108),Color("#c0b6b4"),2.0)

    # Large directional head.
    var pivot: Vector2 = Vector2(0,-91)
    var tip: Vector2 = pivot+d*41.0
    var side: Vector2 = Vector2(-d.y,d.x)
    draw_line(pivot,tip,main,9.0)
    draw_polygon(
        PackedVector2Array([
            tip,
            tip-d*18.0+side*11.0,
            tip-d*18.0-side*11.0
        ]),
        PackedColorArray([main])
    )

    # Arcane ring around the vane head.
    draw_circle(pivot,45.0,Color(main.r,main.g,main.b,glow_alpha*0.45))
    draw_arc(pivot,39.0,0.0,TAU,32,Color(main.r,main.g,main.b,0.32 if not near else 0.72),4.0)

    # Correct vanes get a persistent confirmation mark.
    if correct:
        draw_line(Vector2(-12,-143),Vector2(-3,-133),Color("#b7f7db"),4.0)
        draw_line(Vector2(-3,-133),Vector2(15,-154),Color("#b7f7db"),4.0)

    # Near-player interaction beacon and E badge.
    if near:
        var bounce: float = sin(pulse*5.0)*4.0
        draw_circle(Vector2(0,-178+bounce),18.0,Color(0.98,0.82,0.40,0.16))
        draw_arc(Vector2(0,-178+bounce),18.0,0.0,TAU,24,Color("#ffe08b"),3.0)
        var font: Font = ThemeDB.fallback_font
        draw_string(
            font,
            Vector2(-6,-172+bounce),
            "E",
            HORIZONTAL_ALIGNMENT_LEFT,
            -1,
            15,
            Color("#fff0b6")
        )
        draw_line(Vector2(0,-160+bounce),Vector2(0,-150),Color("#ffe08b"),3.0)
