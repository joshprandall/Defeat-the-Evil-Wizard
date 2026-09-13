# Work Handoff Brief

Use this file when handing the project to a long-running coding/work session.

## Mission

Build the production-quality vertical slice described in `GAME_DESIGN.md` without deleting the original Python prototype or rewriting `main` history.

## First priority

Make the Warrior controller and combat feel exceptional. Do not add more classes until the slice passes its feel gate.

## Required outcomes

1. Godot project opens without parser errors.
2. Warrior can move, jump, dash, attack, use two abilities, and spend an ultimate resource.
3. Three enemy archetypes are readable and fair.
4. Fallen Road slice has beginning, checkpoint, and boss arena.
5. Evil Wizard has multiple real mechanics, not descriptive placeholders.
6. Player death/restart works.
7. Automated headless tests pass.
8. No proprietary or employer data enters the repository.
9. All external assets have documented licenses.

## Do not

- Mechanically translate the old Python menu system.
- Build all fifteen classes before validating the first class.
- Add huge content volumes before movement/combat are tuned.
- Replace original project history.
- Depend on undocumented asset provenance.

## Current vertical-slice state — 0.2

The first polish pass now includes a title screen, pause/restart flow, camera impact response, gamepad defaults, floating damage text, procedural audio, enemy windups, animated hazards/atmosphere, checkpoint shrine feedback, boss arena gates, telegraphed Wizard spells, and a three-phase Wizard encounter.

Before adding class #2, run 0.2 in Godot 4.7.2 and record playtest feedback on movement, enemy tell timing, ability usefulness, audio mix, camera shake, and each Wizard phase. Fix parser/runtime errors before content expansion.
