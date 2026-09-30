import Toybox.WatchUi;
import Toybox.Lang;

(:debug)
class DCDebugItemFilterDelegate extends WatchUi.Menu2InputDelegate {

    private var _delegate as DCDebugMenuDelegate;

    function initialize(delegate as DCDebugMenuDelegate) {
        Menu2InputDelegate.initialize();
        _delegate = delegate;
    }

    function addDebugItemFilter(filter as ItemType) as Void {
        var item_filter = _delegate.item_filter as Array<ItemType>?;
        if (item_filter == null) {
            item_filter = [] as Array<ItemType>;
        }
        if (item_filter.indexOf(filter) == -1) {
            item_filter.add(filter);
        }
        _delegate.item_filter = item_filter;
        _delegate.item_filter_str = "";
        for (var i = 0; i < item_filter.size(); i++) {
            if (i > 0) {
                _delegate.item_filter_str += "/";
            }
            _delegate.item_filter_str += $.Constants.ITEMTYPE_TO_STR[item_filter[i]];
        }
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :all:
                _delegate.item_filter = null;
                _delegate.item_filter_str = "All Items";
                break;
            case :weapons:
                addDebugItemFilter(WEAPON);
                break;
            case :armor:
                addDebugItemFilter(ARMOR);
                break;
            case :consumables:
                addDebugItemFilter(CONSUMABLE);
                break;
            case :materials:
                addDebugItemFilter(MATERIAL);
                break;
            case :sort_id:
            case :sort_name:
            case :sort_weight:
            case :sort_value:
                var sortMenu = new WatchUi.Menu2({:title=>"Sort by"});
                sortMenu.addItem(new WatchUi.MenuItem("Ascending", null, true, null));
                sortMenu.addItem(new WatchUi.MenuItem("Descending", null, false, null));
                WatchUi.pushView(sortMenu, new DCDebugItemSortDelegate(_delegate, type), WatchUi.SLIDE_UP);
                return;
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _delegate.openItemList();
    }
}

(:debug)
class DCDebugItemSortDelegate extends WatchUi.Menu2InputDelegate {

    private var _delegate as DCDebugMenuDelegate;
    private var _sort_type as Symbol;

    function initialize(delegate as DCDebugMenuDelegate, sort_type as Symbol) {
        Menu2InputDelegate.initialize();
        _delegate = delegate;
        _sort_type = sort_type;
    }

    function onSelect(item as MenuItem) as Void {
        var is_ascending = item.getId() as Boolean;
        if (_sort_type == :sort_id) {
            _delegate.item_sort = "Id";
            _delegate.item_sort_comparator = null;
        } else if (_sort_type == :sort_name) {
            _delegate.item_sort_comparator = new NameCompare(is_ascending);
            _delegate.item_sort = "Name";
        } else if (_sort_type == :sort_weight) {
            _delegate.item_sort_comparator = new WeightCompare(is_ascending);
            _delegate.item_sort = "Weight";
        } else if (_sort_type == :sort_value) {
            _delegate.item_sort_comparator = new ValueCompare(is_ascending);
            _delegate.item_sort = "Value";
        }
        _delegate.item_sort_ascending = is_ascending;
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _delegate.openItemList();
    }
}
