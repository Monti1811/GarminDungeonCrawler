import Toybox.Lang;

module Listener {
	
	var listeners as Dictionary<Symbol, Array<Method>> = {};

	function clear() {
		listeners = {};
	}

	//! Add a listener
	//! @param event The event
	//! @param listener The listener
	public function addListener(event as Symbol, listener as Method) {
		if (listeners[event] == null) {
			listeners[event] = [];
		}
		listeners[event].add(listener);
	}

	//! Remove a listener
	//! @param event The event
	//! @param listener The listener
	public function removeListener(event as Symbol, listener as Method) {
		if (listeners[event] == null) {
			return;
		}
		listeners[event].remove(listener);
	}

	//! Trigger an event
	//! @param event The event
	//! @param args The arguments
	public function trigger(event as Symbol, args) {
		if (listeners[event] == null) {
			return;
		}
		for (var i = 0; i < listeners[event].size(); i++) {
			listeners[event][i].invoke(args);
		}
	}

}