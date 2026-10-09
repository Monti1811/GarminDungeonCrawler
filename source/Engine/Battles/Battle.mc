import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

module Battle {

	function attackEnemy(attacker as Player, defender as Enemy) as Boolean {
		var baseDamage = attacker.getAttack(defender);
		var defense = defender.getDefense(attacker);
		var damage = getDamage(baseDamage, defense);
		showAttackString(defender.getPos(), damage);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		var health_before = defender.current_health;
		var death = defender.takeDamage(damage, attacker);
		attacker.onDamageDone(damage, defender);
		$.Quests.trackDamageDealt(damage);
		$.Achievements.bump("damage_dealt", damage);
		if (damage >= 25) {
			$.Achievements.bump("heavy_hits", 1);
		}
		if (death) {
			$.Achievements.bump("kills", 1);
			$.Achievements.bump("floor_kills", 1);
			if (damage >= health_before) {
				$.Achievements.unlock("devastating");
			}
			if (attacker.getHealth() <= 1) {
				$.Achievements.unlock("close_call");
			}
			attacker.onGainExperience(defender.getKillExperience());
			$.Quests.trackKill(defender);
		}
		return death;
	}

	function attackPlayer(attacker as Enemy, defender as Player) as Boolean {
		var baseDamage = attacker.getAttack(defender);
		var defense = defender.getDefense(attacker);
		var damage = getDamage(baseDamage, defense);
		Log.log(attacker.getName() + " attacks " + defender.getName() + " for " + damage + " damage");
		// damage_taken/floor_damage are bumped inside Player.takeDamage so that
		// spells and other direct damage paths count as well.
		return defender.takeDamage(damage, attacker);
	}

	function getDamage(baseDamage as Number, defense as Number) as Number {
		var reduction = 0;
		if (defense > 0 || baseDamage > 0 ) {
			reduction = defense.toFloat() / (defense.toFloat() + baseDamage.toFloat());
		} 
		reduction = MathUtil.clamp(reduction, 0.0, 0.90);
		var damage = MathUtil.ceil(Math.round(baseDamage * (1.0 - reduction)).toNumber(), 1);
		return damage;
	}

	function showAttackString(pos as Point2D, damage as Number) as Void {
		var view = WatchUi.getCurrentView()[0] as DCGameView;
		view.addDamageText(damage, pos);
	}
}