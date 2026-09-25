class_name TowerEnemy
extends CharacterBody2D

signal died(enemy: TowerEnemy)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var enemy_type: String = "void_sentry"
var max_health: float = 96.0
var health: float = 96.0
var move_speed: float = 120.0
var attack_damage: float = 18.0
var attack_range: float = 72.0
var attack_cooldown: float = 0.0
var windup: float = 0.0
var attacking: bool = false
var stun_time: float = 0.0
var facing: float = -1.0
var target: Hero
var blink_cooldown: float = 0.0

func setup(kind: String, at: Vector2, hero: Hero) -> TowerEnemy:
    enemy_type = kind
    global_position = at
    target = hero
    match enemy_type:
        "arcane_eye":
            max_health = 60.0
            move_speed = 62.0
            attack_damage = 16.0
            attack_range = 390.0
        "shadow_knight":
            max_health = 110.0
            move_speed = 105.0
            attack_damage = 27.0
            attack_range = 88.0
        _:
            max_health = 72.0
            move_speed = 150.0
            attack_damage = 19.0
            attack_range = 72.0
    health = max_health
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var capsule: CapsuleShape2D = CapsuleShape2D.new()
    capsule.radius = 18.0 if enemy_type!="shadow_knight" else 24.0
    capsule.height = 54.0 if enemy_type!="shadow_knight" else 72.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-capsule.height*0.5)
    add_child(shape_node)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health<=0.0 or not is_instance_valid(target):
        return

    attack_cooldown = maxf(0.0,attack_cooldown-delta)
    blink_cooldown = maxf(0.0,blink_cooldown-delta)
    stun_time = maxf(0.0,stun_time-delta)

    if not is_on_floor():
        velocity.y += 1900.0*delta

    if stun_time>0.0:
        attacking = false
        velocity.x = move_toward(velocity.x,0.0,1800.0*delta)
        move_and_slide()
        queue_redraw()
        return

    if attacking:
        windup = maxf(0.0,windup-delta)
        velocity.x = move_toward(velocity.x,0.0,1900.0*delta)
        if windup<=0.0:
            _execute_attack()
        move_and_slide()
        queue_redraw()
        return

    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y
    if absf(dx)>3.0:
        facing = signf(dx)

    if enemy_type=="arcane_eye":
        var desired: float = 300.0
        if absf(dx)>desired+55.0:
            velocity.x = move_toward(velocity.x,facing*move_speed,650.0*delta)
        elif absf(dx)<desired-55.0:
            velocity.x = move_toward(velocity.x,-facing*move_speed,650.0*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,900.0*delta)
        if absf(dx)<430.0 and absf(dy)<220.0 and attack_cooldown<=0.0:
            _begin_attack()
    else:
        if enemy_type=="void_sentry" and blink_cooldown<=0.0 and absf(dx)>280.0 and absf(dx)<640.0:
            global_position.x += facing*150.0
            blink_cooldown = 3.4
            sfx_requested.emit("phase_shift",-11.0,1.22)
            request_flash.emit(global_position+Vector2(0,-28),Color("#9d70c7"))

        if absf(dx)>attack_range:
            var accel: float = 1700.0 if enemy_type=="void_sentry" else 900.0
            velocity.x = move_toward(velocity.x,facing*move_speed,accel*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,1900.0*delta)
            if attack_cooldown<=0.0:
                _begin_attack()

    move_and_slide()
    queue_redraw()

func _begin_attack() -> void:
    attacking = true
    if enemy_type=="arcane_eye":
        windup = 0.38
        attack_cooldown = 1.45
    elif enemy_type=="shadow_knight":
        windup = 0.44
        attack_cooldown = 1.12
    else:
        windup = 0.22
        attack_cooldown = 0.90

