class_name EvilWizardBoss
extends CharacterBody2D

signal died
signal projectile_requested(at: Vector2, direction: Vector2, speed: float, damage: float)
signal summon_requested(at: Vector2)
signal health_changed(current: float, maximum: float)
signal phase_changed(phase: int)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

const MAX_HEALTH := 620.0
var health := MAX_HEALTH
var target: Hero
var action_timer := 1.15
var teleport_timer := 4.4
var summon_timer := 8.8
var barrier_time := 0.0
var telegraph_time := 0.0
var queued_spell := ""
var phase := 1
var arena_left: float = 6754.0
var arena_right: float = 8066.0
var rng := RandomNumberGenerator.new()

const ARENA_FLOOR_Y: float = 560.0
const ARENA_FALL_LIMIT: float = 720.0

const VANISH_DURATION: float = 0.70
const VANISH_HEALTH_COST_FRACTION: float = 0.10
const VANISH_DRAIN_PER_SECOND: float = (MAX_HEALTH * VANISH_HEALTH_COST_FRACTION) / VANISH_DURATION
var vanished: bool = false
var vanish_timer: float = 0.0
var vanish_destination_x: float = 0.0
var vanish_cost_accumulated: float = 0.0
var spawn_position: Vector2 = Vector2.ZERO

func setup(
    at: Vector2,
    hero: Hero,
    left_bound: float = 6754.0,
    right_bound: float = 8066.0
) -> EvilWizardBoss:
    global_position = at
    spawn_position = at
    target = hero
    arena_left = minf(left_bound,right_bound)
    arena_right = maxf(left_bound,right_bound)
    return self

func _ready() -> void:
    rng.randomize()
    collision_layer = 2
    collision_mask = 4
    var shape_node := CollisionShape2D.new()
    var capsule := CapsuleShape2D.new()
    capsule.radius = 22.0
    capsule.height = 70.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-35)
    add_child(shape_node)
    health_changed.emit(health, MAX_HEALTH)
    phase_changed.emit(phase)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health <= 0.0 or not is_instance_valid(target):
        return

    if vanished:
        _update_vanish(delta)
        return

    if not is_on_floor():
        velocity.y += 1900.0 * delta
    velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
    action_timer -= delta
    teleport_timer -= delta
    summon_timer -= delta
    barrier_time = maxf(0.0, barrier_time - delta)

    _check_phase()

    if telegraph_time > 0.0:
        telegraph_time = maxf(0.0, telegraph_time - delta)
        if telegraph_time <= 0.0 and queued_spell != "":
            _execute_spell()
        move_and_slide()
        _enforce_arena_integrity()
        queue_redraw()
        return

    if teleport_timer <= 0.0:
        teleport_timer = 4.1 if phase == 1 else (2.8 if phase == 2 else 1.9)
        _shadow_step()

    if summon_timer <= 0.0:
        summon_timer = 10.0 if phase == 1 else (7.0 if phase == 2 else 5.5)
        var summon_x := clampf(global_position.x + rng.randf_range(-160,160), arena_left+90, arena_right-90)
        summon_requested.emit(Vector2(summon_x, 560))

    if action_timer <= 0.0:
        action_timer = rng.randf_range(1.15,1.65) if phase == 1 else (rng.randf_range(0.82,1.20) if phase == 2 else rng.randf_range(0.58,0.92))
        _begin_cast()

    move_and_slide()
    _enforce_arena_integrity()
    queue_redraw()

func _enforce_arena_integrity() -> void:
    if vanished or health <= 0.0:
        return

    var corrected: bool = false
    var safe_x: float = clampf(global_position.x,arena_left,arena_right)
    if not is_equal_approx(safe_x,global_position.x):
        global_position.x = safe_x
        velocity.x = 0.0
        corrected = true

    # Failsafe: the boss should never be able to fall out of the encounter.
    if global_position.y > ARENA_FALL_LIMIT:
        global_position = Vector2(clampf(spawn_position.x,arena_left,arena_right),ARENA_FLOOR_Y)
        velocity = Vector2.ZERO
        corrected = true

    if corrected:
        request_flash.emit(global_position + Vector2(0,-45),Color("#7d4c98"))

