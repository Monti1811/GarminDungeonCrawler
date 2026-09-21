# Items

Item hierarchy, tiers, equipment, and spawn system.

## Item Hierarchy

```
Item (base)
  ├── EquippableItem
  │     ├── WeaponItem
  │     └── ArmorItem
  ├── ConsumableItem
  ├── KeyItem
  ├── Gold
  └── TreasureChest
```

## Item Types

| Type | Enum | Description |
|------|------|-------------|
| Weapon | `WEAPON` | Equippable, deals damage |
| Armor | `ARMOR` | Equippable, provides defense |
| Consumable | `CONSUMABLE` | Used once, removed from inventory |
| Key | `KEY` | Opens treasure chests |
| Custom | `CUSTOM` | Special items |

## Equipment Slots

| Slot | Enum | Typical Items |
|------|------|---------------|
| Right Hand | `RIGHT_HAND` | Swords, axes, bows, staves, daggers |
| Left Hand | `LEFT_HAND` | Shields, gauntlets, off-hand items |
| Chest | `CHEST` | Breast plates, chain mail |
| Head | `HEAD` | Helmets |
| Back | `BACK` | Cloaks, backpacks |
| Legs | `LEGS` | Leg armor |
| Feet | `FEET` | Boots, shoes |
| Accessory | `ACCESSORY` | Rings, amulets |
| Ammunition | `AMMUNITION` | Arrows, bolts |

## Weapon Types

| Type | Enum | Description |
|------|------|-------------|
| Melee | `MELEE` | Standard melee weapons |
| Two-Hand | `TWOHAND` | Occupies both hands |
| Ranged | `RANGED` | Uses ammunition |

## Attack Types

Each weapon has an `AttackType` that determines which attribute scales damage:

| Type | Attribute |
|------|-----------|
| `STRENGTH` | STR |
| `DEXTERITY` | DEX |
| `INTELLIGENCE` | INT |

## Defense Types

Each armor has a `DefenseType`:

| Type | Attribute |
|------|-----------|
| `CONSTITUTION` | CON |
| `WISDOM` | WIS |
| `CHARISMA` | CHA |

## Item Tiers

9 tiers with elemental theming:

| Tier | Name | Element | Weapon IDs | Armor IDs |
|------|------|---------|------------|-----------|
| 0 | Steel | None | 0-8 | 1000-1005 |
| 1 | Bronze | None | 10-18 | 1010-1015 |
| 2 | Fire | Fire | 20-28 | 1020-1025 |
| 3 | Ice | Ice | 30-38 | 1030-1035 |
| 4 | Grass | None | 40-48 | 1040-1045 |
| 5 | Water | None | 50-58 | 1050-1055 |
| 6 | Gold | None | 60-68 | 1060-1065 |
| 7 | Demon | None | 70-78 | 1070-1075 |
| 8 | Blood | None | 80-88 | 1080-1085 |

### Weapons per Tier

Each tier has up to 9 weapon types:
- Axe, Bow, Dagger, Greatsword, Katana, Lance, Spell, Staff, Sword

### Armor per Tier

Each tier has up to 6 armor pieces:
- BreastPlate, Gauntlets, Helmet, Ring1, Ring2, Shoes

### Special Equipment

- **Backpacks** -- Gold/Green/Purple variants (increase carry weight)
- **Shields** -- Gold/Silver/Steel/Wood (defense, left hand)
- **LifeAmulet** -- Accessory with health bonus
- **ManaCrystal** -- Accessory with mana bonus

## Consumables

| ID | Name | Effect |
|----|------|--------|
| 2000 | Health Potion | Restores health |
| 2001 | Greater Health Potion | Restores more health |
| 2002 | Max Health Potion | Full health restore |
| 2003 | Mana Potion | Restores mana |
| 2004 | Greater Mana Potion | Restores more mana |
| 2005 | Max Mana Potion | Full mana restore |

## Special Items

### Gold (ID: 5000)
- Currency pickup, adds to player gold
- Used at merchants to buy items

### Key (ID: 3000)
- Required to open treasure chests
- Consumed on use

### Treasure Chest (ID: 6000)
- Container item placed on the map
- Requires a key to open
- Wraps any loot item (weapon, armor, consumable)
- Visual states: closed, open_empty, open_full

## Spawn System

### Weight Categories

Items are spawned via weighted random across 5 categories:

| Category | Contents |
|----------|----------|
| Weapons | All weapon tiers |
| Armor | All armor tiers |
| Consumables | Health/mana potions |
| High-Quality | Rare weapons/armor |
| Merchant | Shop inventory |

### Treasure Chests

- 10% base chance for items to spawn wrapped in a chest
- 40% chance for high-quality items to be in a chest
- Chests require a key to open

### Depth Scaling

`ItemSpecificValues` provides depth-dependent spawn weights. Higher tiers become available at greater depths, with weight distributions shifting toward better items.

## Item Factory

`Items` module maps 150+ item IDs to concrete classes. Key methods:
- `createItemFromId(id)` -- creates specific item
- `createRandomWeightedItem(type)` -- selects from weighted tables
