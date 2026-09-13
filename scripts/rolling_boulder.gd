class_name RollingBoulder
extends CharacterBody2D

signal sfx_requested(id: String, volume_db: float, pitch: float)

var damage: float = 22.0
var lifetime: float = 5.0
var spin: float = 0.0
var hit_cooldown: float = 0.0

func setup(at: Vector2, horizontal_speed: float, amount: float) -> RollingBoulder:
    global_position = at
    velocity = Vector2(horizontal_speed,-120.0)
    damage = amount
    z_index = 5
    return self

func _ready() -> void:
    collision_layer = 0
    collision_mask = 1 | 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var circle: CircleShape2D = CircleShape2D.new()
    circle.radius = 20.0
    shape_node.shape = circle
    add_child(shape_node)
    queue_redraw()

func _physics_process(delta: float) -> void:
    lifetime -= delta
    hit_cooldown = maxf(0.0,hit_cooldown-delta)
    velocity.y += 1500.0*delta
    spin += velocity.x*delta*0.012
    move_and_slide()

    for i: int in range(get_slide_collision_count()):
        var collision: KinematicCollision2D = get_slide_collision(i)
        var body: Object = collision.get_collider()
        if body and body.has_method("take_damage") and hit_cooldown<=0.0:
            hit_cooldown = 0.6
            body.take_damage(damage,signf(velocity.x)*520.0,global_position)
            sfx_requested.emit("rock_impact",-6.0,0.86)
            queue_free()
            return

    if lifetime<=0.0 or global_position.y>760.0:
        queue_free()
    queue_redraw()

func _draw() -> void:
    draw_set_transform(Vector2.ZERO,spin,Vector2.ONE)
    draw_circle(Vector2.ZERO,20.0,Color("#62595b"))
    draw_line(Vector2(-13,-8),Vector2(9,12),Color("#3b3537"),4.0)
    draw_line(Vector2(-6,12),Vector2(12,-10),Color("#463e40"),3.0)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
