"""
Module Project | Defeat the Evil Wizard
-----------------------------------------
OVERVIEW:
In this mini-project, I create a hero character and battle a powerful Evil Wizard. I use object-oriented programming (OOP)
concepts to extend the starter code, customize my character, and add new functionality. Through a dynamic, menu-driven system,
I control my character by choosing actions such as attacking, using special abilities, healing, and viewing stats. My goal
is to defeat the Evil Wizard by implementing clever game logic and strategy.

LEARNING OBJECTIVES:
- Practice OOP principles including inheritance and methods.
- Build an interactive, turn-based game with a clear menu system.
- Design engaging game logic that includes randomized attack damage, healing, and enemy interactions.

PROJECT REQUIREMENTS:
- Create multiple character classes (Warrior, Mage, Archer, Paladin, plus bonus classes).
- Each character has six unique special abilities.
- Include healing mechanics, randomized attack damage, and a turn-based battle system.
- The Evil Wizard regenerates health each turn and counterattacks.
- Display victory/defeat messages when the battle ends.

BONUS TASKS:
- Implement additional character classes with complex mechanics.
- Add six extra special abilities to the Evil Wizard (e.g., summoning minions, dark curses, shadow strikes, fear induction, arcane barriers, chaos blasts).
- Use extensive comments to explain my coding methods and thought process.

-----------------------------------------
STARTER CODE (Extended Below)
-----------------------------------------
"""

import random

# -----------------------------
# Base Character Class
# -----------------------------
class Character:
    def __init__(self, name, health, attack_power):
        """
        I initialize a character with a name, health, attack power, and set max_health.
        """
        self.name = name
        self.health = health
        self.attack_power = attack_power
        self.max_health = health

    def attack(self, opponent):
        """
        I perform a basic attack against the opponent with damage randomized within ±5 of my base attack power.
        """
        lower = max(0, self.attack_power - 5)
        upper = self.attack_power + 5
        damage = random.randint(lower, upper)
        opponent.health = max(0, opponent.health - damage)
        print(f"{self.name} attacks {opponent.name} for {damage} damage!")
        if opponent.health == 0:
            print(f"{opponent.name} has been defeated!")
        return damage

    def heal(self, amount):
        """
        I heal myself by a given amount without exceeding my maximum health.
        """
        if amount <= 0:
            print("Heal amount must be positive.")
            return
        self.health = min(self.max_health, self.health + amount)
        print(f"{self.name} heals for {amount}. Current health: {self.health}/{self.max_health}")

    def display_stats(self):
        """
        I display my current stats: health and attack power.
        """
        print(f"{self.name}'s Stats - Health: {self.health}/{self.max_health}, Attack Power: {self.attack_power}")

    def random_bonus(self, min_bonus, max_bonus):
        """
        I generate a random bonus value between min_bonus and max_bonus.
        """
        return random.randint(min_bonus, max_bonus)

# -----------------------------
# Evil Wizard Class (Enemy)
# -----------------------------
class EvilWizard(Character):
    def __init__(self, name):
        """
        I initialize the Evil Wizard with balanced health and attack power.
        """
        super().__init__(name, health=150, attack_power=15)

    def regenerate(self):
        """
        I regenerate a fixed amount of health (5 points) each turn.
        """
        regen_amount = 5
        self.health = min(self.max_health, self.health + regen_amount)
        print(f"{self.name} regenerates {regen_amount} health! (Health: {self.health}/{self.max_health})")

    # -----------------------------
    # Bonus: Extra Special Abilities for Evil Wizard
    # -----------------------------
    def summon_minions(self, opponent):
        """
        I summon minions to attack the opponent, dealing extra random bonus damage.
        """
        bonus = self.random_bonus(3, 10)
        print(f"{self.name} summons minions that swarm {opponent.name}!")
        return self.attack(opponent) + bonus

    def dark_curse(self, opponent):
        """
        I cast a dark curse that weakens the opponent's abilities.
        """
        print(f"{self.name} casts a Dark Curse on {opponent.name}, weakening their resolve!")
        # In a full implementation, I would modify opponent attributes temporarily.
        return

    def shadow_strike(self, opponent):
        """
        I deliver a devastating Shadow Strike that deals extra damage.
        """
        bonus = self.random_bonus(4, 12)
        print(f"{self.name} unleashes a Shadow Strike!")
        return self.attack(opponent) + bonus

    def fear_induction(self, opponent):
        """
        I induce fear in the opponent, potentially causing them to lose their next turn.
        """
        print(f"{self.name} instills terror in {opponent.name}! (Opponent might lose their next turn)")
        return

    def arcane_barrier(self):
        """
        I create an arcane barrier that heals me or protects me from the next attack.
        """
        heal_amount = self.random_bonus(5, 12)
        print(f"{self.name} conjures an Arcane Barrier, healing for {heal_amount}!")
        self.heal(heal_amount)
        return

    def chaos_blast(self, opponent):
        """
        I unleash a Chaos Blast that deals a chaotic burst of extra damage.
        """
        bonus = self.random_bonus(6, 15)
        print(f"{self.name} unleashes a Chaos Blast!")
        return self.attack(opponent) + bonus

