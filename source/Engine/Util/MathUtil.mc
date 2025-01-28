import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

typedef Point2D as [Numeric, Numeric];

module MathUtil {

	function floor(value as Numeric, max as Numeric) as Numeric {
		if (value < max) {
			return value;
		}
		return max;
	}

	function ceil(value as Numeric, min as Numeric) as Numeric {
		if (value > min) {
			return value;
		}
		return min;
	}

	function random(min as Numeric, max as Numeric) as Number {
		min = min.toNumber();
		max = max.toNumber();
		return min + Math.rand() % (max - min + 1);
	}

	function rand() as Numeric {
		return (Math.rand() % 100).toFloat() / 100.0;
	}

	function max(value1 as Numeric, value2 as Numeric) as Numeric {
		if (value1 > value2) {
			return value1;
		}
		return value2;
	}

	function min(value1 as Numeric, value2 as Numeric) as Numeric {
		if (value1 < value2) {
			return value1;
		}
		return value2;
	}

	function clamp(value as Numeric, min as Numeric, max as Numeric) as Numeric {
		if (value < min) {
			return min;
		}
		if (value > max) {
			return max;
		}
		return value;
	}

	//! Function to see if a tap falls within a given touch area
	//! @param x X coord of tap
	//! @param y Y coord of tap
	//! @return true if tapped, false otherwise
	function isInAreaArray(coord as Array<Numeric>, area as Array<Numeric>, tolerance as Float) as Boolean {
		if (coord.size() == 2 && area.size() == 4) {
			var x = coord[0];
			var y = coord[1];

			var x1 = area[0] - tolerance * area[0];
			var x2 = area[1] + tolerance * area[1];
			var y1 = area[2] - tolerance * area[2];
			var y2 = area[3] + tolerance * area[3];	

			if (x >= x1 && x <= x2 && y >= y1 && y <= y2) {
				return true;
			}
		}
		return false;
	}

	//! Function to see if a tap falls within a given touch area
	//! @param x X coord of tap
	//! @param y Y coord of tap
	//! @return true if tapped, false otherwise
	function isInArea(x as Numeric, y as Numeric, x1 as Numeric, x2 as Numeric, y1 as Numeric, y2 as Numeric) as Boolean {
		return (x >= x1 && x <= x2 && y >= y1 && y <= y2);
	}

	function abs(value as Numeric) as Numeric {
		if (value < 0) {
			return -value;
		}
		return value;
	}

	function area(x1 as Numeric, y1 as Numeric, x2 as Numeric, y2 as Numeric, x3 as Numeric, y3 as Numeric) {
		return abs((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2.0);
	}
 

	function isInTriangle(x as Number, y as Number, x1 as Numeric, y1 as Numeric, x2 as Numeric, y2 as Numeric, x3 as Numeric, y3 as Numeric) as Boolean {
		/*var A = 1/2 * (-y2 * x3 + y1 * (-x2 + x3) + x1 * (y2 - y3) + x2 * y3);
		var sign = A < 0 ? -1 : 1;
		var s = (y1 * x3 - x1 * y3 + (y3 - y1) * x + (x1 - x3) * y) * sign;
		var t = (x1 * y2 - y1 * x2 + (y1 - y2) * x + (x2 - x1) * y) * sign;
		return s > 0 && t > 0 && (s + t) < 2 * A * sign;*/

		// Calculate area of triangle ABC
		var A = area (x1, y1, x2, y2, x3, y3);
	
		// Calculate area of triangle PBC 
		var A1 = area (x, y, x2, y2, x3, y3);
		
		// Calculate area of triangle PAC 
		var A2 = area (x1, y1, x, y, x3, y3);
		
		// Calculate area of triangle PAB 
		var A3 = area (x1, y1, x2, y2, x, y);
		
		// Check if sum of A1, A2 and A3 
		// is same as A
		if(A == A1 + A2 + A3) {
			return true;
		} else {
			return false;
		}
	}

	function isInTriangleArray(coord as Array<Number>, triangle as Array<Numeric>) as Boolean {
		return isInTriangle(coord[0], coord[1], triangle[0], triangle[1], triangle[2], triangle[3], triangle[4], triangle[5]);
	}

	function getArcCoordinates(cx as Number, cy as Number, r as Number, startAngleDeg as Number, endAngleDeg as Number) as Array {
		var startAngleRad = Math.toRadians(startAngleDeg);
		var endAngleRad = Math.toRadians(endAngleDeg);

		var startX = cx + r * Math.cos(startAngleRad);
		var startY = cy + r * Math.sin(startAngleRad);

		var endX = cx + r * Math.cos(endAngleRad);
		var endY = cy + r * Math.sin(endAngleRad);

		return [
			[startX, startY],
			[endX, endY]
		];
	}

	function IndexToPos2D(index as Numeric, width as Numeric) as Point2D {
		var x = index % width;
		var y = Math.floor(index / width);
		return [x, y];
	}

	function Pos2DToIndex(pos as Point2D, width as Numeric) as Numeric {
		return pos[1] * width + pos[0];
	}

	function PosToIndex2D(x as Numeric, y as Numeric, width as Numeric) as Numeric {
		return y * width + x;
	}

	function isPointAdjacent(p1 as Point2D, p2 as Point2D) as Boolean {
		return (abs(p1[0] - p2[0]) <= 1 && abs(p1[1] - p2[1]) <= 1);
	}

	function isPointDirectAdjacent(p1 as Point2D, p2 as Point2D) as Boolean {
		return (abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]) == 1);
	}
}