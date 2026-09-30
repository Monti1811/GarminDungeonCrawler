import Toybox.Lang;
import Toybox.Test;

(:test)
function debugItemListIncludesMaterials(logger as Test.Logger) as Boolean {
    var delegate = new DCDebugMenuDelegate();
    var items = delegate.getDebugItemList();

    var found_material = false;
    for (var i = 0; i < items.size(); i++) {
        if (items[i].getItemType() == MATERIAL) {
            found_material = true;
            break;
        }
    }
    Test.assert(found_material);
    return true;
}

(:test)
function debugItemListFiltersByItemType(logger as Test.Logger) as Boolean {
    var delegate = new DCDebugMenuDelegate();
    delegate.item_filter = [WEAPON] as Array<ItemType>;
    delegate.item_filter_str = "Weapon";
    var items = delegate.getDebugItemList();

    Test.assert(items.size() > 0);
    for (var i = 0; i < items.size(); i++) {
        Test.assert(items[i].getItemType() == WEAPON);
    }

    delegate.item_filter = null;
    delegate.item_filter_str = "All Items";
    return true;
}

(:test)
function debugItemListSortsByIdDescending(logger as Test.Logger) as Boolean {
    var delegate = new DCDebugMenuDelegate();
    delegate.item_sort = "Id";
    delegate.item_sort_ascending = false;
    var items = delegate.getDebugItemList();

    Test.assert(items.size() > 1);
    for (var i = 1; i < items.size(); i++) {
        Test.assert(items[i].id <= items[i - 1].id);
    }

    delegate.item_sort_ascending = true;
    return true;
}

(:test)
function debugItemListSortsByNameDescending(logger as Test.Logger) as Boolean {
    var delegate = new DCDebugMenuDelegate();
    delegate.item_sort = "Name";
    delegate.item_sort_ascending = false;
    delegate.item_sort_comparator = new NameCompare(false);
    var items = delegate.getDebugItemList();

    Test.assert(items.size() > 1);
    for (var i = 1; i < items.size(); i++) {
        Test.assert(items[i - 1].name.compareTo(items[i].name) >= 0);
    }

    delegate.item_sort = "Id";
    delegate.item_sort_ascending = true;
    delegate.item_sort_comparator = null;
    return true;
}

(:test)
function debugItemListReusesCachedItemInstances(logger as Test.Logger) as Boolean {
    var delegate = new DCDebugMenuDelegate();
    var ascending = delegate.getDebugItemList();

    delegate.item_sort_ascending = false;
    var descending = delegate.getDebugItemList();
    delegate.item_sort_ascending = true;
    var ascending_again = delegate.getDebugItemList();

    Test.assert(ascending.size() > 1);
    Test.assert(ascending.size() == descending.size());
    Test.assert(ascending.size() == ascending_again.size());
    for (var i = 0; i < ascending.size(); i++) {
        Test.assert(ascending[i] == ascending_again[i]);
        Test.assert(ascending[i] == descending[descending.size() - 1 - i]);
    }
    return true;
}

(:test)
function debugItemListReusesItemIcons(logger as Test.Logger) as Boolean {
    var delegate = new DCDebugMenuDelegate();
    var items = delegate.getDebugItemList();

    var icon = delegate.getDebugItemIcon(items[0]);
    Test.assert(icon != null);
    Test.assert(icon == delegate.getDebugItemIcon(items[0]));
    return true;
}
