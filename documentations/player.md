# Player

Player classes, attributes, leveling, and equipment.

## Attributes

7 core attributes, each affecting different stats:

| Attribute | Symbol | Affects |
|-----------|--------|---------|
| Strength | `:strength` | Melee attack damage |
| Constitution | `:constitution` | Max health, physical defense |
| Dexterity | `:dexterity` | Ranged attack, dodge chance |
| Intelligence | `:intelligence` | Magic attack, mana pool |
| Wisdom | `:wisdom` | Magic defense, mana regen |
| Charisma | `:charisma` | Merchant prices, NPC interactions |
| Luck | `:luck` | Critical hit chance, loot quality |

Attribute weights per equipment slot are defined in `Constants.ATTACK_ATTRIBUTE_WEIGHTS` and `Constants.DEFENSE_ATTRIBUTE_WEIGHTS`.

## Player Classes

### Warrior (ID: 0)
- **HP:** 150
- **HP/level:** +13
- **Starting gear:** Steel Axe + Steel Breast Plate
- **Attributes:** STR 14, CON 20, INT 1, WIS 2, DEX 1, CHA 3, LCK 4
- **Playstyle:** High health, strong melee. Tank-oriented.

### Mage (ID: 1)
- **HP:** 38
- **Mana:** 30
- **HP/level:** +8, Mana/level: +5
- **Starting gear:** Steel Staff + Steel Ring 1
- **Attributes:** STR 2, CON 3, INT 13, WIS 13, DEX 2, CHA 0, LCK 4
- **Playstyle:** Low health, magic damage. Has mana pool (second arc on HUD). Mana restores to 75% on dungeon transition.

### Archer (ID: 2)
- **HP:** (default from Player base)
- **HP/level:** +11
- **Starting gear:** Steel Bow + Steel Gauntlets + 20 Arrows
- **Attributes:** STR 14, CON 18, INT 4, WIS 4, DEX 48, CHA 14, LCK 7
- **Playstyle:** Extremely high DEX, ranged combat. Uses ammunition system.

### Nameless (ID: 3)
- **HP:** 150
- **Mana:** 15
- **HP/level:** +12, Mana/level: +4
- **Starting gear:** Steel Dagger + Life Amulet
- **Attributes:** All 13, LCK 5
- **Playstyle:** Balanced jack-of-all-trades. Has mana pool. Mana restores to 50% on dungeon transition.

### Paladin (ID: 4)
- **HP:** 85
- **HP/level:** +17
- **Starting gear:** Steel Dagger + Steel Shield + Steel Breast Plate
- **Attributes:** STR 4, CON 12, INT 1, WIS 4, DEX 4, CHA 3, LCK 4
- **Playstyle:** Highest HP growth. Defensive, shield-bearing tank.

### God (ID: 999)
- Debug/cheat class for testing.

## Health & Mana

- **Health** -- all classes have a health pool shown as red arc
- **Mana** -- Mage and Nameless have a mana pool shown as second arc
- **Dungeon transition:** HP partially restored (formula varies by class), mana partially restored

## Leveling

- Gained by killing enemies (`kill_experience` per enemy)
- `onLevelUp()` triggers class-specific bonuses (HP, mana)
- Level displayed in player details view

## Equipment

### Slots

| Slot | Description |
|------|-------------|
| `RIGHT_HAND` | Main weapon |
| `LEFT_HAND` | Shield or off-hand |
| `CHEST` | Body armor |
| `HEAD` | Helmet |
| `BACK` | Cape/backpack |
| `LEGS` | Leg armor |
| `FEET` | Boots |
| `ACCESSORY` | Ring/amulet |
| `AMMUNITION` | Arrows/bolts |

### Equip/Unequip

- **Slot conflicts** -- equipping to an occupied slot swaps items
- **Two-hand weapons** -- occupy both hands, unequips left hand
- **Ammunition stacking** -- arrows/bolts stack in inventory
- **Attribute bonuses** -- applied on equip, removed on unequip

### Inventory

- Weight-based system with max weight limit
- Items tracked by ID with quantity
- Sortable by name, value, or weight
