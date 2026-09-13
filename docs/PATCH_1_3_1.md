# Patch v1.3.1 — Storm Vane clarity

## Runtime playtest finding

The Blighted Mountains correctly set the objective to align three Storm Vanes, but the objects visually read too much like environmental decoration.

A player could reach the vane section without realizing:
- the vanes were interactive,
- **E** rotates them,
- how many were already aligned.

## Changes

### Vane presentation
- interaction distance: 115px → 175px,
- larger mast and directional head,
- larger arcane ring,
- pulsing ground halo,
- world-space **E** beacon when in range,
- persistent check mark when correctly aligned.

### HUD feedback
A new contextual puzzle tracker reports:
- puzzle name,
- current completion count,
- total required objects,
- short interaction reminder.

### Rotation feedback
Correct alignment:
- uses the positive rune chime,
- announces `VANE LOCKED`.

Incorrect orientation:
- retains the wind feedback,
- announces `VANE TURNED`.

### Control legend
The controls legend now occupies a compact 34px bottom footer instead of floating higher inside the gameplay area.

### Interaction prompt
The interaction prompt is now placed at y=548–596 inside a dark translucent panel, well above the footer.

## Design principle

Environmental puzzles must visually communicate three things:
1. **this object matters,**
2. **this object can be interacted with,**
3. **the interaction caused a meaningful state change.**

This patch applies that rule to Storm Vanes and adds infrastructure that also benefits the Arcane Mirror and Crown Sigil encounters.
