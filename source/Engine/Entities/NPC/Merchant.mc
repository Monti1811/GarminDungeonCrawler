import Toybox.Lang;

class Merchant extends NPC {
	

	function initialize() {
		NPC.initialize();
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.Merchant;
	}

	function deepcopy() as Entity {
		var npc = new Merchant();
		npc.name = name;
		npc.pos = pos;
		return npc;
	}
	
}