import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module Battle {

	function attackEnemy(attacker as Player, defender as Enemy) as Boolean {
		var damage = MathUtil.ceil(attacker.getAttack(defender) - defender.getDefense(attacker), 0);
		showAttackString(defender.getPos(), damage);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage, attacker);
		attacker.onDamageDone(damage, defender);
		return death;
	}

	function attackPlayer(attacker as Enemy, defender as Player, defender_pos as Point2D) as Boolean {
		var damage = MathUtil.ceil(attacker.getAttack(defender) - defender.getDefense(attacker), 0);
		showAttackString(defender_pos, damage);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage, attacker);
		return death;
	}

	function showAttackString(pos as Point2D, damage as Number) as Void {
		(WatchUi.getCurrentView() as DCGameView).addDamageText(damage, pos);
	}
}