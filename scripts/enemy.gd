class_name RealmEnemy
extends CharacterBody2D

signal died(enemy: RealmEnemy)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var enemy_type := "crawler"
var max_health := 70.0
var health := 70.0
var move_speed := 105.0
var attack_damage := 13.0
var attack_range := 56.0
var aggro_range := 520.0
var attack_cooldown := 0.0
var stun_time := 0.0
var windup_time := 0.0
var attack_pending := false
var facing := -1.0
var target: Hero
var spawn_position := Vector2.ZERO

func setup(kind: String, at: Vector2, hero: Hero) -> RealmEnemy:
    enemy_type = kind
    global_position = at
    spawn_position = at
    target = hero
    match kind:
        "sentinel":
            max_health = 120.0
            move_speed = 76.0
            attack_damage = 21.0
            attack_range = 68.0
            aggro_range = 560.0
        "wisp":
            max_health = 50.0
            move_speed = 138.0
            attack_damage = 11.0
            attack_range = 280.0
            aggro_range = 650.0
        _:
            max_health = 74.0
            move_speed = 116.0
            attack_damage = 14.0
            attack_range = 56.0
    health = max_health
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 4
    var shape_node := CollisionShape2D.new()
    var shape := CapsuleShape2D.new()
    shape.radius = 16.0 if enemy_type != "sentinel" else 21.0
    shape.height = 46.0 if enemy_type != "sentinel" else 58.0
    shape_node.shape = shape
    shape_node.position = Vector2(0,-shape.height*0.5)
    add_child(shape_node)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health <= 0.0 or not is_instance_valid(target):
        return
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    stun_time = maxf(0.0, stun_time - delta)

    if not is_on_floor():
        velocity.y += 1900.0 * delta

    if stun_time > 0.0:
        attack_pending = false
        windup_time = 0.0
        velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
        move_and_slide()
        queue_redraw()
        return

    if attack_pending:
        windup_time = maxf(0.0, windup_time - delta)
        velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)
        if windup_time <= 0.0:
            _execute_attack()
        move_and_slide()
        queue_redraw()
        return

    var distance := global_position.distance_to(target.global_position)
    if distance < aggro_range:
        var dx := target.global_position.x - global_position.x
        if absf(dx) > 4.0:
            facing = signf(dx)
        if absf(dx) > attack_range:
            var acceleration := 1100.0 if enemy_type == "wisp" else 900.0
            velocity.x = move_toward(velocity.x, facing * move_speed, acceleration * delta)
        else:
            velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
            if attack_cooldown <= 0.0:
                _begin_attack()
    else:
        velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)

    move_and_slide()
    queue_redraw()

func _begin_attack() -> void:
    attack_pending = true
    if enemy_type == "sentinel":
        windup_time = 0.42
    elif enemy_type == "wisp":
        windup_time = 0.19
    else:
        windup_time = 0.28
    attack_cooldown = 0.85 if enemy_type == "wisp" else 1.12
    queue_redraw()

func _execute_attack() -> void:
    attack_pending = false
    windup_time = 0.0
    if not is_instance_valid(target):
        return
    var dx: float = target.global_position.x - global_position.x
    var dy: float = target.global_position.y - global_position.y

    if enemy_type == "wisp":
        if absf(dx) <= 350.0 and absf(dy) < 150.0:
            var direction: Vector2 = (target.global_position + Vector2(0,-28) - (global_position + Vector2(0,-28))).normalized()
            var bolt: DarkBolt = DarkBolt.new().setup(global_position + Vector2(facing*18,-30),direction,365.0,attack_damage)
            get_parent().add_child(bolt)
            request_flash.emit(global_position + Vector2(0,-28),Color("#a889ff"))
        sfx_requested.emit("wizard_cast",-11.0,1.18)
        queue_redraw()
        return

    if enemy_type == "crawler":
        velocity.x = facing * 270.0

    var reach_bonus: float = 20.0 if enemy_type == "sentinel" else 16.0
    if absf(dx) <= attack_range + reach_bonus and absf(dy) < 105.0:
        var knockback: float = 440.0 if enemy_type == "sentinel" else 350.0
        target.take_damage(attack_damage,signf(dx)*knockback,global_position)
        request_flash.emit(target.global_position + Vector2(0,-28),Color("#ff7d74"))
    sfx_requested.emit("enemy_attack",-9.0,0.90 if enemy_type == "sentinel" else 1.08)
    queue_redraw()

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health <= 0.0:
        return
    health = maxf(0.0, health - amount)
    velocity.x = knockback
    velocity.y = -170.0
    stun_time = maxf(stun_time, stun)
    attack_pending = false
    windup_time = 0.0
    request_flash.emit(global_position + Vector2(0,-25), Color("#ffd99a"))
    damage_text_requested.emit(global_position + Vector2(0,-66), "%d" % int(round(amount)), Color("#ffe0a5"))
    queue_redraw()
    if health <= 0.0:
        collision_layer = 0
        sfx_requested.emit("enemy_down", -9.0, randf_range(0.90, 1.12))
        died.emit(self)
        var tween := create_tween()
        tween.set_parallel(true)
        tween.tween_property(self, "modulate:a", 0.0, 0.26)
        tween.tween_property(self, "scale", Vector2(1.38,0.62), 0.26)
        tween.chain().tween_callback(queue_free)

func _draw() -> void:
    var body := Color("#7b3948")
    var eye := Color("#ffcf70")
    var radius := 20.0
    if enemy_type == "sentinel":
        body = Color("#59636e")
        eye = Color("#ff6f66")
        radius = 26.0
    elif enemy_type == "wisp":
        body = Color("#6355a8")
        eye = Color("#8ee9ff")

    if attack_pending:
        var warning := Color(1.0,0.34,0.25,0.65)
        draw_arc(Vector2(0,-28), radius + 10.0, -PI*0.15, PI*1.15, 20, warning, 4.0)
        draw_line(Vector2(facing * 18,-29), Vector2(facing * (attack_range + 18.0),-29), warning, 3.0)

    draw_circle(Vector2(0,-28), radius, body)
    draw_circle(Vector2(-7,-31), 3.5, eye)
    draw_circle(Vector2(7,-31), 3.5, eye)

    if enemy_type == "sentinel":
        draw_rect(Rect2(-23,-26,46,34), body.darkened(0.12))
        draw_line(Vector2(-31,-42), Vector2(31,-42), Color("#b88d59"), 5.0)
        draw_rect(Rect2(facing*22-5,-37,10,31), Color("#7b8792"))
    elif enemy_type == "wisp":
        draw_arc(Vector2.ZERO, 31, PI, TAU, 16, Color(0.45,0.8,1.0,0.55), 4.0)
        draw_circle(Vector2(0,-28), 28.0, Color(0.38,0.62,1.0,0.08))
    else:
        draw_line(Vector2(-12,-12), Vector2(-24,2), Color("#4d232d"), 5.0)
        draw_line(Vector2(12,-12), Vector2(24,2), Color("#4d232d"), 5.0)

    if health < max_health:
        var width := 54.0 if enemy_type != "sentinel" else 66.0
        var ratio := clampf(health / max_health, 0.0, 1.0)
        draw_rect(Rect2(-width*0.5,-68,width,5), Color(0.04,0.05,0.07,0.85))
        draw_rect(Rect2(-width*0.5,-68,width*ratio,5), Color("#d75b59"))