# -----------------------------
# Predefined Character Classes: Warrior and Mage
# -----------------------------
class Warrior(Character):
    def __init__(self, name):
        # I define Warrior with high health and moderate attack power.
        super().__init__(name, health=140, attack_power=25)

class Mage(Character):
    def __init__(self, name):
        # I define Mage with lower health but high attack power.
        super().__init__(name, health=100, attack_power=35)

# -----------------------------
# New Character Classes: Archer and Paladin (Required)
# -----------------------------
class Archer(Character):
    def __init__(self, name):
        super().__init__(name, health=110, attack_power=20)

    # Six unique abilities for Archer
    def quick_shot(self, opponent):
        bonus = self.random_bonus(3, 8)
        print(f"{self.name} uses Quick Shot for a double arrow attack!")
        return (self.attack(opponent) * 2) + bonus

    def evade(self, opponent):
        print(f"{self.name} uses Evade to avoid the next attack!")
        return

    def precision_strike(self, opponent):
        bonus = self.random_bonus(4, 9)
        print(f"{self.name} delivers a Precision Strike!")
        return self.attack(opponent) + bonus

    def rapid_fire(self, opponent):
        total_damage = 0
        print(f"{self.name} unleashes Rapid Fire!")
        for _ in range(2):
            total_damage += self.attack(opponent)
        return total_damage

    def piercing_arrow(self, opponent):
        bonus = self.random_bonus(5, 10)
        print(f"{self.name} fires a Piercing Arrow that bypasses defenses!")
        return self.attack(opponent) + bonus

    def arrow_rain(self, opponent):
        total_damage = 0
        print(f"{self.name} unleashes an Arrow Rain!")
        for _ in range(3):
            total_damage += self.attack(opponent)
        return total_damage

class Paladin(Character):
    def __init__(self, name):
        super().__init__(name, health=130, attack_power=22)
        self.divine_shield_active = False

    # Six unique abilities for Paladin
    def holy_strike(self, opponent):
        bonus = self.random_bonus(6, 12)
        print(f"{self.name} uses Holy Strike!")
        return self.attack(opponent) + bonus

    def divine_shield(self, opponent):
        print(f"{self.name} activates Divine Shield to block the next attack!")
        self.divine_shield_active = True

    def sacred_aura(self, opponent):
        bonus = self.random_bonus(3, 8)
        print(f"{self.name} radiates a Sacred Aura, weakening {opponent.name}!")
        return self.attack(opponent) + bonus

    def smite_evil(self, opponent):
        bonus = self.random_bonus(7, 14)
        print(f"{self.name} smites evil in {opponent.name}!")
        return self.attack(opponent) + bonus

    def blessing(self):
        heal_amount = self.random_bonus(5, 10)
        print(f"{self.name} bestows a Blessing and heals for {heal_amount}.")
        self.heal(heal_amount)

    def righteous_charge(self, opponent):
        bonus = self.random_bonus(4, 10)
        print(f"{self.name} performs a Righteous Charge!")
        return self.attack(opponent) + bonus

# -----------------------------
# Bonus Character Classes (Additional 11 Classes)
# -----------------------------
class Barbarian(Character):
    def __init__(self, name):
        super().__init__(name, health=160, attack_power=30)

    def berserk(self, opponent):
        bonus = self.random_bonus(5, 15)
        print(f"{self.name} goes Berserk!")
        return self.attack(opponent) + bonus

    def war_cry(self, opponent):
        bonus = self.random_bonus(3, 10)
        print(f"{self.name} roars a mighty War Cry!")
        return self.attack(opponent) + bonus

    def rage(self, opponent):
        bonus = self.random_bonus(4, 12)
        print(f"{self.name} is consumed by Rage!")
        return self.attack(opponent) + bonus

    def smash(self, opponent):
        bonus = self.random_bonus(6, 14)
        print(f"{self.name} smashes {opponent.name} with brute force!")
        return self.attack(opponent) + bonus

    def intimidate(self, opponent):
        bonus = self.random_bonus(2, 8)
        print(f"{self.name} intimidates {opponent.name}!")
        return self.attack(opponent) + bonus

    def ground_slam(self, opponent):
        bonus = self.random_bonus(7, 16)
        print(f"{self.name} slams the ground, shaking {opponent.name}!")
        return self.attack(opponent) + bonus

