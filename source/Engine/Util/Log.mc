import Toybox.Lang;
import Toybox.System;

module Log {

	var max_size as Number = 100;
	var messages as Array<String> = [];

	function log(message as String) as Void {
		if (messages.size() >= max_size) {
			clearLastMessages(max_size/2);
		}
		messages.add(message);
	}

	function print() as Void {
		for (var i = 0; i < messages.size(); i++) {
			System.println(messages[i]);
		}
	}

	function clear() as Void {
		messages = [];
	}

	function clearLastMessages(num_messages as Number) as Void {
		messages = messages.slice(messages.size() - num_messages, messages.size());
	}

	function getLastMessage() as String? {
		if (messages.size() > 0) {
			return messages[messages.size() - 1];
		}
		return null;
	}

	function getLastMessages(num_messages as Number) as Array<String> {
		if (num_messages > messages.size()) {
			num_messages = messages.size();
		}
		return messages.slice(messages.size() - num_messages, messages.size());
	}


}