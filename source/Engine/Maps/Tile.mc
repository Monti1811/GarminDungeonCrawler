import Toybox.Lang;

enum TileType {
	EMPTY,
	WALL,
	PASSABLE,
	STAIRS
}

enum WallVariant {
	WALL_H_TOP = 42,
	WALL_H_BOTTOM = 43,
	WALL_H_MID = 44,
	WALL_V_LEFT = 45,
	WALL_V_RIGHT = 46,
	WALL_V_MID = 47,
	OUTER_TL = 50,
	OUTER_TR = 51,
	OUTER_BL = 52,
	OUTER_BR = 53,
	INNER_TL = 54,
	INNER_TR = 55,
	INNER_BL = 56,
	INNER_BR = 57,
	T_DOWN = 58,
	T_UP = 59,
	T_LEFT = 60,
	T_RIGHT = 61,
	CROSS = 62
}

class Tile {
	public var type as TileType = EMPTY;
	public var x as Number = 0;
	public var y as Number = 0;
	public var content as Object?;
	public var player as Boolean = false;

	function initialize(x as Number, y as Number) {
		self.x = x;
		self.y = y;
	}

	function deepcopy() as Tile {
		var new_tile = new Tile(x, y);
		new_tile.type = type;
		new_tile.content = content;
		new_tile.player = player;
		return new_tile;
	}

	function save() as Dictionary {
		var save_data = {};
		save_data["type"] = type;
		save_data["x"] = x;
		save_data["y"] = y;
		return save_data;
	}

	static function load(save_data as Dictionary) as Tile {
		var tile = new Tile(save_data["x"] as Number, save_data["y"] as Number);
		tile.type = save_data["type"] as TileType;
		return tile;
	}

}