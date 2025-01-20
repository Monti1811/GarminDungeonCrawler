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
	private var _connections as Dictionary<String, Dictionary<WalkDirection, Boolean>> = {};

	function initialize(size_x as Number, size_y as Number) {
		_size = [size_x, size_y];
		_rooms = new Array<Array<String?>>[size_x];
		for (var i = 0; i < size_x; i++) {
			_rooms[i] = new Array<String?>[size_y];
		}

	}

	function addRoom(room as Room, pos as Point2D) {
		// Save the room and save the save string of the room in the dungeon
		var save_str = $.SimUtil.getRoomName(pos[0], pos[1]);
		Storage.setValue(save_str, room.save());
		_rooms[pos[0]][pos[1]] = save_str;
	}

	function getConnections() as Dictionary<String, Dictionary<WalkDirection, Boolean>> {
		return _connections;
	}

	function addToConnections(room_name as String, direction as WalkDirection) {
		var room_connections = _connections[room_name];
		if (room_connections == null) {
			_connections[room_name] = {};
			room_connections = _connections[room_name];
		}
		room_connections[direction] = true;
	}

	function getAdjacentRooms(x as Number, y as Number) as Array<Point2D> {
		var adjacent_rooms = [];
		if (x > 0) {
			adjacent_rooms.add([x - 1, y]);
		}
		if (x < _size[0] - 1) {
			adjacent_rooms.add([x + 1, y]);
		}
		if (y > 0) {
			adjacent_rooms.add([x, y - 1]);
		}
		if (y < _size[1] - 1) {
			adjacent_rooms.add([x, y + 1]);
		}
		return adjacent_rooms;
	}

	function getPossibleDirections(x as Number, y as Number) as Array<WalkDirection> {
		var possible_directions = [];
		if (x > 0) {
			possible_directions.add(LEFT);
		}
		if (x < _size[0] - 1) {
			possible_directions.add(RIGHT);
		}
		if (y > 0) {
			possible_directions.add(UP);
		}
		if (y < _size[1] - 1) {
			possible_directions.add(DOWN);
		}
		return possible_directions;
	}

	function connectRoomsRandomly() as Void {

		for (var i = 0; i < _size[0]; i++) {
			for (var j = 0; j < _size[1]; j++) {
				_connections[$.SimUtil.getRoomName(i, j)] = {};
			}
		}

		var start_room_pos = [MathUtil.random(0, _size[0] - 1), MathUtil.random(0, _size[1] - 1)];
		var start_room = $.SimUtil.getRoomName(start_room_pos[0], start_room_pos[1]);
		var connected_rooms = {start_room => true};
		while (connected_rooms.size() < _size[0] * _size[1]) {
			var current_room = $.SimUtil.getRandomKeyFromDict(connected_rooms) as String;
			var current_room_pos = $.SimUtil.getPosFromRoomName(current_room) as Point2D;
			var possible_directions = getPossibleDirections(current_room_pos[0], current_room_pos[1]);
			if (current_room == null) {
				break;
			}
			var direction = $.SimUtil.getRandomFromArray(possible_directions);
			if (_connections[current_room][direction] != null) {
				continue;
			}
			var adjacent_room_pos = $.MapUtil.getCoordInDirection(current_room_pos, direction);
			var adjacent_room_name = $.SimUtil.getRoomName(adjacent_room_pos[0], adjacent_room_pos[1]);
			addToConnections(current_room, direction);
			addToConnections(adjacent_room_name, $.MapUtil.getInversedDirection(direction));
			connected_rooms[adjacent_room_name] = true;
		}
		// Check if all rooms have a connection
		for (var i = 0; i < _size[0]; i++) {
			for (var j = 0; j < _size[1]; j++) {
				var room_name = $.SimUtil.getRoomName(i, j);
				var room_connections = _connections[room_name];
				if (room_connections.size() == 0) {
					var possible_directions = getPossibleDirections(i, j);
					var direction = $.SimUtil.getRandomFromArray(possible_directions);
					var adjacent_room_pos = $.MapUtil.getCoordInDirection([i, j], direction);
					var adjacent_room_name = $.SimUtil.getRoomName(adjacent_room_pos[0], adjacent_room_pos[1]);
					addToConnections(room_name, direction);
					addToConnections(adjacent_room_name, $.MapUtil.getInversedDirection(direction));
				}
			}
		}
	}

	function addStairs() as Void {
		var max_tries = 100;
		while (max_tries > 0) {
			var rand_x = MathUtil.random(0, _size[0] - 1);
			var rand_y = MathUtil.random(0, _size[1] - 1);
			var room_name = _rooms[rand_x][rand_y];
			if (room_name != null) {
				var room = loadRoom(room_name);
				room.addStairs(null, true);
				saveRoom(room_name, room);
				return;
			}
			max_tries -= 1;
		}
		
	}

	function addMerchant() as Void {
		if (MathUtil.random(0, 100) < 0) {
			return;
		}
		var max_tries = 100;
		while (max_tries > 0) {
			var rand_x = MathUtil.random(0, _size[0] - 1);
			var rand_y = MathUtil.random(0, _size[1] - 1);
			var room_name = _rooms[rand_x][rand_y];
			if (room_name != null) {
				var room = loadRoom(room_name);
				room.addMerchant();
				saveRoom(room_name, room);
				return;
			}
			max_tries -= 1;
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