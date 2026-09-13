class_name TrueEvilWizard
extends CharacterBody2D

signal died
signal projectile_requested(at: Vector2, direction: Vector2, speed: float, damage: float)
signal summon_requested(at: Vector2, kind: String)
signal seal_requested(count: int)
signal health_changed(current: float, maximum: float)
signal phase_changed(phase: int)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

const MAX_HEALTH: float = 1400.0
const ARENA_FLOOR_Y: float = 560.0
const ARENA_FALL_LIMIT: float = 720.0
const VANISH_DURATION: float = 0.46
const VANISH_COST_FRACTION: float = 0.03

var max_health: float = MAX_HEALTH
var health: float = MAX_HEALTH
var target: Hero
var arena_left: float = 48680.0
var arena_right: float = 51620.0
var spawn_position: Vector2 = Vector2.ZERO

var phase: int = 1
var action_timer: float = 1.0
var teleport_timer: float = 4.2
var summon_timer: float = 99.0
var barrier_time: float = 0.0
var telegraph_time: float = 0.0
var queued_spell: String = ""
var seal_remaining: int = 0
var seal_called: bool = false

var vanished: bool = false
var vanish_timer: float = 0.0
var vanish_destination_x: float = 0.0
var vanish_cost_accumulated: float = 0.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func setup(at: Vector2, hero: Hero, left_bound: float, right_bound: float) -> TrueEvilWizard:
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

    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var capsule: CapsuleShape2D = CapsuleShape2D.new()
    capsule.radius = 24.0
    capsule.height = 76.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-38)
    add_child(shape_node)

    health_changed.emit(health,MAX_HEALTH)
    phase_changed.emit(phase)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health<=0.0 or not is_instance_valid(target):
        return

    if vanished:
        _update_vanish(delta)
        return

    if not is_on_floor():
        velocity.y += 1900.0*delta

    velocity.x = move_toward(velocity.x,0.0,1550.0*delta)
    action_timer -= delta
    teleport_timer -= delta
    summon_timer -= delta
    barrier_time = maxf(0.0,barrier_time-delta)

    _check_phase()

    if phase>=4:
        var burn: float = MAX_HEALTH*0.009*delta
        health=maxf(0.0,health-burn)
        health_changed.emit(health,MAX_HEALTH)
        if health<=0.0:
            _die()
            return

    if telegraph_time>0.0:
        telegraph_time=maxf(0.0,telegraph_time-delta)
        if telegraph_time<=0.0 and not queued_spell.is_empty():
            _execute_spell()
        move_and_slide()
        _enforce_arena()
        queue_redraw()
        return

    if teleport_timer<=0.0:
        teleport_timer = 4.2 if phase==1 else (3.2 if phase==2 else (2.35 if phase==3 else 1.75))
        _shadow_step()
        return

    if summon_timer<=0.0 and phase>=3:
        summon_timer = 7.2 if phase==3 else 4.8
        var summon_x: float = clampf(
            target.global_position.x+rng.randf_range(-240.0,240.0),
            arena_left+140.0,
            arena_right-140.0
        )
        var kind: String = "void_sentry" if rng.randi_range(0,1)==0 else "arcane_eye"
        summon_requested.emit(Vector2(summon_x,560),kind)

    if action_timer<=0.0:
        action_timer = rng.randf_range(1.0,1.35)
        if phase==2:
            action_timer = rng.randf_range(0.82,1.12)
        elif phase==3:
            action_timer = rng.randf_range(0.62,0.92)
        elif phase>=4:
            action_timer = rng.randf_range(0.42,0.68)
        _begin_cast()

    move_and_slide()
    _enforce_arena()
    queue_redraw()

