import Toybox.Lang;

class NumberCompare {

	function initialize() {
	}

	function compare(a as Object, b as Object) as Number {
		var val1 = a as Number;
		var val2 = b as Number;

		if (val1 < val2) {
			return -1;
		} else if (val1 > val2) {
			return 1;
		}
		return 0;
		
	}
}