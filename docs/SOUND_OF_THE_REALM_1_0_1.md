# Sound of the Realm — v1.0.1

## Music system

The game now has a real contextual soundtrack rather than a single ambience loop.

### Exploration cues
- **Title Theme** — champion select and opening menu.
- **Fallen Village** — sparse dark-fantasy pulse and bell-like motifs.
- **Whispering Woods** — lighter, mysterious woodland texture.
- **Sunken Keep** — slower submerged masonry/drum character.
- **Memory Labyrinth** — restrained puzzle music with repeating memory motifs.
- **Blighted Mountains** — broader ascent music used when the player reaches the mountain approach.

### Combat cues
- **Boss Battle** — Grave Knight, Briar Hart, and Drowned Castellan.
- **Evil Wizard** — a distinct, more dissonant battle cue for the Black Gate shadow.

### Narrative cue
- **Cinematic Theme** — story interludes and cutscenes.

The `AudioDirector` automatically fades between region, boss, and cinematic music. Music restarts when its WAV reaches the end so every cue behaves as a loop without requiring imported loop metadata.

## New sound effects

- UI confirmation
- cinematic page advance
- Mara's bell
- correct rune
- wrong rune
- Memory Gate opening
- bow release
- arrow impact
- Paladin guard
- Paladin perfect guard
- water/flood impact
- spike trap hit
- crusher hit
- boss encounter sting

## Gameplay integration

- Archer now has actual bow-release and arrow-impact sounds.
- Paladin guard/parry has its own audio identity.
- Rune puzzles provide different correct/wrong feedback.
- The Memory Gate has a dedicated opening sound.
- Mara's first line is introduced by a quiet bell cue.
- Boss encounters receive a short sting before battle music takes over.
- Keep traps make impact sounds when they connect.
- Cinematic pages have subtle transition audio.
- The Movement Lab now includes music and combat effects, making it useful for sound tuning as well as motion tuning.
