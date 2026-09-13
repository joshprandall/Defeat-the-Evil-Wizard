class_name StoryNPC
extends Node2D

var speaker_name: String = "MARA"
var lines: Array[String] = []
var target: Hero
var interaction_range: float = 138.0
var pulse: float = 0.0
var name_label: Label
var role_label: Label

func setup(at: Vector2, hero: Hero, speaker: String, dialogue_lines: Array[String]) -> StoryNPC:
    global_position = at
    target = hero
    speaker_name = speaker
    lines = dialogue_lines
    z_index = 4
    return self

func _ready() -> void:
    name_label = Label.new()
    name_label.position = Vector2(-82,-122)
    name_label.size = Vector2(164,20)
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.text = "MARA"
    name_label.add_theme_font_size_override("font_size",13)
    name_label.add_theme_color_override("font_color",Color("#e9d89a"))
    add_child(name_label)

    role_label = Label.new()
    role_label.position = Vector2(-82,-104)
    role_label.size = Vector2(164,18)
    role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    role_label.text = "BELLKEEPER"
    role_label.add_theme_font_size_override("font_size",9)
    role_label.add_theme_color_override("font_color",Color(0.70,0.75,0.78,0.72))
    add_child(role_label)

func _process(delta: float) -> void:
    pulse += delta*2.0
    if not is_instance_valid(target):
        var candidate: Node = get_tree().get_first_node_in_group("player_hero")
        if candidate is Hero:
            target = candidate as Hero
    var near: bool = is_player_near()
    if is_instance_valid(name_label):
        name_label.modulate.a = 1.0 if near else 0.72
    if is_instance_valid(role_label):
        role_label.modulate.a = 1.0 if near else 0.62
    queue_redraw()

func is_player_near() -> bool:
    if not is_instance_valid(target):
        return false
    return global_position.distance_to(target.global_position) <= interaction_range

func line_count() -> int:
    return lines.size()

func get_line(index: int) -> String:
    if lines.is_empty():
        return ""
    return lines[clampi(index,0,lines.size()-1)]

func _draw() -> void:
    var sway: float = sin(pulse*0.65)*1.4
    var lantern_pulse: float = 0.78+0.22*sin(pulse*2.4)

    # Ground shadow keeps Mara visually anchored to the road.
    draw_set_transform(Vector2(0,12),0.0,Vector2(1.35,0.28))
    draw_circle(Vector2.ZERO,18.0,Color(0.0,0.0,0.0,0.22))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

    # Bellkeeper cloak and hood — deliberately distinct from every playable hero.
    draw_polygon(
        PackedVector2Array([
            Vector2(-18,-50+sway),
            Vector2(18,-50+sway),
            Vector2(27,5),
            Vector2(-27,5)
        ]),
        PackedColorArray([Color("#3f394d")])
    )
    draw_polygon(
        PackedVector2Array([
            Vector2(-19,-60+sway),
            Vector2(0,-79+sway),
            Vector2(20,-60+sway),
            Vector2(13,-46+sway),
            Vector2(-14,-46+sway)
        ]),
        PackedColorArray([Color("#292735")])
    )

    # Face mostly hidden beneath the hood.
    draw_circle(Vector2(0,-57+sway),10.0,Color("#c9a47f"))
    draw_arc(Vector2(0,-57+sway),12.0,PI*1.05,PI*1.95,12,Color("#1e1d28"),5.0)

    # Boots.
    draw_line(Vector2(-10,3),Vector2(-12,22),Color("#20232b"),6.0)
    draw_line(Vector2(10,3),Vector2(12,22),Color("#20232b"),6.0)

    # Bell staff.
    var staff_x: float = 31.0
    draw_line(Vector2(staff_x,8),Vector2(staff_x,-73+sway),Color("#6a6256"),5.0)
    draw_line(Vector2(staff_x,-70+sway),Vector2(49,-70+sway),Color("#6a6256"),4.0)

    # Hanging bell silhouette.
    draw_polygon(
        PackedVector2Array([
            Vector2(42,-67+sway),
            Vector2(56,-67+sway),
            Vector2(60,-52+sway),
            Vector2(38,-52+sway)
        ]),
        PackedColorArray([Color("#a98c4f")])
    )
    draw_circle(Vector2(49,-50+sway),3.0,Color("#d6b765"))

    # Small lantern glow at the staff base, replacing the old head halo.
    draw_circle(Vector2(staff_x,-20),7.0,Color("#d8c46a"))
    draw_circle(
        Vector2(staff_x,-20),
        24.0,
        Color(0.92,0.78,0.34,0.045*lantern_pulse)
    )

    # Interaction marker is now clearly an interaction prompt, not a magic aura.
    if is_player_near():
        draw_circle(Vector2(0,-91),12.0,Color(0.04,0.05,0.07,0.90))
        draw_arc(Vector2(0,-91),12.0,0.0,TAU,20,Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-96),Vector2(-4,-86),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-96),Vector2(4,-96),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-91),Vector2(3,-91),Color("#f0d082"),2.0)
        draw_line(Vector2(-4,-86),Vector2(4,-86),Color("#f0d082"),2.0)
