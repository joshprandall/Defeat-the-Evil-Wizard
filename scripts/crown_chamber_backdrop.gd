class_name CrownChamberBackdrop
extends Node2D

const REGION_LEFT: float = 45800.0
const REGION_RIGHT: float = 52800.0
var time: float = 0.0

func _ready() -> void:
    z_index = -5
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(REGION_LEFT,-100,REGION_RIGHT-REGION_LEFT,840),Color("#09070d"))

    # Cathedral ribs / columns.
    for i: int in range(10):
        var x: float = REGION_LEFT+260.0+float(i)*720.0
        draw_rect(Rect2(x,80,72,540),Color("#211b28"))
        draw_line(Vector2(x+36,80),Vector2(x+36,620),Color("#3a2c47"),4.0)
        draw_arc(Vector2(x+180,118),180.0,PI,TAU,28,Color("#2d2436"),16.0)

    # Stained-glass story panels.
    var glass_colors: Array[Color] = [
        Color("#4f6a91"),Color("#496f58"),Color("#3c6e78"),
        Color("#7a5a82"),Color("#805044"),Color("#6b587d")
    ]
    for i: int in range(6):
        var x: float = REGION_LEFT+520.0+float(i)*1030.0
        var c: Color = glass_colors[i]
        draw_rect(Rect2(x-52,160,104,200),Color(0.05,0.04,0.07,0.88))
        draw_arc(Vector2(x,160),52.0,PI,TAU,22,c,10.0)
        draw_rect(Rect2(x-42,168,84,178),Color(c.r,c.g,c.b,0.18))
        draw_line(Vector2(x,170),Vector2(x,345),Color(c.r,c.g,c.b,0.30),3.0)
        draw_line(Vector2(x-40,250),Vector2(x+40,250),Color(c.r,c.g,c.b,0.30),3.0)

    # Crown dais and throne.
    draw_rect(Rect2(49620,535,1240,85),Color("#1d1722"))
    draw_rect(Rect2(50050,500,380,35),Color("#33263c"))
    draw_polygon(
        PackedVector2Array([
            Vector2(50145,500),Vector2(50190,350),Vector2(50240,500)
        ]),
        PackedColorArray([Color("#3c2c48")])
    )
    draw_polygon(
        PackedVector2Array([
            Vector2(50280,500),Vector2(50335,320),Vector2(50390,500)
        ]),
        PackedColorArray([Color("#44304f")])
    )
    draw_polygon(
        PackedVector2Array([
            Vector2(50430,500),Vector2(50480,350),Vector2(50525,500)
        ]),
        PackedColorArray([Color("#3c2c48")])
    )

    # Suspended crown.
    var crown_y: float = 155.0+sin(time*1.4)*7.0
    draw_circle(Vector2(50335,crown_y),66.0,Color(0.66,0.30,0.82,0.06))
    draw_line(Vector2(50335,0),Vector2(50335,crown_y-42),Color("#4b3b55"),3.0)
    draw_polygon(
        PackedVector2Array([
            Vector2(50282,crown_y+18),Vector2(50290,crown_y-18),
            Vector2(50310,crown_y+2),Vector2(50335,crown_y-28),
            Vector2(50360,crown_y+2),Vector2(50380,crown_y-18),
            Vector2(50388,crown_y+18)
        ]),
        PackedColorArray([Color("#a879c0")])
    )
    draw_line(Vector2(50282,crown_y+18),Vector2(50388,crown_y+18),Color("#d3a6e5"),5.0)

    # Arcane floor seams.
    for i: int in range(15):
        var x: float = 48720.0+float(i)*190.0
        var pulse: float = 0.08+0.05*sin(time*2.4+float(i)*0.7)
        draw_line(Vector2(x,605),Vector2(x+95,570),Color(0.64,0.29,0.78,pulse),3.0)

    # Airborne motes around the crown.
    for i: int in range(34):
        var ang: float = time*(0.16+float(i%4)*0.035)+float(i)*0.81
        var radius: float = 85.0+float((i*19)%170)
        var p: Vector2 = Vector2(50335,crown_y)+Vector2(cos(ang),sin(ang)*0.52)*radius
        draw_circle(p,2.0,Color(0.78,0.54,0.90,0.18))
