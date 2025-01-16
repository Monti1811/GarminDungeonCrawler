import Toybox.Lang;

class NPC extends Entity {
	var id as Number = 0;
	var name as String = "NPC";
	var description as String = "A simple NPC";
	var pos as Point2D = [0, 0];
	

	function initialize() {
		Entity.initialize();
	}

	function onInteract() as Void {
		// Do nothing
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.Merchant;
	}

	function getPos() as Point2D {
		return pos;
	}

	function setPos(pos as Point2D) as Void {
		self.pos = pos;
	}

	function deepcopy() as Entity {
		var npc = new NPC();
		npc.name = name;
		npc.pos = pos;
		return npc;
	}

	function save() as Dictionary {
		var save_data = Entity.save();
		save_data["id"] = id;
		save_data["name"] = name;
		save_data["description"] = description;
		save_data["pos"] = pos;
		return save_data;
	}

	static function load(save_data as Dictionary) as NPC {
		var npc = NPCs.createNPCFromId(save_data["id"]);
		npc.onLoad(save_data);
		return npc;
	}

	function onLoad(save_data as Dictionary) as Void {
		id = save_data["id"];
		name = save_data["name"];
		description = save_data["description"];
		pos = save_data["pos"];
	}
}