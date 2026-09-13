class_name GraveKnight
extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal died
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

const GRAVITY: float = 1900.0
const MODE_CHASE: int = 0
const MODE_WINDUP: int = 1
const MODE_CHARGE: int = 2
const MODE_RECOVER: int = 3

var max_health: float = 360.0
var health: float = 360.0
var target: Hero
var spawn_position: Vector2 = Vector2.ZERO
var facing: float = -1.0
var mode: int = MODE_CHASE
var timer: float = 0.0
var attack_kind: String = "slash"
var attack_cooldown: float = 0.0
var charge_cooldown: float = 1.6
var stun_time: float = 0.0
var shield_active: bool = true
var shield_hits: int = 3
var shield_recover: float = 0.0
var phase_two: bool = false
var charge_hit: bool = false

func setup(at: Vector2, hero: Hero) -> GraveKnight:
    global_position = at
    spawn_position = at
    target = hero
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var capsule: CapsuleShape2D = CapsuleShape2D.new()
    capsule.radius = 27.0
    capsule.height = 76.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-38)
    add_child(shape_node)
    health_changed.emit(health,max_health)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health <= 0.0 or not is_instance_valid(target):
        return
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    charge_cooldown = maxf(0.0, charge_cooldown - delta)
    stun_time = maxf(0.0, stun_time - delta)
    shield_recover = maxf(0.0, shield_recover - delta)
    if not shield_active and shield_recover <= 0.0:
        shield_active = true
        shield_hits = 3
        request_flash.emit(global_position + Vector2(0,-42),Color("#a8d7ff"))

    if not phase_two and health <= max_health * 0.5:
        phase_two = true
        shield_active = false
        shield_recover = 3.0
        request_flash.emit(global_position + Vector2(0,-42),Color("#ff9d69"))
        damage_text_requested.emit(global_position + Vector2(0,-100),"ENRAGED",Color("#ffb078"))
        sfx_requested.emit("boss_phase",-5.0,1.18)

    if stun_time > 0.0:
        mode = MODE_CHASE
        timer = 0.0
        velocity.x = move_toward(velocity.x,0.0,2100.0*delta)
        move_and_slide()
        queue_redraw()
        return

    match mode:
        MODE_WINDUP:
            timer = maxf(0.0,timer-delta)
            velocity.x = move_toward(velocity.x,0.0,2400.0*delta)
            if timer <= 0.0:
                _execute_windup()
        MODE_CHARGE:
            timer = maxf(0.0,timer-delta)
            velocity.x = facing * (560.0 if phase_two else 470.0)
            if not charge_hit and global_position.distance_to(target.global_position) < 76.0:
                charge_hit = true
                target.take_damage(28.0 if phase_two else 23.0,facing*720.0,global_position)
                request_flash.emit(target.global_position+Vector2(0,-30),Color("#ff7d68"))
            if timer <= 0.0:
                mode = MODE_RECOVER
                timer = 0.36
        MODE_RECOVER:
            timer = maxf(0.0,timer-delta)
            velocity.x = move_toward(velocity.x,0.0,2600.0*delta)
            if timer <= 0.0:
                mode = MODE_CHASE
        _:
            _chase_and_choose(delta)

    move_and_slide()
    queue_redraw()

func _chase_and_choose(delta: float) -> void:
    var dx: float = target.global_position.x - global_position.x
    var distance: float = absf(dx)
    if distance > 5.0:
        facing = signf(dx)
    var speed: float = 118.0 if phase_two else 96.0
    if distance > 112.0:
        velocity.x = move_toward(velocity.x,facing*speed,950.0*delta)
    else:
        velocity.x = move_toward(velocity.x,0.0,1800.0*delta)

    if attack_cooldown > 0.0:
        return
    if distance <= 112.0:
        attack_kind = "slash"
        mode = MODE_WINDUP
        timer = 0.34 if phase_two else 0.46
        attack_cooldown = 1.05
    elif distance <= 540.0 and charge_cooldown <= 0.0:
        attack_kind = "charge"
        mode = MODE_WINDUP
        timer = 0.52
        attack_cooldown = 1.35
        charge_cooldown = 3.3 if phase_two else 4.2

