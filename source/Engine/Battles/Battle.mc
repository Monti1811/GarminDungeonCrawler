import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

module Battle {

	function attackEnemy(attacker as Player, defender as Enemy) as Boolean {
		var baseDamage = attacker.getAttack(defender);
		var defense = defender.getDefense(attacker);
		var reduction = defense.toFloat() / (defense.toFloat() + baseDamage.toFloat());
		reduction = MathUtil.clamp(reduction, 0.0, 0.90);
		var damage = MathUtil.ceil(Math.round(baseDamage * (1.0 - reduction)).toNumber(), 1);
		showAttackString(defender.getPos(), damage);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage, attacker);
		attacker.onDamageDone(damage, defender);
		$.Quests.trackDamageDealt(damage);
		if (death) {
			attacker.onGainExperience(defender.getKillExperience());
			$.Quests.trackKill(defender);
		}
		return death;
	}

	function attackPlayer(attacker as Enemy, defender as Player) as Boolean {
		var baseDamage = attacker.getAttack(defender);
		var defense = defender.getDefense(attacker);
		var reduction = defense.toFloat() / (defense.toFloat() + baseDamage.toFloat());
		reduction = MathUtil.clamp(reduction, 0.0, 0.90);
		var damage = MathUtil.ceil(Math.round(baseDamage * (1.0 - reduction)).toNumber(), 1);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var death = defender.takeDamage(damage, attacker);
		$.Quests.trackDamageTaken(damage);
		return death;
	}

	function showAttackString(pos as Point2D, damage as Number) as Void {
		var view = WatchUi.getCurrentView()[0] as DCGameView;
		view.addDamageText(damage, pos);
	}
}