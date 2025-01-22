import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class Player extends Entity {

	var id = 0;
	var current_health as Number = 100;
	var maxHealth as Number = 100;
	var second_bar as Symbol?;
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
		RIGHT_HAND => null,
		ACCESSORY => null,
		AMMUNITION => null,
	};
	var gold as Number = 0;
	var sprite as ResourceId = $.Rez.Drawables.Player;
	var pos as Point2D = [0, 0];

	function initialize() {
		Entity.initialize();
	}

	function hashCode() {
		return id;
	}

	function equipItem(item as Item, slot as ItemSlot, remove as Boolean?) as Boolean {
		// Try to unequip item if slot is already equipped
		if (equipped[slot] != null) {
			var success = unequipItem(slot);
			if (!success) {
				return false;
			}
		}
		if (equipped[slot] == null) {
			if (remove) {
				item = inventory.remove(item);
			}
			equipped[slot] = item;
			item.onEquipItem(me);
			return true;
		}
		return false;
	}

	function unequipItem(slot as ItemSlot) as Boolean {
		var item = equipped[slot];
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
		if (item.canBePickedUp(me)) {
			if (item instanceof EquippableItem && equipped[item.slot] == null) {
				equipItem(item, item.slot, false);
				item.onPickupItem(me);
				return true;
			} else if (!inventory.isFull()) {
				inventory.add(item);
				item.onPickupItem(me);
				return true;
			}
		}
		return false;
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
		// Case where item was equipped and could not be added to inventory as it was full
		if (dropped_item == null) {
			dropped_item = item;
		}
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

	function deleteItem(item as Item) as Boolean {
		return inventory.remove(item) != null;
	}

	function onLevelUp() as Void {
		level++;
		experience -= next_level_experience;
		next_level_experience = level * 100;
		attribute_points += 5;
	}

	function getLevel() as Number {
		return level;
	}

	function onDeath() as Void {
		WatchUi.pushView(new DCGameOverView(), new DCGameOverDelegate(), WatchUi.SLIDE_UP);
	}

	function onRevive() as Void {

	}

	function onGainExperience(amount as Number) as Void {
		experience += amount;
		while (experience >= next_level_experience) {
			onLevelUp();
		}
	}

	function onLoseExperience(amount as Number) as Void {
		experience -= amount;
		if (experience < 0) {
			experience = 0;
		}
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

	function getCurrentMana() as Number {
		return 0;
	}

	function getMaxMana() as Number {
		return 0;
	}

	function getManaPercent() as Float {
		return 0.0;
	}

	function doManaDelta(amount as Number) as Void {
	}

	function onGainHealth(amount as Number) as Void {
		current_health = MathUtil.floor(current_health + amount, maxHealth);
	}

	function onLoseHealth(amount as Number) as Void {
		Toybox.System.println("Losing health: " + amount);
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

	function getHealthPercent() as Float {
		return current_health.toFloat() / maxHealth.toFloat();
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



	function getSprite() as ResourceId {
		return sprite;
	}

	function setSprite(sprite as ResourceId) as Void {
		self.sprite = sprite;
	}

	function getWeaponItem(slot as ItemSlot) as WeaponItem? {
		var weapon = null;
		var item = equipped[slot];
		if (item != null && item.type == WEAPON) {
			weapon = item as WeaponItem;
		} 
		return weapon;
	}

	function canAttack(enemy as Enemy?) as Boolean {
		var weapon_left = getWeaponItem(LEFT_HAND);
		var weapon_right = getWeaponItem(RIGHT_HAND);
		if (weapon_left != null && weapon_left.canAttack(enemy)) {
			return true;
		}
		if (weapon_right != null && weapon_right.canAttack(enemy)) {
			return true;
		}
		return false;
	}

	function getAttack(enemy as Enemy?) as Number {
		var base_attack = 0;
		var weapon_left = getWeaponItem(LEFT_HAND);
		var weapon_right = getWeaponItem(RIGHT_HAND);
		var weapons = [];
		if (weapon_left != null && weapon_left.canAttack(enemy)) {
			weapons.add(weapon_left);
		}
		if (weapon_right != null && weapon_right.canAttack(enemy)) {
			weapons.add(weapon_right);
		}
		for (var i = 0; i < weapons.size(); i++) {
			var weapon = weapons[i];
			base_attack += weapon.getAttack(enemy, weapons.size());
		}
		return base_attack;
	}

	function getArmorItem(slot as ItemSlot) as WeaponItem? {
		var armor = null;
		var item = equipped[slot];
		if (item != null && item.type == ARMOR) {
			armor = item as ArmorItem;
		} 
		return armor;
	}

	function getDefense(enemy as Enemy?) as Number {
		var base_defense = attributes[:constitution];
		var armors = [
			equipped[HEAD] as ArmorItem?,
			equipped[CHEST] as ArmorItem?,
			equipped[BACK] as ArmorItem?,
			equipped[LEGS] as ArmorItem?,
			equipped[FEET] as ArmorItem?,
			equipped[ACCESSORY] as ArmorItem?,
			getArmorItem(LEFT_HAND),
			getArmorItem(RIGHT_HAND),
		];

		var armors_size = armors.size();
		for (var i = 0; i < armors_size; i++) {
			var armor = armors[i];
			if (armor != null) {
				base_defense += armor.getDefense(enemy, armors_size);
			}
		}

		return base_defense;
	}

	function takeDamage(damage as Number, enemy as Enemy?) as Boolean {
		onLoseHealth(damage);
		if (current_health == 0) {
			return true;
		}
		return false;
	}

	function onDamageDone(damage as Number, enemy as Enemy?) as Void {
		var weapon_left = getWeaponItem(LEFT_HAND);
		var weapon_right = getWeaponItem(RIGHT_HAND);
		if (weapon_left != null && weapon_left.canAttack(enemy)) {
			weapon_left.onDamageDone(damage, enemy);
		}
		if (weapon_right != null && weapon_right.canAttack(enemy)) {
			weapon_right.onDamageDone(damage, enemy);
		}
	}

	function getGold() as Number {
		return gold;
	}	

	function doGoldDelta(amount as Number) as Boolean {
		if (gold + amount < 0) {
			return false;
		}
		gold += amount;
		return true;
	}

	function getRange(enemy as Enemy?) as [Numeric, RangeType] {
		var weapon_left = getWeaponItem(LEFT_HAND);
		var weapon_right = getWeaponItem(RIGHT_HAND);
		var range_left = 1;
		var range_right = 1;
		var range_type = DIRECTIONAL;
		if (weapon_left != null && weapon_left.canAttack(enemy)) {
			range_left = weapon_left.getRange();
		}
		if (weapon_right != null && weapon_right.canAttack(enemy)) {
			range_right = weapon_right.getRange();
		}
		if (range_left > range_right && weapon_left != null) {
			range_type = weapon_left.getRangeType() as RangeType;
			return [range_left, range_type];
		} else if (range_right >= range_left && weapon_right != null) {
			range_type = weapon_right.getRangeType() as RangeType;
			return [range_right, range_type];
		} else {
			return [1, DIRECTIONAL];
		}
	}

	function onTurnDone() as Void {
		var equip_keys = equipped.keys();
		for (var i = 0; i < equip_keys.size(); i++) {
			var slot = equip_keys[i];
			var item = equipped[slot];
			if (item != null) {
				item.onTurnDone();
			}
		}
	}

	function getId() as Number {
		return id;
	}

	function getDescription() as String {
		return description;
	}

	function toString() as String {
		return name;
	}


	
	function getPos() as Point2D {
		return pos;
	}

	function setPos(pos as Point2D) as Void {
		self.pos = pos;
	}

	private function convertAttributeSymbolToString() as Dictionary {
		var attribute_string = {};
		for (var i = 0; i < attributes.size(); i++) {
			var attribute = attributes.keys()[i];
			attribute_string[Constants.ATT_SYMBOL_TO_STR[attribute]] = attributes[attribute];
		}
		return attribute_string;
	}

	private function convertAttributeStringToSymbol(data_attributes as Dictionary) as Dictionary {
		var attribute_symbol = {};
		for (var i = 0; i < data_attributes.size(); i++) {
			var attribute = data_attributes.keys()[i];
			attribute_symbol[Constants.ATT_STR_TO_SYMBOL[attribute]] = data_attributes[attribute];
		}
		return attribute_symbol;
	}

	function save() as Dictionary {
		var save_data = {
			"id" => id,
			"name" => name,
			"current_health" => current_health,
			"maxHealth" => maxHealth,
			"level" => level,
			"experience" => experience,
			"next_level_experience" => next_level_experience,
			"attributes" => convertAttributeSymbolToString(),
			"attribute_points" => attribute_points,
			"inventory" => inventory.save(),
			"equipped" => {},
			"gold" => gold
		};
		for (var i = 0; i < equipped.size(); i++) {
			var slot = equipped.keys()[i];
			var item = equipped[slot];
			if (item != null) {
				save_data["equipped"][slot] = item.save();
			}
		}
		Toybox.System.println("Equipped: " + save_data["equipped"]);
		return save_data;
	}

	static function load(save_data as Dictionary) as Player {
		Toybox.System.println("Loading player: " + save_data);
		if (save_data["id"] == null) {
			save_data["id"] = 0;
		}
		var player = Players.createPlayerFromId(save_data["id"] as Number, save_data["name"] as String);
		player.onLoad(save_data);
		return player;
	}

	function onLoad(save_data as Dictionary) as Void {
		if (save_data["current_health"] != null) {
			current_health = save_data["current_health"] as Number;
		}
		if (save_data["maxHealth"] != null) {
			maxHealth = save_data["maxHealth"] as Number;
		}
		if (save_data["level"] != null) {
			level = save_data["level"] as Number;
		}
		if (save_data["experience"] != null) {
			experience = save_data["experience"] as Number;
		}
		if (save_data["next_level_experience"] != null) {
			next_level_experience = save_data["next_level_experience"] as Number;
		}
		if (save_data["attributes"] != null) {
			attributes = convertAttributeStringToSymbol(save_data["attributes"] as Dictionary);
		}
		if (save_data["attribute_points"] != null) {
			attribute_points = save_data["attribute_points"] as Number;
		}
		if (save_data["inventory"] != null) {
			inventory = Inventory.load(save_data["inventory"] as Dictionary);
		}
		var equipped_save = save_data["equipped"] as Dictionary?;
		if (equipped_save != null) {
			self.equipped = {};
			var equipped_save_keys = equipped_save.keys();
			for (var i = 0; i < equipped_save_keys.size(); i++) {
				var slot = equipped_save_keys[i] as ItemSlot;
				var item_data = equipped_save[slot] as Dictionary?;
				if (item_data != null && item_data["id"] != null) {
					var item = Items.createItemFromId(item_data["id"]);
					item.onLoad(item_data);
					self.equipItem(item, slot, null);
				}
			}
		}
		if (save_data["gold"] != null) {
			gold = save_data["gold"] as Number;
		}

	}

}
