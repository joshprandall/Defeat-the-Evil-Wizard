class_name CinematicArt
extends Control

var scene_kind: String = "village"
var champion: String = "warrior"
var time: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func set_scene(kind: String, hero_class: String = "warrior") -> void:
    scene_kind = kind
    champion = hero_class
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO,size),Color("#070a10"))
    match scene_kind:
        "prologue":
            _draw_village()
        "black_gate":
            _draw_black_gate()
        "woods":
            _draw_woods()
        "keep":
            _draw_keep()
        "labyrinth":
            _draw_labyrinth()
        "mountain":
            _draw_mountain()
        _:
            _draw_village()
    _draw_champion_silhouette()

func _draw_champion_silhouette() -> void:
    var base: Vector2 = Vector2(size.x*0.18,size.y*0.84)
    var accent: Color = Color("#d6a55b")
    if champion == "mage":
        accent = Color("#72c7f4")
    elif champion == "rogue":
        accent = Color("#bd83ec")
    elif champion == "paladin":
        accent = Color("#eed878")
    elif champion == "archer":
        accent = Color("#7fdda3")
    elif champion == "barbarian":
        accent = Color("#e07756")
    elif champion == "fighter":
        accent = Color("#e0b66f")
    elif champion == "monk":
        accent = Color("#7ed8c8")
    elif champion == "ranger":
        accent = Color("#91c96d")
    elif champion == "cleric":
        accent = Color("#b8d8ef")

    draw_set_transform(base,0.0,Vector2(1.35,1.35))
    draw_circle(Vector2(0,-64),13.0,Color("#171b23"))
    draw_polygon(
        PackedVector2Array([Vector2(-20,-51),Vector2(20,-51),Vector2(16,-6),Vector2(-16,-6)]),
        PackedColorArray([Color("#141820")])
    )
    draw_line(Vector2(-8,-7),Vector2(-10,18),Color("#11151b"),8.0)
    draw_line(Vector2(8,-7),Vector2(10,18),Color("#11151b"),8.0)

    if champion == "mage":
        draw_polygon(PackedVector2Array([Vector2(-17,-73),Vector2(0,-100),Vector2(19,-73)]),PackedColorArray([Color("#141820")]))
        draw_line(Vector2(17,-43),Vector2(38,-91),accent,4.0)
        draw_circle(Vector2(40,-95),6.0,accent)
    elif champion == "rogue":
        draw_polygon(PackedVector2Array([Vector2(-18,-75),Vector2(0,-94),Vector2(18,-75),Vector2(12,-56),Vector2(-12,-56)]),PackedColorArray([Color("#141820")]))
        draw_line(Vector2(13,-42),Vector2(41,-17),accent,4.0)
        draw_line(Vector2(8,-35),Vector2(34,-5),accent,3.0)
    elif champion == "paladin":
        draw_circle(Vector2(-30,-42),19.0,Color("#141820"))
        draw_arc(Vector2(-30,-42),21.0,0.0,TAU,20,accent,4.0)
        draw_line(Vector2(15,-42),Vector2(44,-10),accent,5.0)
    elif champion == "archer":
        draw_arc(Vector2(31,-44),26.0,-1.25,1.25,20,accent,4.0)
        draw_line(Vector2(31,-68),Vector2(31,-20),accent,1.5)
    elif champion == "barbarian":
        draw_polygon(PackedVector2Array([Vector2(-22,-52),Vector2(22,-52),Vector2(17,-61),Vector2(-17,-61)]),PackedColorArray([Color("#141820")]))
        draw_line(Vector2(15,-43),Vector2(48,-12),accent,7.0)
        draw_circle(Vector2(51,-9),11.0,accent)
    elif champion == "fighter":
        draw_circle(Vector2(-28,-40),12.0,Color("#141820"))
        draw_arc(Vector2(-28,-40),13.0,0.0,TAU,18,accent,3.0)
        draw_line(Vector2(15,-43),Vector2(46,-15),accent,5.0)
    elif champion == "monk":
        draw_line(Vector2(-16,-40),Vector2(-40,-20),accent,5.0)
        draw_line(Vector2(16,-40),Vector2(40,-20),accent,5.0)
        draw_arc(Vector2(0,-40),30.0,0.0,TAU,22,Color(accent.r,accent.g,accent.b,0.22),3.0)
    elif champion == "ranger":
        draw_arc(Vector2(31,-44),25.0,-1.22,1.22,20,accent,4.0)
        draw_line(Vector2(31,-67),Vector2(31,-21),accent,2.0)
        draw_line(Vector2(-12,-49),Vector2(22,-30),accent,3.0)
    elif champion == "cleric":
        draw_line(Vector2(16,-43),Vector2(43,-90),accent,5.0)
        draw_circle(Vector2(45,-94),7.0,accent)
        draw_arc(Vector2(0,-41),27.0,0.0,TAU,22,Color(accent.r,accent.g,accent.b,0.20),3.0)
    else:
        draw_circle(Vector2(-28,-40),14.0,Color("#141820"))
        draw_line(Vector2(15,-43),Vector2(45,-13),accent,5.0)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_village() -> void:
    draw_rect(Rect2(0,size.y*0.58,size.x,size.y*0.42),Color("#111a22"))
    for i: int in range(7):
        var x: float = float(i)*size.x/6.0-50.0
        var h: float = 80.0+float((i*31)%90)
        draw_polygon(
            PackedVector2Array([
                Vector2(x,size.y*0.70),
                Vector2(x+130,size.y*0.70),
                Vector2(x+105,size.y*0.70-h),
                Vector2(x+30,size.y*0.70-h)
            ]),
            PackedColorArray([Color("#17222c")])
        )
        draw_polygon(
            PackedVector2Array([
                Vector2(x+16,size.y*0.70-h),
                Vector2(x+67,size.y*0.70-h-46),
                Vector2(x+116,size.y*0.70-h)
            ]),
            PackedColorArray([Color("#101820")])
        )
    draw_circle(Vector2(size.x*0.78,size.y*0.23),54.0,Color(0.88,0.83,0.66,0.24))

