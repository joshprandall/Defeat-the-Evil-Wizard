# Patch 0.4.1 — The Void Has a Price

The Evil Wizard's teleport/disappearance is now an intentional boss mechanic.

- Shadow Step now has a short visible disappearance window instead of an instantaneous relocation.
- While absent, the Wizard continuously loses health.
- The boss health bar updates during the disappearance so the cost is visible to the player.
- Reappearing displays the total health paid as `VOID COST`.
- The Wizard cannot be struck while fully vanished; the self-drain is the tradeoff.
- Encounter reset now restores visibility, collision, scale, opacity, velocity, and the original boss spawn position.
- This also makes the encounter more robust if a retry occurs after a teleport.
