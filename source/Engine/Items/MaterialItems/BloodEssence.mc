import Toybox.Lang;

class BloodEssence extends MaterialItem {

	function initialize() {
		MaterialItem.initialize();
		self.id = 4008;
		self.name = "Blood Essence";
		self.description = "A vial of thick, living blood.";
		self.value = 350;
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.blood_essence;
	}
}
