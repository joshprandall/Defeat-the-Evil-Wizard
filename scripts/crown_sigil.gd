class_name CrownSigil
extends StaticBody2D

signal shattered(sigil: CrownSigil)
signal request_flash(at: Vector2, color: Color)
signal damage_text_requested(at: Vector2, text: String, color: Color)
signal sfx_requested(id: String, volume_db: float, pitch: float)

var max_health: float = 120.0
var health: float = 120.0
var pulse: float = 0.0
var sigil_id: int = 0

func setup(id: int, at: Vector2) -> CrownSigil:
    sigil_id = id
    global_position = at
    z_index = 5
    return self

func _ready() -> void:
    collision_layer = 2
    collision_mask = 0
    var shape_node: CollisionShape2D = CollisionShape2D.new()
    var circle: CircleShape2D = CircleShape2D.new()
    circle.radius = 24.0
    shape_node.shape = circle
    add_child(shape_node)
    queue_redraw()

func _process(delta: float) -> void:
    pulse += delta
    queue_redraw()

func take_damage(amount: float, _knockback: float = 0.0, _source: Vector2 = Vector2.ZERO, _stun: float = 0.0) -> void:
    if health<=0.0:
        return
    health=maxf(0.0,health-amount)
    request_flash.emit(global_position,Color("#e7b3fa"))
    damage_text_requested.emit(global_position+Vector2(0,-48),"%d" % int(round(amount)),Color("#eed4f8"))
    if health<=0.0:
        collision_layer=0
        sfx_requested.emit("sigil_shatter",-4.0,0.94+float(sigil_id)*0.04)
        shattered.emit(self)
        var tween: Tween=create_tween()
        tween.set_parallel(true)
        tween.tween_property(self,"modulate:a",0.0,0.48)
        tween.tween_property(self,"scale",Vector2(1.8,1.8),0.48)
        tween.chain().tween_callback(queue_free)
    queue_redraw()

func _draw() -> void:
    var ratio: float = clampf(health/max_health,0.0,1.0)
    var c: Color = Color("#c68ce5")
    draw_circle(Vector2.ZERO,34.0,Color(c.r,c.g,c.b,0.07+0.04*sin(pulse*3.2)))
    draw_arc(Vector2.ZERO,25.0,0.0,TAU,28,c,4.0)
    draw_polygon(
        PackedVector2Array([
            Vector2(-15,8),Vector2(-11,-11),Vector2(0,1),
            Vector2(11,-11),Vector2(15,8)
        ]),
        PackedColorArray([Color(c.r,c.g,c.b,0.32)])
    )
    draw_line(Vector2(-15,8),Vector2(15,8),c,3.0)
    draw_rect(Rect2(-26,37,52,5),Color(0.03,0.02,0.04,0.92))
    draw_rect(Rect2(-26,37,52*ratio,5),Color("#c88ce2"))
