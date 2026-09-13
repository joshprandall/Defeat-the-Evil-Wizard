class_name BriarHart
extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal died
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)
signal projectile_requested(at: Vector2, direction: Vector2, speed: float, damage: float)

const GRAVITY: float = 1900.0
const MODE_CHASE: int = 0
const MODE_WINDUP: int = 1
const MODE_CHARGE: int = 2
const MODE_RECOVER: int = 3

var max_health: float = 540.0
var health: float = 540.0
var target: Hero
var spawn_position: Vector2 = Vector2.ZERO
var arena_left: float = 12710.0
var arena_right: float = 14060.0
var facing: float = -1.0
var mode: int = MODE_CHASE
var timer: float = 0.0
var attack_kind: String = "antler"
var attack_cooldown: float = 0.8
var charge_cooldown: float = 2.0
var volley_cooldown: float = 1.4
var stun_time: float = 0.0
var phase_two: bool = false
var charge_hit: bool = false
var pulse: float = 0.0

func setup(at: Vector2, hero: Hero, left_bound: float, right_bound: float) -> BriarHart:
    global_position = at
    spawn_position = at
    target = hero
    arena_left = minf(left_bound,right_bound)
    arena_right = maxf(left_bound,right_bound)
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var capsule: CapsuleShape2D = CapsuleShape2D.new()
    capsule.radius = 31.0
    capsule.height = 82.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-41)
    add_child(shape_node)
    health_changed.emit(health,max_health)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health <= 0.0 or not is_instance_valid(target):
        return
    pulse += delta
    attack_cooldown = maxf(0.0,attack_cooldown-delta)
    charge_cooldown = maxf(0.0,charge_cooldown-delta)
    volley_cooldown = maxf(0.0,volley_cooldown-delta)
    stun_time = maxf(0.0,stun_time-delta)
    if not is_on_floor():
        velocity.y += GRAVITY*delta

    if not phase_two and health <= max_health*0.48:
        phase_two = true
        request_flash.emit(global_position+Vector2(0,-48),Color("#a5f06d"))
        damage_text_requested.emit(global_position+Vector2(0,-120),"THE HEART AWAKENS",Color("#bff58c"))
        sfx_requested.emit("boss_phase",-4.0,1.10)

    if stun_time > 0.0:
        mode = MODE_CHASE
        velocity.x = move_toward(velocity.x,0.0,1900.0*delta)
        move_and_slide()
        _enforce_arena()
        queue_redraw()
        return

    match mode:
        MODE_WINDUP:
            timer = maxf(0.0,timer-delta)
            velocity.x = move_toward(velocity.x,0.0,2300.0*delta)
            if timer <= 0.0:
                _execute_windup()
        MODE_CHARGE:
            timer = maxf(0.0,timer-delta)
            velocity.x = facing*(690.0 if phase_two else 580.0)
            if not charge_hit and global_position.distance_to(target.global_position) < 82.0:
                charge_hit = true
                target.take_damage(31.0 if phase_two else 26.0,facing*760.0,global_position)
                request_flash.emit(target.global_position+Vector2(0,-28),Color("#9de86a"))
            if timer <= 0.0:
                mode = MODE_RECOVER
                timer = 0.36
        MODE_RECOVER:
            timer = maxf(0.0,timer-delta)
            velocity.x = move_toward(velocity.x,0.0,2500.0*delta)
            if timer <= 0.0:
                mode = MODE_CHASE
        _:
            _chase_and_choose(delta)

    move_and_slide()
    _enforce_arena()
    queue_redraw()

func _chase_and_choose(delta: float) -> void:
    var dx: float = target.global_position.x-global_position.x
    var distance: float = absf(dx)
    if distance > 4.0:
        facing = signf(dx)
    if distance > 130.0:
        velocity.x = move_toward(velocity.x,facing*(145.0 if phase_two else 118.0),980.0*delta)
    else:
        velocity.x = move_toward(velocity.x,0.0,1800.0*delta)

    if attack_cooldown > 0.0:
        return

    if distance <= 135.0:
        attack_kind = "antler"
        mode = MODE_WINDUP
        timer = 0.30 if phase_two else 0.42
        attack_cooldown = 0.92
    elif distance <= 560.0 and charge_cooldown <= 0.0:
        attack_kind = "charge"
        mode = MODE_WINDUP
        timer = 0.46
        attack_cooldown = 1.1
        charge_cooldown = 3.0 if phase_two else 4.0
    elif volley_cooldown <= 0.0:
        attack_kind = "thorns"
        mode = MODE_WINDUP
        timer = 0.38
        attack_cooldown = 1.05
        volley_cooldown = 2.4 if phase_two else 3.4

