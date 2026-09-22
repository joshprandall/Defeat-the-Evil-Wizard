class_name RuinedBackdrop
extends Node2D

var world_width: float = 8200.0

func _ready() -> void:
    z_index = -100
    queue_redraw()

func _draw() -> void:
    # Separating sky, far mountains, and nearby ruins makes the side-scrolling
    # path easier to read on small screens without changing collision or light.
    draw_rect(Rect2(0,-500,world_width,1300),Color("#07101b"))
    draw_rect(Rect2(0,120,world_width,600),Color(0.035,0.055,0.082,0.42))
    draw_rect(Rect2(0,330,world_width,390),Color(0.055,0.067,0.085,0.42))

    for p: Vector2 in [
        Vector2(210,96),Vector2(490,145),Vector2(880,78),Vector2(1270,128),Vector2(1660,72),
        Vector2(2120,142),Vector2(2720,94),Vector2(3180,160),Vector2(3610,84),Vector2(4120,126),
        Vector2(4680,88),Vector2(5210,148),Vector2(5880,76),Vector2(6510,132),Vector2(7180,92),Vector2(7980,140)
    ]:
        draw_circle(p,2.0,Color(0.78,0.84,0.88,0.50))
    draw_line(Vector2(0,205),Vector2(world_width,205),Color(0.20,0.28,0.39,0.14),2.0)

    # A subtle halo gives the late-village moon its own depth plane.
    draw_circle(Vector2(7280,92),177.0,Color(0.66,0.73,0.83,0.025))
    draw_circle(Vector2(7280,92),150.0,Color(0.66,0.73,0.83,0.045))
    draw_circle(Vector2(7280,92),128.0,Color("#d9dbc9"))
    draw_circle(Vector2(7335,61),124.0,Color("#07101b"))

    var far: PackedVector2Array = PackedVector2Array([
        Vector2(0,560),Vector2(520,260),Vector2(950,520),Vector2(1450,220),Vector2(1950,530),
        Vector2(2500,300),Vector2(3100,520),Vector2(3700,230),Vector2(4300,500),Vector2(4900,260),
        Vector2(5500,520),Vector2(6100,245),Vector2(6750,510),Vector2(7350,255),Vector2(8200,520),
        Vector2(8200,720),Vector2(0,720)
    ])
    draw_colored_polygon(far,Color("#18283a"))
    var near: PackedVector2Array = PackedVector2Array([
        Vector2(0,610),Vector2(380,410),Vector2(760,590),Vector2(1120,360),Vector2(1520,610),
        Vector2(2100,390),Vector2(2520,610),Vector2(3000,380),Vector2(3520,610),Vector2(3980,350),
        Vector2(4450,610),Vector2(4900,400),Vector2(5400,590),Vector2(5960,370),Vector2(6480,610),
        Vector2(7060,390),Vector2(7580,610),Vector2(8200,410),Vector2(8200,720),Vector2(0,720)
    ])
    draw_colored_polygon(near,Color("#101b29"))

    # Fallen Village skyline: roof highlights keep the ruins distinct from
    # mountains; sparse warm windows hint at the occupied road ahead.
    for x: float in [420.0,760.0,1080.0,1460.0,1830.0,2240.0,2670.0,3120.0,3560.0,3970.0,4380.0,4780.0,5180.0]:
        var height: float = 95.0 + fmod(x,170.0) * 0.22
        draw_rect(Rect2(x,610.0-height,150.0,height),Color("#111923"))
        draw_polygon(PackedVector2Array([Vector2(x-12.0,610.0-height),Vector2(x+75.0,565.0-height),Vector2(x+162.0,610.0-height)]),PackedColorArray([Color("#0e151e")]))
        draw_line(Vector2(x-12.0,610.0-height),Vector2(x+75.0,565.0-height),Color(0.28,0.39,0.47,0.28),2.0)
        draw_rect(Rect2(x+24.0,540.0-height,20.0,28.0),Color("#251d2a"))
        draw_rect(Rect2(x+94.0,530.0-height,22.0,30.0),Color("#251d2a"))

    for x: float in [760.0,1830.0,2670.0,3970.0,4780.0]:
        var height: float = 95.0 + fmod(x,170.0) * 0.22
        var window_at := Vector2(x+35.0,552.0-height)
        draw_circle(window_at,38.0,Color(0.93,0.52,0.23,0.035))
        draw_rect(Rect2(window_at-Vector2(8.0,11.0),Vector2(16.0,22.0)),Color(0.94,0.53,0.25,0.67))
        draw_line(window_at+Vector2(0.0,-11.0),window_at+Vector2(0.0,11.0),Color("#32261f"),2.0)

    # Ruined bell tower marks the village center.
    draw_rect(Rect2(3270,315,120,305),Color("#0f1720"))
    draw_polygon(PackedVector2Array([Vector2(3248,315),Vector2(3330,235),Vector2(3412,315)]),PackedColorArray([Color("#0c131b")]))
    draw_circle(Vector2(3330,355),24,Color("#1d2026"))
    draw_line(Vector2(3330,236),Vector2(3330,194),Color("#202a31"),7.0)
    draw_line(Vector2(3313,210),Vector2(3347,210),Color("#202a31"),5.0)
    draw_circle(Vector2(3330,355),30.0,Color(0.83,0.67,0.41,0.055))
    draw_arc(Vector2(3330,355),24.0,0.0,TAU,32,Color(0.66,0.54,0.36,0.36),1.5,true)

    # Grave Knight's broken gatehouse.
    draw_rect(Rect2(4890,360,80,260),Color("#10161d"))
    draw_rect(Rect2(5200,360,80,260),Color("#10161d"))
    draw_line(Vector2(4930,390),Vector2(5240,390),Color("#151d24"),18.0)
    draw_line(Vector2(4930,401),Vector2(5240,401),Color(0.40,0.43,0.48,0.21),2.0)

    # Black Tower dominates the final approach.
    draw_rect(Rect2(7420,205,170,415),Color("#0b0c14"))
    draw_polygon(PackedVector2Array([Vector2(7370,235),Vector2(7505,92),Vector2(7640,235)]),PackedColorArray([Color("#0b0c14")]))
    draw_rect(Rect2(7460,305,26,62),Color("#351848"))
    draw_rect(Rect2(7525,305,26,62),Color("#351848"))
    draw_circle(Vector2(7505,174),14,Color(0.56,0.20,0.74,0.46))
    draw_line(Vector2(7505,96),Vector2(7505,42),Color("#17111e"),10.0)
    draw_circle(Vector2(7505,35),9,Color(0.72,0.27,0.92,0.52))

    for x in range(180,8100,280):
        draw_line(Vector2(x,610),Vector2(x+20,480),Color("#17212b"),12.0)
        draw_line(Vector2(x+8,530),Vector2(x-32,495),Color("#17212b"),7.0)
        draw_line(Vector2(x+10,545),Vector2(x+50,510),Color("#17212b"),7.0)

    for p: Vector2 in [Vector2(7030,215),Vector2(7120,252),Vector2(7210,184),Vector2(7750,245),Vector2(7840,198)]:
        draw_line(p,p+Vector2(8,-4),Color(0.55,0.58,0.62,0.45),1.5)
        draw_line(p+Vector2(8,-4),p+Vector2(16,0),Color(0.55,0.58,0.62,0.45),1.5)
