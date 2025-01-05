import Toybox.Lang;

class Player extends Entity {

	var current_health as Number = 100;
	var maxHealth as Number = 100;
	var name as String = "Player";
	var description as String = "The player character";
	var level as Number = 1;
	var experience as Number = 0;
	var next_level_experience as Number = 100;
	var attributes as Dictionary<Symbol, Number> = {
		:strength=> 0,
		:constitution=> 0,
		:dexterity=> 0,
		:intelligence=> 0,
		:wisdom=> 0,
		:charisma=> 0,
		:luck=> 0
	};
	var attribute_points as Number = 5;
	var inventory as Inventory = new Inventory(10);
	var equipped as Dictionary<ItemSlot, Item> = {
		HEAD => null,
		CHEST => null,
		BACK => null,
		LEGS => null,
		FEET => null,
		LEFT_HAND => null,
		RIGHT_HAND => null
	};
	var gold as Number = 0;
	var sprite as ResourceId = $.Rez.Drawables.Player;

	function initialize() {
		Entity.initialize();
	}

	function equipItem(item as Item, slot as ItemSlot, remove as Boolean?) as Boolean {
		if (equipped[slot] == null) {
			equipped[slot] = item;
			item.onEquipItem(me);
			if (remove) {
				inventory.remove(item);
			}
			return true;
		}
		return false;
	}

	function unequipItem(item as Item, slot as ItemSlot) as Boolean {
		if (equipped[slot] != null) {
			if (!inventory.isFull()) {
				inventory.add(item);
			} else if (!dropItem(item)) {
				return false;
			}
			equipped[slot].onUnequipItem(me);
			equipped.remove(slot);
			return true;
		}
		return false;
	}

	function getEquip(slot as ItemSlot) as Item? {
		return equipped[slot];
	}

	function pickupItem(item as Item) as Boolean {
		if (!inventory.isFull() && item.canBePickedUp(me)) {
			item.onPickupItem(me);
			if (equipped[item.slot] == null) {
				equipItem(item, item.slot, false);
			} else {
				inventory.add(item);
			}
			return true;
		}
		
		return true;
	}

	function addInventoryItem(item as Item) as Boolean {
		if (!inventory.isFull()) {
			inventory.add(item);
			return true;
		}
		return false;
	}

	function removeInventoryItem(item as Item) as Boolean {
		return inventory.remove(item) != null;
	}

	function getInventory() as Inventory {
		return inventory;
	}

	function onUseItem(item as Item) as Boolean {
		if (item.canBeUsed(me)) {
			item.onUseItem(me);
			return true;
		}
		return false;
	}

	function dropItem(item as Item) as Boolean {
		var dropped_item = inventory.remove(item);
		dropped_item.onDropItem(me);
		var room = getApp().getCurrentDungeon().getCurrentRoom();
		var player_pos = room.getPlayerPos();
		var new_item_pos = room.getNearbyFreePos(player_pos) as Point2D?;
		if (new_item_pos != null) {
			dropped_item.setPos(new_item_pos);
			room.addItem(dropped_item);
			return true;
		}
		return false;
	}

	function onLevelUp() as Void {
		level++;
	}

	function getLevel() as Number {
		return level;
	}

	function onDeath() as Void {

	}

	function onRevive() as Void {

	}

	function onGainExperience(amount as Number) as Void {
		experience += amount;
	}

	function onLoseExperience(amount as Number) as Void {
		experience -= amount;
	}

	function getExperience() as Number {
		return experience;
	}

	function getNextLevelExperience() as Number {
		return next_level_experience;
	}

	function getExperienceToNextLevel() as Number {
		return next_level_experience - experience;
	}

	function onGainHealth(amount as Number) as Void {
		current_health = MathUtil.floor(current_health + amount, maxHealth);
	}

	function onLoseHealth(amount as Number) as Void {
		current_health = MathUtil.ceil(current_health - amount, 0);
		if (current_health == 0) {
			onDeath();
		}
	}

