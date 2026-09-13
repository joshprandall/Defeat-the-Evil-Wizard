class_name DarkBolt
extends Area2D

var velocity := Vector2.ZERO
var damage := 18.0
var lifetime := 4.0
var pulse := 0.0

func setup(at: Vector2, direction: Vector2, speed := 430.0, amount := 18.0) -> DarkBolt:
    global_position = at
    velocity = direction.normalized() * speed
    damage = amount
    return self

func _ready() -> void:
    collision_layer = 0
    collision_mask = 1 | 4
    var shape_node := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 9.0
    shape_node.shape = circle
    add_child(shape_node)
    body_entered.connect(_on_body_entered)
    queue_redraw()

func _physics_process(delta: float) -> void:
    global_position += velocity * delta
    rotation = velocity.angle()
    lifetime -= delta
    pulse += delta * 12.0
    queue_redraw()
    if lifetime <= 0.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage, velocity.x * 0.35, global_position)
    queue_free()

func _draw() -> void:
    var halo := 14.0 + sin(pulse) * 2.5
    draw_circle(Vector2.ZERO, halo, Color(0.34,0.14,0.53,0.24))
    draw_circle(Vector2.ZERO, 10.0, Color(0.33,0.16,0.50,0.70))
    draw_circle(Vector2.ZERO, 5.5, Color("#e0a3ff"))
    draw_line(Vector2(-34,0), Vector2(-8,0), Color(0.55,0.2,0.75,0.35), 7.0)
    draw_line(Vector2(-50,0), Vector2(-18,0), Color(0.72,0.42,0.94,0.16), 3.0)
