# Whispering Woods 0.7

## Campaign expansion

The Black Gate encounter is now revealed to be a projection of the Evil Wizard rather than the final confrontation. Defeating it opens the road into the Whispering Woods.

The new region adds:
- a distinct green/blue moonlit visual language,
- layered tree silhouettes,
- drifting fog,
- fireflies,
- glowing mushrooms,
- new traversal routes,
- three forest enemy archetypes,
- a Deepwood checkpoint,
- a third shrine blessing opportunity,
- the Briar Hart regional boss.

## Paladin

Paladin is the fourth playable champion and the first kit whose identity is built around receiving attacks deliberately.

### Divine Guard
The opening 0.22 seconds are a perfect-guard window:
- zero damage,
- Faith gain,
- dedicated hit feedback.

The remainder of the guard reduces incoming damage to 30%.

### Sacred Nova
Consumes Faith, heals the Paladin, damages nearby enemies, and applies knockback/stun.

### Judgment
Full-Faith ultimate:
- radial burst,
- healing,
- temporary Sacred Armor,
- strong crowd control.

## Visual production pipeline

`data/visuals/animation_manifest.json` is the first formal contract for replacing procedural champions with authored sprites.

Gameplay states and attack windows remain authoritative. Final animation will be fit to those timings, not the reverse.