class Bard(Character):
    def __init__(self, name):
        super().__init__(name, health=100, attack_power=18)

    def inspire(self, opponent):
        bonus = self.random_bonus(3, 9)
        print(f"{self.name} inspires allies with a rousing melody!")
        return self.attack(opponent) + bonus

    def distract(self, opponent):
        bonus = self.random_bonus(2, 8)
        print(f"{self.name} distracts {opponent.name} with a clever tune!")
        return self.attack(opponent) + bonus

    def serenade(self, opponent):
        bonus = self.random_bonus(4, 10)
        print(f"{self.name} serenades {opponent.name}!")
        return self.attack(opponent) + bonus

    def charm(self, opponent):
        bonus = self.random_bonus(3, 7)
        print(f"{self.name} charms {opponent.name} with charisma!")
        return self.attack(opponent) + bonus

    def rally(self, opponent):
        bonus = self.random_bonus(2, 6)
        print(f"{self.name} rallies with an uplifting song!")
        return self.attack(opponent) + bonus

    def echo_voice(self, opponent):
        bonus = self.random_bonus(5, 12)
        print(f"{self.name} uses an echoing voice to confuse {opponent.name}!")
        return self.attack(opponent) + bonus

class Cleric(Character):
    def __init__(self, name):
        super().__init__(name, health=120, attack_power=15)

    def smite(self, opponent):
        bonus = self.random_bonus(8, 16)
        print(f"{self.name} smites {opponent.name} with divine power!")
        return self.attack(opponent) + bonus

    def heal_self(self):
        heal_amount = self.random_bonus(10, 20)
        print(f"{self.name} calls upon divine mercy to heal!")
        self.heal(heal_amount)

    def divine_intervention(self, opponent):
        bonus = self.random_bonus(5, 12)
        print(f"{self.name} invokes divine intervention against {opponent.name}!")
        return self.attack(opponent) + bonus

    def sanctify(self, opponent):
        bonus = self.random_bonus(4, 10)
        print(f"{self.name} sanctifies the ground, weakening {opponent.name}!")
        return self.attack(opponent) + bonus

    def exorcise(self, opponent):
        bonus = self.random_bonus(7, 14)
        print(f"{self.name} exorcises evil from {opponent.name}!")
        return self.attack(opponent) + bonus

    def bless(self, opponent):
        bonus = self.random_bonus(3, 8)
        print(f"{self.name} blesses {opponent.name}, turning the tide!")
        return self.attack(opponent) + bonus

class Druid(Character):
    def __init__(self, name):
        super().__init__(name, health=115, attack_power=17)

    def nature_call(self, opponent):
        bonus = self.random_bonus(5, 12)
        print(f"{self.name} calls upon nature's fury!")
        return self.attack(opponent) + bonus

    def wild_shape(self, opponent):
        bonus = self.random_bonus(4, 10)
        print(f"{self.name} transforms into a beast!")
        return self.attack(opponent) + bonus

    def entangle(self, opponent):
        bonus = self.random_bonus(3, 9)
        print(f"{self.name} entangles {opponent.name} with vines!")
        return self.attack(opponent) + bonus

    def rejuvenate(self):
        heal_amount = self.random_bonus(8, 16)
        print(f"{self.name} is rejuvenated by nature!")
        self.heal(heal_amount)

    def earth_shock(self, opponent):
        bonus = self.random_bonus(6, 13)
        print(f"{self.name} unleashes an earth shock!")
        return self.attack(opponent) + bonus

    def storm_brew(self, opponent):
        bonus = self.random_bonus(7, 15)
        print(f"{self.name} conjures a storm!")
        return self.attack(opponent) + bonus

