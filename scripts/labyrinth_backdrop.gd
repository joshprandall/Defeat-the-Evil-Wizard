class_name LabyrinthBackdrop
extends Node2D

const REGION_LEFT: float = 21200.0
const REGION_RIGHT: float = 27650.0
var time: float = 0.0

func _ready() -> void:
    z_index = -9
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(REGION_LEFT,-80,REGION_RIGHT-REGION_LEFT,820),Color("#100e18"))

    # Deep repeating maze masonry.
    for row: int in range(4):
        var y: float = 80.0+float(row)*135.0
        for i: int in range(26):
            var x: float = REGION_LEFT+float(i)*260.0+float(row%2)*120.0
            var h: float = 82.0+float((i*37+row*53)%80)
            draw_rect(Rect2(x,y,82.0,h),Color("#252231"))
            draw_rect(Rect2(x+82.0,y+h-18.0,150.0,18.0),Color("#292536"))

    # Vertical light wells.
    for i: int in range(9):
        var x: float = REGION_LEFT+340.0+float(i)*720.0
        draw_polygon(
            PackedVector2Array([
                Vector2(x-38,0),
                Vector2(x+38,0),
                Vector2(x+120,620),
                Vector2(x-120,620)
            ]),
            PackedColorArray([Color(0.39,0.29,0.61,0.018)])
        )

    # Floor haze.
    for i: int in range(34):
        var span: float = REGION_RIGHT-REGION_LEFT
        var x: float = REGION_LEFT+fmod(time*(8.0+float(i%4)*2.0)+float(i)*211.0,span)
        var y: float = 500.0+float(i%5)*21.0
        draw_circle(Vector2(x,y),64.0,Color(0.50,0.38,0.68,0.015))

    # Rune constellations hinting the solution.
    _rune(Vector2(22400,140),"bell",Color("#d9b45f"))
    draw_line(Vector2(22435,140),Vector2(22610,140),Color(0.75,0.69,0.58,0.20),2.0)
    _rune(Vector2(22650,140),"moon",Color("#80c8eb"))
    draw_line(Vector2(22685,140),Vector2(22860,140),Color(0.64,0.68,0.82,0.20),2.0)
    _rune(Vector2(22900,140),"crown",Color("#bc82e1"))

func _rune(at: Vector2, rune_id: String, c: Color) -> void:
    draw_circle(at,25.0,Color(c.r,c.g,c.b,0.055))
    draw_arc(at,18.0,0.0,TAU,18,c,2.0)
    if rune_id == "bell":
        draw_arc(at,8.0,PI,TAU,10,c,3.0)
        draw_line(at+Vector2(-8,0),at+Vector2(-11,10),c,3.0)
        draw_line(at+Vector2(8,0),at+Vector2(11,10),c,3.0)
        draw_line(at+Vector2(-11,10),at+Vector2(11,10),c,3.0)
    elif rune_id == "moon":
        draw_arc(at,10.0,-PI*0.55,PI*0.55,12,c,4.0)
    else:
        draw_line(at+Vector2(-11,8),at+Vector2(-8,-8),c,3.0)
        draw_line(at+Vector2(-8,-8),at,c,3.0)
        draw_line(at,at+Vector2(8,-8),c,3.0)
        draw_line(at+Vector2(8,-8),at+Vector2(11,8),c,3.0)
