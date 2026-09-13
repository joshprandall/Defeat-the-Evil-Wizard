class_name CollapsingMountainPlatform
extends AnimatableBody2D

signal sfx_requested(id: String, volume_db: float, pitch: float)

var platform_size: Vector2 = Vector2(170,28)
var target: Hero
var home_position: Vector2 = Vector2.ZERO
var armed: bool = false
var falling: bool = false
var timer: float = 0.0
var reset_timer: float = 0.0
var collision_shape: CollisionShape2D
var shake_time: float = 0.0
var fall_velocity: Vector2 = Vector2.ZERO

func setup(at: Vector2, size_value: Vector2 = Vector2(170,28), hero: Hero = null) -> CollapsingMountainPlatform:
    global_position = at
    home_position = at
    platform_size = size_value
    target = hero
    z_index = 2
    return self

func _ready() -> void:
    collision_layer = 4
    collision_mask = 0
    collision_shape = CollisionShape2D.new()
    var rect: RectangleShape2D = RectangleShape2D.new()
    rect.size = platform_size
    collision_shape.shape = rect
    add_child(collision_shape)
    queue_redraw()

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        var candidate: Node = get_tree().get_first_node_in_group("player_hero")
        if candidate is Hero:
            target = candidate as Hero

    if falling:
        fall_velocity.y += 1500.0*delta
        position += fall_velocity*delta
        reset_timer -= delta
        if reset_timer <= 0.0:
            falling = false
            armed = false
            timer = 0.0
            fall_velocity = Vector2.ZERO
            global_position = home_position
            collision_shape.set_deferred("disabled",false)
            modulate.a = 1.0
        queue_redraw()
        return

    if not is_instance_valid(target):
        return

    var local: Vector2 = target.global_position-global_position
    var standing: bool = absf(local.x) < platform_size.x*0.46 and local.y < -4.0 and local.y > -82.0 and target.is_on_floor()

    if standing and not armed:
        armed = true
        timer = 0.70
        shake_time = 0.70
        sfx_requested.emit("rock_crack",-10.0,1.0)

    if armed:
        timer -= delta
        shake_time = maxf(0.0,shake_time-delta)
        if timer <= 0.0:
            falling = true
            reset_timer = 3.4
            collision_shape.set_deferred("disabled",true)
            sfx_requested.emit("rock_break",-6.0,0.92)

    queue_redraw()

func _draw() -> void:
    var shake: float = sin(Time.get_ticks_msec()*0.035)*3.0 if armed and not falling else 0.0
    draw_rect(Rect2(Vector2(-platform_size.x*0.5+shake,-platform_size.y*0.5),platform_size),Color("#4a444b"))
    draw_line(Vector2(-platform_size.x*0.42+shake,-3),Vector2(platform_size.x*0.42+shake,-3),Color("#777077"),3.0)
    if armed:
        draw_line(Vector2(-18+shake,-10),Vector2(0+shake,8),Color("#1d1a20"),3.0)
        draw_line(Vector2(0+shake,8),Vector2(20+shake,-7),Color("#1d1a20"),3.0)
