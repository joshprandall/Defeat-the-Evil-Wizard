class_name TideBolt
extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 16.0
var lifetime: float = 3.0
var pulse: float = 0.0

func setup(at: Vector2, direction: Vector2, speed: float, amount: float) -> TideBolt:
    global_position = at
    velocity = direction.normalized()*speed
    damage = amount
    return self

func _ready() -> void:
    collision_layer = 0
    collision_mask = 1 | 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var circle: CircleShape2D = CircleShape2D.new()
    circle.radius = 9.0
    shape_node.shape = circle
    add_child(shape_node)
    body_entered.connect(_on_body_entered)
    queue_redraw()

func _physics_process(delta: float) -> void:
    global_position += velocity*delta
    rotation = velocity.angle()
    lifetime -= delta
    pulse += delta*13.0
    if lifetime <= 0.0:
        queue_free()
    queue_redraw()

func _on_body_entered(body: Node) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage,velocity.x*0.24,global_position)
    queue_free()

func _draw() -> void:
    draw_circle(Vector2.ZERO,16.0+sin(pulse)*2.0,Color(0.28,0.74,0.90,0.12))
    draw_circle(Vector2.ZERO,8.0,Color("#57bfd8"))
    draw_circle(Vector2.ZERO,4.0,Color("#c7f7ff"))
    draw_line(Vector2(-30,0),Vector2(-8,0),Color(0.35,0.78,0.92,0.28),5.0)
