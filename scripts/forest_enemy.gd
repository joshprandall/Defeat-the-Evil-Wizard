class_name ForestEnemy
extends CharacterBody2D

signal died(enemy: ForestEnemy)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var enemy_type: String = "briarling"
var max_health: float = 82.0
var health: float = 82.0
var move_speed: float = 130.0
var attack_damage: float = 15.0
var attack_range: float = 62.0
var attack_cooldown: float = 0.0
var windup_time: float = 0.0
var attack_pending: bool = false
var stun_time: float = 0.0
var facing: float = -1.0
var target: Hero
var hover_origin_y: float = 0.0
var life_time: float = 0.0

func setup(kind: String, at: Vector2, hero: Hero) -> ForestEnemy:
    enemy_type = kind
    global_position = at
    target = hero
    hover_origin_y = at.y
    match enemy_type:
        "gloom_moth":
            max_health = 44.0
            move_speed = 150.0
            attack_damage = 13.0
            attack_range = 330.0
        "root_guard":
            max_health = 92.0
            move_speed = 72.0
            attack_damage = 24.0
            attack_range = 82.0
        _:
            max_health = 66.0
            move_speed = 142.0
            attack_damage = 16.0
            attack_range = 62.0
    health = max_health
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var capsule: CapsuleShape2D = CapsuleShape2D.new()
    capsule.radius = 18.0 if enemy_type != "root_guard" else 24.0
    capsule.height = 50.0 if enemy_type != "root_guard" else 68.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-capsule.height*0.5)
    add_child(shape_node)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health <= 0.0 or not is_instance_valid(target):
        return
    life_time += delta
    attack_cooldown = maxf(0.0,attack_cooldown-delta)
    stun_time = maxf(0.0,stun_time-delta)

    if enemy_type != "gloom_moth" and not is_on_floor():
        velocity.y += 1900.0*delta

    if stun_time > 0.0:
        attack_pending = false
        windup_time = 0.0
        velocity.x = move_toward(velocity.x,0.0,1700.0*delta)
        move_and_slide()
        queue_redraw()
        return

    if attack_pending:
        windup_time = maxf(0.0,windup_time-delta)
        velocity.x = move_toward(velocity.x,0.0,2000.0*delta)
        if windup_time <= 0.0:
            _execute_attack()
        move_and_slide()
        queue_redraw()
        return

    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y
    if absf(dx) > 3.0:
        facing = signf(dx)

    if enemy_type == "gloom_moth":
        global_position.y = lerpf(global_position.y,hover_origin_y+sin(life_time*2.2)*28.0,minf(1.0,delta*4.0))
        var desired_gap: float = 255.0
        if absf(dx) > desired_gap+40.0:
            velocity.x = move_toward(velocity.x,facing*move_speed,850.0*delta)
        elif absf(dx) < desired_gap-45.0:
            velocity.x = move_toward(velocity.x,-facing*move_speed,850.0*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,900.0*delta)
        if absf(dx) < 390.0 and absf(dy) < 220.0 and attack_cooldown <= 0.0:
            _begin_attack()
    else:
        if absf(dx) > attack_range:
            velocity.x = move_toward(velocity.x,facing*move_speed,(1050.0 if enemy_type=="briarling" else 720.0)*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,1500.0*delta)
            if attack_cooldown <= 0.0:
                _begin_attack()

    move_and_slide()
    queue_redraw()

func _begin_attack() -> void:
    attack_pending = true
    if enemy_type == "gloom_moth":
        windup_time = 0.34
        attack_cooldown = 1.45
    elif enemy_type == "root_guard":
        windup_time = 0.52
        attack_cooldown = 1.35
    else:
        windup_time = 0.24
        attack_cooldown = 0.94

