import Toybox.ActivityMonitor;
import Toybox.Lang;

module Sensor {

    (:debug) var _mock as Mock.MockInstance? = null;
    
	(:debug)
    function setMock(_mockInstance as Object?) as Void {
		_mock = _mockInstance as Mock.MockInstance?;
    }

	(:release)
    function setMock(_mockInstance as Object?) as Void {
    }

	(:debug)
    function getSteps() as Number? {
        if (_mock != null) {
            return _mock.invoke(:getSteps) as Number?;
        }
    	return null;
    }

	(:release)
	function getSteps() as Number? {
        var info = ActivityMonitor.getInfo();
        if (info == null) {
            return null;
        }
        return info.steps;
    }
}