func _check_phase() -> void:
    if phase == 1 and health <= MAX_HEALTH * 0.60:
        phase = 2
        barrier_time = 1.4
        action_timer = 0.55
        summon_timer = 1.8
        phase_changed.emit(phase)
        request_flash.emit(global_position + Vector2(0,-45), Color("#d07cff"))
        damage_text_requested.emit(global_position + Vector2(0,-122), "PHASE II", Color("#e2a5ff"))
        sfx_requested.emit("boss_phase", -1.0, 1.0)
    elif phase == 2 and health <= MAX_HEALTH * 0.25:
        phase = 3
        barrier_time = 1.8
        action_timer = 0.25
        summon_timer = 1.2
        phase_changed.emit(phase)
        request_flash.emit(global_position + Vector2(0,-45), Color("#ff628e"))
        damage_text_requested.emit(global_position + Vector2(0,-122), "PHASE III", Color("#ff8fb0"))
        sfx_requested.emit("boss_phase", 0.0, 0.82)

func _begin_cast() -> void:
    if not is_instance_valid(target):
        return
    var roll := rng.randi_range(0, 99)
    if phase == 1:
        if roll < 42:
            queued_spell = "bolt"
        elif roll < 68:
            queued_spell = "spread"
        elif roll < 82:
            queued_spell = "barrier"
        else:
            queued_spell = "shadow"
    elif phase == 2:
        if roll < 30:
            queued_spell = "bolt"
        elif roll < 55:
            queued_spell = "spread"
        elif roll < 70:
            queued_spell = "barrier"
        elif roll < 86:
            queued_spell = "shadow"
        else:
            queued_spell = "chaos"
    else:
        if roll < 22:
            queued_spell = "bolt"
        elif roll < 48:
            queued_spell = "spread"
        elif roll < 64:
            queued_spell = "shadow"
        else:
            queued_spell = "chaos"

    telegraph_time = 0.42 if queued_spell in ["shadow", "chaos"] else 0.30
    if queued_spell == "barrier":
        telegraph_time = 0.22
    sfx_requested.emit("wizard_cast", -7.0, 0.94 + phase * 0.05)
    queue_redraw()

func _execute_spell() -> void:
    if not is_instance_valid(target):
        queued_spell = ""
        return
    var direction := (target.global_position + Vector2(0,-28) - (global_position + Vector2(0,-50))).normalized()
    match queued_spell:
        "bolt":
            projectile_requested.emit(global_position + Vector2(0,-52), direction, 480.0 + phase * 35.0, 16.0 + phase * 3.0)
        "spread":
            var spread := 0.22 if phase < 3 else 0.30
            for offset in [-spread, 0.0, spread]:
                projectile_requested.emit(global_position + Vector2(0,-52), direction.rotated(offset), 430.0 + phase * 30.0, 12.0 + phase * 2.0)
        "barrier":
            barrier_time = 3.0 if phase == 1 else 2.4
            request_flash.emit(global_position + Vector2(0,-45), Color("#b26aff"))
        "shadow":
            _shadow_strike()
        "chaos":
            for offset in [-0.46, -0.23, 0.0, 0.23, 0.46]:
                projectile_requested.emit(global_position + Vector2(0,-52), direction.rotated(offset), 470.0 + phase * 20.0, 14.0 + phase * 2.0)
            request_flash.emit(global_position + Vector2(0,-48), Color("#ff6cab"))
    queued_spell = ""
    queue_redraw()

func _shadow_step() -> void:
    if not is_instance_valid(target) or vanished:
        return
    var side: float = -1.0 if rng.randi() % 2 == 0 else 1.0
    vanish_destination_x = clampf(
        target.global_position.x + side * rng.randf_range(150.0,260.0),
        arena_left + 55.0,
        arena_right - 55.0
    )
    vanished = true
    vanish_timer = VANISH_DURATION
    vanish_cost_accumulated = 0.0
    velocity = Vector2.ZERO
    collision_layer = 0
    request_flash.emit(global_position + Vector2(0,-45), Color("#6f49a8"))
    damage_text_requested.emit(global_position + Vector2(0,-118), "VOID STEP", Color("#c995ff"))
    sfx_requested.emit("teleport", -5.0, 0.92 + phase * 0.06)
    visible = false

func _update_vanish(delta: float) -> void:
    if not vanished:
        return

    var drain: float = VANISH_DRAIN_PER_SECOND * delta
    vanish_cost_accumulated += drain
    health = maxf(0.0, health - drain)
    health_changed.emit(health, MAX_HEALTH)

    if health <= 0.0:
        _die()
        return

    vanish_timer = maxf(0.0, vanish_timer - delta)
    if vanish_timer <= 0.0:
        _reappear_from_void()

func _reappear_from_void() -> void:
    if not vanished:
        return
    vanished = false
    visible = true
    collision_layer = 2
    global_position = Vector2(
        clampf(vanish_destination_x,arena_left,arena_right),
        ARENA_FLOOR_Y
    )
    request_flash.emit(global_position + Vector2(0,-45), Color("#a973e3"))
    damage_text_requested.emit(
        global_position + Vector2(0,-118),
        "-%d VOID COST" % int(round(vanish_cost_accumulated)),
        Color("#ff8fb0")
    )
    sfx_requested.emit("teleport", -4.0, 1.04 + phase * 0.06)
    vanish_cost_accumulated = 0.0
    queue_redraw()

