# Patch 0.2.1

Fixed three Godot GDScript UNUSED_PARAMETER warnings that were reported during project load.

- `player.gd`: renamed unused `source` parameter to `_source`.
- `wizard.gd`: renamed unused `source` parameter to `_source`.
- `wizard.gd`: renamed unused `stun` parameter to `_stun`.

The method signatures remain positionally compatible with existing calls; gameplay behavior is unchanged.
