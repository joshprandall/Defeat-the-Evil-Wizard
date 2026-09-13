# Roster Expansion v1.4

## Why this milestone exists

The campaign now has a beginning, middle, final dungeon, true Evil Wizard encounter, and epilogue.

The next major production need is to complete the champion roster without recreating the title-screen cutoff problem found during earlier runtime playtests.

v1.4 therefore does two things at once:

1. adds two more fully playable classes,
2. replaces the fixed all-at-once champion grid with a paged roster that can scale to all 15 original class identities.

## Champion Select redesign

The selection screen now shows **five champions per page**.

Current roster:
- Page 1: Warrior, Mage, Rogue, Paladin, Archer
- Page 2: Barbarian, Fighter, Monk, Ranger, Cleric

The underlying UI supports a future third page for the remaining five champions.

This keeps:
- character names readable,
- ability summaries readable,
- buttons at comfortable sizes,
- the screen entirely inside 1280×720,
- no scrolling required.

## Ninth champion — Ranger

Ranger is a hybrid hunter positioned between Archer's pure ranged spacing and the melee champions.

### Resource
**Hunt**

Hunt is earned by landing attacks and surviving pressure.

### Marked Quarry
Every third light shot becomes a stronger Marked Quarry shot with bonus damage and stun.

### Movement
**Trail Step**

A quick evasive dash with a visible afterimage.

### Kit
- Hunter Shot
- Hunter Sweep
- Aimed Shot
- Nature's Favor
- Predator's Focus

### Predator's Focus
Consumes full Hunt and grants a six-second 35% damage increase.

## Tenth champion — Cleric

Cleric is a sustain / holy burst champion.

### Resource
**Grace**

Grace is earned through melee combat, radiant projectile hits, taking damage, and Arcane Shards.

### Movement
**Sanctified Step**

A slower defensive dash with stronger invulnerability than a standard movement burst.

### Kit
- three-hit mace chain
- Radiant Bolt
- Smite
- Rejuvenation
- Divine Intervention

### Rejuvenation
Consumes Grace to restore 42 base health.

### Divine Intervention
Consumes full Grace and:
- heals the Cleric,
- grants temporary invulnerability,
- damages and stuns enemies in a large radius.

## Movement Lab

Keyboard shortcuts now include:
- 9 — Ranger
- 0 — Cleric

The legend was reflowed to remain readable.

## Audio

Five dedicated effects were added:
- Hunt Mark
- Nature's Favor
- Cleric Smite
- Rejuvenation
- Divine Intervention

## Additional polish

The Might blessing now correctly preserves temporary class-specific damage buffs for:
- Warrior Last Stand,
- Ranger Predator's Focus,
- Barbarian Berserk.

## Remaining class identities

All 15 original identities remain in the class data.

Still awaiting playable implementation after v1.4:
- Bard
- Druid
- Sorcerer
- Warlock
- Wizard

The selection UI already has room for them as Page 3.
