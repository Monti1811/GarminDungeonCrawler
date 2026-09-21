# Enemies

Enemy types, AI behavior, spawning, and difficulty scaling.

## Enemy Roster (38 types)

### Easy (early depths)

| ID | Name | Cost | Weight |
|----|------|------|--------|
| 0 | Frog | 3 | 8 |
| 1 | Bat | 7 | 8 |
| 3 | Orc | 5 | 8 |
| 4 | Imp | 5 | 8 |
| 5 | Skeleton | -- | -- |
| 7 | ZombieSmall | -- | -- |
| 25 | Goblin | -- | -- |
| 36 | ShadowStalker | 9 | 5 |
| 37 | GloomLurker | 10 | 6 |

### Normal (mid depths)

| ID | Name |
|----|------|
| 6 | Necromancer |
| 8 | Zombie |
| 28 | Chort |
| 29 | Bies |
| 32 | OrcMasked |
| 33 | OrcShaman |

### Hard (late depths)

| ID | Name |
|----|------|
| 9 | Wogol |
| 11 | DarkKnight |
| 27 | Demonolog |
| 31 | OrcArmored |
| 34 | OrcVeteran |
| 35 | Rokita |

### Bosses

| ID | Name |
|----|------|
| 2 | Demon |
| 10 | Ogre |
| 26 | Tentackle |

### Elementals (15 types)

Small variants (early depths):
- `ElementalAirSmall` (12), `ElementalEarthSmall` (13), `ElementalFireSmall` (14)
- `ElementalGoldSmall` (15), `ElementalGooSmall` (16), `ElementalPlantSmall` (30)
- `ElementalWaterSmall` (17)

Normal variants (mid-late depths):
- `ElementalAir` (18), `ElementalEarth` (19), `ElementalFire` (20)
- `ElementalGold` (21), `ElementalGoo` (22), `ElementalPlant` (23)
- `ElementalWater` (24)

## AI Behavior

Enemy AI is processed sequentially in `Turn.doTurn()`:

1. **Pathfinding** -- A* algorithm with Manhattan heuristic, capped at 200 iterations
2. **Movement** -- enemies move toward player along computed path
3. **Combat** -- attack when adjacent to player
4. **Special abilities** -- some enemies have unique behaviors:
   - **Necromancer** -- summons undead allies
   - **OrcShaman** -- heals nearby allies
   - **Teleport enemies** -- can teleport to random positions

**Energy system:** Each enemy has `energy_per_turn`. Actions cost energy; enemies with higher energy act more frequently.

**Cooldown system:** Enemies have attack cooldowns. After attacking, they must wait N turns before attacking again.

## Spawning

### Weighted Selection

Enemies are selected via weighted random from `dungeon_enemies` table. Each entry has:
- `id` -- enemy type ID
- `cost` -- difficulty budget cost
- `weight` -- spawn probability weight

### Budget System

`Main.createRandomEnemies()` allocates a difficulty budget per room:
- Budget increases with dungeon depth
- Stronger enemies cost more budget points
- Selection prefers enemies that fit within remaining budget
- Maximum 15 enemies per room (`Constants.MAX_ENEMIES_PER_ROOM`)

### Depth Scaling

`EnemySpecificValues` provides depth-dependent spawn weights. Different enemy types become available at different depths, with weight distributions shifting toward harder enemies as depth increases.

## Difficulty Scaling

Enemy stats scale with depth via `Enemy.setLevel(level)`:

| Stat | Scaling |
|------|---------|
| Damage | `ENEMY_DAMAGE_SCALE` per level |
| Health | `ENEMY_HEALTH_SCALE` per level |
| Kill XP | Fixed per enemy type |

## Combat Stats

| Stat | Description |
|------|-------------|
| `damage` | Base attack power |
| `armor` | Damage reduction |
| `current_health` / `max_health` | Health pool |
| `kill_experience` | XP awarded on death |
| `cooldown` | Turns between attacks |
| `energy_per_turn` | Action frequency |
| `level` | Scaled to dungeon depth |

## Element System

Elemental enemies deal bonus damage based on their element:
- **Fire** -- damage over time (burning)
- **Ice** -- slow/reduce energy regeneration

Player resistance to elements is derived from equipped armor (`ElementUtil`).
