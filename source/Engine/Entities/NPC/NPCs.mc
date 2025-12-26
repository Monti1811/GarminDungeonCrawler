import Toybox.Lang;

module NPCs {
	
	var npcs as Dictionary<Number, Symbol> = {
		0 => :createMerchant,
		1 => :createQuestGiver,
	};

	var weights as Dictionary<Number, Number> = {
		0 => 5,
		1 => 2,
	};
	var total_weight = 7;

	function createMerchant() as NPC {
		return new Merchant();
	}

	function createQuestGiver() as NPC {
		return new QuestGiver();
	}


	function createNPCFromId(id as Number) as NPC {
		var method = new Lang.Method(self, npcs[id]);
		return method.invoke() as NPC;
	}

	function createRandomNPC() as NPC {
		var npc_keys = npcs.keys();
		var rand = MathUtil.random(0, npc_keys.size() - 1);
		var method = new Lang.Method(self, npcs[npc_keys[rand]]);
		return method.invoke() as NPC;
	}

	function createRandomWeightedNPC() as NPC? {
		var rand = MathUtil.random(0, total_weight - 1);
		var current_weight = 0;
		var weight_keys = weights.keys();
		for (var i = 0; i < weight_keys.size(); i++) {
			current_weight += weights[weight_keys[i]];
			if (rand < current_weight) {
				var method = new Lang.Method(self, npcs[weight_keys[i]]);
				return method.invoke() as NPC;
			}
		}
		return null;
	}
}