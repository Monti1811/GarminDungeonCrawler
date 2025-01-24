import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

class DCMapDrawable extends WatchUi.Drawable {

	private const size_tile as Number = 4;
	private const size_room as Number = size_tile * 23;
	private const middle_of_room as Number = size_room / 2;

	private var initial_pos as Point2D;

	private var size as Point2D;

	function initialize() {
		Drawable.initialize({});
		var dungeon_map = $.Game.map;
		var dungeon_size = [dungeon_map.size(), dungeon_map[0].size()];
		size = [dungeon_size[0] * size_room, dungeon_size[1] * size_room];
		var current_room_pos = getApp().getCurrentDungeon().getCurrentRoomPosition();
		initial_pos = [
			180 - (current_room_pos[0] * size_room + middle_of_room), 
			180 - (current_room_pos[1] * size_room + middle_of_room)
		];
	}

	function drawRoom(dc as Dc, pos as Point2D) {
		var room_data = $.Game.map[pos[0]][pos[1]];
		// Check if room data exists and if the room has been visited
		if (room_data == null || room_data[3] == false) {
			return;
		}
		var room_connections = room_data[1];
		var room_size = room_data[2];
		var flags = room_data[4];
		var entire_room_x = locX + pos[0] * size_room;
		var entire_room_y = locY + pos[1] * size_room;
		var room_x = entire_room_x + middle_of_room - room_size[0] * size_tile / 2;
		var room_y = entire_room_y + middle_of_room - room_size[1] * size_tile / 2;
		dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		dc.drawRectangle(room_x - 1, room_y - 1, room_size[0] * size_tile + 2, room_size[1] * size_tile + 2);
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(room_x, room_y, room_size[0] * size_tile, room_size[1] * size_tile);

		// Draw the connections
		dc.setPenWidth(size_tile);

		var middle_x = entire_room_x + middle_of_room;
		var middle_y = entire_room_y + middle_of_room;

		drawConnection(dc, room_connections, UP, middle_x, middle_y, middle_x, entire_room_y);
		drawConnection(dc, room_connections, DOWN, middle_x, middle_y, middle_x, entire_room_y + size_room);
		drawConnection(dc, room_connections, LEFT, middle_x, middle_y, entire_room_x, middle_y);
		drawConnection(dc, room_connections, RIGHT, middle_x, middle_y, entire_room_x + size_room, middle_y);

		// Draw the flags
		var stairs_pos = flags[0];
		if (stairs_pos != null) {
			drawFlag(dc, [stairs_pos[0] * size_tile + entire_room_x, stairs_pos[1] * size_tile + entire_room_y], $.Rez.Drawables.Stairs);
		}
		var merchant_pos = flags[1];
		if (merchant_pos != null) {
			drawFlag(dc, [merchant_pos[0] * size_tile + entire_room_x, merchant_pos[1] * size_tile + entire_room_y], $.Rez.Drawables.Merchant);
		}

	}

	function drawConnection(dc as Dc, room_connections as Dictionary<WalkDirection, Boolean>, direction as WalkDirection, x1 as Number, y1 as Number, x2 as Number, y2 as Number) {
			if (room_connections[direction] == true) {
				dc.drawLine(x1, y1, x2, y2);
			}
		}

	function drawFlag(dc as Dc, pos as Point2D, rez_id as ResourceId) {
		dc.drawScaledBitmap(
			pos[0] - size_tile/2, 
			pos[1] - size_tile/2,
			size_tile * 2, 
			size_tile * 2,
			WatchUi.loadResource(rez_id)
		);
	}

	// Draw the player
	function drawPlayer(dc as Dc) {
		var current_room_pos = getApp().getCurrentDungeon().getCurrentRoomPosition();
		var player = getApp().getPlayer();
		var player_pos = player.getPos();
		var entire_room_x = locX + current_room_pos[0] * size_room;
		var entire_room_y = locY + current_room_pos[1] * size_room;
		dc.drawScaledBitmap(
			player_pos[0] * size_tile + entire_room_x - size_tile, //* 3/2,
			player_pos[1] * size_tile + entire_room_y - size_tile, //* 3/2,
			size_tile * 3,
			size_tile * 3,
			player.getSpriteRef()
		);
	}

	function draw(dc as Dc) {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(0, 0, size[0] * size_room, size[1] * size_room);
		for (var i = 0; i < $.Game.map.size(); i++) {
			for (var j = 0; j < $.Game.map[i].size(); j++) {
				drawRoom(dc, [i, j]);
			}
		}
		drawPlayer(dc);
		dc.setPenWidth(1);
	}

	function getInitialPos() as Point2D {
		return initial_pos;
	}

	function getDrawableSize() as Point2D {
		return size;
	}
}