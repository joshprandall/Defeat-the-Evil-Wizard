class_name RuneHazard
extends Area2D

var size := Vector2(150,24)
var occupants: Array[Node] = []
var cooldowns := {}
var pulse := 0.0

func setup(center: Vector2, hazard_size: Vector2) -> RuneHazard:
    position = center
    size = hazard_size
    return self

func _ready() -> void:
    collision_layer = 8
    collision_mask = 1
    var shape_node := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = size
    shape_node.shape = rect
    add_child(shape_node)
    body_entered.connect(_entered)
    body_exited.connect(_exited)
    queue_redraw()

func _physics_process(delta: float) -> void:
    pulse += delta * 4.0
    var expired := []
    for id in cooldowns:
        cooldowns[id] = maxf(0.0, float(cooldowns[id]) - delta)
        if float(cooldowns[id]) <= 0.0:
            expired.append(id)
    for id in expired:
        cooldowns.erase(id)
    for body in occupants.duplicate():
        if not is_instance_valid(body):
            occupants.erase(body)
            continue
        var id: int = body.get_instance_id()
        if not cooldowns.has(id) and body.has_method("take_damage"):
            body.take_damage(24.0, 0.0, global_position)
            cooldowns[id] = 0.72
    queue_redraw()

func _entered(body: Node) -> void:
    if body not in occupants:
        occupants.append(body)

func _exited(body: Node) -> void:
    occupants.erase(body)

func _draw() -> void:
    var r := Rect2(-size*0.5,size)
    var alpha := 0.34 + 0.10*sin(pulse)
    draw_rect(r, Color(0.35,0.05,0.12,alpha))
    draw_rect(Rect2(r.position,Vector2(r.size.x,3.0)),Color(0.88,0.18,0.30,0.30+0.16*sin(pulse)))
    for x in range(int(r.position.x)+10, int(r.end.x)-10, 30):
        draw_line(Vector2(x,r.end.y), Vector2(x+12,r.position.y), Color("#c13b57"), 3.0)
        draw_line(Vector2(x+12,r.position.y), Vector2(x+24,r.end.y), Color("#c13b57"), 3.0)
