import Toybox.Lang;

enum TileType {
	EMPTY,
	WALL,
	PASSABLE,
	STAIRS
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