func _check_phase() -> void:
    if phase==1 and health<=MAX_HEALTH*0.70:
        phase=2
        barrier_time=1.5
        action_timer=0.55
        phase_changed.emit(phase)
        request_flash.emit(global_position+Vector2(0,-48),Color("#d69aef"))
        damage_text_requested.emit(global_position+Vector2(0,-130),"THE CROWN SEAL",Color("#ebc2fa"))
        sfx_requested.emit("final_phase",-1.0,0.94)
        if not seal_called:
            seal_called=true
            seal_remaining=3
            seal_requested.emit(3)
    elif phase==2 and health<=MAX_HEALTH*0.38 and seal_remaining<=0:
        phase=3
        barrier_time=1.2
        action_timer=0.35
        summon_timer=0.9
        phase_changed.emit(phase)
        request_flash.emit(global_position+Vector2(0,-48),Color("#c76fe1"))
        damage_text_requested.emit(global_position+Vector2(0,-130),"THE ROADS RETURN",Color("#e7aaf2"))
        sfx_requested.emit("final_phase",-1.0,0.82)
    elif phase==3 and health<=MAX_HEALTH*0.14:
        phase=4
        barrier_time=0.8
        action_timer=0.18
        summon_timer=0.6
        phase_changed.emit(phase)
        request_flash.emit(global_position+Vector2(0,-48),Color("#ff668d"))
        damage_text_requested.emit(global_position+Vector2(0,-130),"MORTAL SPELL",Color("#ff9bb2"))
        sfx_requested.emit("mortal_spell",0.0,0.86)

func break_seal_piece() -> void:
    if seal_remaining<=0:
        return
    seal_remaining-=1
    request_flash.emit(global_position+Vector2(0,-48),Color("#f0c5ff"))
    damage_text_requested.emit(
        global_position+Vector2(0,-128),
        "CROWN SEAL  //  %d REMAIN" % seal_remaining,
        Color("#ebc8f8")
    )
    if seal_remaining<=0:
        barrier_time=0.0
        action_timer=0.30
        sfx_requested.emit("mirror_lock",-3.0,0.76)
        damage_text_requested.emit(global_position+Vector2(0,-150),"THE SEAL IS BROKEN",Color("#ffe0a2"))

func _begin_cast() -> void:
    if not is_instance_valid(target):
        return

    var roll: int = rng.randi_range(0,99)
    if phase==1:
        queued_spell = "bolt" if roll<45 else ("fan" if roll<78 else "lance")
    elif phase==2:
        queued_spell = "fan" if roll<30 else ("rain" if roll<58 else ("lance" if roll<82 else "wave"))
    elif phase==3:
        queued_spell = "chaos" if roll<34 else ("rain" if roll<58 else ("wave" if roll<80 else "lance"))
    else:
        queued_spell = "chaos" if roll<40 else ("lance" if roll<64 else ("rain" if roll<84 else "wave"))

    telegraph_time = 0.42
    if queued_spell=="lance":
        telegraph_time=0.32
    elif queued_spell=="chaos":
        telegraph_time=0.50
    elif phase>=4:
        telegraph_time*=0.78

    sfx_requested.emit("true_cast",-10.0,0.92+float(phase)*0.04)
    queue_redraw()

func _execute_spell() -> void:
    if not is_instance_valid(target):
        queued_spell=""
        return

    var origin: Vector2 = global_position+Vector2(0,-52)
    var aim: Vector2 = (target.global_position+Vector2(0,-30)-origin).normalized()

    match queued_spell:
        "bolt":
            projectile_requested.emit(origin,aim,520.0,20.0)
        "fan":
            var count: int = 3 if phase<3 else 5
            for i: int in range(count):
                var spread: float = (float(i)-float(count-1)*0.5)*0.14
                projectile_requested.emit(origin,aim.rotated(spread),500.0+float(phase)*22.0,18.0+float(phase)*2.0)
        "lance":
            projectile_requested.emit(origin,aim,790.0+float(phase)*35.0,30.0+float(phase)*3.0)
            request_flash.emit(origin,Color("#f0b3ff"))
        "rain":
            var count: int = 5 if phase<4 else 7
            for i: int in range(count):
                var xoff: float = (float(i)-float(count-1)*0.5)*82.0
                var rain_at: Vector2 = Vector2(
                    clampf(target.global_position.x+xoff,arena_left+80.0,arena_right-80.0),
                    125.0-float(i%2)*35.0
                )
                projectile_requested.emit(rain_at,Vector2(0,1),560.0+float(phase)*35.0,18.0+float(phase)*2.0)
        "chaos":
            var count: int = 7 if phase==3 else 9
            for i: int in range(count):
                var spread: float = (float(i)-float(count-1)*0.5)*0.12
                projectile_requested.emit(origin,aim.rotated(spread),545.0+float(i%3)*45.0,19.0+float(phase)*2.0)
        "wave":
            var dx: float = target.global_position.x-global_position.x
            request_flash.emit(global_position+Vector2(0,-30),Color("#8e4bac"))
            sfx_requested.emit("void_pulse",-4.0,0.78)
            if absf(dx)<540.0 and absf(target.global_position.y-global_position.y)<180.0:
                target.take_damage(24.0+float(phase)*4.0,signf(dx)*620.0,global_position)

    queued_spell=""

