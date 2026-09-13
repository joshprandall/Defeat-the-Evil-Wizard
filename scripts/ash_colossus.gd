class_name AshColossus
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

var max_health: float = 820.0
var health: float = 820.0
var target: Hero
var arena_left: float = 34420.0
var arena_right: float = 35840.0
var spawn_position: Vector2 = Vector2.ZERO
var facing: float = -1.0
var mode: int = MODE_CHASE
var timer: float = 0.0
var attack_kind: String = "slam"
var action_cooldown: float = 0.8
var charge_cooldown: float = 2.4
var boulder_cooldown: float = 1.4
var stun_time: float = 0.0
var phase_two: bool = false
var charge_hit: bool = false
var pulse: float = 0.0

func setup(at: Vector2, hero: Hero, left_bound: float, right_bound: float) -> AshColossus:
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
    capsule.radius = 34.0
    capsule.height = 96.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-48)
    add_child(shape_node)
    health_changed.emit(health,max_health)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health<=0.0 or not is_instance_valid(target):
        return

    pulse += delta
    action_cooldown = maxf(0.0,action_cooldown-delta)
    charge_cooldown = maxf(0.0,charge_cooldown-delta)
    boulder_cooldown = maxf(0.0,boulder_cooldown-delta)
    stun_time = maxf(0.0,stun_time-delta)

    if not phase_two and health<=max_health*0.50:
        phase_two = true
        request_flash.emit(global_position+Vector2(0,-58),Color("#ef7d57"))
        damage_text_requested.emit(global_position+Vector2(0,-136),"THE MOUNTAIN ANSWERS",Color("#ffaf80"))
        sfx_requested.emit("stone_roar",-2.0,0.86)

    if not is_on_floor():
        velocity.y += GRAVITY*delta

    if stun_time>0.0:
        mode = MODE_CHASE
        velocity.x = move_toward(velocity.x,0.0,1800.0*delta)
        move_and_slide()
        _enforce_arena()
        queue_redraw()
        return

    match mode:
        MODE_WINDUP:
            timer = maxf(0.0,timer-delta)
            velocity.x = move_toward(velocity.x,0.0,2200.0*delta)
            if timer<=0.0:
                _execute_windup()
        MODE_CHARGE:
            timer = maxf(0.0,timer-delta)
            velocity.x = facing*(610.0 if phase_two else 525.0)
            if not charge_hit and global_position.distance_to(target.global_position)<88.0:
                charge_hit = true
                target.take_damage(35.0 if phase_two else 30.0,facing*820.0,global_position)
                request_flash.emit(target.global_position+Vector2(0,-28),Color("#e68c68"))
            if timer<=0.0:
                mode = MODE_RECOVER
                timer = 0.40
        MODE_RECOVER:
            timer = maxf(0.0,timer-delta)
            velocity.x = move_toward(velocity.x,0.0,2300.0*delta)
            if timer<=0.0:
                mode = MODE_CHASE
        _:
            _chase_and_choose(delta)

    move_and_slide()
    _enforce_arena()
    queue_redraw()

func _chase_and_choose(delta: float) -> void:
    var dx: float = target.global_position.x-global_position.x
    var distance: float = absf(dx)
    if distance>4.0:
        facing = signf(dx)

    if distance>145.0:
        velocity.x = move_toward(velocity.x,facing*(118.0 if phase_two else 96.0),760.0*delta)
    else:
        velocity.x = move_toward(velocity.x,0.0,1700.0*delta)

    if action_cooldown>0.0:
        return

    if distance<=150.0:
        attack_kind = "slam"
        mode = MODE_WINDUP
        timer = 0.46 if not phase_two else 0.34
        action_cooldown = 1.00
    elif distance<=620.0 and charge_cooldown<=0.0:
        attack_kind = "charge"
        mode = MODE_WINDUP
        timer = 0.48
        action_cooldown = 1.0
        charge_cooldown = 3.2 if phase_two else 4.3
    elif boulder_cooldown<=0.0:
        attack_kind = "boulder"
        mode = MODE_WINDUP
        timer = 0.42
        action_cooldown = 1.0
        boulder_cooldown = 2.25 if phase_two else 3.1

