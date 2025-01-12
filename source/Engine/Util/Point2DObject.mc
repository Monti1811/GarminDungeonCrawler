import Toybox.Lang;

class Point2DObject {
	var x as Number;
	var y as Number;

	function initialize(x as Number, y as Number) {
		self.x = x;
		self.y = y;
	}

	function add(point as Point2DObject) as Point2DObject {
		return new Point2DObject(self.x + point.x, self.y + point.y);
	}

	function subtract(point as Point2DObject) as Point2DObject {
		return new Point2DObject(self.x - point.x, self.y - point.y);
	}

	function multiply(scalar as Number) as Point2DObject {
		return new Point2DObject(self.x * scalar, self.y * scalar);
	}

	function divide(scalar as Number) as Point2DObject {
		return new Point2DObject(self.x / scalar, self.y / scalar);
	}

	function distance(point as Point2DObject) as Numeric {
		return Math.sqrt(Math.pow(point.x - self.x, 2) + Math.pow(point.y - self.y, 2));
	}

	function toString() as String {
		return "(" + self.x + ", " + self.y + ")";
	}

	function equals(other as Object?) as Boolean {
		if (other == null || !(other instanceof Point2DObject)) {
			return false;
		}
		var point = other as Point2DObject;
		return self.x == point.x && self.y == point.y;
	}

	function hashCode() as Number {
		// Shift x 8 bits to the left and add y
		return self.x << 8 + self.y;
	}

	static function toPoint2D(point as Point2D) as Point2DObject {
		return new Point2DObject(point[0], point[1]);
	}

	static function toArrayPoint2D(points as Array<Point2D>) as Array<Point2DObject> {
		var result = new Array<Point2DObject>[points.size()];
		for (var i = 0; i < points.size(); i++) {
			result[i] = Point2DObject.toPoint2D(points[i]);
		}
		return result;
	}
}