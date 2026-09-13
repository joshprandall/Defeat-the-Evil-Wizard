# Patch 0.4.4 — Grave Knight Arena Timing

The first boss arena was sealing too early.

## Root cause

The Grave Knight encounter triggered at X=4560 while the left arena wall was at X=4635. That meant the wall could appear **in front of the player** before the player had actually entered the arena.

## Fix

- The Grave Knight trigger now fires at X=4860.
- The left wall remains at X=4635, so it rises about 225 pixels **behind** the player.
- The Grave Knight remains at X=5100, leaving the player roughly 240 pixels of approach space before reaching the boss.
- Arena positions are now named constants so future level-layout changes do not silently break the encounter timing.

The fight itself, boss balance, checkpoints, and final Evil Wizard encounter are unchanged.