class Fighter(Character):
    def __init__(self, name):
        super().__init__(name, health=150, attack_power=28)

    def power_attack(self, opponent):
        bonus = self.random_bonus(5, 15)
        print(f"{self.name} executes a Power Attack!")
        return self.attack(opponent) + bonus

    def shield_bash(self, opponent):
        bonus = self.random_bonus(3, 10)
        print(f"{self.name} bashes {opponent.name} with a shield!")
        return self.attack(opponent) + bonus

    def parry(self):
        bonus = self.random_bonus(2, 8)
        print(f"{self.name} parries the incoming attack!")
        return bonus

    def riposte(self, opponent):
        bonus = self.random_bonus(4, 12)
        print(f"{self.name} ripostes after parrying!")
        return self.attack(opponent) + bonus

    def charge(self, opponent):
        bonus = self.random_bonus(6, 14)
        print(f"{self.name} charges at {opponent.name}!")
        return self.attack(opponent) + bonus

    def fortify(self):
        heal_amount = self.random_bonus(5, 10)
        print(f"{self.name} fortifies defenses and recovers!")
        self.heal(heal_amount)

class Monk(Character):
    def __init__(self, name):
        super().__init__(name, health=110, attack_power=24)

    def flurry(self, opponent):
        total_damage = 0
        print(f"{self.name} unleashes a flurry of strikes!")
        for _ in range(3):
            total_damage += self.attack(opponent)
        return total_damage

    def meditative_strike(self, opponent):
        bonus = self.random_bonus(3, 9)
        print(f"{self.name} channels inner peace into a meditative strike!")
        return self.attack(opponent) + bonus

    def swift_kick(self, opponent):
        bonus = self.random_bonus(2, 7)
        print(f"{self.name} delivers a swift kick!")
        return self.attack(opponent) + bonus

    def focus(self):
        bonus = self.random_bonus(1, 5)
        print(f"{self.name} focuses intensely, boosting attack power by {bonus} temporarily.")
        self.attack_power += bonus
        return bonus

    def inner_peace(self):
        heal_amount = self.random_bonus(4, 8)
        print(f"{self.name} achieves inner peace and heals for {heal_amount}.")
        self.heal(heal_amount)

    def acrobatic_dodge(self):
        print(f"{self.name} performs an acrobatic dodge, avoiding the next attack!")
        return

class Ranger(Character):
    def __init__(self, name):
        super().__init__(name, health=105, attack_power=22)

    def rapid_fire(self, opponent):
        total_damage = 0
        print(f"{self.name} unleashes rapid fire!")
        for _ in range(2):
            total_damage += self.attack(opponent)
        return total_damage

    def aim_shot(self, opponent):
        bonus = self.random_bonus(5, 12)
        print(f"{self.name} takes careful aim for a powerful shot!")
        return self.attack(opponent) + bonus

    def track(self):
        print(f"{self.name} meticulously tracks the enemy!")
        return

    def camouflage(self):
        print(f"{self.name} blends into the surroundings, reducing incoming damage!")
        return

    def double_strike(self, opponent):
        bonus = self.random_bonus(3, 7)
        print(f"{self.name} executes a double strike!")
        return self.attack(opponent) + bonus

    def natures_favor(self):
        heal_amount = self.random_bonus(3, 8)
        print(f"{self.name} calls upon nature's favor and heals for {heal_amount}.")
        self.heal(heal_amount)

class Rogue(Character):
    def __init__(self, name):
        super().__init__(name, health=95, attack_power=24)

    def backstab(self, opponent):
        bonus = self.random_bonus(7, 15)
        print(f"{self.name} performs a lethal backstab!")
        return self.attack(opponent) + bonus

    def stealth(self):
        print(f"{self.name} vanishes into the shadows, preparing for a critical strike!")
        return

    def disarm_trap(self):
        print(f"{self.name} skillfully disarms a trap!")
        return

    def evade(self):
        print(f"{self.name} dodges swiftly, avoiding the next attack!")
        return

    def critical_strike(self, opponent):
        bonus = self.random_bonus(5, 10)
        print(f"{self.name} lands a critical strike!")
        return self.attack(opponent) + bonus

    def quick_escape(self):
        print(f"{self.name} quickly escapes to a safer location!")
        return

class Sorcerer(Character):
    def __init__(self, name):
        super().__init__(name, health=90, attack_power=38)

    def arcane_blast(self, opponent):
        bonus = self.random_bonus(6, 12)
        print(f"{self.name} casts Arcane Blast!")
        return self.attack(opponent) + bonus

    def fireball(self, opponent):
        bonus = self.random_bonus(5, 15)
        print(f"{self.name} launches a Fireball!")
        return self.attack(opponent) + bonus

    def lightning_bolt(self, opponent):
        bonus = self.random_bonus(7, 14)
        print(f"{self.name} strikes with Lightning Bolt!")
        return self.attack(opponent) + bonus

    def frost_nova(self, opponent):
        bonus = self.random_bonus(3, 10)
        print(f"{self.name} unleashes Frost Nova!")
        return self.attack(opponent) + bonus

    def mana_surge(self):
        print(f"{self.name} experiences a surge of mana!")
        return

    def mystic_shield(self):
        print(f"{self.name} conjures a mystic shield to block incoming damage!")
        return

