class_name MountainVista
extends Node2D

const REGION_LEFT: float = 26700.0
const REGION_RIGHT: float = 28600.0
var time: float = 0.0

func _ready() -> void:
    z_index = -8
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(REGION_LEFT,-80,REGION_RIGHT-REGION_LEFT,820),Color(0.10,0.085,0.10,0.52))
    draw_polygon(
        PackedVector2Array([
            Vector2(26720,620),
            Vector2(27420,120),
            Vector2(28020,620)
        ]),
        PackedColorArray([Color("#2b2830")])
    )
    draw_polygon(
        PackedVector2Array([
            Vector2(27240,620),
            Vector2(27820,40),
            Vector2(28560,620)
        ]),
        PackedColorArray([Color("#37313a")])
    )
    draw_polygon(
        PackedVector2Array([
            Vector2(27640,210),
            Vector2(27820,40),
            Vector2(28000,220)
        ]),
        PackedColorArray([Color("#b8b3ba")])
    )
    for i: int in range(12):
        var y: float = 100.0+float(i)*34.0
        var pulse: float = 0.08+0.035*sin(time*2.0+float(i))
        draw_line(Vector2(27680,y),Vector2(28120,y+32.0),Color(0.80,0.29,0.20,pulse),3.0)
