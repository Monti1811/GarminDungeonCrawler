import Toybox.Lang;

class SaveCompare {


		function initialize() {
		}

		function compare(a as Object, b as Object) as Number {
			var val1 = (a as String).toNumber();
			var val2 = (b as String).toNumber();

			if (val2 < val1) {
				return -1;
			} else if (val2 > val1) {
				return 1;
			}
			return 0;
			
		}
	}