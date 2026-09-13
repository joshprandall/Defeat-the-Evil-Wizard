class_name HeroEcho
extends Node2D

var hero_class: String = "warrior"
var facing: float = 1.0
var tint: Color = Color("#8fdfff")
var life: float = 0.20
var max_life: float = 0.20

func setup(at: Vector2, class_id: String, direction: float, color: Color, duration: float = 0.20) -> HeroEcho:
    global_position = at
    hero_class = class_id
    facing = direction
    tint = color
    life = duration
    max_life = duration
    z_index = 2
    return self

func _process(delta: float) -> void:
    life = maxf(0.0, life - delta)
    if life <= 0.0:
        queue_free()
        return
    queue_redraw()

func _draw() -> void:
    var alpha: float = clampf(life / maxf(max_life,0.001),0.0,1.0) * 0.30
    var c: Color = Color(tint.r,tint.g,tint.b,alpha)
    draw_circle(Vector2(0,-50),12.0,c)
    if hero_class == "mage":
        draw_polygon(
            PackedVector2Array([Vector2(-20,-42),Vector2(19,-42),Vector2(27,2),Vector2(-28,2)]),
            PackedColorArray([c])
        )
    elif hero_class == "rogue":
        draw_polygon(
            PackedVector2Array([Vector2(-16,-42),Vector2(15,-42),Vector2(13,1),Vector2(-13,1)]),
            PackedColorArray([c])
        )
        draw_line(Vector2(facing*11,-29),Vector2(facing*34,-16),c,4.0)
        draw_line(Vector2(facing*7,-24),Vector2(facing*29,-5),c,3.0)
    elif hero_class == "paladin":
        draw_polygon(
            PackedVector2Array([Vector2(-20,-43),Vector2(20,-43),Vector2(17,-4),Vector2(-17,-4)]),
            PackedColorArray([c])
        )
        draw_circle(Vector2(-facing*28,-32),18.0,c)
        draw_line(Vector2(facing*13,-31),Vector2(facing*38,-8),c,5.0)
    elif hero_class == "archer":
        draw_polygon(
            PackedVector2Array([Vector2(-17,-42),Vector2(17,-42),Vector2(14,-4),Vector2(-14,-4)]),
            PackedColorArray([c])
        )
        draw_arc(Vector2(facing*25,-30),20.0,-1.3 if facing>0.0 else PI-1.3,1.3 if facing>0.0 else PI+1.3,16,c,3.0)
    elif hero_class == "barbarian":
        draw_polygon(
            PackedVector2Array([Vector2(-23,-45),Vector2(23,-45),Vector2(20,-4),Vector2(-20,-4)]),
            PackedColorArray([c])
        )
        draw_line(Vector2(facing*13,-33),Vector2(facing*45,-7),c,7.0)
        draw_circle(Vector2(facing*47,-5),10.0,c)
    elif hero_class == "fighter":
        draw_polygon(
            PackedVector2Array([Vector2(-18,-43),Vector2(18,-43),Vector2(15,-4),Vector2(-15,-4)]),
            PackedColorArray([c])
        )
        draw_circle(Vector2(-facing*18,-29),10.0,c)
        draw_line(Vector2(facing*13,-34),Vector2(facing*42,-10),c,5.0)
    elif hero_class == "monk":
        draw_polygon(
            PackedVector2Array([Vector2(-16,-42),Vector2(16,-42),Vector2(13,-4),Vector2(-13,-4)]),
            PackedColorArray([c])
        )
        draw_line(Vector2(facing*9,-31),Vector2(facing*28,-23),c,4.0)
        draw_line(Vector2(-facing*9,-31),Vector2(-facing*27,-22),c,4.0)
    elif hero_class == "ranger":
        draw_polygon(
            PackedVector2Array([Vector2(-18,-43),Vector2(18,-43),Vector2(15,-4),Vector2(-15,-4)]),
            PackedColorArray([c])
        )
        draw_arc(Vector2(facing*23,-31),22.0,-1.2 if facing>0.0 else PI-1.2,1.2 if facing>0.0 else PI+1.2,16,c,3.0)
    elif hero_class == "cleric":
        draw_polygon(
            PackedVector2Array([Vector2(-20,-44),Vector2(20,-44),Vector2(23,2),Vector2(-23,2)]),
            PackedColorArray([c])
        )
        draw_line(Vector2(facing*13,-35),Vector2(facing*38,-72),c,5.0)
        draw_circle(Vector2(facing*40,-76),6.0,c)
    else:
        draw_polygon(
            PackedVector2Array([Vector2(-19,-42),Vector2(18,-42),Vector2(15,-5),Vector2(-15,-5)]),
            PackedColorArray([c])
        )
        draw_line(Vector2(facing*15,-34),Vector2(facing*38,-17),c,5.0)
    draw_line(Vector2(-8,-4),Vector2(-10,16),c,7.0)
    draw_line(Vector2(8,-4),Vector2(10,16),c,7.0)
