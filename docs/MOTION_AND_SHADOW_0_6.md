# Motion & Shadow 0.6

## Why this milestone exists

Before producing final character art, motion needs a stable contract. Animation should follow gameplay timing instead of forcing gameplay to conform to finished sprites.

The Hero now has a lightweight named animation-state layer. Procedural rendering uses it immediately, while future Sprite2D/AnimationTree content can consume the same states.

## Rogue

Rogue is the movement stress test.

His kit deliberately pushes:
- rapid reversals,
- short action locks,
- repeated dashes,
- a double jump,
- air correction,
- close-range burst,
- invulnerability timing.

If Warrior, Mage, and Rogue all feel distinct while sharing one Hero controller, the architecture is ready to support the remaining roster through data plus class-specific mechanics.

## Next visual gate

Do not commission/finalize all animation frames yet.

First lock:
1. run acceleration,
2. jump apex,
3. fall speed,
4. wall interaction,
5. dash distance,
6. attack cancel windows,
7. Rogue double-jump height,
8. class silhouette scale.

Then authored animation can be produced against stable timings.
