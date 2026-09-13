# Game Design Document — Defeat the Evil Wizard

## High concept

A responsive 2D dark-fantasy action-platformer/action-RPG in which one of fifteen hero classes crosses a corrupted realm, masters a compact class kit, defeats regional guardians, and climbs the Black Tower to confront the Evil Wizard in a multi-phase finale.

## Design pillars

1. **Movement must feel good before content expands.** Coyote time, buffered jumps, variable height, readable air control, responsive dash, and camera behavior are baseline requirements.
2. **Every class changes how the player solves combat.** Class identity is mechanical, not cosmetic.
3. **Enemies telegraph danger.** Difficulty comes from patterns, combinations, positioning, and resource pressure—not inflated health bars.
4. **The Wizard is present throughout the game.** He changes environments, speaks to the chosen class, and introduces mechanics before using their final forms in the last battle.
5. **A screenshot should be recognizable.** Strong silhouettes, ruined architecture, restrained color, magical contrast, layered depth, and readable effects define the visual language.

## Core loop

Explore → traverse → fight → discover → recover/upgrade → choose route or challenge → defeat guardian → advance toward the Black Tower.

## World structure

### Region I — The Fallen Village
Tutorial through environmental storytelling. Teaches movement, melee/ranged readability, checkpoint shrines, corruption hazards, and the first Wizard projection.

### Region II — The Whispering Woods
Vertical routes, moving foliage, illusion enemies, hidden paths, poison/corruption pressure.

### Region III — The Sunken Keep
Traps, armor, switches, gates, narrow combat rooms, environmental puzzles.

### Region IV — The Blighted Mountains
Wind, collapsing terrain, aerial enemies, long traversal chains, scarce recovery.

### Region V — The Wizard's Dominion
Rules begin to break: inverted rooms, repeated spaces, hostile magic, remixed enemies, strong narrative pressure.

### Finale — The Black Tower
Dense final ascent followed by a three-phase Wizard encounter.

## Combat language

Each hero has:

- Basic attack/combo.
- Heavy or alternate attack.
- Movement technique.
- Active ability 1.
- Active ability 2.
- Ultimate ability.
- Passive trait.

This creates six meaningful class features without menu-driven combat.

## Warrior vertical-slice kit

- Basic: three-hit sword chain.
- Heavy: charged cleave.
- Movement: dash/shoulder rush.
- Ability 1: Shield Bash — damage, displacement, short stun.
- Ability 2: Whirlwind — close-range multi-target answer.
- Ultimate: Last Stand — spends full Rage, heals a small amount, increases damage for a short window.
- Passive direction: Iron Resolve — future production version gains temporary armor under pressure.

## Progression

Keep progression compact. Shrines spend earned essence on permanent character improvements. Relics alter playstyle rather than providing tiny statistical increments.

Candidate relic examples:

- Ember Signet — burning enemies explode on defeat.
- Mirror Stone — a perfectly timed movement technique reflects a projectile.
- Broken Crown — higher outgoing damage at lower maximum health.
- Pilgrim Bell — checkpoint healing improves, but enemies become more aggressive after each shrine.

## Failure and recovery

Death returns the hero to the most recent shrine. Normal enemies reset by encounter policy. Bosses fully reset. The player should understand why they died and be back in control quickly.

## Difficulty

- Story — broader timing windows and reduced incoming damage.
- Adventure — intended tuning.
- Heroic — faster patterns, stronger encounter combinations, tighter recovery, no arbitrary health inflation.

## Boss philosophy

Bosses are exams on mechanics already taught in the region. New mechanics may appear, but never without readable anticipation.

## Evil Wizard final battle

### Phase I — The Architect
Teleportation, precise projectiles, Shadow Strike, controlled summons, Arcane Barrier.

### Phase II — The Usurper
Arena collapses. Faster casting. Multiple projectiles. Corrupted platforms. Summons become part of pattern combinations.

### Phase III — The Unbound
The Wizard sacrifices control for raw magic. Large telegraphed attacks reshape the arena; previously learned movement skills become essential.

## Replay value

- Fifteen class routes.
- Class-specific Wizard dialogue.
- Relic combinations.
- Optional rooms and guardians.
- Time/challenge trials after completion.

## Accessibility targets

- Full remapping for keyboard/controller.
- Hold/toggle choices where appropriate.
- Screen shake slider including zero.
- Flash reduction.
- Subtitle/caption support.
- High-contrast enemy telegraph mode.
- Adjustable text scale.
- Color-independent combat cues.
- Story difficulty without locking content.
