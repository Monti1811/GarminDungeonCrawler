import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Application.Storage;

class Map {

	private var _width as Number;
	private var _height as Number;
	private var _tiles as Array<Array<Tile?>>;
	private var _map_string as Array<String>;
	// Sentinel tile used when a requested tile does not exist (treated as wall/non-passable)
	private var _null_tile as Tile;


	function initialize(width as Number, height as Number, with_tiles as Boolean) {
		_width = width;
		_height = height;
		_tiles = new Array<Array<Tile?>>[width];
		_null_tile = new Tile(-1, -1);
		for (var i = 0; i < width; i++) {
			_tiles[i] = new Array<Tile?>[height];
			if (with_tiles) {
				for (var j = 0; j < height; j++) {
					_tiles[i][j] = null; // Unused tiles remain null
				}
			}
		}
		_map_string = [];
	}

	function setTile(x as Number, y as Number, tile as Tile) as Void {
		if (x >= 0 && x < _width && y >= 0 && y < _height) {
			_tiles[x][y] = tile;
		}
	}

	function getTile(x as Number, y as Number) as Tile {
		var tile = _tiles[x][y];
		if (tile == null) {
			return _null_tile;
		}
		return tile;
	}

	function getTileFromPos(pos as Point2D) as Tile {
		return getTile(pos[0], pos[1]);
	}

	function getSize() as Point2D {
		return [_width, _height];
	}

	function getXSize() as Number {
		return _width;
	}

	function getYSize() as Number {
		return _height;
	}

	function getTiles() as Array<Array<Tile?>> {
		return _tiles;
	}

	function deepcopy() as Map {
		var new_map = new Map(_width, _height, false);
		for (var i = 0; i < _width; i++) {
			for (var j = 0; j < _height; j++) {
				var tile = _tiles[i][j];
				if (tile != null) {
					new_map.setTile(i, j, tile);
				}
			}
		}
		return new_map;
	}

	function setContent(pos as Point2D, Object as Object?) as Void {
		var tile = self.getTileFromPos(pos);
		if (tile == _null_tile) {
			return;
		}
		tile.content = Object;
	}

	function getContent(pos as Point2D) as Object? {
		var tile = self.getTileFromPos(pos);
		if (tile == _null_tile) {
			return null;
		}
		return tile.content;
	}

	function isPosFree(pos as Point2D) as Boolean {
		var tile = self.getTileFromPos(pos);
		if (tile == _null_tile) {
			return false;
		}
		if (tile.type == PASSABLE && tile.content == null) {
			return true;
		}
		return false;
	}

	function setType(pos as Point2D, type as TileType) as Void {
		var tile = _tiles[pos[0]][pos[1]];
		if (type != EMPTY) {
			if (tile == null) {
				tile = new Tile(pos[0], pos[1]);
				_tiles[pos[0]][pos[1]] = tile;
			}
			tile.type = type;
			return;
		}
		// For WALL or EMPTY we drop the tile reference to keep storage sparse
		_tiles[pos[0]][pos[1]] = null;
	}

	function getType(pos as Point2D) as TileType {
		return self.getTileFromPos(pos).type;
	}

	function isWall(pos as Point2D) as Boolean {
		return self.getTileFromPos(pos).type == WALL;
	}

	function setPlayer(pos as Point2D, player as Boolean) as Void {
		var tile = self.getTileFromPos(pos);
		if (tile == _null_tile) {
			return;
		}
		tile.player = player;
	}

	function getPlayer(pos as Point2D) as Boolean {
		var tile = self.getTileFromPos(pos);
		return (tile != _null_tile) && tile.player;
	}