func _execute_attack() -> void:
    attacking = false
    if not is_instance_valid(target):
        return

    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y

    if enemy_type=="arcane_eye":
        var direction: Vector2 = (target.global_position+Vector2(0,-28)-(global_position+Vector2(facing*18,-42))).normalized()
        var bolt: DarkBolt = DarkBolt.new().setup(global_position+Vector2(facing*20,-44),direction,500.0,attack_damage)
        get_parent().add_child(bolt)
        request_flash.emit(global_position+Vector2(0,-38),Color("#bf83df"))
        sfx_requested.emit("wizard_cast",-10.0,1.22)
        return

    if enemy_type=="void_sentry":
        velocity.x = facing*360.0

    if _can_melee_target(24.0):
        var knockback: float = 650.0 if enemy_type=="shadow_knight" else 390.0
        target.take_damage(attack_damage,signf(dx)*knockback,global_position)
        request_flash.emit(target.global_position+Vector2(0,-28),Color("#c78ee0"))
    sfx_requested.emit("enemy_attack",-8.0,0.70 if enemy_type=="shadow_knight" else 1.15)

func _can_melee_target(reach_bonus: float = 0.0) -> bool:
    if not is_instance_valid(target):
        return false
    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y
    var max_vertical: float = 82.0 if enemy_type=="shadow_knight" else 62.0
    if absf(dx) > attack_range+reach_bonus or absf(dy) > max_vertical:
        return false
    var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
        global_position+Vector2(0,-32),target.global_position+Vector2(0,-29),4,[get_rid()]
    )
    return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health<=0.0:
        return
    var resistance: float = 0.48 if enemy_type=="shadow_knight" else 0.82
    health = maxf(0.0,health-amount)
    velocity.x = knockback*resistance
    velocity.y = -140.0
    stun_time = maxf(stun_time,stun*(0.55 if enemy_type=="shadow_knight" else 1.0))
    attacking = false
    request_flash.emit(global_position+Vector2(0,-30),Color("#e1b0ef"))
    damage_text_requested.emit(global_position+Vector2(0,-84),"%d" % int(round(amount)),Color("#ead2f4"))
    if health<=0.0:
        collision_layer = 0
        sfx_requested.emit("enemy_down",-9.0,0.78)
        died.emit(self)
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,0.38)
        tween.tween_property(self,"scale",Vector2(1.26,0.56),0.38)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _draw() -> void:
    if attacking:
        draw_arc(Vector2(0,-32),44.0,-0.35,PI+0.35,20,Color(0.78,0.40,0.92,0.60),4.0)

    if enemy_type=="arcane_eye":
        draw_circle(Vector2(0,-42),24.0,Color("#4a3855"))
        draw_circle(Vector2(facing*4,-42),10.0,Color("#c08adf"))
        draw_circle(Vector2(facing*7,-42),4.0,Color("#f1d8ff"))
        draw_arc(Vector2(0,-42),31.0,0.0,TAU,24,Color(0.72,0.39,0.88,0.18),3.0)
        draw_line(Vector2(0,-15),Vector2(0,0),Color("#584766"),5.0)
    elif enemy_type=="shadow_knight":
        draw_polygon(PackedVector2Array([Vector2(-28,-66),Vector2(28,-66),Vector2(34,-5),Vector2(-34,-5)]),PackedColorArray([Color("#28232d")]))
        draw_circle(Vector2(0,-80),20.0,Color("#34303a"))
        draw_polygon(PackedVector2Array([Vector2(-21,-83),Vector2(21,-83),Vector2(15,-96),Vector2(-15,-96)]),PackedColorArray([Color("#4b4053")]))
        draw_line(Vector2(facing*20,-44),Vector2(facing*54,-9),Color("#8a7a91"),7.0)
        draw_circle(Vector2(facing*7,-80),4.0,Color("#ca82ee"))
    else:
        draw_polygon(PackedVector2Array([Vector2(-19,-49),Vector2(19,-49),Vector2(16,-4),Vector2(-16,-4)]),PackedColorArray([Color("#393044")]))
        draw_circle(Vector2(0,-61),13.0,Color("#54445f"))
        draw_line(Vector2(facing*13,-36),Vector2(facing*38,-8),Color("#8c6fa0"),5.0)
        draw_circle(Vector2(facing*5,-61),3.0,Color("#e0a8ff"))

    if health<max_health:
        var width: float = 66.0 if enemy_type!="shadow_knight" else 78.0
        var ratio: float = clampf(health/max_health,0.0,1.0)
        draw_rect(Rect2(-width*0.5,-104,width,5),Color(0.03,0.02,0.025,0.92))
        draw_rect(Rect2(-width*0.5,-104,width*ratio,5),Color("#9d66b8"))
