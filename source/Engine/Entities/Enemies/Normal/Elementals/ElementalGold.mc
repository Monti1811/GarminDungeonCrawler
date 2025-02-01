import Toybox.Lang;

class ElementalGold extends Elemental {

	function initialize() {
		Elemental.initialize();
		id = 21;
		name = "Gold Elemental";
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.monster_elemental_gold_tall;
	}

	function getLoot() as Item? {
		var gold = new Gold();
		gold.amount = MathUtil.random(50, 100);
		return gold;
	}

}