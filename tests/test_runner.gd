extends SceneTree

var failures := 0

func _initialize() -> void:
    _assert_close(CombatMath.clamp_health(90,100,20),100,"healing clamps at max")
    _assert_close(CombatMath.clamp_health(20,100,-50),0,"damage clamps at zero")
    _assert_close(CombatMath.mitigation(100,0.35),65,"barrier mitigation")
    _assert_true(CombatMath.probability_roll(0.5,0.49),"probability success")
    _assert_true(not CombatMath.probability_roll(0.5,0.5),"probability boundary")
    _assert_equal(CombatMath.boss_phase(620,620),1,"boss starts in phase one")
    _assert_equal(CombatMath.boss_phase(372,620),2,"phase two starts at sixty percent")
    _assert_equal(CombatMath.boss_phase(155,620),3,"phase three starts at twenty-five percent")
    _assert_close(CombatMath.cooldown_after(0.5,0.2),0.3,"cooldown decreases")
    _assert_close(CombatMath.cooldown_after(0.1,0.5),0.0,"cooldown clamps at zero")
    _assert_close(CombatMath.guarded_damage(100,0.48),48,"grave knight guard mitigation")
    _assert_true(CombatMath.shard_complete(5,5),"five shards completes set")
    _assert_true(not CombatMath.shard_complete(4,5),"partial shard set remains incomplete")
    _assert_close(CombatMath.arena_position_x(5000,6754,8066),6754,"boss cannot teleport left of arena")
    _assert_close(CombatMath.arena_position_x(9000,6754,8066),8066,"boss cannot teleport right of arena")
    _assert_close(CombatMath.arena_position_x(7550,6754,8066),7550,"valid boss position remains unchanged")
    _assert_close(CombatMath.vitality_after(160),184,"vitality blessing")
    _assert_close(CombatMath.might_after(1.0),1.12,"might blessing")
    _assert_close(CombatMath.swiftness_after(340),367.2,"swiftness blessing")
    _assert_close(CombatMath.rogue_shadow_gain(20),10.0,"rogue shadow gain")
    _assert_close(CombatMath.turn_acceleration(1000,true),1220,"reverse-direction acceleration boost")
    _assert_close(CombatMath.turn_acceleration(1000,false),1000,"normal acceleration unchanged")
    _assert_close(CombatMath.paladin_guard_damage(30,false),9.0,"paladin guard reduces damage")
    _assert_close(CombatMath.paladin_guard_damage(30,true),0.0,"perfect guard negates damage")
    _assert_true(CombatMath.woods_phase_two(250,540),"Briar Hart phase two threshold")
    _assert_close(CombatMath.archer_focus_gain(20),6.0,"archer focus on projectile hit")
    _assert_close(CombatMath.resilience_damage(50),45.0,"resilience damage reduction")
    _assert_true(CombatMath.keep_phase_two(345,690),"Drowned Castellan phase threshold")
    _assert_true(CombatMath.memory_rune_matches(0,"bell"),"memory puzzle begins with bell")
    _assert_true(CombatMath.memory_rune_matches(1,"moon"),"memory puzzle second rune")
    _assert_true(CombatMath.memory_rune_matches(2,"crown"),"memory puzzle final rune")
    _assert_true(not CombatMath.memory_rune_matches(0,"crown"),"wrong memory rune rejected")
    _assert_true(CombatMath.memory_gate_complete(3),"memory gate opens after three runes")
    _assert_close(CombatMath.barbarian_fury_gain(20),8.8,"barbarian Fury from melee hit")
    _assert_true(CombatMath.storm_vane_matches(5,1),"storm vane orientation wraps correctly")
    _assert_true(not CombatMath.storm_vane_matches(2,1),"wrong storm vane orientation rejected")
    _assert_close(CombatMath.renewal_heal(20),25.0,"Renewal blessing improves healing")
    _assert_true(CombatMath.ash_colossus_phase_two(410,820),"Ash Colossus phase threshold")
    _assert_close(CombatMath.fighter_momentum_gain(50),8.0,"Fighter Momentum from technical hit")
    _assert_true(CombatMath.mirror_orientation_matches(4,0),"mirror orientation wraps correctly")
    _assert_true(not CombatMath.mirror_orientation_matches(2,1),"incorrect mirror orientation rejected")
    _assert_close(CombatMath.steadfast_knockback(400),300.0,"Steadfast reduces knockback")
    _assert_true(CombatMath.obsidian_warden_phase(595,960)==2,"Obsidian Warden phase two threshold")
    _assert_true(CombatMath.obsidian_warden_phase(268,960)==3,"Obsidian Warden phase three threshold")
    _assert_close(CombatMath.monk_chi_gain(20),7.0,"Monk Chi from flowing combo")
    _assert_close(CombatMath.ascension_resource_floor(100),35.0,"Ascension starting resource floor")
    _assert_true(CombatMath.true_wizard_phase(981,1400,0)==1,"Crown Seal remains inactive above threshold")
    _assert_true(CombatMath.true_wizard_phase(979,1400,0)==2,"Crown Seal activates below threshold")
    _assert_true(CombatMath.true_wizard_phase(980,1400,0)==2,"True Wizard Crown Seal threshold")
    _assert_true(CombatMath.true_wizard_phase(532,1400,0)==3,"True Wizard Roads Return threshold")
    _assert_true(CombatMath.true_wizard_phase(196,1400,0)==4,"True Wizard Mortal Spell threshold")
    _assert_true(CombatMath.true_wizard_phase(400,1400,2)==2,"Crown Seal blocks phase three progression")
    _assert_close(CombatMath.crown_seal_damage(100,3),12.0,"Crown Seal damage mitigation")
    _assert_close(CombatMath.void_step_cost(1400),42.0,"True Wizard Void Step health cost")
    _assert_close(CombatMath.ranger_marked_damage(18),29.0,"Ranger third shot becomes Marked Quarry")
    _assert_close(CombatMath.ranger_hunt_gain(25),7.0,"Ranger gains Hunt from projectile damage")
    _assert_close(CombatMath.cleric_grace_gain(20),5.1,"Cleric gains Grace from melee damage")
    _assert_close(CombatMath.cleric_rejuvenation_heal(42),42.0,"Cleric Rejuvenation base heal")
    _assert_close(CombatMath.bard_tempo_gain(25),7.0,"Bard gains Tempo from resonant damage")
    _assert_close(CombatMath.druid_avatar_damage(100),68.0,"Druid Avatar reduces incoming damage")
    _assert_close(CombatMath.sorcerer_overcharge_multiplier(),1.42,"Sorcerer Overcharge multiplier")
    _assert_close(CombatMath.warlock_pact_health_cost(200),24.0,"Warlock Infernal Pact health cost")
    _assert_close(CombatMath.wizard_arcana_regen(2,true),28.0,"Wizard safe Arcana regeneration")
    _assert_close(CombatMath.crouch_capsule_height(),40.0,"Crouch collision height")
    _assert_close(CombatMath.standing_capsule_height(),58.0,"Standing collision height")
    _assert_close(CombatMath.difficulty_damage(100,"story"),70.0,"Story difficulty damage")
    _assert_close(CombatMath.difficulty_damage(100,"legend"),125.0,"Legend difficulty damage")
    if failures == 0:
        print("All combat-math tests passed.")
        quit(0)
    else:
        printerr("%d tests failed." % failures)
        quit(1)

func _assert_close(actual: float, expected: float, label: String) -> void:
    if absf(actual-expected) > 0.0001:
        failures += 1
        printerr("FAIL %s: got %s expected %s" % [label,actual,expected])

func _assert_true(value: bool, label: String) -> void:
    if not value:
        failures += 1
        printerr("FAIL %s" % label)

func _assert_equal(actual: int, expected: int, label: String) -> void:
    if actual != expected:
        failures += 1
        printerr("FAIL %s: got %s expected %s" % [label,actual,expected])
