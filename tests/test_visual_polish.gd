extends SceneTree

var failures: int = 0

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    if change_scene_to_file("res://scenes/Main.tscn") != OK:
        printerr("FAIL: cannot load game scene")
        quit(1)
        return
    await process_frame
    await process_frame
    var game: Node2D = current_scene as Node2D
    if game == null:
        printerr("FAIL: game scene missing")
        quit(1)
        return
    var polish: Node2D = game.get_node_or_null("VisualPolish") as Node2D
    _check(polish != null, "visual polish node is present")
    if polish == null:
        quit(1)
        return
    _check(polish.process_mode == Node.PROCESS_MODE_PAUSABLE, "effects pause with gameplay")
    _check(polish.get("motes").size() == 0, "effect pool begins empty")
    polish.call("_on_flash", Vector2(200.0, 500.0), Color("#ffd99a"))
    _check(polish.get("motes").size() == 7, "hit flash spawns seven cosmetic sparks")
    polish.call("_emit_footfall", Vector2(200.0, 560.0), 1.0)
    _check(polish.get("motes").size() == 10, "movement adds three footfall motes")
    polish.call("_process", 0.7)
    _check(polish.get("motes").is_empty(), "expired particles are removed")
    for i in range(110):
        polish.call("_on_flash", Vector2(200.0, 500.0), Color.WHITE)
    _check(polish.get("motes").size() <= 80, "effect count is bounded for handheld")

    var found_enemy: bool = false
    for child in game.get_children():
        if child is RealmEnemy:
            var enemy: RealmEnemy = child as RealmEnemy
            found_enemy = true
            var previous_health: float = enemy.health
            enemy.take_damage(1.0)
            _check(enemy.health < previous_health, "existing enemy damage remains active")
            _check(enemy.hurt_glow > 0.0, "enemy hit response highlights impact")
            break
    _check(found_enemy, "a village enemy exists for the hit response test")
    if failures > 0:
        printerr("%d visual polish checks failed" % failures)
        quit(1)
    else:
        print("Visual polish checks passed: impact, footfall, expiry, cap and enemy feedback.")
        quit(0)

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL: " + label)
