import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module Battle {

	function attackEnemy(view as DCGameView, attacker as Player, defender as Enemy) as Boolean {
		var damage = MathUtil.ceil(attacker.getAttack() - defender.getDefense(), 0);
		showAttackString(view, defender.getPos(), damage);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage);
		return death;
	}

	function attackPlayer(view as DCGameView, attacker as Enemy, defender as Player, defender_pos as Point2D) as Boolean {
		var damage = MathUtil.ceil(attacker.getAttack() - defender.getDefense(), 0);
		showAttackString(view, defender_pos, damage);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage);
		return death;
	}

	function showAttackString(view as DCGameView, pos as Point2D, damage as Number) as Void {
		view.addDamageText(damage, pos);
	}
}