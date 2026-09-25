class_name MountainEnemy
extends CharacterBody2D

signal died(enemy: MountainEnemy)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var enemy_type: String = "ash_hound"
var max_health: float = 88.0
var health: float = 88.0
var move_speed: float = 155.0
var attack_damage: float = 17.0
var attack_range: float = 62.0
var attack_cooldown: float = 0.0
var windup: float = 0.0
var attacking: bool = false
var stun_time: float = 0.0
var facing: float = -1.0
var target: Hero

func setup(kind: String, at: Vector2, hero: Hero) -> MountainEnemy:
    enemy_type = kind
    global_position = at
    target = hero
    match enemy_type:
        "storm_shaman":
            max_health = 66.0
            move_speed = 78.0
            attack_damage = 17.0
            attack_range = 360.0
        "stone_raider":
            max_health = 96.0
            move_speed = 92.0
            attack_damage = 24.0
            attack_range = 82.0
        _:
            max_health = 68.0
            move_speed = 175.0
            attack_damage = 18.0
            attack_range = 62.0
    health = max_health
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var capsule: CapsuleShape2D = CapsuleShape2D.new()
    capsule.radius = 18.0 if enemy_type!="stone_raider" else 23.0
    capsule.height = 52.0 if enemy_type!="stone_raider" else 70.0
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
        attacking = false
        velocity.x = move_toward(velocity.x,0.0,1800.0*delta)
        move_and_slide()
        queue_redraw()
        return

    if attacking:
        windup = maxf(0.0,windup-delta)
        velocity.x = move_toward(velocity.x,0.0,1800.0*delta)
        if windup <= 0.0:
            _execute_attack()
        move_and_slide()
        queue_redraw()
        return

    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y
    if absf(dx) > 3.0:
        facing = signf(dx)

    if enemy_type=="storm_shaman":
        var desired: float = 280.0
        if absf(dx)>desired+50.0:
            velocity.x = move_toward(velocity.x,facing*move_speed,650.0*delta)
        elif absf(dx)<desired-45.0:
            velocity.x = move_toward(velocity.x,-facing*move_speed,650.0*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,900.0*delta)
        if absf(dx)<410.0 and absf(dy)<190.0 and attack_cooldown<=0.0:
            _begin_attack()
    else:
        if absf(dx)>attack_range:
            var accel: float = 1500.0 if enemy_type=="ash_hound" else 800.0
            velocity.x = move_toward(velocity.x,facing*move_speed,accel*delta)
        else:
            velocity.x = move_toward(velocity.x,0.0,1800.0*delta)
            if attack_cooldown<=0.0:
                _begin_attack()

    move_and_slide()
    queue_redraw()

func _begin_attack() -> void:
    attacking = true
    if enemy_type=="storm_shaman":
        windup = 0.40
        attack_cooldown = 1.55
    elif enemy_type=="stone_raider":
        windup = 0.46
        attack_cooldown = 1.18
    else:
        windup = 0.18
        attack_cooldown = 0.86

func _execute_attack() -> void:
    attacking = false
    if not is_instance_valid(target):
        return

    var dx: float = target.global_position.x-global_position.x
    var dy: float = target.global_position.y-global_position.y

    if enemy_type=="storm_shaman":
        var direction: Vector2 = (target.global_position+Vector2(0,-28)-(global_position+Vector2(facing*18,-42))).normalized()
        var bolt: DarkBolt = DarkBolt.new().setup(global_position+Vector2(facing*18,-42),direction,455.0,attack_damage)
        get_parent().add_child(bolt)
        request_flash.emit(global_position+Vector2(0,-40),Color("#c18bea"))
        sfx_requested.emit("wizard_cast",-10.0,1.12)
        return

    if enemy_type=="ash_hound":
        velocity.x = facing*470.0

    if absf(dx)<=attack_range+25.0 and absf(dy)<115.0:
        var knockback: float = 560.0 if enemy_type=="stone_raider" else 360.0
        target.take_damage(attack_damage,signf(dx)*knockback,global_position)
        request_flash.emit(target.global_position+Vector2(0,-28),Color("#e18c6f"))
    sfx_requested.emit("enemy_attack",-8.0,0.72 if enemy_type=="stone_raider" else 1.16)

func take_damage(amount: float, knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, stun: float = 0.0) -> void:
    if health<=0.0:
        return
    health = maxf(0.0,health-amount)
    velocity.x = knockback*(0.48 if enemy_type=="stone_raider" else 0.82)
    velocity.y = -140.0
    stun_time = maxf(stun_time,stun*(0.60 if enemy_type=="stone_raider" else 1.0))
    attacking = false
    request_flash.emit(global_position+Vector2(0,-30),Color("#f0b194"))
    damage_text_requested.emit(global_position+Vector2(0,-82),"%d" % int(round(amount)),Color("#ffd1b4"))
    if health<=0.0:
        collision_layer = 0
        sfx_requested.emit("enemy_down",-9.0,0.84)
        died.emit(self)
        var tween: Tween = create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,0.34)
        tween.tween_property(self,"scale",Vector2(1.30,0.58),0.34)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _draw() -> void:
    if attacking:
        draw_arc(Vector2(0,-32),42.0,-0.35,PI+0.35,20,Color(0.95,0.45,0.28,0.62),4.0)

    if enemy_type=="storm_shaman":
        draw_polygon(PackedVector2Array([Vector2(-18,-45),Vector2(18,-45),Vector2(24,0),Vector2(-24,0)]),PackedColorArray([Color("#4a3d52")]))
        draw_circle(Vector2(0,-57),12.0,Color("#b89c8c"))
        draw_line(Vector2(facing*13,-40),Vector2(facing*31,-79),Color("#74616e"),4.0)
        draw_circle(Vector2(facing*34,-84),6.0,Color("#c98ae7"))
        draw_arc(Vector2(0,-36),31.0,0.0,TAU,22,Color(0.68,0.36,0.80,0.16),2.0)
    elif enemy_type=="stone_raider":
        draw_polygon(PackedVector2Array([Vector2(-27,-63),Vector2(27,-63),Vector2(33,-5),Vector2(-33,-5)]),PackedColorArray([Color("#514b4d")]))
        draw_circle(Vector2(0,-75),21.0,Color("#6b6262"))
        draw_line(Vector2(facing*19,-42),Vector2(facing*46,-10),Color("#8e7c70"),8.0)
        draw_circle(Vector2(-facing*30,-38),17.0,Color("#5c5558"))
        draw_circle(Vector2(facing*7,-75),4.0,Color("#e49b74"))
    else:
        draw_circle(Vector2(0,-23),22.0,Color("#4a3b3d"))
        draw_polygon(PackedVector2Array([Vector2(-22,-24),Vector2(-38,-10),Vector2(-22,-3)]),PackedColorArray([Color("#665053")]))
        draw_polygon(PackedVector2Array([Vector2(22,-24),Vector2(38,-10),Vector2(22,-3)]),PackedColorArray([Color("#665053")]))
        draw_circle(Vector2(facing*8,-25),4.0,Color("#f0a06f"))

    if health<max_health:
        var width: float = 64.0 if enemy_type!="stone_raider" else 74.0
        var ratio: float = clampf(health/max_health,0.0,1.0)
        draw_rect(Rect2(-width*0.5,-96,width,5),Color(0.03,0.02,0.025,0.92))
        draw_rect(Rect2(-width*0.5,-96,width*ratio,5),Color("#c66f59"))
