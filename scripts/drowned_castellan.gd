class_name DrownedCastellan
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

var max_health: float = 690.0
var health: float = 690.0
var target: Hero
var spawn_position: Vector2 = Vector2.ZERO
var arena_left: float = 19840.0
var arena_right: float = 21040.0
var facing: float = -1.0
var mode: int = MODE_CHASE
var timer: float = 0.0
var attack_kind: String = "anchor"
var action_cooldown: float = 0.8
var charge_cooldown: float = 2.4
var volley_cooldown: float = 1.5
var flood_cooldown: float = 3.0
var stun_time: float = 0.0
var phase_two: bool = false
var charge_hit: bool = false
var pulse: float = 0.0

func setup(at: Vector2, hero: Hero, left_bound: float, right_bound: float) -> DrownedCastellan:
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
    capsule.radius = 30.0
    capsule.height = 88.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-44)
    add_child(shape_node)
    health_changed.emit(health,max_health)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health <= 0.0 or not is_instance_valid(target):
        return

    pulse += delta
    action_cooldown = maxf(0.0,action_cooldown-delta)
    charge_cooldown = maxf(0.0,charge_cooldown-delta)
    volley_cooldown = maxf(0.0,volley_cooldown-delta)
    flood_cooldown = maxf(0.0,flood_cooldown-delta)
    stun_time = maxf(0.0,stun_time-delta)

    if not phase_two and health <= max_health*0.50:
        phase_two = true
        request_flash.emit(global_position+Vector2(0,-52),Color("#72d6e8"))
        damage_text_requested.emit(global_position+Vector2(0,-126),"THE KEEP FLOODS",Color("#9befff"))
        sfx_requested.emit("boss_phase",-3.0,0.84)

    if not is_on_floor():
        velocity.y += GRAVITY*delta

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
            velocity.x = move_toward(velocity.x,0.0,2200.0*delta)
            if timer <= 0.0:
                _execute_windup()
        MODE_CHARGE:
            timer = maxf(0.0,timer-delta)
            velocity.x = facing*(640.0 if phase_two else 555.0)
            if not charge_hit and global_position.distance_to(target.global_position) < 82.0:
                charge_hit = true
                target.take_damage(32.0 if phase_two else 27.0,facing*780.0,global_position)
                request_flash.emit(target.global_position+Vector2(0,-28),Color("#6bd7e8"))
            if timer <= 0.0:
                mode = MODE_RECOVER
                timer = 0.34
        MODE_RECOVER:
            timer = maxf(0.0,timer-delta)
            velocity.x = move_toward(velocity.x,0.0,2400.0*delta)
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

    if distance > 135.0:
        velocity.x = move_toward(velocity.x,facing*(132.0 if phase_two else 108.0),900.0*delta)
    else:
        velocity.x = move_toward(velocity.x,0.0,1700.0*delta)

    if action_cooldown > 0.0:
        return

    if phase_two and distance < 300.0 and flood_cooldown <= 0.0:
        attack_kind = "flood"
        mode = MODE_WINDUP
        timer = 0.48
        action_cooldown = 1.0
        flood_cooldown = 3.4
    elif distance <= 142.0:
        attack_kind = "anchor"
        mode = MODE_WINDUP
        timer = 0.34 if phase_two else 0.44
        action_cooldown = 0.94
    elif distance <= 600.0 and charge_cooldown <= 0.0:
        attack_kind = "charge"
        mode = MODE_WINDUP
        timer = 0.46
        action_cooldown = 1.0
        charge_cooldown = 3.1 if phase_two else 4.1
    elif volley_cooldown <= 0.0:
        attack_kind = "tide"
        mode = MODE_WINDUP
        timer = 0.38
        action_cooldown = 1.0
        volley_cooldown = 2.25 if phase_two else 3.25

