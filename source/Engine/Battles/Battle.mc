import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module Battle {

	function attackEnemy(attacker as Player, defender as Enemy) as Boolean {
		var damage = MathUtil.ceil(attacker.getAttack(defender) - defender.getDefense(attacker), 1);
		showAttackString(defender.getPos(), damage);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage, attacker);
		attacker.onDamageDone(damage, defender);
		if (death) {
			attacker.onGainExperience(defender.getKillExperience());
		}
		return death;
	}

	function attackPlayer(attacker as Enemy, defender as Player) as Boolean {
		var damage = MathUtil.ceil(attacker.getAttack(defender) - defender.getDefense(attacker), 1);
		defender.damage_received += damage;
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage, attacker);
		return death;
	}

	function showAttackString(pos as Point2D, damage as Number) as Void {
		var view = WatchUi.getCurrentView()[0] as DCGameView;
		view.addDamageText(damage, pos);
	}
}