func _execute_windup() -> void:
    if attack_kind == "charge":
        mode = MODE_CHARGE
        timer = 0.62
        charge_hit = false
        sfx_requested.emit("heavy",-5.0,0.82)
        return

    mode = MODE_RECOVER
    timer = 0.28

    if attack_kind == "thorns":
        var base: Vector2 = (target.global_position+Vector2(0,-25)-(global_position+Vector2(facing*24,-54))).normalized()
        var count: int = 5 if phase_two else 3
        for i: int in range(count):
            var offset: float = (float(i)-float(count-1)*0.5)*0.13
            projectile_requested.emit(global_position+Vector2(facing*24,-54),base.rotated(offset),430.0 if phase_two else 380.0,15.0 if phase_two else 12.0)
        request_flash.emit(global_position+Vector2(0,-52),Color("#86d95e"))
        sfx_requested.emit("wizard_cast",-7.0,0.94)
        return

    var dx: float = target.global_position.x-global_position.x
    if absf(dx) <= 158.0 and absf(target.global_position.y-global_position.y) < 126.0:
        target.take_damage(29.0 if phase_two else 24.0,signf(dx)*620.0,global_position)
        request_flash.emit(target.global_position+Vector2(0,-28),Color("#a4e86d"))
    sfx_requested.emit("enemy_attack",-5.0,0.69)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health <= 0.0:
        return
    var applied: float = amount*(0.92 if phase_two else 1.0)
    health = maxf(0.0,health-applied)
    health_changed.emit(health,max_health)
    velocity.x = knockback*0.24
    stun_time = maxf(stun_time,stun*0.45)
    request_flash.emit(global_position+Vector2(0,-48),Color("#d8f1a6"))
    damage_text_requested.emit(global_position+Vector2(0,-110),"%d" % int(round(applied)),Color("#e8f7bd"))
    if health <= 0.0:
        collision_layer = 0
        sfx_requested.emit("boss_die",-3.0,0.92)
        died.emit()
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,0.9)
        tween.tween_property(self,"scale",Vector2(1.45,0.55),0.9)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _enforce_arena() -> void:
    var safe_x: float = clampf(global_position.x,arena_left,arena_right)
    if not is_equal_approx(safe_x,global_position.x):
        global_position.x = safe_x
        velocity.x = 0.0
    if global_position.y > 720.0:
        global_position = Vector2(clampf(spawn_position.x,arena_left,arena_right),560.0)
        velocity = Vector2.ZERO

func _draw() -> void:
    var body: Color = Color("#4d5e45") if not phase_two else Color("#556d3d")
    var glow: Color = Color("#bce77b") if not phase_two else Color("#d3ff6c")
    if mode == MODE_WINDUP:
        draw_arc(Vector2(0,-50),62.0,-0.25,PI+0.25,26,Color(0.65,1.0,0.32,0.68),5.0)
        if attack_kind=="charge":
            draw_line(Vector2(facing*34,-36),Vector2(facing*210,-36),Color(0.65,1.0,0.32,0.52),5.0)

    draw_polygon(PackedVector2Array([Vector2(-43,-57),Vector2(41,-57),Vector2(48,-14),Vector2(-48,-14)]),PackedColorArray([body]))
    draw_circle(Vector2(facing*32,-70),27.0,body.darkened(0.08))
    draw_circle(Vector2(facing*42,-75),4.5,glow)

    # Antlers.
    var head: Vector2 = Vector2(facing*31,-76)
    draw_line(head+Vector2(0,-12),head+Vector2(facing*28,-46),Color("#82906b"),7.0)
    draw_line(head+Vector2(facing*16,-31),head+Vector2(facing*42,-56),Color("#82906b"),5.0)
    draw_line(head+Vector2(facing*9,-27),head+Vector2(-facing*8,-53),Color("#82906b"),5.0)
    draw_line(Vector2(-27,-15),Vector2(-35,13),Color("#38463a"),8.0)
    draw_line(Vector2(27,-15),Vector2(35,13),Color("#38463a"),8.0)
    draw_arc(Vector2(0,-52),58.0,0.0,TAU,28,Color(glow.r,glow.g,glow.b,0.14+0.04*sin(pulse*3.0)),3.0)

    var ratio: float = clampf(health/max_health,0.0,1.0)
    draw_rect(Rect2(-84,-140,168,8),Color(0.02,0.04,0.025,0.92))
    draw_rect(Rect2(-84,-140,168*ratio,8),Color("#87b957"))