func _execute_windup() -> void:
    if attack_kind == "charge":
        mode = MODE_CHARGE
        timer = 0.66
        charge_hit = false
        sfx_requested.emit("heavy",-5.0,0.72)
        return

    mode = MODE_RECOVER
    timer = 0.30

    if attack_kind == "tide":
        var origin: Vector2 = global_position+Vector2(facing*27,-58)
        var base: Vector2 = (target.global_position+Vector2(0,-26)-origin).normalized()
        var count: int = 5 if phase_two else 3
        for i: int in range(count):
            var offset: float = (float(i)-float(count-1)*0.5)*0.12
            projectile_requested.emit(origin,base.rotated(offset),455.0 if phase_two else 395.0,16.0 if phase_two else 13.0)
        request_flash.emit(global_position+Vector2(0,-54),Color("#6bcde1"))
        sfx_requested.emit("wizard_cast",-7.0,0.78)
        return

    if attack_kind == "flood":
        request_flash.emit(global_position+Vector2(0,-25),Color("#6bd9eb"))
        var distance: float = global_position.distance_to(target.global_position)
        if distance <= 305.0:
            var direction: float = signf(target.global_position.x-global_position.x)
            target.take_damage(30.0,direction*650.0,global_position)
        sfx_requested.emit("water_splash",-4.0,0.78)
        return

    var dx: float = target.global_position.x-global_position.x
    if absf(dx) <= 166.0 and absf(target.global_position.y-global_position.y) < 126.0:
        target.take_damage(31.0 if phase_two else 26.0,signf(dx)*660.0,global_position)
        request_flash.emit(target.global_position+Vector2(0,-28),Color("#7cd7e4"))
    sfx_requested.emit("enemy_attack",-5.0,0.64)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health <= 0.0:
        return
    var applied: float = amount*(0.90 if phase_two else 1.0)
    health = maxf(0.0,health-applied)
    health_changed.emit(health,max_health)
    velocity.x = knockback*0.20
    stun_time = maxf(stun_time,stun*0.38)
    request_flash.emit(global_position+Vector2(0,-50),Color("#b9eff4"))
    damage_text_requested.emit(global_position+Vector2(0,-116),"%d" % int(round(applied)),Color("#c9f7fa"))
    if health <= 0.0:
        collision_layer = 0
        sfx_requested.emit("boss_die",-3.0,0.84)
        died.emit()
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,1.0)
        tween.tween_property(self,"scale",Vector2(1.5,0.52),1.0)
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
    var body: Color = Color("#43565e") if not phase_two else Color("#42626b")
    var glow: Color = Color("#7fd6e5") if not phase_two else Color("#9df1ff")

    if mode == MODE_WINDUP:
        draw_arc(Vector2(0,-50),66.0,-0.25,PI+0.25,26,Color(0.45,0.88,1.0,0.70),5.0)
        if attack_kind=="charge":
            draw_line(Vector2(facing*35,-38),Vector2(facing*220,-38),Color(0.45,0.88,1.0,0.48),5.0)
        elif attack_kind=="flood":
            draw_arc(Vector2(0,-26),110.0,0.0,TAU,30,Color(0.45,0.88,1.0,0.40),4.0)

    # Armored drowned body.
    draw_polygon(PackedVector2Array([Vector2(-38,-66),Vector2(38,-66),Vector2(45,-7),Vector2(-45,-7)]),PackedColorArray([body]))
    draw_circle(Vector2(0,-80),26.0,body.lightened(0.04))
    draw_polygon(PackedVector2Array([Vector2(-25,-95),Vector2(25,-95),Vector2(31,-80),Vector2(-31,-80)]),PackedColorArray([Color("#61747a")]))
    draw_circle(Vector2(facing*9,-81),4.5,glow)

    # Anchor weapon.
    var hand: Vector2 = Vector2(facing*24,-45)
    draw_line(hand,hand+Vector2(facing*52,40),Color("#7c8c91"),8.0)
    var anchor: Vector2 = hand+Vector2(facing*58,47)
    draw_line(anchor+Vector2(-facing*18,-8),anchor+Vector2(facing*18,-8),Color("#819399"),6.0)
    draw_line(anchor,anchor+Vector2(0,28),Color("#819399"),6.0)
    draw_line(anchor+Vector2(0,25),anchor+Vector2(-facing*18,39),Color("#819399"),5.0)
    draw_line(anchor+Vector2(0,25),anchor+Vector2(facing*18,39),Color("#819399"),5.0)

    # Water aura.
    draw_arc(Vector2(0,-44),58.0,0.0,TAU,28,Color(glow.r,glow.g,glow.b,0.13+0.05*sin(pulse*3.0)),3.0)
    if phase_two:
        draw_arc(Vector2(0,-44),72.0,0.0,TAU,30,Color(glow.r,glow.g,glow.b,0.22),3.0)

    var ratio: float = clampf(health/max_health,0.0,1.0)
    draw_rect(Rect2(-92,-150,184,8),Color(0.02,0.04,0.05,0.92))
    draw_rect(Rect2(-92,-150,184*ratio,8),Color("#62b9c8"))
