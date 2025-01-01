import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;

class Dungeon {

	private var _rooms as Array<Array<Room>>;

	function initialize(size_x as Number, size_y as Number) {
		_rooms = new Array<Array<Room>>[size_x];
		for (var i = 0; i < size_x; i++) {
			_rooms[i] = new Array<Room>[size_y];
		}

	}

	function addRoom(room as Room, pos as Point2D, connections as Dictionary<WalkDirection, Point2D>) {
		// Add room to dungeon
		_rooms[pos[0]][pos[1]] = room;
		var connection_keys = connections.keys();
		for (var i = 0; i < connection_keys.size(); i++) {
			var connection = connections[connection_keys[i]];
			// Add connections to room
			_rooms[pos[0]][pos[1]].addConnection(connection_keys[i], _rooms[connection[0]][connection[1]]);
		}
	}

	function getRoom(index as Point2D) as Room {
		return _rooms[index[0]][index[1]];
	}

	function getRooms() as Array<Array<Room>> {
		return _rooms;
	}
}