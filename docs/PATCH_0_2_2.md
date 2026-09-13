# Patch 0.2.2

Fixed a Godot parser error in `scripts/hazard.gd`.

- Explicitly typed the local instance ID as `int` because Godot could not infer the type from the duplicated occupant array during parsing.
- Gameplay behavior is unchanged.
