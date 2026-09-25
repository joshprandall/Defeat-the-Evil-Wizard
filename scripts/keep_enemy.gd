class_name KeepEnemy
extends CharacterBody2D

signal died(enemy: KeepEnemy)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var enemy_type: String = "drowned_guard"
var max_health: float = 112.0
var health: float = 112.0
var move_speed: float = 95.0
var attack_damage: float = 20.0
var attack_range: float = 72.0
var attack_cooldown: float = 0.0
var windup_time: float = 0.0
var attack_pending: bool = false
var stun_time: float = 0.0
var facing: float = -1.0
var target: Hero

func setup(kind: String, at: Vector2, hero: Hero) -> KeepEnemy:
    enemy_type = kind
    global_position = at
    target = hero
    match enemy_type:
        "rune_caster":
            max_health = 60.0
            move_speed = 82.0
            attack_damage = 16.0
            attack_range = 340.0
        "crypt_leech":
            max_health = 44.0
            move_speed = 205.0
            attack_damage = 14.0
            attack_range = 50.0
        _:
            max_health = 88.0
            move_speed = 95.0
            attack_damage = 21.0
            attack_range = 78.0
    health = max_health
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var capsule: CapsuleShape2D = CapsuleShape2D.new()
    capsule.radius = 17.0 if enemy_type != "drowned_guard" else 22.0
    capsule.height = 48.0 if enemy_type != "drowned_guard" else 66.0
    shape_node.shape = capsule
    shape_node.position = Vector2(0,-capsule.height*0.5)
    add_child(shape_node)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if health <= 0.0 or not is_instance_valid(target):
        return
    attack_cooldown = maxf(0.0,attack_cooldown-delta)
    stun_time = maxf(0.0,stun_time-delta)
    if not is_on_floor():
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
        velocity.x = move_toward(velocity.x,0.0,1800.0*delta)
        if windup_time <= 0.0:
            _execute_attack()
        move_and_slide()
        queue_redraw()
        return

    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y
    if absf(dx) > 3.0:
        facing = signf(dx)

    if enemy_type == "rune_caster":
        var desired: float = 275.0
        if absf(dx) > desired+55.0:
            velocity.x = move_toward(velocity.x,facing*move_speed,650.0*delta)
        elif absf(dx) < desired-50.0:
            velocity.x = move_toward(velocity.x,-facing*move_speed,650.0*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,850.0*delta)
        if absf(dx) < 390.0 and absf(dy) < 170.0 and attack_cooldown <= 0.0:
            _begin_attack()
    else:
        if absf(dx) > attack_range:
            var accel: float = 1500.0 if enemy_type=="crypt_leech" else 800.0
            velocity.x = move_toward(velocity.x,facing*move_speed,accel*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,1700.0*delta)
            if attack_cooldown <= 0.0:
                _begin_attack()

    move_and_slide()
    queue_redraw()

func _begin_attack() -> void:
    attack_pending = true
    if enemy_type == "rune_caster":
        windup_time = 0.40
        attack_cooldown = 1.55
    elif enemy_type == "crypt_leech":
        windup_time = 0.16
        attack_cooldown = 0.82
    else:
        windup_time = 0.42
        attack_cooldown = 1.15

func _execute_attack() -> void:
    attack_pending = false
    windup_time = 0.0
    if not is_instance_valid(target):
        return

    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y

    if enemy_type == "rune_caster":
        var direction: Vector2 = (target.global_position+Vector2(0,-28)-(global_position+Vector2(0,-34))).normalized()
        var bolt: DarkBolt = DarkBolt.new().setup(global_position+Vector2(facing*18,-34),direction,430.0,attack_damage)
        get_parent().add_child(bolt)
        request_flash.emit(global_position+Vector2(0,-34),Color("#68c4dd"))
        sfx_requested.emit("wizard_cast",-11.0,0.88)
        return

    if enemy_type == "crypt_leech":
        velocity.x = facing*430.0

    if _can_melee_target(24.0):
        var knockback: float = 520.0 if enemy_type=="drowned_guard" else 300.0
        target.take_damage(attack_damage,signf(dx)*knockback,global_position)
        request_flash.emit(target.global_position+Vector2(0,-28),Color("#6dc6dc"))
    sfx_requested.emit("enemy_attack",-8.0,0.72 if enemy_type=="drowned_guard" else 1.22)

func _can_melee_target(reach_bonus: float = 0.0) -> bool:
    if not is_instance_valid(target):
        return false
    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y
    var max_vertical: float = 74.0 if enemy_type=="drowned_guard" else 58.0
    if absf(dx) > attack_range+reach_bonus or absf(dy) > max_vertical:
        return false
    var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
        global_position+Vector2(0,-30),target.global_position+Vector2(0,-29),4,[get_rid()]
    )
    return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health <= 0.0:
        return
    health = maxf(0.0,health-amount)
    velocity.x = knockback*(0.48 if enemy_type=="drowned_guard" else 0.82)
    velocity.y = -130.0
    stun_time = maxf(stun_time,stun*(0.62 if enemy_type=="drowned_guard" else 1.0))
    attack_pending = false
    request_flash.emit(global_position+Vector2(0,-30),Color("#a5edf2"))
    damage_text_requested.emit(global_position+Vector2(0,-78),"%d" % int(round(amount)),Color("#b9f4f6"))
    if health <= 0.0:
        collision_layer = 0
        sfx_requested.emit("enemy_down",-9.0,0.90)
        died.emit(self)
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,0.34)
        tween.tween_property(self,"scale",Vector2(1.28,0.60),0.34)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _draw() -> void:
    if attack_pending:
        draw_arc(Vector2(0,-30),39.0,-0.35,PI+0.35,20,Color(0.40,0.82,0.92,0.70),4.0)

    if enemy_type == "rune_caster":
        draw_polygon(PackedVector2Array([Vector2(-17,-43),Vector2(17,-43),Vector2(23,0),Vector2(-23,0)]),PackedColorArray([Color("#31444d")]))
        draw_circle(Vector2(0,-55),12.0,Color("#718a91"))
        draw_circle(Vector2(facing*5,-57),3.0,Color("#8be8f2"))
        draw_arc(Vector2(0,-32),30.0,0.0,TAU,22,Color(0.32,0.78,0.92,0.18),2.0)
    elif enemy_type == "crypt_leech":
        draw_circle(Vector2(0,-18),19.0,Color("#334f56"))
        draw_polygon(PackedVector2Array([Vector2(-20,-22),Vector2(-38,-8),Vector2(-19,-3)]),PackedColorArray([Color("#45656b")]))
        draw_circle(Vector2(facing*7,-21),4.0,Color("#8deaf1"))
    else:
        draw_polygon(PackedVector2Array([Vector2(-24,-58),Vector2(24,-58),Vector2(30,-5),Vector2(-30,-5)]),PackedColorArray([Color("#3c5057")]))
        draw_circle(Vector2(0,-69),20.0,Color("#4b6268"))
        draw_line(Vector2(facing*17,-40),Vector2(facing*45,-11),Color("#71868b"),7.0)
        draw_circle(Vector2(-facing*28,-38),17.0,Color("#52676d"))
        draw_circle(Vector2(facing*7,-70),4.0,Color("#8deaf1"))

    if health < max_health:
        var width: float = 62.0 if enemy_type!="drowned_guard" else 72.0
        var ratio: float = clampf(health/max_health,0.0,1.0)
        draw_rect(Rect2(-width*0.5,-94,width,5),Color(0.02,0.04,0.05,0.9))
        draw_rect(Rect2(-width*0.5,-94,width*ratio,5),Color("#68b9c8"))