class Warlock(Character):
    def __init__(self, name):
        super().__init__(name, health=95, attack_power=36)

    def eldritch_blast(self, opponent):
        bonus = self.random_bonus(6, 13)
        print(f"{self.name} fires an Eldritch Blast!")
        return self.attack(opponent) + bonus

    def dark_pact(self):
        sacrifice = self.random_bonus(3, 7)
        print(f"{self.name} invokes Dark Pact, sacrificing {sacrifice} health!")
        self.health = max(0, self.health - sacrifice)
        return sacrifice

    def curse(self, opponent):
        bonus = self.random_bonus(4, 10)
        print(f"{self.name} casts a Curse on {opponent.name}!")
        return self.attack(opponent) + bonus

    def summon_familiar(self):
        print(f"{self.name} summons a familiar to aid in battle!")
        return

    def soul_drain(self, opponent):
        bonus = self.random_bonus(5, 12)
        print(f"{self.name} drains the soul of {opponent.name}!")
        damage = self.attack(opponent) + bonus
        heal_amount = bonus // 2
        self.heal(heal_amount)
        return damage

    def infernal_power(self, opponent):
        bonus = self.random_bonus(7, 15)
        print(f"{self.name} unleashes infernal power!")
        return self.attack(opponent) + bonus

class Wizard(Character):
    def __init__(self, name):
        super().__init__(name, health=85, attack_power=40)

    def magic_missile(self, opponent):
        bonus = self.random_bonus(5, 10)
        print(f"{self.name} fires a Magic Missile!")
        return self.attack(opponent) + bonus

    def teleport(self):
        print(f"{self.name} teleports to a strategic position!")
        return

    def shield_spell(self):
        print(f"{self.name} casts a Shield Spell to reduce incoming damage!")
        return

    def polymorph(self, opponent):
        bonus = self.random_bonus(3, 8)
        print(f"{self.name} casts Polymorph on {opponent.name}!")
        return self.attack(opponent) + bonus

    def time_warp(self):
        print(f"{self.name} warps time and gains an extra turn!")
        return

    def arcane_explosion(self, opponent):
        bonus = self.random_bonus(6, 12)
        print(f"{self.name} unleashes an Arcane Explosion!")
        return self.attack(opponent) + bonus

# -----------------------------
# Battle System and Menu
# -----------------------------
def create_character():
    """
    I prompt the user to choose a character class and enter their name.
    I return an instance of the chosen character.
    """
    print("1. Warrior")
    print("2. Mage")
    print("3. Archer")
    print("4. Paladin")
    print("5. Barbarian")
    print("6. Bard")
    print("7. Cleric")
    print("8. Druid")
    print("9. Fighter")
    print("10. Monk")
    print("11. Ranger")
    print("12. Rogue")
    print("13. Sorcerer")
    print("14. Warlock")
    print("15. Wizard")
    
    choice = input("Enter the number of your class choice: ").strip()
    name = input("Enter your character's name: ").strip()

    mapping = {
        '1': Warrior,
        '2': Mage,
        '3': Archer,
        '4': Paladin,
        '5': Barbarian,
        '6': Bard,
        '7': Cleric,
        '8': Druid,
        '9': Fighter,
        '10': Monk,
        '11': Ranger,
        '12': Rogue,
        '13': Sorcerer,
        '14': Warlock,
        '15': Wizard
    }
    cls = mapping.get(choice)
    if cls is None:
        print("Invalid choice. Defaulting to Warrior.")
        return Warrior(name)
    return cls(name)

