import Toybox.Lang;
import Toybox.System;

module DebugLogger {

	(:debug)
	function print(message as String) as Void {
		System.print(message);
	}

	(:release)
	function print(message as String) as Void {
	}

	(:debug)
	function println(message as String) as Void {
		System.println(message);
	}

	(:release)
	function println(message as String) as Void {
	}
}
