//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Main picker that shows all the other pickers
class DCAmountPicker extends WatchUi.Picker {

    var _amount as Number;

    //! Constructor
    public function initialize(amount as Number, value as Number) {
        _amount = amount;
        var title = new WatchUi.Text({:text=>"Amount: ", :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new $.DCNumberFactory(0, _amount, 1, {:value=>value});
        Picker.initialize({:title=>title, :pattern=>[factory]});
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

//! Responds to a picker selection or cancellation
class DCAmountPickerDelegate extends WatchUi.PickerDelegate {

    var callback as Method;

    //! Constructor
    public function initialize(callback as Method) {
        PickerDelegate.initialize();
        self.callback = callback;
    }

    //! Handle a cancel event from the picker
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! When a user selects a picker, start that picker
    //! @param values The values chosen in the picker
    //! @return true if handled, false otherwise
    public function onAccept(values as Array) as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        callback.invoke(values[0]);
        return true;
    }

}