func _shadow_step() -> void:
    if vanished or health<=0.0:
        return

    vanished=true
    vanish_timer=VANISH_DURATION
    vanish_cost_accumulated=0.0
    visible=false
    collision_layer=0
    velocity=Vector2.ZERO

    var preferred: float = target.global_position.x
    var side: float = -1.0 if target.global_position.x>global_position.x else 1.0
    vanish_destination_x=clampf(
        preferred+side*rng.randf_range(170.0,290.0),
        arena_left+90.0,
        arena_right-90.0
    )

    request_flash.emit(global_position+Vector2(0,-45),Color("#7c4a99"))
    sfx_requested.emit("teleport",-7.0,0.78)

func _update_vanish(delta: float) -> void:
    vanish_timer=maxf(0.0,vanish_timer-delta)

    var total_cost: float = MAX_HEALTH*VANISH_COST_FRACTION
    var drain_rate: float = total_cost/VANISH_DURATION
    var remaining_cost: float = maxf(0.0,total_cost-vanish_cost_accumulated)
    var drain: float = minf(remaining_cost,drain_rate*delta)

    vanish_cost_accumulated+=drain
    health=maxf(0.0,health-drain)
    health_changed.emit(health,MAX_HEALTH)

    if health<=0.0:
        _die()
        return

    if vanish_timer<=0.0:
        _reappear()

func _reappear() -> void:
    vanished=false
    visible=true
    collision_layer=2
    global_position=Vector2(vanish_destination_x,ARENA_FLOOR_Y)
    velocity=Vector2.ZERO
    request_flash.emit(global_position+Vector2(0,-45),Color("#ca80e7"))
    damage_text_requested.emit(
        global_position+Vector2(0,-128),
        "VOID COST  -%d" % int(round(vanish_cost_accumulated)),
        Color("#dba6ed")
    )
    sfx_requested.emit("teleport",-6.0,1.18)
    queue_redraw()

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, _stun: float = 0.0) -> void:
    if health<=0.0 or vanished:
        return

    var applied: float=amount
    if seal_remaining>0:
        applied*=0.12
    elif barrier_time>0.0:
        applied*=0.30
    elif phase>=4:
        applied*=0.92

    health=maxf(0.0,health-applied)
    velocity.x=knockback*0.08
    health_changed.emit(health,MAX_HEALTH)
    request_flash.emit(global_position+Vector2(0,-45),Color("#f4c5ff"))
    damage_text_requested.emit(global_position+Vector2(0,-126),"%d" % int(round(applied)),Color("#f1d0fb"))

    if seal_remaining>0:
        damage_text_requested.emit(global_position+Vector2(0,-151),"SEALED",Color("#c697df"))

    if health<=0.0:
        _die()
    queue_redraw()

