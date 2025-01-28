import Toybox.Lang;

class WeightCompare {

	private var is_ascending as Boolean;


	function initialize(is_ascending as Boolean) {
		self.is_ascending = is_ascending;
	}

	function compare(a as Object, b as Object) as Number {
		var item1 = a as Item;
		var item2 = b as Item;

		var val1 = item1.weight;
		var val2 = item2.weight;

		if (!is_ascending) {
			if (val2 < val1) {
				return -1;
			} else if (val2 > val1) {
				return 1;
			}
		} else {
			if (val1 < val2) {
				return -1;
			} else if (val1 > val2) {
				return 1;
			}
		}
		return 0;
	}
}