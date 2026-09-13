# Patch v1.4.2 — Safe Story Dialogue

Story NPC conversations are now guaranteed safe narrative space.

## While dialogue is open

The gameplay SceneTree is paused. This freezes:
- normal enemies,
- bosses,
- enemy projectiles,
- hazards,
- physics,
- moving and collapsing platforms,
- the player character.

The HUD remains active, and the Game node temporarily uses `PROCESS_MODE_ALWAYS` solely so the player can press **E** to advance through the conversation.

## When dialogue ends

The world resumes only after the final line is dismissed.

The champion receives 0.45 seconds of temporary invulnerability after the conversation. This prevents an enemy that was already standing beside the player from landing a hit on the exact frame combat resumes.

## Pause-menu protection

ESC cannot open or toggle the normal pause menu during NPC dialogue, so it cannot accidentally resume the world.

## Design rule

Story conversations should never punish the player for reading them.
