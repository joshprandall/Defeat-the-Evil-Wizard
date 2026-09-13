# Patch v1.4.1 — World Edge Safety

## Runtime issue

A player could move or dash beyond the left edge of the world.

The camera was correctly limited to x = 0, but a Camera2D limit does **not** constrain a CharacterBody2D. The player therefore continued into negative world coordinates while the camera stayed behind, making the champion appear to disappear.

## Fix

Two independent protections were added.

### 1. Physical edge blockers

Invisible StaticBody2D-compatible platform blockers now sit just outside both world edges.

They stop normal walking, jumping, rolling, and dashing through the level boundary.

### 2. Hard coordinate fail-safe

Every game frame checks the champion's world position.

Playable horizontal range:

- minimum x: 48
- maximum x: 52720

If a future high-speed move, physics edge case, or new class ability crosses the physical blocker, the champion is immediately placed back at the safe edge and outward velocity is cancelled.

This protects both the left and right sides of the entire campaign.

## Player feedback

Attempting to force the left boundary displays:

`THE ROAD DOES NOT GO THAT WAY`

Attempting to force the far-right boundary displays:

`THE ROAD ENDS HERE`
