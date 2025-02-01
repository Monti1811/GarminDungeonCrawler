import Toybox.Lang;

module EntityManager {
	var entity_num = 0;
	var entities = {} as Dictionary<Number, Entity>;


	function init() as Void {
		entity_num = 0;
		entities = {};
	}

	function addEntity(entity as Entity) as Void {
		entity.guid = entity_num;
		entities.put(entity_num, entity);
		entity_num++;
	}

	function removeEntity(entity as Entity) as Void {
		for (var i = 0; i < entities.size(); i++) {
			if (entities[i] == entity) {
				entities.remove(i);
				break;
			}
		}
	}

	function getEntityById(id as Number) as Entity? {
		return entities[id];
	}

	function save() as Dictionary {
		var save_data = {};
		save_data["entity_num"] = entity_num;
		return save_data;
	}

	function load(save_data as Dictionary) as Void {
		entity_num = save_data["entity_num"] as Number;
	}


}