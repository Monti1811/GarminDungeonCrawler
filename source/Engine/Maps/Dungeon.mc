import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Application.Storage;

class Dungeon {

	private var _rooms as Array<Array<String?>>;
	private var _current_room as Room?;
	private var _current_room_name as String?;
	private var _current_room_position as Point2D?;
	private var _size as Point2D;

	function initialize(size_x as Number, size_y as Number) {
		_size = [size_x, size_y];
		_rooms = new Array<Array<String?>>[size_x];
		for (var i = 0; i < size_x; i++) {
			_rooms[i] = new Array<String?>[size_y];
		}

	}

	function addRoom(room as Room, pos as Point2D, connections as Dictionary<WalkDirection, Point2D>) {
		// Add room to dungeon
		var connection_keys = connections.keys();
		for (var i = 0; i < connection_keys.size(); i++) {
			var connection = connections[connection_keys[i]];
			// Add connections to room
			room.addConnection(connection_keys[i], _rooms[connection[0]][connection[1]]);
		}
		var save_str = SaveData.chosen_save + "_dungeon_" + pos[0] + "_" + pos[1];
		Storage.setValue(save_str, room.save());
		_rooms[pos[0]][pos[1]] = save_str;
	}

	function addStairs() as Void {
		while (true) {
			var rand_x = MathUtil.random(0, _size[0] - 1);
			var rand_y = MathUtil.random(0, _size[1] - 1);
			var room_name = _rooms[rand_x][rand_y];
			if (room_name != null) {
				var room = loadRoom(room_name);
				room.addStairs(null, true);
				saveRoom(room_name, room);
				return;
			}
		}
		
	}

	function getRoom(index as Point2D) as String {
		return _rooms[index[0]][index[1]];
	}

	function saveRoom(room_name as String, room as Room) as Void {
		Storage.setValue(room_name, room.save());
	}

	function loadRoom(room_name as String) as Room {
		var room = Storage.getValue(room_name) as Dictionary;
		return Room.load(room);
	}

	function saveCurrentRoom() as Void {
		if (_current_room != null) {
			var room_save = _current_room.save();
			Storage.setValue(_current_room_name, room_save);
		}
	}

	function getRooms() as Array<Array<String?>> {
		return _rooms;
	}

	function getCurrentRoom() as Room {
		return _current_room;
	}

	function setCurrentRoom(room_name as String?) {
		saveCurrentRoom();
		if (room_name == null) {
			_current_room = null;
			_current_room_name = null;
			_current_room_position = null;
			return;
		}
		_current_room = loadRoom(room_name);
		_current_room_name = room_name;
		_current_room_position = getRoomPosition(room_name) as Point2D;
	}

	function setCurrentRoomFromIndex(index as Point2D) {
		_current_room_name = getRoom(index);
		_current_room = loadRoom(_current_room_name);
		_current_room_position = index;
	}

	function getCurrentRoomPosition() as Point2D {
		if (_current_room_position != null) {
			return _current_room_position;
		}
		return getRoomPosition(_current_room_name) as Point2D;
	}

	function getSize() as Point2D {
		return _size;
	}

	function getRoomPosition(room_name as String) as Point2D? {
		for (var i = 0; i < _size[0]; i++) {
			for (var j = 0; j < _size[1]; j++) {
				if (_rooms[i][j] == room_name) {
					return [i, j];
				}
			}
		}
		return null;
	}

	function getRoomInDirection(direction as WalkDirection) as String? {
		var current_pos = getCurrentRoomPosition();
		var new_pos = [current_pos[0], current_pos[1]];
		switch (direction) {
			case UP:
				new_pos[1] -= 1;
				break;
			case DOWN:
				new_pos[1] += 1;
				break;
			case LEFT:
				new_pos[0] -= 1;
				break;
			case RIGHT:
				new_pos[0] += 1;
				break;
			case STANDING:
				return null;
		}
		if (new_pos[0] >= 0 && new_pos[0] < _size[0] && new_pos[1] >= 0 && new_pos[1] < _size[1]) {
			return _rooms[new_pos[0]][new_pos[1]];
		}
		return null;
	}

	function save() as Dictionary {
		var data = {
			"size" => _size,
			"current_room_position" => _current_room_position,
			"rooms" => new Array<String?>[_size[0] * _size[1]]
		};
		saveCurrentRoom();
		for (var i = 0; i < _size[0]; i++) {
			for (var j = 0; j < _size[1]; j++) {
				if (_rooms[i][j] != null) {
					data["rooms"][i * _size[1] + j] = _rooms[i][j];
				}
			}
		}
		return data;
	}

	function onLoad(data as Dictionary) as Void {
		var rooms = data["rooms"] as Array<String?>;
		for (var i = 0; i < _size[0]; i++) {
			for (var j = 0; j < _size[1]; j++) {
				_rooms[i][j] = rooms[i * _size[1] + j];
			}
		}
		setCurrentRoomFromIndex(data["current_room_position"] as Point2D);
	}

	static function load(data as Dictionary) as Dungeon {
		var size = data["size"] as Point2D;
		var dungeon = new Dungeon(size[0] as Number, size[1] as Number);
		dungeon.onLoad(data);
		return dungeon;
	}
}