	function getHealth() as Number {
		return current_health;
	}

	function getMaxHealth() as Number {
		return maxHealth;
	}

	function addToAttribute(attribute as Symbol, amount as Number) as Void {
		attributes[attribute] = MathUtil.floor(attributes[attribute] + amount, Constants.MAX_ATTRIBUTE_POINTS);
		onGainAttribute(attribute, amount);
	}

	function removeFromAttribute(attribute as Symbol, amount as Number) as Void {
		attributes[attribute] = MathUtil.ceil(attributes[attribute] - amount, Constants.MIN_ATTRIBUTE_POINTS);
		onLoseAttribute(attribute, amount);
	}

	function onGainAttribute(attribute as Symbol, amount as Number) as Void {

	}

	function onLoseAttribute(attribute as Symbol, amount as Number) as Void {

	}

	function setAttribute(attribute as Symbol, amount as Number) as Void {
		attributes[attribute] = amount;
	}

	function getAttribute(attribute as Symbol) as Number {
		return attributes[attribute];
	}

	function getAttributePoints() as Number {
		return attribute_points;
	}

	function setAttributePoints(points as Number) as Void {
		attribute_points = points;
	}


	function save(saveData as SaveData) {
		return saveData;
	}

	function load(saveData as SaveData) {
		return saveData;
	}

	function getSprite() as ResourceId {
		return sprite;
	}

	function setSprite(sprite as ResourceId) as Void {
		self.sprite = sprite;
	}

	function getAttack() as Number {
		var base_attack = attributes[:strength];
		var weapon_left = equipped[LEFT_HAND] as WeaponItem?;
		var weapon_right = equipped[RIGHT_HAND] as WeaponItem?;
		if (weapon_left != null) {
			base_attack += weapon_left.getAttack();
		}
		if (weapon_right != null) {
			base_attack += weapon_right.getAttack();
		}
		return base_attack;
	}

	function getDefense() as Number {
		var base_defense = attributes[:constitution];
		var armor_head = equipped[HEAD] as ArmorItem?;
		var armor_chest = equipped[CHEST] as ArmorItem?;
		var armor_back = equipped[BACK] as ArmorItem?;
		var armor_legs = equipped[LEGS] as ArmorItem?;
		var armor_feet = equipped[FEET] as ArmorItem?;

		if (armor_head != null) {
			base_defense += armor_head.getDefense();
		}
		if (armor_chest != null) {
			base_defense += armor_chest.getDefense();
		}
		if (armor_back != null) {
			base_defense += armor_back.getDefense();
		}
		if (armor_legs != null) {
			base_defense += armor_legs.getDefense();
		}
		if (armor_feet != null) {
			base_defense += armor_feet.getDefense();
		}

		return base_defense;
	}

	function takeDamage(damage as Number) as Boolean {
		var defense = getDefense();
		var damage_taken = damage - defense;
		if (damage_taken < 0) {
			damage_taken = 0;
		}
		onLoseHealth(damage_taken);
		if (current_health == 0) {
			onDeath();
			return true;
		}
		return false;
	}

	function getGold() as Number {
		return gold;
	}	

	function getRange() as [Numeric, RangeType] {
		var weapon_left = equipped[LEFT_HAND] as WeaponItem?;
		var weapon_right = equipped[RIGHT_HAND] as WeaponItem?;
		var range_left = 1;
		var range_right = 1;
		var range_type = SURROUNDING;
		if (weapon_left != null) {
			range_left = weapon_left.getRange();
		}
		if (weapon_right != null) {
			range_right = weapon_right.getRange();
		}
		if (range_left > range_right && weapon_left != null) {
			range_type = weapon_left.getRangeType() as RangeType;
			return [range_left, range_type];
		} else if (range_right >= range_left && weapon_right != null) {
			range_type = weapon_right.getRangeType() as RangeType;
			return [range_right, range_type];
		} else {
			return [1, SURROUNDING];
		}
	}

	function getDescription() as String {
		return description;
	}

}