func _draw_black_gate() -> void:
    draw_rect(Rect2(0,size.y*0.62,size.x,size.y*0.38),Color("#11131a"))
    var gate_x: float = size.x*0.66
    draw_line(Vector2(gate_x-82,size.y*0.62),Vector2(gate_x-82,size.y*0.18),Color("#252532"),30.0)
    draw_line(Vector2(gate_x+82,size.y*0.62),Vector2(gate_x+82,size.y*0.18),Color("#252532"),30.0)
    draw_arc(Vector2(gate_x,size.y*0.22),82.0,PI,TAU,28,Color("#252532"),30.0)
    for r: int in range(3):
        draw_arc(Vector2(gate_x,size.y*0.37),48.0+float(r)*20.0,0.0,TAU,30,Color(0.55,0.20,0.72,0.22-float(r)*0.04),3.0)
    draw_circle(Vector2(gate_x,size.y*0.37),8.0,Color("#bb72e3"))

func _draw_woods() -> void:
    draw_rect(Rect2(0,size.y*0.64,size.x,size.y*0.36),Color("#102019"))
    draw_circle(Vector2(size.x*0.78,size.y*0.22),52.0,Color("#bac9b9"))
    draw_circle(Vector2(size.x*0.80,size.y*0.20),51.0,Color("#08120f"))
    for i: int in range(12):
        var x: float = 30.0+float(i)*size.x/11.0
        var h: float = 180.0+float((i*41)%130)
        draw_line(Vector2(x,size.y*0.70),Vector2(x+sin(float(i))*20.0,size.y*0.70-h),Color("#173129"),18.0)
    for i: int in range(28):
        var x: float = fmod(float(i)*97.0+time*12.0,size.x)
        var y: float = 70.0+float((i*47)%250)
        draw_circle(Vector2(x,y),2.0,Color(0.70,1.0,0.68,0.55))

