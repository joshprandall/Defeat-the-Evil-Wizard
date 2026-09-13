class_name WhisperingWoodsBackdrop
extends Node2D

const REGION_LEFT: float = 8150.0
const REGION_RIGHT: float = 14550.0
var time: float = 0.0
var trunks: Array[Dictionary] = []
var fireflies: Array[Vector2] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    z_index = -11
    rng.seed = 44073
    for i: int in range(48):
        var x: float = REGION_LEFT + 80.0 + float(i) * 132.0 + rng.randf_range(-34.0,34.0)
        var h: float = rng.randf_range(240.0,520.0)
        var w: float = rng.randf_range(22.0,54.0)
        trunks.append({"x":x,"h":h,"w":w,"lean":rng.randf_range(-0.08,0.08)})
    for i: int in range(70):
        fireflies.append(Vector2(
            rng.randf_range(REGION_LEFT+80.0,REGION_RIGHT-80.0),
            rng.randf_range(170.0,570.0)
        ))
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(REGION_LEFT,-80,REGION_RIGHT-REGION_LEFT,820),Color("#0d1720"))
    draw_circle(Vector2(11140,140),92.0,Color(0.74,0.82,0.74,0.12))
    draw_circle(Vector2(11140,140),66.0,Color("#b8c8b7"))
    draw_circle(Vector2(11170,120),69.0,Color("#0d1720"))

    # Far tree layer.
    for entry: Dictionary in trunks:
        var x: float = float(entry["x"])
        var h: float = float(entry["h"])
        var w: float = float(entry["w"])
        var lean: float = float(entry["lean"])
        var base_y: float = 620.0
        var top_x: float = x + lean*h
        draw_polygon(
            PackedVector2Array([
                Vector2(x-w*0.55,base_y),
                Vector2(x+w*0.55,base_y),
                Vector2(top_x+w*0.22,base_y-h),
                Vector2(top_x-w*0.22,base_y-h)
            ]),
            PackedColorArray([Color("#14242a")])
        )
        for branch: int in range(3):
            var by: float = base_y-h*(0.45+0.16*float(branch))
            var side: float = -1.0 if branch % 2 == 0 else 1.0
            draw_line(
                Vector2(top_x,by),
                Vector2(top_x+side*(70.0+float(branch)*22.0),by-42.0),
                Color("#14242a"),
                11.0
            )

    # Rolling fog bands.
    for band: int in range(4):
        var fog_y: float = 410.0 + float(band)*58.0
        var drift: float = fmod(time*(12.0+float(band)*4.0),240.0)
        for i: int in range(30):
            var fx: float = REGION_LEFT - 150.0 + float(i)*240.0 + drift
            draw_circle(Vector2(fx,fog_y),96.0,Color(0.62,0.74,0.72,0.018+float(band)*0.004))

    # Fireflies.
    for i: int in range(fireflies.size()):
        var p: Vector2 = fireflies[i]
        var bob: float = sin(time*1.8+float(i)*0.71)*9.0
        var glow: float = 0.34+0.22*sin(time*2.6+float(i)*0.39)
        draw_circle(p+Vector2(0,bob),5.0,Color(0.58,0.96,0.66,0.08*glow))
        draw_circle(p+Vector2(0,bob),1.8,Color(0.75,1.0,0.72,0.62*glow))