func _die() -> void:
    if health>0.0:
        return
    vanished=false
    visible=true
    collision_layer=0
    queued_spell=""
    telegraph_time=0.0
    sfx_requested.emit("final_defeat",1.0,0.82)
    died.emit()
    var tween: Tween=create_tween()
    tween.set_parallel(true)
    tween.tween_property(self,"modulate:a",0.0,1.8)
    tween.tween_property(self,"scale",Vector2(2.2,2.2),1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.chain().tween_callback(queue_free)

func _enforce_arena() -> void:
    if vanished or health<=0.0:
        return
    var safe_x: float=clampf(global_position.x,arena_left,arena_right)
    if not is_equal_approx(safe_x,global_position.x):
        global_position.x=safe_x
        velocity.x=0.0
    if global_position.y>ARENA_FALL_LIMIT:
        global_position=Vector2(clampf(spawn_position.x,arena_left,arena_right),ARENA_FLOOR_Y)
        velocity=Vector2.ZERO

func _draw() -> void:
    var robe: Color=Color("#2f183f")
    var magic: Color=Color("#c17ae5")
    if phase==2:
        robe=Color("#451843")
        magic=Color("#d48be8")
    elif phase==3:
        robe=Color("#54163d")
        magic=Color("#e56db4")
    elif phase>=4:
        robe=Color("#661a35")
        magic=Color("#ff668d")

    if telegraph_time>0.0:
        draw_arc(Vector2(0,-50),72.0,0.0,TAU,40,Color(magic.r,magic.g,magic.b,0.68),5.0)
        if queued_spell=="lance" and is_instance_valid(target):
            var local_target: Vector2=to_local(target.global_position+Vector2(0,-30))
            draw_dashed_line(Vector2(0,-50),local_target,Color(magic.r,magic.g,magic.b,0.62),3.0,11.0)

    # Robes and mantle.
    draw_polygon(
        PackedVector2Array([
            Vector2(-34,-64),Vector2(31,-64),Vector2(42,4),Vector2(-46,4)
        ]),
        PackedColorArray([robe])
    )
    draw_polygon(
        PackedVector2Array([
            Vector2(-38,-63),Vector2(0,-84),Vector2(38,-63),Vector2(24,-47),Vector2(-25,-47)
        ]),
        PackedColorArray([robe.lightened(0.08)])
    )

    # Face, crown, and staff.
    draw_circle(Vector2(0,-79),17.0,Color("#c7aa99"))
    draw_polygon(
        PackedVector2Array([
            Vector2(-22,-94),Vector2(-17,-112),Vector2(-7,-98),
            Vector2(0,-120),Vector2(8,-98),Vector2(18,-112),Vector2(23,-94)
        ]),
        PackedColorArray([Color("#a36ab7")])
    )
    draw_line(Vector2(-22,-94),Vector2(23,-94),Color("#d9a8e7"),3.0)
    draw_circle(Vector2(-6,-80),3.0,magic)
    draw_circle(Vector2(6,-80),3.0,magic)

    draw_line(Vector2(27,-49),Vector2(52,-101),Color("#75617e"),6.0)
    draw_circle(Vector2(55,-106),10.0,magic)
    draw_circle(Vector2(55,-106),20.0,Color(magic.r,magic.g,magic.b,0.12))

    # Phase sigils on the robe.
    for i: int in range(phase):
        var y: float=-38.0+float(i)*13.0
        draw_arc(Vector2(0,y),8.0,0.0,TAU,18,magic,2.0)

    if seal_remaining>0:
        draw_arc(Vector2(0,-50),63.0,0.0,TAU,40,Color(0.80,0.54,0.92,0.78),6.0)
        for i: int in range(seal_remaining):
            var a: float=float(i)*TAU/3.0
            draw_circle(Vector2(cos(a)*62.0,-50+sin(a)*62.0),7.0,Color("#e4b7f2"))
    elif barrier_time>0.0:
        draw_arc(Vector2(0,-50),60.0,0.0,TAU,40,Color(0.73,0.39,0.88,0.62),5.0)

    if phase>=4:
        draw_arc(Vector2(0,-50),78.0,0.0,TAU,40,Color(1.0,0.34,0.50,0.20+0.08*sin(Time.get_ticks_msec()*0.008)),4.0)
