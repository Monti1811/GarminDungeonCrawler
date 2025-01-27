import Toybox.Lang;

class NameCompare {

	private var is_ascending as Boolean;


	function initialize(is_ascending as Boolean) {
		self.is_ascending = is_ascending;
	}

	function compare(a as Object, b as Object) as Number {
		var item1 = a as Item;
		var item2 = b as Item;

		var val1 = item1.name;
		var val2 = item2.name;

		var comparison = val1.compareTo(val2);
		return is_ascending ? comparison : -comparison;
	}
}