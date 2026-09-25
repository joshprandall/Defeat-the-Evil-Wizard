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

    # A monster can overlap the hero because their collision masks intentionally
    # do not push each other apart. Point-blank contact must still be hittable.
    var point_blank := RealmEnemy.new().setup("crawler",Vector2(8,0),hero)
    world.add_child(point_blank)
    await physics_frame
    hero.facing = 1.0
    var point_blank_before := point_blank.health
    hero.call("_strike",18.0,62.0,44.0,0.0,0.0)
    _assert_true(point_blank.health < point_blank_before,"point-blank overlapping enemy is hittable")
    point_blank.queue_free()
    enemy.queue_free()
    await process_frame
    await physics_frame

    # Normal early enemies are deliberately a short encounter: three clean
    # Warrior light attacks must kill a crawler. Verify every health transition
    # so a future hit-detection regression cannot hide behind a final-state test.
    var ttk_enemy := RealmEnemy.new().setup("crawler",Vector2(34,0),hero)
    world.add_child(ttk_enemy)
    await physics_frame
    await physics_frame
    hero.global_position = Vector2(0,0)
    hero.facing = 1.0
    hero.combo_step = 0
    hero.combo_timer = 0.0
    hero.damage_multiplier = 1.0
    _assert_close(ttk_enemy.health,58.0,"crawler QA health budget")
    hero.call("_warrior_light_attack")
    _assert_close(ttk_enemy.health,40.0,"crawler health after light hit one")
    hero.call("_warrior_light_attack")
    _assert_close(ttk_enemy.health,18.0,"crawler health after light hit two")
    hero.call("_warrior_light_attack")
    _assert_close(ttk_enemy.health,0.0,"crawler health after light hit three")
    ttk_enemy.queue_free()
    await process_frame
    await physics_frame

    # The platform/wall obstruction rule must apply to every standard melee
    # enemy family, not only the Fallen Village enemies.
    var blocker := StaticBody2D.new()
    blocker.collision_layer = 4
    blocker.collision_mask = 0
    var blocker_shape := CollisionShape2D.new()
    var blocker_rect := RectangleShape2D.new()
    blocker_rect.size = Vector2(10,140)
    blocker_shape.shape = blocker_rect
    blocker.add_child(blocker_shape)
    blocker.global_position = Vector2(25,-30)
    world.add_child(blocker)
    await physics_frame
    await physics_frame

    var regional_enemies: Array[Node] = [
        ForestEnemy.new().setup("briarling",Vector2(0,0),hero),
        KeepEnemy.new().setup("drowned_guard",Vector2(0,0),hero),
        MountainEnemy.new().setup("ash_hound",Vector2(0,0),hero),
        TowerEnemy.new().setup("void_sentry",Vector2(0,0),hero),
    ]
    for regional_enemy: Node in regional_enemies:
        world.add_child(regional_enemy)
        await physics_frame
        hero.health = hero.max_health
        hero.invulnerable = 0.0
        hero.global_position = Vector2(50,0)
        var regional_before: float = hero.health
        regional_enemy.call("_execute_attack")
        _assert_close(hero.health,regional_before,"%s melee respects world obstruction" % regional_enemy.get_class())
        regional_enemy.queue_free()
        await process_frame

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
