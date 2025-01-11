import Toybox.Lang;

class Point2D {
	var x as Number;
	var y as Number;

	function initialize(x as Number, y as Number) {
		self.x = x;
		self.y = y;
	}

	function add(point as Point2D) as Point2D {
		return new Point2D(self.x + point.x, self.y + point.y);
	}

	function subtract(point as Point2D) as Point2D {
		return new Point2D(self.x - point.x, self.y - point.y);
	}

	function multiply(scalar as Number) as Point2D {
		return new Point2D(self.x * scalar, self.y * scalar);
	}

	function divide(scalar as Number) as Point2D {
		return new Point2D(self.x / scalar, self.y / scalar);
	}

	function distance(point as Point2D) as Numeric {
		return Math.sqrt(Math.pow(point.x - self.x, 2) + Math.pow(point.y - self.y, 2));
	}

	function toString() as String {
		return "(" + self.x + ", " + self.y + ")";
	}

	function equals(other as Object?) as Boolean {
		if (other == null || !(other instanceof Point2D)) {
			return false;
		}
		return self.x == point.x && self.y == point.y;
	}

	function hashCode() as Number {
		return self.x * 31 + self.y;
	}

	static function toPoint2D(point as Array<Number>) as Point2D {
		return new Point2D(point[0], point[1]);
	}

	static function toArrayPoint2D(points as Array<[Number, Number]>) as Array<Point2D> {
		var result = new Array<Point2D>[points.size()];
		for (var i = 0; i < points.size(); i++) {
			result[i] = Point2D.toPoint2D(points[i]);
		}
		return result;
	}
}