	function getNearbyFreePos(pos as Point2D) as Point2D? {
        var new_pos = [pos[0], pos[1] - 1];
        if (new_pos[1] >= 0 && self.getType(new_pos) == PASSABLE && self.getContent(new_pos) == null) {
            return new_pos;
        }
        new_pos = [pos[0], pos[1] + 1];
        if (new_pos[1] < _height && self.getType(new_pos) == PASSABLE && self.getContent(new_pos) == null) {
            return new_pos;
        }
        new_pos = [pos[0] - 1, pos[1]];
        if (new_pos[0] >= 0 && self.getType(new_pos) == PASSABLE && self.getContent(new_pos) == null) {
            return new_pos;
        }
        new_pos = [pos[0] + 1, pos[1]];
        if (new_pos[0] < _width && self.getType(new_pos) == PASSABLE && self.getContent(new_pos) == null) {
            return new_pos;
        }
        return null;
    }

	// The tiles are created from a font, so we need to map the tile types to characters
	function getMapChar(tile as Tile?) as Number {
		if (tile == null) {
			return 36;
		}
        switch (tile.type) {
            case WALL:
                return 33;
            case PASSABLE:
                return 32;
            case STAIRS:
                return 34;
            default:
                return 36;
        }
    }

	function mapToString() as Array<String> {
		var map_string = [] as Array<String>;
		for (var j = 0; j < self._height; j++) {
			var row = "";
			for (var i = 0; i < self._width; i++) {
				row += getMapChar(_tiles[i][j]).toChar();
			}
			map_string.add(row);
		}
		self._map_string = map_string;
        return map_string; 
    }

	function getMapString() as Array<String> {
		if (self._map_string.size() == 0) {
			return self.mapToString();
		}
		return self._map_string;
	}

	function isInBound(pos as Point2D) as Boolean {
		if (pos[0] >= 0 && pos[0] < _width && pos[1] >= 0 && pos[1] < _height) {
			return true;
		}
		return false;
	}

	function save() as Dictionary {
		var save_data = {} as Dictionary;
		save_data["width"] = _width;
		save_data["height"] = _height;
		var tiles_data = [] as Array<Dictionary?>;
		for (var i = 0; i < _width; i++) {
			for (var j = 0; j < _height; j++) {
				var tile = _tiles[i][j];
				if (tile == null) {
					tiles_data.add(null);
				} else {
					tiles_data.add(tile.save());
				}
			}
		}
		save_data["tiles"] = tiles_data;
		return save_data;
	}

	static function load(save_data as Dictionary) as Map {
		var map = new Map(
			save_data["width"].toNumber() as Number,
			save_data["height"].toNumber() as Number,
			false
		);
		map.onLoad(save_data);
		return map;
	}

	function onLoad(save_data as Dictionary) as Void {
		_width = save_data["width"] as Number;
		_height = save_data["height"] as Number;
		_tiles = new Array<Array<Tile?>>[_width];
		for (var i = 0; i < _width; i++) {
			_tiles[i] = new Array<Tile?>[_height];
		}
		var tiles_data = save_data["tiles"] as Array<Dictionary?>;
		var index = 0;
		for (var i = 0; i < _width; i++) {
			for (var j = 0; j < _height; j++) {
				var tile_data = tiles_data[index];
				if (tile_data == null) {
					_tiles[i][j] = null;
				} else {
					_tiles[i][j] = Tile.load(tile_data as Dictionary);
				}
				index += 1;
			}
		}
	}

	static function createRandomMap(width as Number, height as Number, left as Number, right as Number, top as Number, bottom as Number) as Map {
		var map = new Map(width, height, true);

		// Add walls to tiles by changing the type of the tile
		// Top wall
		for (var i = left; i <= right; i++) {
			map.setType([i, top], WALL);
		}
		// Bottom wall
		for (var i = left; i <= right; i++) {
			map.setType([i, bottom], WALL);
		}
		// Left wall
		for (var j = top; j <= bottom; j++) {
			map.setType([left, j], WALL);
		}
		// Right wall
		for (var j = top; j <= bottom; j++) {
			map.setType([right, j], WALL);
		}

		// Add passable to tiles
		for (var i = left + 1; i < right; i++) {
			for (var j = top + 1; j < bottom; j++) {
				map.setType([i, j], PASSABLE);
			}
		}

		/*var map_string = map.mapToString();
		for (var i = 0; i < map_string.size(); i++) {
			Toybox.System.println(map_string[i]);
		}*/

		return map;
	}

}
