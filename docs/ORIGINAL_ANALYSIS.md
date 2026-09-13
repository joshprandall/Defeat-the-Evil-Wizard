# Original Prototype Analysis

Baseline reviewed: `main` at commit `ed3e1c449f6c12382bc64e37c50c0c5c013f8154`.

## What should survive

The original project already established the core identity:

- A named hero chosen from a large class roster.
- Distinct class fantasies and special abilities.
- An Evil Wizard with regenerative and disruptive powers.
- Randomness as a source of combat variation.
- Healing, statistics, victory, and defeat.
- A clear “hero versus final villain” premise.

Those concepts become the creative source material for the real-time game.

## What cannot survive unchanged

The existing implementation is a single command-line Python file. It is suitable as an OOP exercise but not as a game runtime architecture.

### Combat effects are frequently descriptive rather than mechanical

Several abilities print that an effect occurs but do not maintain state for that effect. Examples include fear, evasion, camouflage, shields, teleportation, and time manipulation.

### Returned bonus damage and applied damage diverge

Many methods call `attack()`, which immediately subtracts the base random damage from the target, then return `attack_result + bonus`. The caller receives the larger number, but the extra bonus is not automatically subtracted from target health. In a real-time combat system, one authoritative damage pipeline must own both calculation and application.

### Ability dispatch depends on method signatures and exception handling

The menu tries an ability with an opponent argument and catches `TypeError` to try again without one. That conflates intended zero-argument abilities with real coding errors. Production actions should use explicit ability data and a stable activation interface.

### Player turns are not consistently meaningful

Viewing stats, invalid input, or some non-damaging abilities can still allow the Wizard's full response turn. Healing accepts arbitrary positive integers without a finite resource. These rules are acceptable for a classroom menu but do not create fair, learnable action-game decisions.

### The class roster is wider than the implemented systems

The roster is a strength, but ninety bespoke buttons should not be implemented before there is a stable combat language. The rebuild standardizes each class around a basic attack, alternate attack, movement tool, two actives, ultimate, and passive.

### Balance is embedded directly in code

Health, attack values, bonus ranges, and ability lists are spread through constructors and methods. Production balance data belongs in resources/data files so it can be tuned without rewriting combat systems.

## Migration conclusion

Do not mechanically port the original file. Preserve it as the historical prototype, extract the class fantasies and villain mechanics, and rebuild the game around real-time state machines, hit detection, animation timing, data-driven abilities, deterministic damage rules, and testable systems.
