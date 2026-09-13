class_name WorldTravelNode
extends Node2D

var travel_id: String = ""
var display_name: String = "PASSAGE"
var destination: Vector2 = Vector2.ZERO
var destination_name: String = ""
var kind: String = "tunnel"
var target: Hero
var radius: float = 92.0
var pulse: float = 0.0

func setup(id_value: String, at: Vector2, destination_value: Vector2, destination_label: String, node_kind: String, hero: Hero) -> WorldTravelNode:
    travel_id = id_value
    global_position = at
    destination = destination_value
    destination_name = destination_label
    kind = node_kind
    target = hero
    display_name = "ARCANE PORTAL" if kind == "portal" else "PASSAGE"
    return self

func _process(delta: float) -> void:
    pulse += delta * 2.2
    queue_redraw()

func is_player_near() -> bool:
    if not is_instance_valid(target):
        var heroes: Array[Node] = get_tree().get_nodes_in_group("player_hero")
        if not heroes.is_empty() and heroes[0] is Hero:
            target = heroes[0] as Hero
    return is_instance_valid(target) and target.global_position.distance_to(global_position) <= radius

func prompt() -> String:
    if kind == "portal":
        return "E  ENTER ARCANE PORTAL  //  %s" % destination_name.to_upper()
    return "E  ENTER %s" % destination_name.to_upper()

func _draw() -> void:
    var near: bool = is_player_near()
    var alpha: float = 0.68 if near else 0.38
    if kind == "portal":
        var c: Color = Color("#a879e8")
        draw_circle(Vector2(0,-42),32.0+sin(pulse)*3.0,Color(c.r,c.g,c.b,0.10+alpha*0.12))
        draw_arc(Vector2(0,-42),27.0,0.0,TAU,32,Color(c.r,c.g,c.b,alpha),4.0)
        draw_arc(Vector2(0,-42),18.0,pulse,pulse+PI*1.45,24,Color("#8ee8ff"),3.0)
        draw_circle(Vector2(0,0),24.0,Color(0.05,0.04,0.08,0.92))
    else:
        draw_rect(Rect2(-34,-55,68,55),Color("#171a1e"))
        draw_arc(Vector2(0,-54),34.0,PI,TAU,24,Color("#5e6b65"),7.0)
        draw_rect(Rect2(-30,-50,60,50),Color("#0b1013"))
        draw_line(Vector2(-30,-2),Vector2(30,-2),Color("#8a7656"),4.0)
    if near:
        draw_circle(Vector2(0,10),7.0+sin(pulse*2.0)*1.0,Color("#f0d07b"))
        draw_string(ThemeDB.fallback_font,Vector2(-7,15),"E",HORIZONTAL_ALIGNMENT_LEFT,18,14,Color("#1b1b1b"))
