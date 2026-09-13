class_name CombatMath
extends RefCounted

static func clamp_health(current: float, maximum: float, delta: float) -> float:
    return clampf(current + delta, 0.0, maximum)

static func mitigation(raw_damage: float, reduction: float) -> float:
    return maxf(0.0, raw_damage) * (1.0 - clampf(reduction, 0.0, 1.0))

static func probability_roll(chance: float, sample: float) -> bool:
    return clampf(sample, 0.0, 0.999999) < clampf(chance, 0.0, 1.0)

static func boss_phase(current: float, maximum: float) -> int:
    if maximum <= 0.0:
        return 3
    var ratio := clampf(current / maximum, 0.0, 1.0)
    if ratio <= 0.25:
        return 3
    if ratio <= 0.60:
        return 2
    return 1

static func cooldown_after(value: float, delta: float) -> float:
    return maxf(0.0, value - maxf(0.0, delta))

static func guarded_damage(raw_damage: float, guard_multiplier: float = 0.48) -> float:
    return maxf(0.0,raw_damage) * clampf(guard_multiplier,0.0,1.0)

static func shard_complete(current: int, total: int) -> bool:
    return total > 0 and current >= total

static func arena_position_x(value: float, left_bound: float, right_bound: float) -> float:
    var left: float = minf(left_bound,right_bound)
    var right: float = maxf(left_bound,right_bound)
    return clampf(value,left,right)

static func vitality_after(base_health: float) -> float:
    return maxf(0.0,base_health) + 24.0

static func might_after(base_multiplier: float) -> float:
    return maxf(0.0,base_multiplier) * 1.12

static func swiftness_after(base_speed: float) -> float:
    return maxf(0.0,base_speed) * 1.08

static func rogue_shadow_gain(base_damage: float) -> float:
    return 8.0 + maxf(0.0,base_damage) * 0.10

static func turn_acceleration(base_accel: float, reversing: bool) -> float:
    return maxf(0.0,base_accel) * (1.22 if reversing else 1.0)

static func paladin_guard_damage(incoming: float, perfect: bool) -> float:
    if perfect:
        return 0.0
    return maxf(0.0,incoming)*0.30

static func woods_phase_two(current: float, maximum: float) -> bool:
    return maximum > 0.0 and current <= maximum*0.48

static func archer_focus_gain(hit_damage: float) -> float:
    return 4.0 + maxf(0.0,hit_damage)*0.10

static func resilience_damage(incoming: float) -> float:
    return maxf(0.0,incoming)*0.90

static func keep_phase_two(current: float, maximum: float) -> bool:
    return maximum > 0.0 and current <= maximum*0.50

static func memory_rune_matches(progress: int, rune_id: String) -> bool:
    var order: Array[String] = ["bell","moon","crown"]
    if progress < 0 or progress >= order.size():
        return false
    return rune_id == order[progress]

static func memory_gate_complete(progress: int) -> bool:
    return progress >= 3

static func barbarian_fury_gain(base_damage: float) -> float:
    return 7.0+maxf(0.0,base_damage)*0.09

static func storm_vane_matches(current_orientation: int, target_orientation: int) -> bool:
    return posmod(current_orientation,4)==posmod(target_orientation,4)

static func renewal_heal(base_heal: float) -> float:
    return maxf(0.0,base_heal)*1.25

static func ash_colossus_phase_two(current: float, maximum: float) -> bool:
    return maximum>0.0 and current<=maximum*0.50

static func fighter_momentum_gain(base_damage: float) -> float:
    return 4.5+maxf(0.0,base_damage)*0.07

static func mirror_orientation_matches(current_orientation: int, target_orientation: int) -> bool:
    return posmod(current_orientation,4)==posmod(target_orientation,4)

static func steadfast_knockback(base_knockback: float) -> float:
    return base_knockback*0.75

static func obsidian_warden_phase(current: float, maximum: float) -> int:
    if maximum<=0.0:
        return 1
    if current<=maximum*0.28:
        return 3
    if current<=maximum*0.62:
        return 2
    return 1

static func monk_chi_gain(base_damage: float) -> float:
    return 5.5+maxf(0.0,base_damage)*0.075

static func ascension_resource_floor(maximum: float) -> float:
    return maxf(0.0,maximum)*0.35

static func true_wizard_phase(current: float, maximum: float, seal_remaining: int = 0) -> int:
    if maximum<=0.0:
        return 1
    if current<=maximum*0.14:
        return 4
    if current<=maximum*0.38 and seal_remaining<=0:
        return 3
    if current<=maximum*0.70:
        return 2
    return 1

static func crown_seal_damage(base_damage: float, seal_remaining: int) -> float:
    return base_damage*0.12 if seal_remaining>0 else base_damage

static func void_step_cost(maximum: float) -> float:
    return maxf(0.0,maximum)*0.03

static func ranger_marked_damage(normal_damage: float) -> float:
    return maxf(0.0,normal_damage)*(29.0/18.0)

static func ranger_hunt_gain(projectile_damage: float) -> float:
    return 5.0+maxf(0.0,projectile_damage)*0.08

static func cleric_grace_gain(melee_damage: float) -> float:
    return 4.0+maxf(0.0,melee_damage)*0.055

static func cleric_rejuvenation_heal(base_heal: float) -> float:
    return maxf(0.0,base_heal)

static func bard_tempo_gain(base_damage: float) -> float:
    return 5.0+base_damage*0.08

static func druid_avatar_damage(base_damage: float) -> float:
    return base_damage*0.68

static func sorcerer_overcharge_multiplier() -> float:
    return 1.42

static func warlock_pact_health_cost(maximum: float) -> float:
    return maximum*0.12

static func wizard_arcana_regen(seconds: float, safe: bool = true) -> float:
    return seconds*(14.0 if safe else 8.0)

static func crouch_capsule_height() -> float:
    return 40.0

static func standing_capsule_height() -> float:
    return 58.0

static func difficulty_damage(base_damage: float, mode: String) -> float:
    if mode=="story":
        return base_damage*0.70
    if mode=="legend":
        return base_damage*1.25
    return base_damage
