class_name BlackTowerBackdrop
extends Node2D

const REGION_LEFT: float = 35900.0
const REGION_RIGHT: float = 46200.0

var time: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var motes: Array[Vector2] = []

func _ready() -> void:
    z_index = -6
    rng.seed = 12071
    for i: int in range(110):
        motes.append(Vector2(
            rng.randf_range(REGION_LEFT,REGION_RIGHT),
            rng.randf_range(40.0,610.0)
        ))
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(REGION_LEFT,-100,REGION_RIGHT-REGION_LEFT,840),Color("#0d0b13"))

    # Repeating vertical architecture.
    for i: int in range(15):
        var x: float = REGION_LEFT+180.0+float(i)*720.0
        var h: float = 390.0+float((i*53)%170)
        draw_rect(Rect2(x,620.0-h,90.0,h),Color("#211d29"))
        draw_rect(Rect2(x+18.0,620.0-h+55.0,54.0,18.0),Color("#332944"))
        draw_rect(Rect2(x+18.0,620.0-h+122.0,54.0,18.0),Color("#332944"))

    # Tall arched windows and interior glow.
    for i: int in range(11):
        var x: float = REGION_LEFT+430.0+float(i)*930.0
        var y: float = 155.0+float((i*37)%160)
        draw_arc(Vector2(x,y),44.0,PI,TAU,24,Color("#3c3150"),12.0)
        draw_rect(Rect2(x-44.0,y,88.0,132.0),Color("#17121f"))
        draw_rect(Rect2(x-27.0,y+20.0,54.0,86.0),Color(0.48,0.20,0.66,0.08))
        draw_line(Vector2(x,y+20.0),Vector2(x,y+106.0),Color(0.52,0.24,0.70,0.12),2.0)

    # Arcane conduits.
    for i: int in range(22):
        var x: float = REGION_LEFT+260.0+float(i)*455.0
        var y: float = 245.0+float((i*71)%280)
        var pulse: float = 0.08+0.045*sin(time*2.4+float(i))
        draw_line(Vector2(x,y),Vector2(x+150.0,y+35.0),Color(0.57,0.25,0.78,pulse),3.0)
        draw_circle(Vector2(x+75.0,y+18.0),6.0,Color(0.72,0.37,0.88,pulse*1.4))

    # Floating ash / magic motes.
    var span: float = REGION_RIGHT-REGION_LEFT
    for i: int in range(motes.size()):
        var p: Vector2 = motes[i]
        var xoff: float = fmod((p.x-REGION_LEFT)+time*(10.0+float(i%4)*3.0),span)
        var y: float = p.y+sin(time*1.3+float(i))*12.0
        var c: Color = Color(0.74,0.50,0.90,0.12) if i%3 else Color(0.72,0.69,0.78,0.10)
        draw_circle(Vector2(REGION_LEFT+xoff,y),2.0,c)

    # Huge central shaft in the final stretch.
    draw_rect(Rect2(44700,20,1150,600),Color("#08070c"))
    for floor_y: float in [145.0,265.0,385.0,505.0]:
        draw_line(Vector2(44730,floor_y),Vector2(45820,floor_y),Color("#241e2b"),12.0)
    draw_circle(Vector2(45320,180),58.0,Color(0.62,0.25,0.78,0.07))
    draw_arc(Vector2(45320,180),42.0,0.0,TAU,32,Color("#754c8f"),4.0)