func _draw_keep() -> void:
    draw_rect(Rect2(0,size.y*0.62,size.x,size.y*0.38),Color("#0c2029"))
    for i: int in range(5):
        var x: float = 180.0+float(i)*190.0
        draw_line(Vector2(x,size.y*0.62),Vector2(x,size.y*0.18),Color("#263940"),24.0)
        draw_arc(Vector2(x+70,size.y*0.22),70.0,PI,TAU,24,Color("#263940"),22.0)
    for i: int in range(14):
        var y: float = size.y*0.64+float(i%3)*25.0
        var drift: float = fmod(time*18.0+float(i)*83.0,size.x)
        draw_line(Vector2(drift,y),Vector2(minf(size.x,drift+88.0),y),Color(0.37,0.78,0.92,0.10),2.0)

func _draw_labyrinth() -> void:
    draw_rect(Rect2(0,size.y*0.62,size.x,size.y*0.38),Color("#15131f"))
    for i: int in range(10):
        var x: float = 40.0+float(i)*size.x/9.5
        var top: float = 80.0+float((i*37)%150)
        draw_rect(Rect2(x,top,34.0,size.y*0.68-top),Color("#2a2637"))
        if i < 9:
            var bridge_y: float = 130.0+float((i*53)%190)
            draw_rect(Rect2(x,bridge_y,size.x/10.0,22.0),Color("#302b3e"))
    _draw_rune(Vector2(size.x*0.52,size.y*0.30),"bell",Color("#ddb65e"))
    _draw_rune(Vector2(size.x*0.66,size.y*0.30),"moon",Color("#8dc9ea"))
    _draw_rune(Vector2(size.x*0.80,size.y*0.30),"crown",Color("#c799ed"))

func _draw_mountain() -> void:
    draw_rect(Rect2(0,size.y*0.72,size.x,size.y*0.28),Color("#17151a"))
    draw_polygon(
        PackedVector2Array([
            Vector2(size.x*0.22,size.y*0.72),
            Vector2(size.x*0.52,size.y*0.08),
            Vector2(size.x*0.78,size.y*0.72)
        ]),
        PackedColorArray([Color("#2b2730")])
    )
    draw_polygon(
        PackedVector2Array([
            Vector2(size.x*0.48,size.y*0.18),
            Vector2(size.x*0.52,size.y*0.08),
            Vector2(size.x*0.56,size.y*0.20)
        ]),
        PackedColorArray([Color("#b6b3b9")])
    )
    for i: int in range(8):
        var y: float = 85.0+float(i)*35.0
        draw_line(Vector2(size.x*0.46,y),Vector2(size.x*0.58,y+20.0),Color(0.77,0.29,0.20,0.10),3.0)

func _draw_rune(at: Vector2, rune_id: String, color: Color) -> void:
    draw_circle(at,26.0,Color(color.r,color.g,color.b,0.08))
    draw_arc(at,20.0,0.0,TAU,20,color,2.0)
    if rune_id == "bell":
        draw_arc(at+Vector2(0,2),9.0,PI,TAU,12,color,3.0)
        draw_line(at+Vector2(-9,2),at+Vector2(-12,12),color,3.0)
        draw_line(at+Vector2(9,2),at+Vector2(12,12),color,3.0)
        draw_line(at+Vector2(-12,12),at+Vector2(12,12),color,3.0)
    elif rune_id == "moon":
        draw_arc(at,10.0,-PI*0.55,PI*0.55,14,color,4.0)
    else:
        draw_line(at+Vector2(-12,9),at+Vector2(-9,-8),color,3.0)
        draw_line(at+Vector2(-9,-8),at+Vector2(0,1),color,3.0)
        draw_line(at+Vector2(0,1),at+Vector2(9,-8),color,3.0)
        draw_line(at+Vector2(9,-8),at+Vector2(12,9),color,3.0)
