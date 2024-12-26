//
// Copyright 2015-2023 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! ViewLoop Factory which manages the main primate view/delegate paires
class DCGameMenuItemInfoFactory extends WatchUi.ViewLoopFactory {
    private const NUM_PAGES = 3;
    private var _item as Item;

    function initialize(item as Item) {
        ViewLoopFactory.initialize();
        _item = item;
    }

    //! Retrieve a view/delegate pair for the page at the given index
    function getView(page as Number) as [View] or [View, BehaviorDelegate] {
        switch (page) {
            case 0:
                return [new $.DCItemInfoOverviewView(_item), new WatchUi.BehaviorDelegate()];
            case 1:
                return [new $.DCItemInfoValuesView(_item), new WatchUi.BehaviorDelegate()];
            case 2: 
                return [new $.DCItemInfoDescriptionView(_item), new WatchUi.BehaviorDelegate()];
        }
        return [new $.DCItemInfoOverviewView(_item), new WatchUi.BehaviorDelegate()];
    }

    //! Return the number of view/delegate pairs that are managed by this factory
    function getSize() {
        return NUM_PAGES;
    }
}