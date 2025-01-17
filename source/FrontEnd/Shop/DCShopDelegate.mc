import Toybox.WatchUi;
import Toybox.Lang;

class DCShopDelegate extends WatchUi.Menu2InputDelegate {

    private var merchant as Merchant;

    function initialize(merchant as Merchant) {
        Menu2InputDelegate.initialize();
        self.merchant = merchant;
    }

    function onSelect(item as MenuItem) as Void {
        var type = item.getId() as Symbol;
        switch (type) {
            case :buy:
                showBuyMenu();
                break;
            case :sell:
                showSellMenu();
                break;
            case :talk:
                WatchUi.pushView(new TextView(merchant.getDialog()), new TextDelegate(), WatchUi.SLIDE_UP);
                break;
        }
    }

    function showBuyMenu() as Void {
        var items = merchant.getSellableItems();
        var buyMenu = new WatchUi.Menu2({:title=>"Buy"});
        for (var i = 0; i < items.size(); i++) {
            var item = items[i];
            var amount = item.getAmount();
            var icon = new DCItemIcon(item);
            buyMenu.addItem(new WatchUi.IconMenuItem(item.getName() + " x" + amount, "Cost: " + item.getValue() + " gold", item, icon, null));
        }
        WatchUi.pushView(buyMenu, new DCShopBuyDelegate(buyMenu, merchant), WatchUi.SLIDE_UP);
    }

    function showSellMenu() as Void {
        var player = getApp().getPlayer();
        var items = player.getInventory().getItems();
        var sellMenu = new WatchUi.Menu2({:title=>"Sell"});
        for (var i = 0; i < items.size(); i++) {
            var item = items[i];
            var amount = item.getAmount();
            var icon = new DCItemIcon(item);
            sellMenu.addItem(new WatchUi.IconMenuItem(item.getName() + " x" + amount, "Value: " + item.getSellValue() + " gold", item, icon, null));
        }
        WatchUi.pushView(sellMenu, new DCShopSellDelegate(sellMenu, merchant), WatchUi.SLIDE_UP);
    }

}

class DCShopBuyDelegate extends WatchUi.Menu2InputDelegate {

    private var buyMenu as WatchUi.Menu2;
    private var merchant as Merchant;

    function initialize(buyMenu as WatchUi.Menu2, merchant as Merchant) {
        Menu2InputDelegate.initialize();
        self.buyMenu = buyMenu;
        self.merchant = merchant;
    }

    function onSelect(menuItem as MenuItem) as Void {
        var item = menuItem.getId() as Item;
        var optionsMenu = new WatchUi.Menu2({:title=>"Buy Item"});
        optionsMenu.addItem(new WatchUi.MenuItem("Buy", "Buy item", :buy, null));
        optionsMenu.addItem(new WatchUi.MenuItem("Info", "More information", :info, null));
        WatchUi.pushView(optionsMenu, new DCShopBuyOptionsDelegate(buyMenu, merchant, item), WatchUi.SLIDE_UP);
    }

}

class DCShopBuyOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var buyMenu as WatchUi.Menu2;
    private var merchant as Merchant;
    private var item as Item;

    function initialize(buyMenu as WatchUi.Menu2, merchant as Merchant, item as Item) {
        Menu2InputDelegate.initialize();
        self.buyMenu = buyMenu;
        self.merchant = merchant;
        self.item = item;
    }

    function onSelect(menuItem as MenuItem) as Void {
        var type = menuItem.getId() as Symbol;
        switch (type) {
            case :buy:
                WatchUi.pushView(new DCAmountPicker(self.item.getAmount(), self.item.getValue()), new DCAmountPickerDelegate(new Method(self, :doBuy)), WatchUi.SLIDE_UP);
                break;
            case :info:
                showInfo(self.item);
                break;
        }  
    }

    function doBuy(amount as Number) as Void {
        if (amount <= 0) {
            return;
        }
        var player = getApp().getPlayer();
        var cost = item.getValue() * amount;
        var can_buy = player.doGoldDelta(-cost);
        if (can_buy) {
            var purchased_item = item.deepcopy();
            purchased_item.setAmount(amount);
            player.addInventoryItem(purchased_item);
            item.setAmount(item.getAmount() - amount);
            var index = buyMenu.findItemById(item);
            if (item.getAmount() == 0) {
                buyMenu.deleteItem(index);
                merchant.removeSellableItem(item);
            } else {
                buyMenu.updateItem(new WatchUi.IconMenuItem(item.getName() + " x" + item.getAmount(), "Cost: " + item.getValue() + " gold", item, new DCItemIcon(item), null), index);
            }
        } else {
            WatchUi.showToast("Not enough gold", {:icon=>Rez.Drawables.cancelToastIcon});
        }
    }

    function showInfo(item as Item) {
        var factory = new DCGameMenuItemInfoFactory(item);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCGameMenuItemInfoDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}

class DCShopSellDelegate extends WatchUi.Menu2InputDelegate {
    
    private var sellMenu as WatchUi.Menu2;
    private var merchant as Merchant;

    function initialize(sellMenu as WatchUi.Menu2, merchant as Merchant) {
        Menu2InputDelegate.initialize();
        self.sellMenu = sellMenu;
        self.merchant = merchant;
    }

    function onSelect(menuItem as MenuItem) as Void {
        var item = menuItem.getId() as Item;
        var optionsMenu = new WatchUi.Menu2({:title=>"Sell Item"});
        optionsMenu.addItem(new WatchUi.MenuItem("Sell", "Sell item", :sell, null));
        optionsMenu.addItem(new WatchUi.MenuItem("Info", "More information", :info, null));
        WatchUi.pushView(optionsMenu, new DCShopSellOptionsDelegate(sellMenu, merchant, item), WatchUi.SLIDE_UP);
    }
}

class DCShopSellOptionsDelegate extends WatchUi.Menu2InputDelegate {

    private var sellMenu as WatchUi.Menu2;
    private var merchant as Merchant;
    private var item as Item;

    function initialize(sellMenu as WatchUi.Menu2, merchant as Merchant, item as Item) {
        Menu2InputDelegate.initialize();
        self.sellMenu = sellMenu;
        self.merchant = merchant;
        self.item = item;
    }

    function onSelect(menuItem as MenuItem) as Void {
        var type = menuItem.getId() as Symbol;
        switch (type) {
            case :sell:
                WatchUi.pushView(new DCAmountPicker(self.item.getAmount(), self.item.getSellValue()), new DCAmountPickerDelegate(new Method(self, :doSell)), WatchUi.SLIDE_UP);
                break;
            case :info:
                showInfo(self.item);
                break;
        }  
    }

    function doSell(amount as Number) as Void {
        if (amount <= 0) {
            return;
        }
        var player = getApp().getPlayer();
        var value = item.getSellValue();
        player.doGoldDelta(value);
        var sold_items = player.getInventory().removeMultiple(item, amount) as Item;
        merchant.addSellableItem(sold_items);
        var index = sellMenu.findItemById(item);
        if (item.getAmount() == 0) {
            sellMenu.deleteItem(index);
        } else {
            sellMenu.updateItem(new WatchUi.IconMenuItem(item.getName() + " x" + item.getAmount(), "Value: " + item.getSellValue() + " gold", item, new DCItemIcon(item), null), index);
        }
    }

    function showInfo(item as Item) {
        var factory = new DCGameMenuItemInfoFactory(item);
        var viewLoop = new WatchUi.ViewLoop(factory, {:wrap => true});
        WatchUi.pushView(viewLoop, new DCGameMenuItemInfoDelegate(viewLoop), WatchUi.SLIDE_IMMEDIATE);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}