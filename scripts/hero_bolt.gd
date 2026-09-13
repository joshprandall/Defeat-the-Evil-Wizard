class_name HeroBolt
extends Area2D

signal enemy_hit(amount: float)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var velocity: Vector2 = Vector2.ZERO
var damage: float = 20.0
var stun: float = 0.0
var lifetime: float = 2.8
var pulse: float = 0.0
var tint: Color = Color("#7acfff")
var visual_scale: float = 1.0
var pierces_remaining: int = 0
var hit_ids: Dictionary = {}
var impact_sfx: String = "hit"

func setup(at: Vector2, direction: Vector2, speed: float, amount: float, stun_seconds: float, color: Color, size_scale: float = 1.0, pierces: int = 0, impact_sound: String = "hit") -> HeroBolt:
    global_position = at
    velocity = direction.normalized() * speed
    damage = amount
    stun = stun_seconds
    tint = color
    visual_scale = size_scale
    pierces_remaining = maxi(0,pierces)
    impact_sfx = impact_sound
    return self

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2 | 4
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var circle: CircleShape2D = CircleShape2D.new()
    circle.radius = 8.0 * visual_scale
    shape_node.shape = circle
    add_child(shape_node)
    body_entered.connect(_on_body_entered)
    queue_redraw()

func _physics_process(delta: float) -> void:
    global_position += velocity * delta
    rotation = velocity.angle()
    lifetime -= delta
    pulse += delta * 14.0
    queue_redraw()
    if lifetime <= 0.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    var id: int = body.get_instance_id()
    if hit_ids.has(id):
        return
    hit_ids[id] = true

    if body.has_method("take_damage"):
        body.take_damage(damage,velocity.x*0.28,global_position,stun)
        enemy_hit.emit(damage)
        sfx_requested.emit(impact_sfx,-11.0,1.0)
        if pierces_remaining > 0:
            pierces_remaining -= 1
            return
    queue_free()

func _draw() -> void:
    var core: float = 5.5 * visual_scale
    var halo: float = (12.0 + sin(pulse) * 2.0) * visual_scale
    draw_circle(Vector2.ZERO, halo, Color(tint.r, tint.g, tint.b, 0.18))
    draw_circle(Vector2.ZERO, core + 3.0, Color(tint.r, tint.g, tint.b, 0.52))
    draw_circle(Vector2.ZERO, core, tint.lightened(0.28))
    draw_line(Vector2(-32.0 * visual_scale,0), Vector2(-7.0 * visual_scale,0), Color(tint.r,tint.g,tint.b,0.28), 6.0 * visual_scale)