func _shadow_strike() -> void:
    if not is_instance_valid(target):
        return
    var dx := target.global_position.x - global_position.x
    if absf(dx) < 190.0:
        target.take_damage(25.0 + phase * 5.0, signf(dx) * 650.0, global_position)
        request_flash.emit(target.global_position + Vector2(0,-28), Color("#d78cff"))
    else:
        projectile_requested.emit(global_position + Vector2(0,-50), Vector2(signf(dx),0), 680.0 + phase * 30.0, 20.0 + phase * 2.0)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, _stun: float = 0.0) -> void:
    if health <= 0.0 or vanished:
        return
    var applied: float = amount * (0.35 if barrier_time > 0.0 else 1.0)
    health = maxf(0.0, health - applied)
    velocity.x = knockback * 0.10
    health_changed.emit(health, MAX_HEALTH)
    request_flash.emit(global_position + Vector2(0,-42), Color("#f7b7ff"))
    damage_text_requested.emit(global_position + Vector2(0,-116), "%d" % int(round(applied)), Color("#f0c2ff"))
    queue_redraw()
    if health <= 0.0:
        _die()

func _die() -> void:
    if health > 0.0:
        return
    vanished = false
    visible = true
    collision_layer = 0
    telegraph_time = 0.0
    queued_spell = ""
    sfx_requested.emit("boss_die", 0.0, 1.0)
    died.emit()
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "modulate:a", 0.0, 1.35)
    tween.tween_property(self, "scale", Vector2(1.9,1.9), 1.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.chain().tween_callback(queue_free)

func reset_encounter() -> void:
    health = MAX_HEALTH
    phase = 1
    action_timer = 1.0
    teleport_timer = 3.5
    summon_timer = 7.0
    barrier_time = 0.0
    telegraph_time = 0.0
    queued_spell = ""
    vanished = false
    vanish_timer = 0.0
    vanish_cost_accumulated = 0.0
    visible = true
    modulate.a = 1.0
    scale = Vector2.ONE
    collision_layer = 2
    global_position = Vector2(
        clampf(spawn_position.x,arena_left,arena_right),
        ARENA_FLOOR_Y
    )
    velocity = Vector2.ZERO
    health_changed.emit(health, MAX_HEALTH)
    phase_changed.emit(phase)
    queue_redraw()

func _draw() -> void:
    var robe := Color("#3c214f")
    if phase == 2:
        robe = Color("#551b49")
    elif phase == 3:
        robe = Color("#6b183b")

    if telegraph_time > 0.0:
        var warning := Color(0.80,0.38,1.0,0.70)
        if queued_spell == "shadow":
            warning = Color(0.95,0.30,0.55,0.75)
        elif queued_spell == "chaos":
            warning = Color(1.0,0.24,0.36,0.78)
        draw_arc(Vector2(0,-50), 61.0, 0, TAU, 40, warning, 4.0)
        draw_circle(Vector2(48,-92), 13.0 + 3.0*sin(telegraph_time*30.0), warning)
        if queued_spell == "shadow" and is_instance_valid(target):
            var local_target := to_local(target.global_position + Vector2(0,-28))
            draw_dashed_line(Vector2(0,-48), local_target, warning, 3.0, 12.0)

    draw_polygon(PackedVector2Array([Vector2(-28,-58),Vector2(25,-58),Vector2(34,4),Vector2(-38,4)]), PackedColorArray([robe]))
    draw_circle(Vector2(0,-72), 16, Color("#cab4a6"))
    draw_polygon(PackedVector2Array([Vector2(-30,-82),Vector2(5,-112),Vector2(32,-82)]), PackedColorArray([Color("#18111f")]))
    draw_circle(Vector2(-6,-74), 3, Color("#d682ff"))
    draw_circle(Vector2(6,-74), 3, Color("#d682ff"))
    draw_line(Vector2(26,-48), Vector2(46,-88), Color("#76617f"), 5)
    draw_circle(Vector2(48,-92), 8, Color("#c67dff") if phase < 3 else Color("#ff5c93"))
    if barrier_time > 0.0:
        draw_arc(Vector2(0,-50), 54, 0, TAU, 40, Color(0.7,0.35,1.0,0.75), 5.0)
        draw_arc(Vector2(0,-50), 48, 0, TAU, 32, Color(0.92,0.70,1.0,0.28), 2.0)
