class_name BlightedMountainsBackdrop
extends Node2D

const REGION_LEFT: float = 26800.0
const REGION_RIGHT: float = 36450.0
var time: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var ash: Array[Vector2] = []

func _ready() -> void:
    z_index = -7
    rng.seed = 11031
    for i: int in range(95):
        ash.append(Vector2(
            rng.randf_range(REGION_LEFT,REGION_RIGHT),
            rng.randf_range(30.0,610.0)
        ))
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(REGION_LEFT,-100,REGION_RIGHT-REGION_LEFT,840),Color("#151219"))

    # Distant ranges.
    for layer: int in range(3):
        var base_y: float = 570.0-float(layer)*42.0
        var c: Color = Color("#2a2630").lightened(float(layer)*0.025)
        for i: int in range(9):
            var x: float = REGION_LEFT-220.0+float(i)*1260.0+float(layer)*170.0
            var peak: float = 185.0+float((i*83+layer*41)%250)
            draw_polygon(
                PackedVector2Array([
                    Vector2(x,base_y),
                    Vector2(x+430.0,base_y-peak),
                    Vector2(x+890.0,base_y)
                ]),
                PackedColorArray([c])
            )

    # Main peaks and snow scars.
    for i: int in range(7):
        var x: float = REGION_LEFT+540.0+float(i)*1370.0
        var peak_y: float = 70.0+float((i*61)%120)
        draw_polygon(
            PackedVector2Array([
                Vector2(x-540,620),
                Vector2(x,peak_y),
                Vector2(x+610,620)
            ]),
            PackedColorArray([Color("#37313b")])
        )
        draw_polygon(
            PackedVector2Array([
                Vector2(x-125,peak_y+145),
                Vector2(x,peak_y),
                Vector2(x+150,peak_y+165),
                Vector2(x+68,peak_y+145),
                Vector2(x+15,peak_y+105),
                Vector2(x-55,peak_y+160)
            ]),
            PackedColorArray([Color("#aaa6ad")])
        )

    # Blight fissures.
    for i: int in range(26):
        var x: float = REGION_LEFT+220.0+float(i)*360.0
        var y: float = 250.0+float((i*47)%260)
        var pulse: float = 0.06+0.025*sin(time*2.1+float(i))
        draw_line(Vector2(x,y),Vector2(x+85.0,y+42.0),Color(0.84,0.28,0.18,pulse),3.0)
        draw_line(Vector2(x+48.0,y+24.0),Vector2(x+22.0,y+67.0),Color(0.84,0.28,0.18,pulse*0.8),2.0)

    # Ash and snow moving sideways in the high wind.
    var span: float = REGION_RIGHT-REGION_LEFT
    for i: int in range(ash.size()):
        var p: Vector2 = ash[i]
        var drift: float = fmod((p.x-REGION_LEFT)+time*(38.0+float(i%5)*9.0),span)
        var bob: float = sin(time*1.8+float(i))*10.0
        var c: Color = Color(0.78,0.77,0.80,0.18) if i%3 else Color(0.38,0.33,0.36,0.20)
        draw_line(
            Vector2(REGION_LEFT+drift,p.y+bob),
            Vector2(REGION_LEFT+drift+12.0,p.y+bob-2.0),
            c,
            2.0
        )

    # Black Tower teaser at the far edge.
    var tower_x: float = 36030.0
    draw_polygon(
        PackedVector2Array([
            Vector2(tower_x-78,560),
            Vector2(tower_x+78,560),
            Vector2(tower_x+48,118),
            Vector2(tower_x+18,50),
            Vector2(tower_x-18,50),
            Vector2(tower_x-48,118)
        ]),
        PackedColorArray([Color("#121017")])
    )
    draw_circle(Vector2(tower_x,166),15.0,Color("#9e4dc2"))
    draw_circle(Vector2(tower_x,166),42.0,Color(0.60,0.22,0.74,0.07))
