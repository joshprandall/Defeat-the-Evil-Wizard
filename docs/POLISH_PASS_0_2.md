# Vertical Slice 0.2 — Polish Pass

## Purpose

Version 0.2 moves the rebuild from a mechanics proof into a small game-shaped experience. The purpose is not content quantity. The purpose is to evaluate feel, readability, pacing, and whether the Wizard encounter earns another production pass.

## Added systems

### Front end

- Title screen.
- Begin-game flow.
- Pause overlay.
- Restart and quit actions.
- Runtime camera-shake accessibility toggle.

### Combat feel

- Camera trauma on impacts.
- Floating damage numbers.
- Expanded hit burst visuals.
- Jump/dash/attack/ability/enemy/boss sound cues.
- Dash streaks.
- Landing squash.
- Slightly tuned jump apex and falling gravity.

### Enemy readability

Normal enemies now enter a visible windup state before contact damage is applied. The player can move or dash out of range during the tell and cause the attack to miss.

### Boss readability and escalation

The Evil Wizard now queues and telegraphs spells before execution.

Phase I establishes the vocabulary:
- Dark Bolt
- Spread volley
- Arcane Barrier
- Shadow Strike

Phase II begins at 60% health:
- faster action cadence
- more frequent summons
- Chaos volleys added
- faster teleport pacing

Phase III begins at 25% health:
- aggressive cast cadence
- frequent teleports
- five-projectile Chaos patterns
- shorter summon interval

The boss arena closes when entered and opens after victory.

### Atmosphere

The Fallen Road now includes:
- moving fog
- drifting embers
- expanded ruined silhouettes
- a more prominent Black Tower
- checkpoint shrine feedback
- original procedural ambience

## Playtest questions

1. Is normal movement enjoyable when no enemies are present?
2. Does the jump feel controllable both on a tap and a held press?
3. Is dash useful without trivializing every encounter?
4. Can enemy attacks be read before they hit?
5. Do attacks feel stronger because of sound, flash, knockback, damage text, and camera response?
6. Are Shield Bash and Whirlwind worth using instead of repeating the basic combo?
7. Does Rage reach Last Stand often enough to matter without becoming constant?
8. Does the boss clearly communicate what it is about to do?
9. Does each boss phase feel meaningfully more dangerous?
10. Is the encounter challenging enough to be exciting without feeling arbitrary?
11. Does the soundtrack add atmosphere without becoming distracting?
12. Would a player voluntarily replay the slice immediately after finishing it?

## Next gate

If the answers to the questions above are mostly positive, version 0.3 should focus on authored visual assets, character animation, stronger enemy archetype behaviors, and a second playable class rather than expanding level length.