func _execute_windup() -> void:
    if attack_kind == "charge":
        mode = MODE_CHARGE
        timer = 0.58
        charge_hit = false
        sfx_requested.emit("heavy",-6.0,0.76)
        return
    mode = MODE_RECOVER
    timer = 0.30
    var dx: float = target.global_position.x - global_position.x
    if absf(dx) <= 136.0 and absf(target.global_position.y-global_position.y) < 120.0:
        target.take_damage(24.0 if phase_two else 20.0,signf(dx)*560.0,global_position)
        request_flash.emit(target.global_position+Vector2(0,-30),Color("#ff806d"))
    sfx_requested.emit("enemy_attack",-5.0,0.73)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health <= 0.0:
        return
    var applied: float = amount
    if shield_active:
        applied *= 0.48
        shield_hits -= 1
        damage_text_requested.emit(global_position+Vector2(0,-96),"GUARDED",Color("#a9d8ff"))
        if shield_hits <= 0:
            shield_active = false
            shield_recover = 4.0
            request_flash.emit(global_position+Vector2(0,-42),Color("#d4efff"))
            damage_text_requested.emit(global_position+Vector2(0,-112),"GUARD BROKEN",Color("#e4f6ff"))
    health = maxf(0.0,health-applied)
    health_changed.emit(health,max_health)
    velocity.x = knockback * 0.35
    stun_time = maxf(stun_time,stun*0.55)
    request_flash.emit(global_position+Vector2(0,-40),Color("#ffd094"))
    damage_text_requested.emit(global_position+Vector2(0,-82),"%d" % int(round(applied)),Color("#ffdba7"))
    if health <= 0.0:
        collision_layer = 0
        sfx_requested.emit("boss_die",-4.0,1.18)
        died.emit()
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,0.55)
        tween.tween_property(self,"scale",Vector2(1.25,0.68),0.55)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func reset_encounter() -> void:
    global_position = spawn_position
    velocity = Vector2.ZERO
    health = max_health
    mode = MODE_CHASE
    timer = 0.0
    attack_cooldown = 0.8
    charge_cooldown = 1.8
    stun_time = 0.0
    shield_active = true
    shield_hits = 3
    shield_recover = 0.0
    phase_two = false
    charge_hit = false
    health_changed.emit(health,max_health)
    queue_redraw()

func _draw() -> void:
    var armor: Color = Color("#59636d") if not phase_two else Color("#754d49")
    var eye: Color = Color("#ff7b62") if phase_two else Color("#8fd6ff")
    if mode == MODE_WINDUP:
        var warn: Color = Color(1.0,0.35,0.23,0.68)
        draw_arc(Vector2(0,-42),50.0,-PI*0.15,PI*1.15,24,warn,5.0)
        if attack_kind == "charge":
            draw_line(Vector2(facing*24,-32),Vector2(facing*170,-32),warn,5.0)

    draw_polygon(PackedVector2Array([Vector2(-26,-65),Vector2(25,-65),Vector2(31,-5),Vector2(-30,-5)]),PackedColorArray([armor]))
    draw_circle(Vector2(0,-78),22.0,armor.darkened(0.12))
    draw_rect(Rect2(-20,-82,40,12),Color("#242b31"))
    draw_circle(Vector2(facing*8,-76),4.0,eye)
    draw_line(Vector2(facing*22,-48),Vector2(facing*55,-10),Color("#aeb6bb"),7.0)
    draw_line(Vector2(facing*55,-10),Vector2(facing*64,4),Color("#d4c6a5"),4.0)
    draw_circle(Vector2(-facing*31,-43),22.0,Color("#38434d"))
    draw_arc(Vector2(-facing*31,-43),22.0,0,TAU,24,Color("#8195a3") if shield_active else Color("#4d555b"),4.0)
    if shield_active:
        draw_arc(Vector2(-facing*31,-43),29.0,0,TAU,24,Color(0.42,0.78,1.0,0.42),3.0)
    var ratio: float = clampf(health/max_health,0.0,1.0)
    draw_rect(Rect2(-72,-126,144,8),Color(0.03,0.04,0.05,0.90))
    draw_rect(Rect2(-72,-126,144*ratio,8),Color("#bd554b"))
