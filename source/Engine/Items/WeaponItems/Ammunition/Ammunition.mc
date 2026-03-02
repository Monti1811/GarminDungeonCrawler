import Toybox.Lang;

class Ammunition extends WeaponItem {

	var type as AmmunitionType = ARROW;
	var element_override as ElementType = ELEMENT_NONE;

	function initialize() {
		WeaponItem.initialize();
		slot = AMMUNITION;
		attack = 1;
		weight = 0.01;
		value = 5;
	}

	function getType() as AmmunitionType {
		return type;
	}

	function isType(type as AmmunitionType) as Boolean {
		return self.type == type;
	}

	function getElement() as ElementType {
		if (element_override == ELEMENT_NONE && id != null) {
			// Fallback only once for legacy ammo
			element_override = $.ElementUtil.getAmmunitionElement(id);
		}
		return element_override;
	}


}