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
					new_map.setTile(i, j, tile.deepcopy());
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

		// Fill interior based on shape (only PASSABLE, walls are added later by addWallsAroundPassable)
		switch (shape) {
			case ROOMSHAPE_RECTANGLE:
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
				// Overlap by 1 row to ensure connectivity
				var v_width = $.MathUtil.max(2, room_width / 3);
				for (var i = right - v_width; i < right; i++) {
					for (var j = top + h_height - 1; j < bottom; j++) {
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
				// Overlap by 1 row to ensure connectivity
				for (var i = stem_start; i < stem_start + stem_width; i++) {
					for (var j = top + bar_height - 1; j < bottom; j++) {
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

		// Safety check: ensure the shape is connected
		if (!isRoomConnected(map, left, right, top, bottom)) {
			// Fall back to rectangle if shape is disconnected
			System.println("WARNING: Room shape " + shape + " is disconnected, falling back to RECTANGLE");
			for (var i = left + 1; i < right; i++) {
				for (var j = top + 1; j < bottom; j++) {
					map.setType([i, j], PASSABLE);
				}
			}
		}

		return map;
	}

	static function addWallsAroundPassable(map as Map) as Void {
		var width = map.getXSize();
		var height = map.getYSize();
		var dirs8 = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
		var toWall = [] as Array<Point2D>;
		for (var x = 0; x < width; x++) {
			for (var y = 0; y < height; y++) {
				if (map.getTile(x, y).type != EMPTY) { continue; }
				for (var d = 0; d < dirs8.size(); d++) {
					var nx = x + dirs8[d][0];
					var ny = y + dirs8[d][1];
					if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
						if (map.getTile(nx, ny).type == PASSABLE) {
							toWall.add([x, y]);
							break;
						}
					}
				}
			}
		}
		for (var i = 0; i < toWall.size(); i++) {
			map.setType(toWall[i], WALL);
		}
	}

	static function addWallsAround(map as Map, x as Number, y as Number) as Void {
		var sx = map.getXSize();
		var sy = map.getYSize();
		var dirs = [[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]] as Array<Array<Number>>;
		for (var d = 0; d < dirs.size(); d++) {
			var cx = x + dirs[d][0];
			var cy = y + dirs[d][1];
			if (cx < 0 || cx >= sx || cy < 0 || cy >= sy) { continue; }
			if (map.getTile(cx, cy).type != PASSABLE) { continue; }
			for (var d2 = 0; d2 < dirs.size(); d2++) {
				var nx = cx + dirs[d2][0];
				var ny = cy + dirs[d2][1];
				if (nx >= 0 && nx < sx && ny >= 0 && ny < sy && map.getTile(nx, ny).type == EMPTY) {
					map.setType([nx, ny], WALL);
				}
			}
		}
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
		} else if (room_area > 64) {
			max_islands = 3;
		} else if (room_area > 36) {
			max_islands = 2;
		} else if (room_area > 20) {
			max_islands = 1;
		} else {
			max_islands = 0;
		}
		
		// Reduce islands for non-rectangular shapes (they have less open space)
		if (room_shape == ROOMSHAPE_L_SHAPE || room_shape == ROOMSHAPE_T_SHAPE) {
			max_islands = $.MathUtil.max(0, max_islands - 1);
		} else if (room_shape == ROOMSHAPE_PLUS) {
			max_islands = $.MathUtil.max(0, max_islands - 2);
		}
		
		var num_islands = (max_islands > 0) ? $.MathUtil.random(0, max_islands + 1) : 0;
		
		// Skip islands if room is too small
		if (room_width < 5 || room_height < 5) {
			return;
		}

		for (var island = 0; island < num_islands; island++) {
			// Choose island size based on room dimensions
			var max_island_w = $.MathUtil.min(4, (room_width - 4) / 2);
			var max_island_h = $.MathUtil.min(4, (room_height - 4) / 2);
			if (max_island_w < 1 || max_island_h < 1) {
				continue;
			}
			var island_width = $.MathUtil.random(1, max_island_w + 1);
			var island_height = $.MathUtil.random(1, max_island_h + 1);
			
			// Try to place the island
			var placed = false;
			var tries = 0;
			var ix_min = left + 3;
			var ix_max = right - island_width - 2;
			var iy_min = top + 3;
			var iy_max = bottom - island_height - 2;
			if (ix_max < ix_min || iy_max < iy_min) {
				continue;
			}
			while (!placed && tries < 20) {
				tries += 1;
				var ix = $.MathUtil.random(ix_min, ix_max);
				var iy = $.MathUtil.random(iy_min, iy_max);
				
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
						if (check_x <= left + 2 || check_x >= right - 2 || check_y <= top + 2 || check_y >= bottom - 2) {
							valid = false;
						} else if (map.getTile(check_x, check_y).type != PASSABLE) {
							valid = false;
						}
					}
				}
				
				if (!valid) {
					continue;
				}
				
				// Place the island
				for (var dx = 0; dx < island_width; dx++) {
					for (var dy = 0; dy < island_height; dy++) {
						map.setType([ix + dx, iy + dy], WALL);
					}
				}

				// Quick local check: each island tile must have at least 2 passable neighbors
				// and no neighbor should be a tunnel tile (narrow passage)
				var island_valid = true;
				for (var dx = 0; dx < island_width && island_valid; dx++) {
					for (var dy = 0; dy < island_height && island_valid; dy++) {
						var ax = ix + dx;
						var ay = iy + dy;
						var passable_neighbors = 0;
						// Inline neighbor check + narrow passage check (no array alloc)
						var nb_dirs = [[0,1],[0,-1],[1,0],[-1,0]] as Array<Array<Number>>;
						for (var d = 0; d < nb_dirs.size(); d++) {
							var nx = ax + nb_dirs[d][0];
							var ny = ay + nb_dirs[d][1];
							if (nx > left && nx < right && ny > top && ny < bottom) {
								if (map.getTile(nx, ny).type == PASSABLE) {
									passable_neighbors += 1;
									// Check if this neighbor is a narrow passage (inlined)
									var narrow_count = 0;
									for (var d2 = 0; d2 < nb_dirs.size(); d2++) {
										var nnx = nx + nb_dirs[d2][0];
										var nny = ny + nb_dirs[d2][1];
										if (nnx >= 0 && nnx < map.getXSize() && nny >= 0 && nny < map.getYSize()) {
											if (map.getTile(nnx, nny).type == PASSABLE) {
												narrow_count += 1;
											}
										}
									}
									if (narrow_count <= 2) {
										island_valid = false;
									}
								}
							}
						}
						if (passable_neighbors < 2) {
							island_valid = false;
						}
					}
				}

				if (!island_valid) {
					// Remove the island - too close to bottleneck
					for (var dx = 0; dx < island_width; dx++) {
						for (var dy = 0; dy < island_height; dy++) {
							map.setType([ix + dx, iy + dy], PASSABLE);
						}
					}
				} else {
					placed = true;
				}
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

	static function isRoomConnected(map as Map, left as Number, right as Number, top as Number, bottom as Number) as Boolean {
		// Find first passable tile by scanning
		var start = null as Point2D?;
		var total_passable = 0;
		for (var i = left + 1; i < right; i++) {
			for (var j = top + 1; j < bottom; j++) {
				if (map.getTile(i, j).type == PASSABLE) {
					total_passable += 1;
					if (start == null) {
						start = [i, j];
					}
				}
			}
		}

		if (start == null || total_passable == 0) {
			return true;
		}

		var visited = {} as Dictionary<Number, Boolean>;
		var queue = [start] as Array<Point2D>;
		visited[(start[0] << 8) + start[1]] = true;
		var reachable = 0;
		var queue_idx = 0;
		var dirs = [[0,1],[0,-1],[1,0],[-1,0]] as Array<Array<Number>>;

		while (queue_idx < queue.size()) {
			var current = queue[queue_idx];
			queue_idx++;
			reachable += 1;
			for (var d = 0; d < dirs.size(); d++) {
				var nx = current[0] + dirs[d][0];
				var ny = current[1] + dirs[d][1];
				if (nx > left && nx < right && ny > top && ny < bottom) {
					var key = (nx << 8) + ny;
					if (visited[key] == null && map.getTile(nx, ny).type == PASSABLE) {
						visited[key] = true;
						queue.add([nx, ny]);
					}
				}
			}
		}

		return reachable >= total_passable;
	}

	static function findNearestPassable(map as Map, pos as Point2D, left as Number, right as Number, top as Number, bottom as Number) as Point2D? {
		var queue = [pos] as Array<Point2D>;
		var visited = {} as Dictionary<Number, Boolean>;
		visited[(pos[0] << 8) + pos[1]] = true;
		var queue_idx = 0;
		var dirs = [[0,1],[0,-1],[1,0],[-1,0]] as Array<Array<Number>>;

		while (queue_idx < queue.size()) {
			var current = queue[queue_idx];
			queue_idx++;
			if (current[0] >= left && current[0] <= right && current[1] >= top && current[1] <= bottom) {
				if (map.getType(current) == PASSABLE && map.getContent(current) == null) {
					return current;
				}
			}
			for (var d = 0; d < dirs.size(); d++) {
				var nx = current[0] + dirs[d][0];
				var ny = current[1] + dirs[d][1];
				var key = (nx << 8) + ny;
				if (visited[key] == null) {
					visited[key] = true;
					if (nx >= left && nx <= right && ny >= top && ny <= bottom) {
						queue.add([nx, ny]);
					}
				}
			}
		}
		return null;
	}

	static function digConnectionTunnel(map as Map, edge_pos as Point2D, direction as WalkDirection, screen_size_x as Number, screen_size_y as Number, target as Point2D) as Array<Point2D> {
		var tunnel_tiles = [] as Array<Point2D>;

		// Determine main direction (toward room)
		var main_dx = 0, main_dy = 0;
		if (direction == LEFT) { main_dx = 1; }
		else if (direction == RIGHT) { main_dx = -1; }
		else if (direction == UP) { main_dy = 1; }
		else if (direction == DOWN) { main_dy = -1; }

		var is_horizontal = (direction == LEFT || direction == RIGHT);

		var x = edge_pos[0];
		var y = edge_pos[1];

		// Set edge position to PASSABLE so player can reach screen border
		if (x >= 0 && x < screen_size_x && y >= 0 && y < screen_size_y) {
			if (map.getTile(x, y).type != PASSABLE) {
				map.setType([x, y], PASSABLE);
			}
			tunnel_tiles.add([x, y]);
		}

		// Phase 1: Dig 2 straight tiles from edge
		for (var i = 0; i < 2; i++) {
			x += main_dx;
			y += main_dy;
			if (x < 0 || x >= screen_size_x || y < 0 || y >= screen_size_y) { break; }
			if (map.getTile(x, y).type == PASSABLE) { break; }
			map.setType([x, y], PASSABLE);
			tunnel_tiles.add([x, y]);
		}

		// Phase 2: Optional curve at tile 2 (50% chance)
		if ($.MathUtil.random(0, 100) < 50) {
			var perp_dir = ($.MathUtil.random(0, 1) == 0) ? -1 : 1;
			var curve_length = $.MathUtil.random(1, 3);
			for (var i = 0; i < curve_length; i++) {
				if (is_horizontal) {
					y += perp_dir;
				} else {
					x += perp_dir;
				}
				if (x < 0 || x >= screen_size_x || y < 0 || y >= screen_size_y) { break; }
				if (map.getTile(x, y).type == PASSABLE) { break; }
				map.setType([x, y], PASSABLE);
				tunnel_tiles.add([x, y]);
			}
		}

		// Phase 3: Continue toward room with random straight/steer chunks
		var max_steps = (screen_size_x + screen_size_y) * 2;
		var straight_left = 0;
		var steer_left = 0;
		for (var step = 0; step < max_steps; step++) {
			// Pick new chunk sizes when both are exhausted
			if (straight_left <= 0 && steer_left <= 0) {
				straight_left = $.MathUtil.random(1, 3);
				steer_left = $.MathUtil.random(1, 2);
			}

			var newX = x;
			var newY = y;
			var moving_main = false;

			if (straight_left > 0) {
				// Main direction
				newX += main_dx;
				newY += main_dy;
				straight_left -= 1;
				moving_main = true;
			} else {
				// Steer: move on perpendicular axis toward target
				if (is_horizontal) {
					if (newY < target[1]) { newY += 1; }
					else if (newY > target[1]) { newY -= 1; }
				} else {
					if (newX < target[0]) { newX += 1; }
					else if (newX > target[0]) { newX -= 1; }
				}
				steer_left -= 1;
			}

			if (newX < 0 || newX >= screen_size_x || newY < 0 || newY >= screen_size_y) { break; }

			// Only break on PASSABLE when moving in main direction (reached room or another tunnel)
			if (moving_main && map.getTile(newX, newY).type == PASSABLE) { break; }

			if (map.getTile(newX, newY).type != PASSABLE) {
				map.setType([newX, newY], PASSABLE);
				tunnel_tiles.add([newX, newY]);
			}

			x = newX;
			y = newY;
		}

		return tunnel_tiles;
	}

}
