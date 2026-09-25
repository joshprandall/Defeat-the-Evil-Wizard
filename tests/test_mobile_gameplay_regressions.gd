extends SceneTree

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var world := Node2D.new()
    root.add_child(world)

    var hero := Hero.new()
    world.add_child(hero)
    hero.global_position = Vector2(50,0)

    var enemy := RealmEnemy.new().setup("crawler",Vector2(0,0),hero)
    world.add_child(enemy)

    var wall := StaticBody2D.new()
    wall.collision_layer = 4
    wall.collision_mask = 0
    var wall_shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = Vector2(10,120)
    wall_shape.shape = rectangle
    wall.add_child(wall_shape)
    wall.global_position = Vector2(25,-28)
    world.add_child(wall)

    await physics_frame
    await physics_frame

    var before := hero.health
    enemy.call("_execute_attack")
    _assert_close(hero.health,before,"world geometry blocks melee damage")

    wall.queue_free()
    await physics_frame
    await physics_frame

    hero.invulnerable = 0.0
    hero.global_position = Vector2(50,0)
    enemy.global_position = Vector2(0,0)
    before = hero.health
    enemy.call("_execute_attack")
    _assert_true(hero.health < before,"clear same-level melee can damage player")

    hero.health = hero.max_health
    hero.invulnerable = 0.0
    hero.global_position = Vector2(0,-82)
    enemy.global_position = Vector2(0,0)
    before = hero.health
    enemy.call("_execute_attack")
    _assert_close(hero.health,before,"vertical separation blocks melee through platforms")

    hero.global_position = Vector2(0,0)
    enemy.global_position = Vector2(50,0)
    hero.facing = 1.0
    hero.aim_direction = Vector2.LEFT
    var enemy_before := enemy.health
    hero.call("_strike",20.0,62.0,44.0,0.0,0.0)
    _assert_true(enemy.health < enemy_before,"melee follows facing when mouse aim is stale")

    enemy.queue_free()
    await physics_frame

    var tutorial := RealmEnemy.new().setup("crawler",Vector2(6,0),hero)
    tutorial.make_tutorial_enemy()
    world.add_child(tutorial)
    await physics_frame
    hero.global_position = Vector2(0,0)
    hero.facing = 1.0
    hero.call("_strike",18.0,62.0,44.0,0.0,0.0)
    _assert_close(tutorial.health,30.0,"point-blank enemy inside former dead zone takes damage")
    tutorial.global_position = Vector2(6,0)
    tutorial.velocity = Vector2.ZERO
    hero.call("_strike",18.0,62.0,44.0,0.0,0.0)
    tutorial.global_position = Vector2(6,0)
    tutorial.velocity = Vector2.ZERO
    hero.call("_strike",18.0,62.0,44.0,0.0,0.0)
    _assert_close(tutorial.health,0.0,"tutorial crawler dies in three ordinary light hits")

    world.queue_free()
    if failures == 0:
        print("Mobile gameplay regression tests passed.")
        quit(0)
        return
    printerr("%d mobile gameplay regression tests failed." % failures)
    quit(1)

func _assert_close(actual: float, expected: float, label: String) -> void:
    if absf(actual-expected) > 0.0001:
        failures += 1
        printerr("FAIL %s: got %s expected %s" % [label,actual,expected])

func _assert_true(value: bool, label: String) -> void:
    if not value:
        failures += 1
        printerr("FAIL %s" % label)
