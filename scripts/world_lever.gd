class_name WorldLever
extends Node2D

var lever_id: String = ""
var target: Hero
var activated: bool = false
var radius: float = 92.0

func setup(id_value: String, at: Vector2, hero: Hero) -> WorldLever:
    lever_id = id_value
    global_position = at
    target = hero
    return self

func is_player_near() -> bool:
    if not is_instance_valid(target):
        var heroes: Array[Node] = get_tree().get_nodes_in_group("player_hero")
        if not heroes.is_empty() and heroes[0] is Hero:
            target = heroes[0] as Hero
    return is_instance_valid(target) and target.global_position.distance_to(global_position) <= radius

func activate() -> bool:
    if activated:
        return false
    activated = true
    queue_redraw()
    return true

func _draw() -> void:
    draw_rect(Rect2(-18,-44,36,44),Color("#33383c"))
    draw_line(Vector2(0,-38),Vector2(18 if not activated else -18,-72),Color("#d0b269"),6.0)
    draw_circle(Vector2(18 if not activated else -18,-72),7.0,Color("#e6c46f"))
    if activated:
        draw_circle(Vector2(0,-22),7.0,Color("#7bd99a"))
    elif is_player_near():
        draw_circle(Vector2(0,10),7.0,Color("#f0d07b"))
        draw_string(ThemeDB.fallback_font,Vector2(-7,15),"E",HORIZONTAL_ALIGNMENT_LEFT,18,14,Color("#1b1b1b"))
