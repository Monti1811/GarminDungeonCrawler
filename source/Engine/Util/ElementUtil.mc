import Toybox.Lang;

module ElementUtil {

    function getWeaponElement(id as Number) as ElementType {
        if (id >= 20 && id <= 28) {
            return ELEMENT_FIRE;
        }
        if (id >= 30 && id <= 38) {
            return ELEMENT_ICE;
        }
        return ELEMENT_NONE;
    }

    function getAmmunitionElement(id as Number) as ElementType {
        if (id == 201 || id == 251) {
            return ELEMENT_FIRE;
        }
        if (id == 202 || id == 252) {
            return ELEMENT_ICE;
        }
        return ELEMENT_NONE;
    }

    function getArmorElement(id as Number) as ElementType {
        if (id >= 1020 && id <= 1025) {
            return ELEMENT_FIRE;
        }
        if (id >= 1030 && id <= 1035) {
            return ELEMENT_ICE;
        }
        return ELEMENT_NONE;
    }

    function getArmorResistance(id as Number, element as ElementType) as Float {
        var armor_element = getArmorElement(id);
        if (armor_element == element) {
            return 0.25; // Matching elemental armor softens the effect
        }
        return 0.0;
    }

    function buildElementalEffect(element as ElementType, damage as Number) as Dictionary<Symbol, Number> {
        switch (element) {
            case ELEMENT_FIRE:
                return {
                    :power => MathUtil.max(1, MathUtil.floor(damage * 0.30, 1)),
                    :turns => 3
                };
            case ELEMENT_ICE:
                return {
                    :power => MathUtil.max(10, MathUtil.ceil(damage * 0.4, 0)),
                    :turns => 2
                };
            default:
                return {};
        }
    }
}
