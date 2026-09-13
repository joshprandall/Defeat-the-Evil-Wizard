class_name KeepTrap
extends Node2D

signal sfx_requested(id: String, volume_db: float, pitch: float)

var trap_kind: String = "spikes"
var target: Hero
var time: float = 0.0
var damage_cooldown: float = 0.0
var phase_offset: float = 0.0

func setup(kind: String, at: Vector2, hero: Hero = null, phase: float = 0.0) -> KeepTrap:
    trap_kind = kind
    global_position = at
    target = hero
    phase_offset = phase
    z_index = 3
    return self

func _process(delta: float) -> void:
    time += delta
    damage_cooldown = maxf(0.0,damage_cooldown-delta)
    if not is_instance_valid(target):
        var candidate: Node = get_tree().get_first_node_in_group("player_hero")
        if candidate is Hero:
            target = candidate as Hero
    if not is_instance_valid(target):
        queue_redraw()
        return
    _check_damage()
    queue_redraw()

func _check_damage() -> void:
    if damage_cooldown > 0.0:
        return

    var local: Vector2 = target.global_position-global_position
    if trap_kind == "spikes":
        var active: bool = sin((time+phase_offset)*2.6) > -0.15
        if active and absf(local.x) < 58.0 and local.y > -72.0 and local.y < 28.0:
            damage_cooldown = 0.85
            sfx_requested.emit("trap_spike",-7.0,1.0)
            target.take_damage(19.0,signf(local.x)*260.0,global_position)
    elif trap_kind == "crusher":
        var crusher_y: float = _crusher_y()
        if absf(local.x) < 42.0 and absf(local.y-crusher_y) < 68.0:
            damage_cooldown = 1.0
            sfx_requested.emit("crusher",-5.0,0.90)
            target.take_damage(27.0,signf(local.x)*180.0,global_position)
    elif trap_kind == "rune":
        var active: bool = sin((time+phase_offset)*3.1) > 0.55
        if active and absf(local.x) < 70.0 and absf(local.y) < 72.0:
            damage_cooldown = 0.9
            target.take_damage(22.0,signf(local.x)*320.0,global_position)

func _crusher_y() -> float:
    var wave: float = (sin((time+phase_offset)*1.55)+1.0)*0.5
    return lerpf(-280.0,-35.0,wave*wave)

func _draw() -> void:
    if trap_kind == "spikes":
        var active_amount: float = clampf((sin((time+phase_offset)*2.6)+1.0)*0.65,0.15,1.0)
        for i: int in range(6):
            var x: float = -55.0+float(i)*22.0
            draw_polygon(
                PackedVector2Array([Vector2(x-9,0),Vector2(x+9,0),Vector2(x,-46.0*active_amount)]),
                PackedColorArray([Color("#87949a")])
            )
    elif trap_kind == "crusher":
        var y: float = _crusher_y()
        draw_line(Vector2(0,-420),Vector2(0,y-34),Color("#49585e"),7.0)
        draw_rect(Rect2(-48,y-34,96,68),Color("#47565c"))
        draw_polygon(
            PackedVector2Array([
                Vector2(-48,y+34),
                Vector2(-20,y+60),
                Vector2(0,y+34),
                Vector2(20,y+60),
                Vector2(48,y+34)
            ]),
            PackedColorArray([Color("#65757b")])
        )
    else:
        var pulse: float = clampf((sin((time+phase_offset)*3.1)+1.0)*0.5,0.0,1.0)
        draw_circle(Vector2.ZERO,38.0,Color(0.25,0.68,0.82,0.04+0.08*pulse))
        draw_arc(Vector2.ZERO,30.0,0.0,TAU,24,Color(0.35,0.82,0.94,0.25+0.35*pulse),3.0)
        draw_line(Vector2(-18,0),Vector2(18,0),Color("#6bd0e4"),3.0)
        draw_line(Vector2(0,-18),Vector2(0,18),Color("#6bd0e4"),3.0)
