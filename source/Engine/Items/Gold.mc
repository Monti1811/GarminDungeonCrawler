import Toybox.Lang;


class Gold extends Item {
	var id as Number = 5000;
	var name as String = "Gold";
	var description as String = "Used to pay for goods.";
	var value as Number = 1;
	var weight as Number = 0;

	function initialize() {
		Item.initialize();
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.gold;
	}
	

	function deepcopy() as Item {
		var gold = new Gold();
		gold.amount = amount;
		gold.pos = pos;
		gold.in_inventory = in_inventory;
		return gold;
	}

}