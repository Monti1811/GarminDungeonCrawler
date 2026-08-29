import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
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

	function getDungeonStyleTranslation() as Dictionary<TileType, Number> {
		var dungeonStyle = $.Game.getDungeon().getStyle();
		switch (dungeonStyle) {
			case DUNGEONSTYLE_NORMAL:
				return {
					WALL => 33,
					PASSABLE => 32,
					STAIRS => 34,
					EMPTY => 36
				} as Dictionary<TileType, Number>;
			case DUNGEONSTYLE_FIRE:
				return {
					WALL => 33,
					PASSABLE => 40,
					STAIRS => 34,
					EMPTY => 36
				} as Dictionary<TileType, Number>;
			case DUNGEONSTYLE_BOSS:
				return {
					WALL => 41,
					PASSABLE => 37,
					STAIRS => 34,
					EMPTY => 36
				} as Dictionary<TileType, Number>;
			case DUNGEONSTYLE_ICE:
				return {
					WALL => 33,
					PASSABLE => 38,
					STAIRS => 34,
					EMPTY => 35
				} as Dictionary<TileType, Number>;
			default:
				return {
					WALL => 33,
					PASSABLE => 32,
					STAIRS => 34,
					EMPTY => 36
				} as Dictionary<TileType, Number>;
		}
	}

	// The tiles are created from a font, so we need to map the tile types to characters
	function getMapChar(tile as Tile?, translation as Dictionary<TileType, Number>) as Number {
		if (tile == null) {
			return translation[EMPTY];
		}
		return translation[tile.type];
    }

	function mapToString() as Array<String> {
		var translation = self.getDungeonStyleTranslation();
		var map_string = [] as Array<String>;
		for (var j = 0; j < self._height; j++) {
			var row = "";
			for (var i = 0; i < self._width; i++) {
				row += getMapChar(_tiles[i][j], translation).toChar();
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

	static function createRoomShape(width as Number, height as Number, left as Number, right as Number, top as Number, bottom as Number, shape as RoomShape) as Map {
		var map = new Map(width, height, true);
		var room_width = right - left;
		var room_height = bottom - top;

		// Step 1: Create base rectangle (all walls)
		for (var i = left; i <= right; i++) {
			map.setType([i, top], WALL);
		}
		for (var i = left; i <= right; i++) {
			map.setType([i, bottom], WALL);
		}
		for (var j = top; j <= bottom; j++) {
			map.setType([left, j], WALL);
		}
		for (var j = top; j <= bottom; j++) {
			map.setType([right, j], WALL);
		}

		// Step 2: Fill interior based on shape
		switch (shape) {
			case ROOMSHAPE_RECTANGLE:
				// Default rectangle - fill everything
				for (var i = left + 1; i < right; i++) {
					for (var j = top + 1; j < bottom; j++) {
						map.setType([i, j], PASSABLE);
					}
				}
				break;

			case ROOMSHAPE_L_SHAPE:
				// L-shape: Two overlapping rectangles
				// Main horizontal part (top half)
				var h_height = $.MathUtil.max(2, room_height / 2);
				for (var i = left + 1; i < right; i++) {
					for (var j = top + 1; j < top + h_height; j++) {
						map.setType([i, j], PASSABLE);
					}
				}
				// Vertical part (right side, extending down)
				var v_width = $.MathUtil.max(2, room_width / 3);
				for (var i = right - v_width; i < right; i++) {
					for (var j = top + h_height; j < bottom; j++) {
						map.setType([i, j], PASSABLE);
					}
				}
				break;

			case ROOMSHAPE_T_SHAPE:
				// T-shape: Wide top, narrow vertical stem
				var stem_width = $.MathUtil.max(2, room_width / 3);
				var stem_start = left + (room_width - stem_width) / 2;
				// Top horizontal bar
				var bar_height = $.MathUtil.max(2, room_height / 3);
				for (var i = left + 1; i < right; i++) {
					for (var j = top + 1; j < top + bar_height; j++) {
						map.setType([i, j], PASSABLE);
					}
				}
				// Vertical stem
				for (var i = stem_start; i < stem_start + stem_width; i++) {
					for (var j = top + bar_height; j < bottom; j++) {
						map.setType([i, j], PASSABLE);
					}
				}
				break;

			case ROOMSHAPE_PLUS:
				// Plus/Cross shape
				var arm_width = $.MathUtil.max(2, room_width / 3);
				var arm_height = $.MathUtil.max(2, room_height / 3);
				var cx = left + room_width / 2;
				var cy = top + room_height / 2;
				// Horizontal arm
				for (var i = left + 1; i < right; i++) {
					for (var j = cy - arm_height / 2; j <= cy + arm_height / 2; j++) {
						if (j > top && j < bottom) {
							map.setType([i, j], PASSABLE);
						}
					}
				}
				// Vertical arm
				for (var j = top + 1; j < bottom; j++) {
					for (var i = cx - arm_width / 2; i <= cx + arm_width / 2; i++) {
						if (i > left && i < right) {
							map.setType([i, j], PASSABLE);
						}
					}
				}
				break;

			case ROOMSHAPE_ROUNDED:
				// Rounded rectangle: Fill rectangle, then cut corners
				var corner_radius = $.MathUtil.min(room_width, room_height) / 4;
				for (var i = left + 1; i < right; i++) {
					for (var j = top + 1; j < bottom; j++) {
						// Check distance to each corner
						var dx_left = i - (left + corner_radius);
						var dx_right = (right - corner_radius) - i;
						var dy_top = j - (top + corner_radius);
						var dy_bottom = (bottom - corner_radius) - j;
						var cut_corner = false;
						// Top-left corner
						if (dx_left < 0 && dy_top < 0) {
							if (Math.sqrt(dx_left * dx_left + dy_top * dy_top) > corner_radius) {
								cut_corner = true;
							}
						}
						// Top-right corner
						if (dx_right < 0 && dy_top < 0) {
							if (Math.sqrt(dx_right * dx_right + dy_top * dy_top) > corner_radius) {
								cut_corner = true;
							}
						}
						// Bottom-left corner
						if (dx_left < 0 && dy_bottom < 0) {
							if (Math.sqrt(dx_left * dx_left + dy_bottom * dy_bottom) > corner_radius) {
								cut_corner = true;
							}
						}
						// Bottom-right corner
						if (dx_right < 0 && dy_bottom < 0) {
							if (Math.sqrt(dx_right * dx_right + dy_bottom * dy_bottom) > corner_radius) {
								cut_corner = true;
							}
						}
						if (!cut_corner) {
							map.setType([i, j], PASSABLE);
						}
					}
				}
				break;
		}

		return map;
	}

	static function addIslands(map as Map, left as Number, right as Number, top as Number, bottom as Number, room_shape as RoomShape) as Void {
		var room_width = right - left;
		var room_height = bottom - top;
		
		// Number of islands depends on room size and shape
		var max_islands = 0;
		var room_area = room_width * room_height;
		
		// Calculate max islands based on room size
		if (room_area > 100) {
			max_islands = 4;
		} else if (room_area > 50) {
			max_islands = 3;
		} else if (room_area > 25) {
			max_islands = 2;
		} else {
			max_islands = 1;
		}
		
		// Reduce islands for non-rectangular shapes (they have less open space)
		if (room_shape == ROOMSHAPE_L_SHAPE || room_shape == ROOMSHAPE_T_SHAPE) {
			max_islands = $.MathUtil.max(1, max_islands - 1);
		} else if (room_shape == ROOMSHAPE_PLUS) {
			max_islands = $.MathUtil.max(1, max_islands - 2);
		}
		
		var num_islands = $.MathUtil.random(1, max_islands + 1);
		
		for (var island = 0; island < num_islands; island++) {
			// Choose island size: 1x1, 2x1, 1x2, or 2x2
			var island_type = $.MathUtil.random(0, 3);
			var island_width = (island_type == 0 || island_type == 2) ? 1 : 2;
			var island_height = (island_type == 0 || island_type == 1) ? 1 : 2;
			
			// Try to place the island
			var placed = false;
			var tries = 0;
			while (!placed && tries < 20) {
				tries += 1;
				var ix = $.MathUtil.random(left + 2, right - island_width - 1);
				var iy = $.MathUtil.random(top + 2, bottom - island_height - 1);
				
				// Check if position is valid (not too close to center/spawn)
				var center_x = (left + right) / 2;
				var center_y = (top + bottom) / 2;
				var dist_to_center = $.MathUtil.abs(ix - center_x) + $.MathUtil.abs(iy - center_y);
				
				// Don't place too close to center (spawn point)
				if (dist_to_center < 3) {
					continue;
				}
				
				// Check if all tiles for the island are PASSABLE
				var valid = true;
				for (var dx = 0; dx < island_width && valid; dx++) {
					for (var dy = 0; dy < island_height && valid; dy++) {
						var check_x = ix + dx;
						var check_y = iy + dy;
						if (check_x <= left || check_x >= right || check_y <= top || check_y >= bottom) {
							valid = false;
						} else if (map.getType([check_x, check_y]) != PASSABLE) {
							valid = false;
						}
					}
				}
				
				if (!valid) {
					continue;
				}
				
				// Check if island blocks passage (ensure there's still a path around it)
				// Simple check: make sure there's passable tiles on at least 3 sides
				var passable_sides = 0;
				// Check left
				if (ix > left + 1 && map.getType([ix - 1, iy]) == PASSABLE) {
					passable_sides += 1;
				}
				// Check right
				if (ix + island_width < right - 1 && map.getType([ix + island_width, iy]) == PASSABLE) {
					passable_sides += 1;
				}
				// Check top
				if (iy > top + 1 && map.getType([ix, iy - 1]) == PASSABLE) {
					passable_sides += 1;
				}
				// Check bottom
				if (iy + island_height < bottom - 1 && map.getType([ix, iy + island_height]) == PASSABLE) {
					passable_sides += 1;
				}
				
				if (passable_sides < 3) {
					continue;
				}
				
				// Place the island
				for (var dx = 0; dx < island_width; dx++) {
					for (var dy = 0; dy < island_height; dy++) {
						map.setType([ix + dx, iy + dy], WALL);
					}
				}
				placed = true;
			}
		}
	}

	static function chooseRandomRoomShape() as RoomShape {
		var chances = {
			ROOMSHAPE_RECTANGLE => 40,  // 40% chance
			ROOMSHAPE_L_SHAPE => 25,    // 25% chance
			ROOMSHAPE_T_SHAPE => 20,    // 20% chance
			ROOMSHAPE_PLUS => 10,       // 10% chance
			ROOMSHAPE_ROUNDED => 5      // 5% chance
		};
		return $.MathUtil.weighted_random(chances) as RoomShape;
	}

}