func _execute_attack() -> void:
    attack_pending = false
    windup_time = 0.0
    if not is_instance_valid(target):
        return
    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y

    if enemy_type == "gloom_moth":
        var direction: Vector2 = (target.global_position+Vector2(0,-28)-(global_position+Vector2(0,-28))).normalized()
        var bolt: DarkBolt = DarkBolt.new().setup(global_position+Vector2(facing*18,-28),direction,410.0,attack_damage)
        get_parent().add_child(bolt)
        request_flash.emit(global_position+Vector2(0,-28),Color("#7ddf9d"))
        sfx_requested.emit("wizard_cast",-12.0,1.34)
        return

    if enemy_type == "briarling":
        velocity.x = facing*345.0

    if absf(dx) <= attack_range+24.0 and absf(dy) < 110.0:
        var knockback: float = 510.0 if enemy_type=="root_guard" else 370.0
        target.take_damage(attack_damage,signf(dx)*knockback,global_position)
        request_flash.emit(target.global_position+Vector2(0,-28),Color("#99d56e"))
    sfx_requested.emit("enemy_attack",-9.0,0.78 if enemy_type=="root_guard" else 1.12)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health <= 0.0:
        return
    health = maxf(0.0,health-amount)
    velocity.x = knockback*(0.45 if enemy_type=="root_guard" else 0.85)
    if enemy_type != "gloom_moth":
        velocity.y = -150.0
    stun_time = maxf(stun_time,stun*(0.6 if enemy_type=="root_guard" else 1.0))
    attack_pending = false
    request_flash.emit(global_position+Vector2(0,-28),Color("#c9f6a7"))
    damage_text_requested.emit(global_position+Vector2(0,-72),"%d" % int(round(amount)),Color("#dff6ba"))
    if health <= 0.0:
        collision_layer = 0
        sfx_requested.emit("enemy_down",-9.0,1.08)
        died.emit(self)
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,0.32)
        tween.tween_property(self,"scale",Vector2(1.3,0.65),0.32)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _draw() -> void:
    if attack_pending:
        draw_arc(Vector2(0,-30),40.0,-0.4,PI+0.4,20,Color(0.70,1.0,0.44,0.64),4.0)

    if enemy_type == "gloom_moth":
        draw_circle(Vector2(0,-28),12.0,Color("#4f6a55"))
        draw_polygon(PackedVector2Array([Vector2(-7,-30),Vector2(-42,-48),Vector2(-30,-8),Vector2(-4,-20)]),PackedColorArray([Color("#66886f")]))
        draw_polygon(PackedVector2Array([Vector2(7,-30),Vector2(42,-48),Vector2(30,-8),Vector2(4,-20)]),PackedColorArray([Color("#66886f")]))
        draw_circle(Vector2(0,-28),26.0,Color(0.46,0.92,0.58,0.08))
        draw_circle(Vector2(facing*4,-30),3.0,Color("#d4ff9e"))
    elif enemy_type == "root_guard":
        draw_polygon(PackedVector2Array([Vector2(-27,-60),Vector2(26,-60),Vector2(34,-4),Vector2(-34,-4)]),PackedColorArray([Color("#40513e")]))
        draw_circle(Vector2(0,-74),24.0,Color("#344534"))
        draw_line(Vector2(-18,-82),Vector2(-42,-110),Color("#536348"),7.0)
        draw_line(Vector2(18,-82),Vector2(42,-110),Color("#536348"),7.0)
        draw_circle(Vector2(facing*8,-73),4.0,Color("#a4e46d"))
    else:
        draw_circle(Vector2(0,-28),22.0,Color("#4b613f"))
        for a: int in range(6):
            var angle: float = float(a)*TAU/6.0
            draw_line(Vector2(0,-28)+Vector2.from_angle(angle)*16.0,Vector2(0,-28)+Vector2.from_angle(angle)*31.0,Color("#728653"),5.0)
        draw_circle(Vector2(facing*7,-31),4.0,Color("#d1ee70"))

    if health < max_health:
        var width: float = 58.0 if enemy_type!="root_guard" else 72.0
        var ratio: float = clampf(health/max_health,0.0,1.0)
        draw_rect(Rect2(-width*0.5,-86,width,5),Color(0.02,0.04,0.03,0.9))
        draw_rect(Rect2(-width*0.5,-86,width*ratio,5),Color("#8cbf58"))
