import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Application.Storage;

class Dungeon {

	private var _rooms as Array<Array<Room>>;
	private var _current_room as Room?;
	private var _current_room_position as Point2D?;
	private var _size as Point2D;

	function initialize(size_x as Number, size_y as Number) {
		_size = [size_x, size_y];
		_rooms = new Array<Array<Room>>[size_x];
		for (var i = 0; i < size_x; i++) {
			_rooms[i] = new Array<Room>[size_y];
		}

	}

	function addRoom(room as Room, pos as Point2D, connections as Dictionary<WalkDirection, Point2D>) {
		// Add room to dungeon
		_rooms[pos.x][pos.y] = room;
		var connection_keys = connections.keys();
		for (var i = 0; i < connection_keys.size(); i++) {
			var connection = connections[connection_keys[i]];
			// Add connections to room
			_rooms[pos.x][pos.y].addConnection(connection_keys[i], _rooms[connection.x][connection.y]);
		}
	}

	function addStairs() as Void {
		while (true) {
			var rand_x = MathUtil.random(0, _size.x - 1);
			var rand_y = MathUtil.random(0, _size.y - 1);
			if (_rooms[rand_x][rand_y] != null) {
				_rooms[rand_x][rand_y].addStairs(null);
				return;
			}
		}
		
	}

	function getRoom(index as Point2D) as Room {
		return _rooms[index.x][index.y];
	}

	function getRooms() as Array<Array<Room>> {
		return _rooms;
	}

	function getCurrentRoom() as Room {
		return _current_room;
	}

	function setCurrentRoom(room as Room) {
		_current_room = room;
		_current_room_position = getRoomPosition(room) as Point2D;
	}

	function setCurrentRoomFromIndex(index as Point2D) {
		_current_room = getRoom(index);
		_current_room_position = index;
	}

	function getCurrentRoomPosition() as Point2D {
		if (_current_room_position != null) {
			return _current_room_position;
		}
		return getRoomPosition(_current_room) as Point2D;
	}

	function getSize() as Point2D {
		return _size;
	}

	function getRoomPosition(room as Room) as Point2D? {
		for (var i = 0; i < _size.x; i++) {
			for (var j = 0; j < _size.y; j++) {
				if (_rooms[i][j] == room) {
					return new Point2D(i, j);
				}
			}
		}
		return null;
	}

	function getRoomInDirection(direction as WalkDirection) as Room? {
		var current_pos = getCurrentRoomPosition();
		var new_pos = [current_pos.x, current_pos.y];
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
			"rooms" => new Array<String?>[_size.x * _size.y]
		};
		for (var i = 0; i < _size.x; i++) {
			for (var j = 0; j < _size[1]; j++) {
				var save_str = SaveData.chosen_save + "_dungeon_" + i + "_" + j;
				Storage.setValue(save_str, _rooms[i][j].save());
				data["rooms"][i * _size[1] + j] = save_str;
			}
		}
		return data;
	}

	static function load(data as Dictionary) as Dungeon {
		var size = Point2D.toPoint2D(data["size"] as Array<Number>);
		var dungeon = new Dungeon(size.x as Number, size.y as Number);
		var rooms = data["rooms"] as Array<Dictionary<String, Object?>>;
		for (var i = 0; i < size.x; i++) {
			for (var j = 0; j < size[1]; j++) {
				var room_data = Storage.getValue(rooms[i * size[1] + j] as String) as Dictionary;
				dungeon.addRoom(Room.load(room_data), [i, j], {});
			}
		}
		dungeon.setCurrentRoomFromIndex(
			Point2D.toPoint2D(data["current_room_position"] as Array<Number>?)
		);
		return dungeon;
	}
}