import Toybox.Lang;

module EntityManager {
	var entity_num as Number = 0;
	var entities as Dictionary<Number, Entity> = {};


	function init() as Void {
		self.entity_num = 0;
		self.entities = {};
	}

	function addEntity(entity as Entity) as Void {
		entity.guid = entity_num;
		self.entities.put(entity_num, entity);
		self.entity_num++;
	}

	function removeEntity(entity as Entity) as Void {
		for (var i = 0; i < entities.size(); i++) {
			if (self.entities[i] == entity) {
				self.entities.remove(i);
				break;
			}
		}
	}

	function getEntityById(id as Number) as Entity? {
		return self.entities[id];
	}

	function save() as Dictionary {
		var save_data = {};
		save_data["entity_num"] = self.entity_num;
		return save_data;
	}

	function load(save_data as Dictionary) as Void {
		self.entity_num = save_data["entity_num"] as Number;
	}


}