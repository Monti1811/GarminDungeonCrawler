import Toybox.Lang;
import Toybox.Time;

class Player extends Entity {

	var current_health as Number = 100;
	var maxHealth as Number = 100;
	var name as String = "Player";
	var description as String = "The player character";
	var current_run as Number = 0;
	var time_played as Number = 0;
	var time_started as Time.Moment?;
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

	function toString() as String {
		return name;
	}

	function getCurrentRun() as Number {
		return current_run;
	}

	function setCurrentRun(run as Number) as Void {
		current_run = run;
	}

	function addToCurrentRun(amount as Number) as Void {
		current_run += amount;
	}

	function getTimePlayed() as Number {
		return time_played;
	}

	function setTimePlayed(time as Number) as Void {
		time_played = time;
	}

	function addToTimePlayed(time as Number) as Void {
		time_played += time;
	}
	
	function setTimeStarted(time as Time.Moment) as Void {
		time_started = time;
	}

	function updateTimePlayed(time as Time.Moment) as Void {
		Toybox.System.println("Time started: " + time_started);
		Toybox.System.println("Time ended: " + time);
		var diff = time.subtract(time_started);
		time_played += diff.value();
		time_started = time;
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
			"name" => name,
			"run" => current_run,
			"time_played" => time_played,
			"current_health" => current_health,
			"maxHealth" => maxHealth,
			"level" => level,
			"experience" => experience,
			"next_level_experience" => next_level_experience,
			"attributes" => convertAttributeSymbolToString(),
			"attribute_points" => attribute_points,
			"inventory" => inventory.save(),
			"equipped" => {}
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
		var player = Players.createWarrior(save_data["name"]);
		player.onLoad(save_data);
		return player;
	}

	function onLoad(save_data as Dictionary) as Void {
		if (save_data["run"] != null) {
			current_run = save_data["run"] as Number;
		}
		if (save_data["time_played"] != null) {
			time_played = save_data["time_played"] as Number;
		}
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
		if (save_data["equipped"] != null) {
			for (var i = 0; i < equipped.size(); i++) {
				var slot = equipped.keys()[i];
				var item_data = (save_data["equipped"] as Dictionary)[slot] as Dictionary?;
				if (item_data != null && item_data["id"] != null) {
					var item = Items.createItemFromId(item_data["id"]);
					item.onLoad(item_data);
					equipped[slot] = item;
				}
			}
		}

	}

}
