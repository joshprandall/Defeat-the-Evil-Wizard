class_name ObsidianWarden
extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal died
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

const GRAVITY: float = 1900.0
const MODE_CHASE: int = 0
const MODE_WINDUP: int = 1
const MODE_RECOVER: int = 2
const MODE_BLINK: int = 3

var max_health: float = 960.0
var health: float = 960.0
var target: Hero
var arena_left: float = 43820.0
var arena_right: float = 45580.0
var spawn_position: Vector2 = Vector2.ZERO
var facing: float = -1.0
var mode: int = MODE_CHASE
var timer: float = 0.0
var action_cooldown: float = 0.8
var attack_kind: String = "cleave"
var phase: int = 1
var phase_shift_cooldown: float = 3.2
var barrier_time: float = 0.0
var pulse: float = 0.0

func setup(at: Vector2, hero: Hero, left_bound: float, right_bound: float) -> ObsidianWarden:
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
    capsule.radius = 29.0
    capsule.height = 88.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-44)
    add_child(shape_node)
    health_changed.emit(health,max_health)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health<=0.0 or not is_instance_valid(target):
        return

    pulse += delta
    action_cooldown = maxf(0.0,action_cooldown-delta)
    phase_shift_cooldown = maxf(0.0,phase_shift_cooldown-delta)
    barrier_time = maxf(0.0,barrier_time-delta)

    var new_phase: int = 1
    if health<=max_health*0.28:
        new_phase = 3
    elif health<=max_health*0.62:
        new_phase = 2

    if new_phase!=phase:
        phase = new_phase
        barrier_time = 1.35
        action_cooldown = 0.75
        request_flash.emit(global_position+Vector2(0,-50),Color("#cb88ef"))
        damage_text_requested.emit(global_position+Vector2(0,-136),"THE SEAL TIGHTENS  //  PHASE %d" % phase,Color("#e0b3f7"))
        sfx_requested.emit("phase_shift",-3.0,0.76+float(phase)*0.08)

    if not is_on_floor():
        velocity.y += GRAVITY*delta

    if mode==MODE_WINDUP:
        timer=maxf(0.0,timer-delta)
        velocity.x=move_toward(velocity.x,0.0,2200.0*delta)
        if timer<=0.0:
            _execute_attack()
    elif mode==MODE_RECOVER:
        timer=maxf(0.0,timer-delta)
        velocity.x=move_toward(velocity.x,0.0,2100.0*delta)
        if timer<=0.0:
            mode=MODE_CHASE
    elif mode==MODE_BLINK:
        timer=maxf(0.0,timer-delta)
        velocity.x=0.0
        if timer<=0.0:
            _finish_blink()
    else:
        _chase_and_choose(delta)

    move_and_slide()
    _enforce_arena()
    queue_redraw()

func _chase_and_choose(delta: float) -> void:
    var dx: float = target.global_position.x-global_position.x
    var distance: float = absf(dx)
    if distance>4.0:
        facing=signf(dx)

    if distance>130.0:
        velocity.x=move_toward(velocity.x,facing*(130.0+float(phase-1)*18.0),900.0*delta)
    else:
        velocity.x=move_toward(velocity.x,0.0,1800.0*delta)

    if action_cooldown>0.0:
        return

    if phase_shift_cooldown<=0.0 and distance>300.0:
        mode=MODE_BLINK
        timer=0.32
        phase_shift_cooldown=3.8-float(phase)*0.45
        request_flash.emit(global_position+Vector2(0,-45),Color("#8b5dac"))
        sfx_requested.emit("phase_shift",-7.0,0.82)
        return

    if distance<=145.0:
        attack_kind="cleave"
    elif phase>=2 and distance<520.0:
        attack_kind="void_wave"
    else:
        attack_kind="orb"

    mode=MODE_WINDUP
    timer=0.40 if attack_kind!="cleave" else 0.30
    action_cooldown=maxf(0.60,1.05-float(phase-1)*0.12)

func _finish_blink() -> void:
    mode=MODE_RECOVER
    timer=0.18
    var side: float = -1.0 if target.global_position.x>global_position.x else 1.0
    global_position.x = clampf(target.global_position.x+side*170.0,arena_left+90.0,arena_right-90.0)
    facing = -side
    request_flash.emit(global_position+Vector2(0,-45),Color("#c38ce3"))
    sfx_requested.emit("teleport",-6.0,1.15)