def choose_special_ability(character, opponent):
    """
    I prompt the user to choose one of my character's special abilities.
    I map the character class to its 6 unique abilities and then call the chosen ability.
    """
    ability_mapping = {
        Archer: ["quick_shot", "evade", "precision_strike", "rapid_fire", "piercing_arrow", "arrow_rain"],
        Paladin: ["holy_strike", "divine_shield", "sacred_aura", "smite_evil", "blessing", "righteous_charge"],
        Barbarian: ["berserk", "war_cry", "rage", "smash", "intimidate", "ground_slam"],
        Bard: ["inspire", "distract", "serenade", "charm", "rally", "echo_voice"],
        Cleric: ["smite", "heal_self", "divine_intervention", "sanctify", "exorcise", "bless"],
        Druid: ["nature_call", "wild_shape", "entangle", "rejuvenate", "earth_shock", "storm_brew"],
        Fighter: ["power_attack", "shield_bash", "parry", "riposte", "charge", "fortify"],
        Monk: ["flurry", "meditative_strike", "swift_kick", "focus", "inner_peace", "acrobatic_dodge"],
        Ranger: ["rapid_fire", "aim_shot", "track", "camouflage", "double_strike", "natures_favor"],
        Rogue: ["backstab", "stealth", "disarm_trap", "evade", "critical_strike", "quick_escape"],
        Sorcerer: ["arcane_blast", "fireball", "lightning_bolt", "frost_nova", "mana_surge", "mystic_shield"],
        Warlock: ["eldritch_blast", "dark_pact", "curse", "summon_familiar", "soul_drain", "infernal_power"],
        Wizard: ["magic_missile", "teleport", "shield_spell", "polymorph", "time_warp", "arcane_explosion"]
    }
    cls = type(character)
    abilities = ability_mapping.get(cls)
    if not abilities:
        print("Your class does not have unique special abilities. Using normal attack instead.")
        return character.attack(opponent)

    print("\nChoose a special ability:")
    for idx, ability in enumerate(abilities, start=1):
        ability_name = ability.replace('_', ' ').title()
        print(f"{idx}. {ability_name}")
    
    try:
        choice = int(input("Enter the number of your ability choice: "))
        if 1 <= choice <= len(abilities):
            ability_method = getattr(character, abilities[choice - 1], None)
            if callable(ability_method):
                print()
                try:
                    result = ability_method(opponent)
                except TypeError:
                    result = ability_method()
                return result
            else:
                print("Selected ability not implemented.")
        else:
            print("Invalid ability number. No action taken.")
    except ValueError:
        print("Invalid input. Must be a number.")

def battle(player, wizard):
    """
    I run the turn-based battle between my hero and the Evil Wizard.
    In each turn, I choose an action, and then the Evil Wizard regenerates and counterattacks.
    """
    while wizard.health > 0 and player.health > 0:
        print("\n--- Your Turn ---")
        print("1. Normal Attack")
        print("2. Use Special Ability")
        print("3. Heal")
        print("4. View Stats")
        action = input("Choose an action: ").strip()

        if action == '1':
            player.attack(wizard)
        elif action == '2':
            choose_special_ability(player, wizard)
        elif action == '3':
            try:
                amount = int(input("Enter heal amount: "))
                player.heal(amount)
            except ValueError:
                print("Invalid heal amount. Please enter an integer.")
        elif action == '4':
            player.display_stats()
            wizard.display_stats()
        else:
            print("Invalid choice. Try again.")

        # Check if the Evil Wizard is defeated
        if wizard.health <= 0:
            print(f"\nThe Evil Wizard {wizard.name} has been defeated by {player.name}!")
            break

        print("\n--- Evil Wizard's Turn ---")
        wizard.regenerate()
        # I choose a random special ability from the Evil Wizard's bonus list
        evil_abilities = [
            wizard.summon_minions,
            wizard.dark_curse,
            wizard.shadow_strike,
            wizard.fear_induction,
            wizard.arcane_barrier,
            wizard.chaos_blast
        ]
        chosen_ability = random.choice(evil_abilities)
        try:
            chosen_ability(player)
        except TypeError:
            chosen_ability()
        if player.health <= 0:
            print(f"\n{player.name} has been defeated by the Evil Wizard {wizard.name}!")
            break

def main():
    """
    I run the main game loop.
    I introduce the adventure, create my hero, and then start the battle against the Evil Wizard.
    """
    # Exciting introduction to draw the player in
    print("Welcome, brave adventurer!")
    print("In this epic quest, you will choose a hero from an elite roster of champions, each with legendary abilities.")
    print("Your mission is to defeat the powerful Evil Wizard who threatens to plunge the realm into darkness.")
    print("Face challenging battles, master unique skills, and forge your destiny on the battlefield!")
    print("Good luck, and may your hero triumph over evil!\n")
    
    player = create_character()
    wizard = EvilWizard("The Dark Wizard")
    battle(player, wizard)
    print("Game Over.")

if __name__ == "__main__":
    main()
