class_name RealmAtmosphere
extends Node2D

var motes: Array[Dictionary] = []
var fog: Array[Dictionary] = []
var world_width := 5400.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    z_index = -45
    rng.seed = 91173
    for i in 48:
        motes.append({
            "p": Vector2(rng.randf_range(0.0, world_width), rng.randf_range(210.0, 610.0)),
            "speed": rng.randf_range(7.0, 22.0),
            "drift": rng.randf_range(-8.0, 8.0),
            "r": rng.randf_range(1.0, 2.6),
            "a": rng.randf_range(0.14, 0.42)
        })
    for i in 15:
        fog.append({
            "p": Vector2(rng.randf_range(0.0, world_width), rng.randf_range(360.0, 610.0)),
            "speed": rng.randf_range(4.0, 12.0),
            "rx": rng.randf_range(95.0, 220.0),
            "ry": rng.randf_range(12.0, 30.0),
            "a": rng.randf_range(0.025, 0.075)
        })
    queue_redraw()

func _process(delta: float) -> void:
    for mote in motes:
        var p: Vector2 = mote["p"]
        p.x += float(mote["drift"]) * delta
        p.y -= float(mote["speed"]) * delta
        if p.y < 180.0:
            p.y = 620.0
            p.x = rng.randf_range(0.0, world_width)
        if p.x < 0.0:
            p.x += world_width
        elif p.x > world_width:
            p.x -= world_width
        mote["p"] = p
    for cloud in fog:
        var p: Vector2 = cloud["p"]
        p.x += float(cloud["speed"]) * delta
        if p.x > world_width + float(cloud["rx"]):
            p.x = -float(cloud["rx"])
        cloud["p"] = p
    queue_redraw()

func _draw() -> void:
    for cloud in fog:
        var p: Vector2 = cloud["p"]
        var rx := float(cloud["rx"])
        var ry := float(cloud["ry"])
        var a := float(cloud["a"])
        draw_set_transform(p, 0.0, Vector2(rx / maxf(ry, 1.0), 1.0))
        draw_circle(Vector2.ZERO, ry, Color(0.55, 0.68, 0.72, a))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    for mote in motes:
        draw_circle(mote["p"], float(mote["r"]), Color(0.92, 0.53, 0.24, float(mote["a"])))