func _execute_attack() -> void:
    mode=MODE_RECOVER
    timer=0.28

    if attack_kind=="orb":
        _cast_orbs()
        return
    if attack_kind=="void_wave":
        _cast_wave()
        return

    var dx: float = target.global_position.x-global_position.x
    request_flash.emit(global_position+Vector2(facing*44,-38),Color("#c18ddd"))
    sfx_requested.emit("heavy",-4.0,0.76)
    if absf(dx)<=175.0 and absf(target.global_position.y-global_position.y)<130.0:
        target.take_damage(34.0+float(phase)*4.0,signf(dx)*780.0,global_position)

func _cast_orbs() -> void:
    if not is_instance_valid(target):
        return
    var count: int = 2+phase
    for i: int in range(count):
        var target_offset: Vector2 = Vector2(0,-28+float(i-(count/2))*24.0)
        var direction: Vector2 = (target.global_position+target_offset-(global_position+Vector2(0,-52))).normalized()
        direction=direction.rotated((float(i)-float(count-1)*0.5)*0.08)
        var bolt: DarkBolt = DarkBolt.new().setup(global_position+Vector2(facing*25,-52),direction,470.0+float(phase)*30.0,17.0+float(phase)*3.0)
        get_parent().add_child(bolt)
    request_flash.emit(global_position+Vector2(0,-52),Color("#c08adb"))
    sfx_requested.emit("wizard_cast",-5.0,0.92+float(phase)*0.05)

func _cast_wave() -> void:
    var dx: float = target.global_position.x-global_position.x
    request_flash.emit(global_position+Vector2(0,-24),Color("#7f4ca2"))
    sfx_requested.emit("void_pulse",-4.0,0.84)
    if absf(dx)<450.0 and absf(target.global_position.y-global_position.y)<160.0:
        target.take_damage(22.0+float(phase)*4.0,signf(dx)*520.0,global_position)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health<=0.0:
        return
    var applied: float = amount
    if barrier_time>0.0:
        applied *= 0.38
    elif phase>=3:
        applied *= 0.88

    health=maxf(0.0,health-applied)
    health_changed.emit(health,max_health)
    velocity.x=knockback*0.10
    request_flash.emit(global_position+Vector2(0,-48),Color("#e5b6f5"))
    damage_text_requested.emit(global_position+Vector2(0,-132),"%d" % int(round(applied)),Color("#ead0f4"))

    if stun>0.0 and phase==1:
        action_cooldown=maxf(action_cooldown,stun*0.35)

    if health<=0.0:
        collision_layer=0
        sfx_requested.emit("boss_die",-2.0,0.70)
        died.emit()
        var tween: Tween=create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,1.2)
        tween.tween_property(self,"scale",Vector2(1.45,0.45),1.2)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _enforce_arena() -> void:
    var safe_x: float=clampf(global_position.x,arena_left,arena_right)
    if not is_equal_approx(safe_x,global_position.x):
        global_position.x=safe_x
        velocity.x=0.0
    if global_position.y>720.0:
        global_position=Vector2(clampf(spawn_position.x,arena_left,arena_right),560.0)
        velocity=Vector2.ZERO

func _draw() -> void:
    var armor: Color=Color("#2e2834")
    var rune: Color=Color("#a96fca") if phase==1 else Color("#cf7de4")
    if phase>=3:
        rune=Color("#e58ad2")

    if mode==MODE_WINDUP:
        draw_arc(Vector2(0,-48),72.0,-0.2,PI+0.2,26,Color(rune.r,rune.g,rune.b,0.58),5.0)

    draw_polygon(PackedVector2Array([Vector2(-38,-76),Vector2(38,-76),Vector2(44,-6),Vector2(-44,-6)]),PackedColorArray([armor]))
    draw_circle(Vector2(0,-95),27.0,Color("#39313f"))
    draw_polygon(PackedVector2Array([Vector2(-29,-99),Vector2(29,-99),Vector2(20,-116),Vector2(-20,-116)]),PackedColorArray([Color("#51415b")]))
    draw_line(Vector2(facing*22,-48),Vector2(facing*61,-10),Color("#8d7a96"),8.0)
    draw_circle(Vector2(facing*9,-94),5.0,rune)

    draw_line(Vector2(-18,-69),Vector2(4,-48),rune,4.0)
    draw_line(Vector2(4,-48),Vector2(-8,-22),rune,4.0)

    if barrier_time>0.0:
        draw_arc(Vector2(0,-50),62.0,0.0,TAU,32,Color(0.73,0.40,0.88,0.42),5.0)

    draw_arc(Vector2(0,-50),68.0,0.0,TAU,32,Color(rune.r,rune.g,rune.b,0.10+0.05*sin(pulse*3.0)),3.0)

    var ratio: float=clampf(health/max_health,0.0,1.0)
    draw_rect(Rect2(-116,-166,232,9),Color(0.03,0.02,0.025,0.94))
    draw_rect(Rect2(-116,-166,232*ratio,9),Color("#a76ac3"))
