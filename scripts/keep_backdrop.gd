class_name SunkenKeepBackdrop
extends Node2D

const REGION_LEFT: float = 14200.0
const REGION_RIGHT: float = 21450.0
var time: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var windows: Array[Vector2] = []

func _ready() -> void:
    z_index = -10
    rng.seed = 80819
    for i: int in range(24):
        windows.append(Vector2(
            REGION_LEFT + 220.0 + float(i) * 292.0 + rng.randf_range(-52.0,52.0),
            rng.randf_range(130.0,330.0)
        ))
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(REGION_LEFT,-80,REGION_RIGHT-REGION_LEFT,820),Color("#0b1219"))

    # Distant flooded masonry.
    for i: int in range(19):
        var x: float = REGION_LEFT + float(i)*390.0
        var h: float = 280.0 + float((i*53)%190)
        draw_rect(Rect2(x,610.0-h,290.0,h),Color("#17242a"))
        draw_arc(Vector2(x+145.0,610.0-h),110.0,PI,TAU,24,Color("#1d2d33"),20.0)

    # High arches.
    for i: int in range(10):
        var x: float = REGION_LEFT + 240.0 + float(i)*720.0
        draw_line(Vector2(x,590),Vector2(x,125),Color("#24343a"),28.0)
        draw_line(Vector2(x+330,590),Vector2(x+330,125),Color("#24343a"),28.0)
        draw_arc(Vector2(x+165,150),165.0,PI,TAU,28,Color("#24343a"),28.0)

    # Cold windows.
    for p: Vector2 in windows:
        var flicker: float = 0.72 + 0.20*sin(time*2.3+p.x*0.011)
        draw_rect(Rect2(p.x-8,p.y-34,16,68),Color(0.30,0.66,0.78,0.11*flicker))
        draw_circle(p,24.0,Color(0.24,0.65,0.80,0.025*flicker))

    # Floodwater below the road.
    draw_rect(Rect2(REGION_LEFT,592,REGION_RIGHT-REGION_LEFT,148),Color("#0b2530"))
    for i: int in range(52):
        var y: float = 602.0 + float(i%4)*21.0
        var span: float = REGION_RIGHT-REGION_LEFT
        var drift: float = fmod(time*(12.0+float(i%5)*3.0)+float(i)*71.0,span)
        draw_line(
            Vector2(REGION_LEFT+drift,y),
            Vector2(minf(REGION_RIGHT,REGION_LEFT+drift+90.0),y),
            Color(0.35,0.72,0.80,0.055),
            2.0
        )

    # Hanging chains.
    for i: int in range(17):
        var x: float = REGION_LEFT + 180.0 + float(i)*425.0
        var sway: float = sin(time*1.1+float(i))*7.0
        draw_line(Vector2(x,0),Vector2(x+sway,330.0+float((i*37)%130)),Color("#334249"),5.0)
        for link: int in range(7):
            var yy: float = 70.0+float(link)*38.0
            draw_arc(Vector2(x+sway*yy/430.0,yy),7.0,0.0,TAU,12,Color("#45565d"),2.0)
