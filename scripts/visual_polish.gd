extends Node2D

# Purely visual effects. This node does not synthesize input, damage enemies,
# alter collision, or retain progress. It is shared by desktop and handheld.
const MAX_MOTES: int = 80
var motes: Array[Dictionary] = []
var player: Hero
var footfall_clock: float = 0.0

func _ready() -> void:
    z_index = 12
    process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta: float) -> void:
    for i in range(motes.size() - 1, -1, -1):
        var mote: Dictionary = motes[i]
        mote["life"] = float(mote["life"]) - delta
        if float(mote["life"]) <= 0.0:
            motes.remove_at(i)
            continue
        mote["at"] = Vector2(mote["at"]) + Vector2(mote["velocity"]) * delta
        mote["velocity"] = Vector2(mote["velocity"]) + Vector2(0.0, 90.0) * delta
        motes[i] = mote

    if not is_instance_valid(player):
        player = get_tree().get_first_node_in_group("player_hero") as Hero
        if is_instance_valid(player):
            if not player.request_flash.is_connected(_on_flash):
                player.request_flash.connect(_on_flash)

    # Spawned enemies are discovered lazily so replay, respawn and new regions
    # need no special-case wiring. Existing gameplay signal listeners are kept.
    for child in get_parent().get_children():
        if child is RealmEnemy:
            var enemy: RealmEnemy = child as RealmEnemy
            if not enemy.request_flash.is_connected(_on_flash):
                enemy.request_flash.connect(_on_flash)

    if is_instance_valid(player) and player.is_on_floor() and absf(player.velocity.x) > 100.0:
        footfall_clock += delta
        if footfall_clock >= 0.16:
            footfall_clock = 0.0
            _emit_footfall(player.global_position, signf(player.velocity.x))
    else:
        footfall_clock = 0.0

    if not motes.is_empty():
        queue_redraw()

func _on_flash(at: Vector2, tint: Color) -> void:
    # Existing hit/spell flash signals drive these brief sparks. The emitted
    # particles deliberately carry no gameplay effect or screen shake.
    for i in range(7):
        var angle: float = TAU * float(i) / 7.0 + randf_range(-0.18, 0.18)
        var speed: float = randf_range(75.0, 190.0)
        _add_mote(at, Vector2(cos(angle), sin(angle)) * speed, tint, randf_range(1.8, 3.6), randf_range(0.17, 0.30))

func _emit_footfall(at: Vector2, direction: float) -> void:
    for i in range(3):
        _add_mote(at + Vector2(randf_range(-8.0, 8.0), -1.0), Vector2(-direction * randf_range(10.0, 60.0), -randf_range(12.0, 38.0)), Color(0.60, 0.67, 0.74, 0.28), randf_range(1.7, 3.3), 0.24)

func _add_mote(at: Vector2, velocity: Vector2, tint: Color, radius: float, lifetime: float) -> void:
    if motes.size() >= MAX_MOTES:
        motes.remove_at(0)
    motes.append({"at": to_local(at), "velocity": velocity, "tint": tint, "radius": radius, "life": lifetime, "duration": lifetime})

func _draw() -> void:
    for mote in motes:
        var remaining: float = clampf(float(mote["life"]) / float(mote["duration"]), 0.0, 1.0)
        var color: Color = mote["tint"]
        color.a *= remaining
        var at: Vector2 = mote["at"]
        var velocity: Vector2 = mote["velocity"]
        draw_line(at, at - velocity.normalized() * (4.0 * remaining), color, maxf(1.0, float(mote["radius"]) * remaining))
        draw_circle(at, maxf(0.6, float(mote["radius"]) * remaining), color)
