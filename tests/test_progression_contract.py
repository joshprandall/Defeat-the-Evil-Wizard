from pathlib import Path
import re

game = Path("scripts/game.gd").read_text(encoding="utf-8")

# The Memory Labyrinth is a rune-order puzzle. Arcane Shards are exploration
# rewards and must never be presented as a gate for this section.
assert 'var order: Array[String] = ["bell","moon","crown"]' in game
assert 'Activate BELL → MOON → CROWN' in game
assert 'SHARDS ARE OPTIONAL' in game
assert 'NEXT: %s' in game
assert 'if labyrinth_progress >= order.size():' in game
assert 'memory_gate.open_gate()' in game

shards = re.findall(r'_spawn_shard\("[^"]+",Vector2\(([-\d.]+),', game)
assert len(shards) == 5, f"Expected exactly five optional Arcane Shards, found {len(shards)}"
assert max(float(x) for x in shards) < 21450.0, "Arcane Shards unexpectedly became a Memory Labyrinth progression requirement"

# Wrong-order input must reset with an explicit recovery instruction instead of
# silently leaving the player wondering whether the game is stuck.
assert 'WRONG MEMORY  //  ORDER RESET: BELL → MOON → CROWN' in game

print("Progression contract passed: Memory Labyrinth is explicit and shards remain optional.")
