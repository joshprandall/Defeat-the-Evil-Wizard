class_name MountainWindZone
extends Node2D

signal sfx_requested(id: String, volume_db: float, pitch: float)

var zone_size: Vector2 = Vector2(520,260)
var direction: float = 1.0
var strength: float = 520.0
var target: Hero
var time: float = 0.0
var sfx_cooldown: float = 0.0

func setup(at: Vector2, size_value: Vector2, dir: float, force: float, hero: Hero = null) -> MountainWindZone:
    global_position = at
    zone_size = size_value
    direction = 1.0 if dir >= 0.0 else -1.0
    strength = force
    target = hero
    z_index = 1
    return self

func _process(delta: float) -> void:
    time += delta
    sfx_cooldown = maxf(0.0,sfx_cooldown-delta)

    if not is_instance_valid(target):
        var candidate: Node = get_tree().get_first_node_in_group("player_hero")
        if candidate is Hero:
            target = candidate as Hero

    if not is_instance_valid(target):
        queue_redraw()
        return

    var local: Vector2 = target.global_position-global_position
    var inside: bool = absf(local.x) <= zone_size.x*0.5 and absf(local.y) <= zone_size.y*0.5
    if inside:
        var gust: float = 0.68+0.32*maxf(0.0,sin(time*2.4))
        target.velocity.x += direction*strength*gust*delta
        if not target.is_on_floor():
            target.velocity.y -= 22.0*gust*delta
        if gust > 0.90 and sfx_cooldown <= 0.0:
            sfx_cooldown = 2.2
            sfx_requested.emit("wind_gust",-15.0,0.92+0.08*gust)

    queue_redraw()

func _draw() -> void:
    var alpha: float = 0.07+0.035*maxf(0.0,sin(time*2.4))
    for i: int in range(9):
        var y: float = -zone_size.y*0.40+float(i)*(zone_size.y*0.10)
        var span: float = zone_size.x*0.72
        var offset: float = fmod(time*(72.0+float(i)*5.0)+float(i)*61.0,span)
        var x: float = -zone_size.x*0.36+offset
        draw_line(
            Vector2(x,y),
            Vector2(x+direction*(55.0+float(i%3)*18.0),y-4.0),
            Color(0.80,0.84,0.88,alpha),
            2.0
        )
