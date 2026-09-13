# Progression 0.5

This milestone deliberately builds systems before adding another campaign region.

## Persistence
The save file lives in Godot's `user://` storage and contains only progression state. It does not attempt to serialize arbitrary scene nodes.

## Blessing philosophy
Shrine choices are permanent for the saved journey and mutually exclusive per blessing. With two current shrines, the player receives two of the three available blessings. Future regions can add additional shrine pools rather than endlessly stacking raw stats.

## Dialogue
`StoryNPC` is intentionally small: position, speaker, dialogue lines, target proximity, and visual presentation. The game owns input flow while the HUD owns dialogue display.

## Movement Lab
The movement lab is a developer/player testing space for tuning acceleration, air control, wall interaction, dash momentum, jump arc, and attack mobility before those values are locked to authored animation.