func _execute_windup() -> void:
    if attack_kind=="charge":
        mode = MODE_CHARGE
        timer = 0.72
        charge_hit = false
        sfx_requested.emit("heavy",-4.0,0.68)
        return

    mode = MODE_RECOVER
    timer = 0.32

    if attack_kind=="boulder":
        _throw_boulder()
        return

    var dx: float = target.global_position.x-global_position.x
    request_flash.emit(global_position+Vector2(facing*42,-18),Color("#e07a56"))
    sfx_requested.emit("ground_slam",-3.0,0.82)
    if absf(dx)<=185.0 and absf(target.global_position.y-global_position.y)<135.0:
        target.take_damage(38.0 if phase_two else 32.0,signf(dx)*760.0,global_position)
    if phase_two and global_position.distance_to(target.global_position)<310.0:
        target.take_damage(12.0,signf(dx)*360.0,global_position)

func _throw_boulder() -> void:
    if not is_instance_valid(target):
        return
    sfx_requested.emit("rock_break",-7.0,0.82)
    var count: int = 3 if phase_two else 2
    for i: int in range(count):
        var rock: RollingBoulder = RollingBoulder.new().setup(
            global_position+Vector2(facing*(46.0+float(i)*14.0),-88.0-float(i)*16.0),
            facing*(430.0+float(i)*55.0),
            26.0 if phase_two else 22.0
        )
        rock.sfx_requested.connect(func(id: String, volume_db: float, pitch: float):
            sfx_requested.emit(id,volume_db,pitch)
        )
        get_parent().add_child(rock)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health<=0.0:
        return
    var applied: float = amount*(0.88 if phase_two else 1.0)
    health = maxf(0.0,health-applied)
    health_changed.emit(health,max_health)
    velocity.x = knockback*0.15
    stun_time = maxf(stun_time,stun*0.30)
    request_flash.emit(global_position+Vector2(0,-55),Color("#ffc0a0"))
    damage_text_requested.emit(global_position+Vector2(0,-124),"%d" % int(round(applied)),Color("#ffd0b4"))
    if health<=0.0:
        collision_layer = 0
        sfx_requested.emit("boss_die",-2.0,0.76)
        died.emit()
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,1.1)
        tween.tween_property(self,"scale",Vector2(1.58,0.48),1.1)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _enforce_arena() -> void:
    var safe_x: float = clampf(global_position.x,arena_left,arena_right)
    if not is_equal_approx(safe_x,global_position.x):
        global_position.x = safe_x
        velocity.x = 0.0
    if global_position.y>720.0:
        global_position = Vector2(clampf(spawn_position.x,arena_left,arena_right),560.0)
        velocity = Vector2.ZERO

func _draw() -> void:
    var body: Color = Color("#62575a") if not phase_two else Color("#6b4f4b")
    var fissure: Color = Color("#df7657") if not phase_two else Color("#ff8d5f")

    if mode==MODE_WINDUP:
        draw_arc(Vector2(0,-56),72.0,-0.3,PI+0.3,26,Color(0.96,0.42,0.23,0.68),5.0)
        if attack_kind=="charge":
            draw_line(Vector2(facing*42,-40),Vector2(facing*235,-40),Color(0.96,0.42,0.23,0.46),5.0)

    draw_polygon(
        PackedVector2Array([Vector2(-48,-76),Vector2(48,-76),Vector2(54,-8),Vector2(-54,-8)]),
        PackedColorArray([body])
    )
    draw_circle(Vector2(0,-94),31.0,body.lightened(0.04))
    draw_polygon(PackedVector2Array([Vector2(-30,-111),Vector2(30,-111),Vector2(36,-94),Vector2(-36,-94)]),PackedColorArray([Color("#776c6e")]))

    draw_line(Vector2(-20,-70),Vector2(6,-46),fissure,5.0)
    draw_line(Vector2(6,-46),Vector2(-4,-22),fissure,4.0)
    draw_line(Vector2(18,-99),Vector2(6,-74),fissure,4.0)
    draw_circle(Vector2(facing*10,-95),5.0,Color("#ffad75"))

    draw_line(Vector2(facing*27,-52),Vector2(facing*62,-14),Color("#8f7f77"),10.0)
    draw_circle(Vector2(facing*68,-7),18.0,Color("#716668"))

    draw_arc(Vector2(0,-52),65.0,0.0,TAU,30,Color(fissure.r,fissure.g,fissure.b,0.10+0.05*sin(pulse*3.0)),3.0)

    var ratio: float = clampf(health/max_health,0.0,1.0)
    draw_rect(Rect2(-104,-166,208,9),Color(0.03,0.02,0.025,0.94))
    draw_rect(Rect2(-104,-166,208*ratio,9),Color("#c86650"))
