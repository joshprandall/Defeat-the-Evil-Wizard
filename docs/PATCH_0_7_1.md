# Patch 0.7.1 — Champion Select Layout

## Root cause

The title screen attempted to place four champion cards in one horizontal row.

Each card used `_menu_button()`, whose shared minimum width is 400 pixels. Four cards therefore needed at least 1,600 pixels before margins and spacing, while the logical game canvas is 1,280 pixels wide.

## Fix

The selector is now a 2×2 grid:

- Warrior / Mage
- Rogue / Paladin

Each card is 458×168 with a 440-pixel Play button. The grid occupies 940 pixels and remains centered inside the 1,280×720 canvas.

The story hook and lower navigation were moved slightly upward. Gameplay is unchanged.
