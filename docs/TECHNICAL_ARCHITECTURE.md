# Technical Architecture

## Engine baseline

Godot 4.7.2, GDScript, 2D renderer. The current official Linux download page lists 4.7.2 as the stable Godot 4 release as of this rebuild start.

## System boundaries

### Character controller
Owns locomotion only: acceleration, friction, gravity, coyote time, jump buffer, dash, grounding, facing.

### Combat actor
Owns health, invulnerability, knockback, resource gain, death signals.

### Ability execution
Production abilities should derive from a stable activation interface and data resource. They should not depend on catching argument errors.

### Hit resolution
One authoritative damage application path. Damage calculation, mitigation, status application, hit reaction, resource gain, and event emission happen together.

### Enemy AI
Finite-state or behavior-tree style logic with explicit states: idle, investigate, chase, windup, attack, recover, stagger, dead.

### Boss director
Phase transitions and pattern selection live separately from generic health/damage logic.

### Data
Classes, abilities, enemies, items, and tuning values migrate to Godot Resources or validated JSON. `data/classes/classes.json` is the first schema sketch.

### Save system
Versioned save schema. Never serialize arbitrary live scene trees. Save only progression, settings, unlocks, checkpoint state, and run state.

## Physics layers

1. Player
2. Enemies
3. World
4. Hazards

Attack queries use masks rather than depending on render hierarchy.

## Testing strategy

- Pure calculations: headless tests.
- Data validation: every referenced ability/class/item ID exists and is unique.
- Scene smoke tests: load core scenes headlessly.
- Save migration tests: fixture saves from prior schema versions.
- Gameplay acceptance tests: manual controller/keyboard checklist for feel and readability.

## Performance budget

Target 60 FPS on ordinary integrated graphics at 1080p for the intended 2D scope. Avoid allocating large numbers of short-lived nodes every frame. Pool high-frequency projectiles/effects once content density requires it.

## Production repository layout

```text
scenes/
scripts/
data/
assets/
  characters/
  enemies/
  environments/
  vfx/
  ui/
  audio/
docs/
tests/
legacy/
```

## Migration rule

The original Python game remains historical source material. New runtime code does not import it. Reuse concepts, names, and validated mechanics—not the menu architecture.
