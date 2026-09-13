# Patch 0.4.3 — Black Gate Stability

The actual cause of the Evil Wizard leaving the visible encounter was identified: the boss still carried arena bounds from an earlier, shorter level layout (`4300–5120`) while the Black Gate arena now lives around `6700–8120`.

That meant Shadow Step could correctly execute its own old clamp logic while moving the Wizard far outside the current arena.

## Fixes

- The game now derives the playable boss interval from the physical Black Gate positions.
- The Wizard receives those bounds when the encounter begins.
- Shadow Step destinations are constrained to the current arena.
- Reappearance always places the Wizard on the Black Gate floor.
- A runtime arena-integrity check clamps accidental horizontal escape.
- A fall failsafe returns the Wizard to the encounter if he ever drops below the world.
- Arena walls are taller and cannot be cleared by wall jumping.
- Summoning positions inherit the corrected bounds.
- Retry reset keeps the Wizard inside the configured arena.

## Shadow Step

The disappearance mechanic is retained intentionally.

A complete Shadow Step still costs 10% of the Wizard's maximum health, and the boss health bar drains while he is absent.
