import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Application.Storage;

class Map {

	private var _width as Number;
	private var _height as Number;
	private var _tiles as Array<Array<Tile>>;
	private var _map_string as Array<String>;


	function initialize(width as Number, height as Number, with_tiles as Boolean) {
		_width = width;
		_height = height;
		_tiles = new Array<Array<Tile>>[width];
		for (var i = 0; i < width; i++) {
			_tiles[i] = new Array<Tile>[height];
			if (with_tiles) {
				for (var j = 0; j < height; j++) {
					_tiles[i][j] = new Tile(i, j); // Initialize all tiles to 0
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
		return _tiles[x][y];
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

	function getTiles() as Array<Array<Tile>> {
		return _tiles;
	}

	function deepcopy() as Map {
		var new_map = new Map(_width, _height, false);
		for (var i = 0; i < _width; i++) {
			for (var j = 0; j < _height; j++) {
				new_map.setTile(i, j, _tiles[i][j]);
			}
		}
		return new_map;
	}

	function setContent(pos as Point2D, Object as Object?) as Void {
		self.getTileFromPos(pos).content = Object;
	}

	function getContent(pos as Point2D) as Object? {
		return self.getTileFromPos(pos).content;
	}

	function isPosFree(pos as Point2D) as Boolean {
		var tile = self.getTileFromPos(pos);
		if (tile.type == PASSABLE && tile.content == null) {
			return true;
		}
		return false;
	}

	function setType(pos as Point2D, type as TileType) as Void {
		self.getTileFromPos(pos).type = type;
	}

	function getType(pos as Point2D) as TileType {
		return self.getTileFromPos(pos).type;
	}

	function isWall(pos as Point2D) as Boolean {
		return self.getTileFromPos(pos).type == WALL;
	}

	function setPlayer(pos as Point2D, player as Boolean) as Void {
		self.getTileFromPos(pos).player = player;
	}

	function getPlayer(pos as Point2D) as Boolean {
		return self.getTileFromPos(pos).player;
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

	function getMapChar(tile as Tile?) as Number {
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
                row += getMapChar(self.getTile(i, j)).toChar();
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
		var tiles_data = [] as Array<Dictionary>;
		for (var i = 0; i < _width; i++) {
			for (var j = 0; j < _height; j++) {
				tiles_data.add(_tiles[i][j].save());
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
		var tiles_data = save_data["tiles"] as Array<Dictionary>;
		var index = 0;
		for (var i = 0; i < _width; i++) {
			for (var j = 0; j < _height; j++) {
				var tile_data = tiles_data[index];
				var tile = Tile.load(tile_data);
				_tiles[i][j] = tile;
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

		return map;
	}
}
