import Toybox.WatchUi;
import Toybox.Lang;

class DCShopDelegate extends WatchUi.Menu2InputDelegate {

    private var shopMenu as WatchUi.Menu2;
    private var merchant as Merchant;

    function initialize(shopMenu as WatchUi.Menu2, merchant as Merchant) {
        Menu2InputDelegate.initialize();
        self.shopMenu = shopMenu;
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
                var dialog = new WatchUi.Confirmation(merchant.getDialog());
                break;
        }
    }

    function showBuyMenu() as Void {
        var items = merchant.getSellableItems();
        var buyMenu = new WatchUi.Menu2({:title=>"Buy"});
        for (var i = 0; i < items.size(); i++) {
            var item = items[i];
            buyMenu.addItem(new WatchUi.MenuItem(item.getName(), "Cost: " + item.getValue() + " gold", item, null));
        }
        WatchUi.pushView(buyMenu, new DCShopBuyDelegate(buyMenu, merchant), WatchUi.SLIDE_UP);
    }

    function showSellMenu() as Void {
        var player = getApp().getPlayer();
        var items = player.getInventory().getItems();
        var sellMenu = new WatchUi.Menu2({:title=>"Sell"});
        for (var i = 0; i < items.size(); i++) {
            var item = items[i];
            sellMenu.addItem(new WatchUi.MenuItem(item.getName(), "Value: " + item.getSellValue() + " gold", item, null));
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
                doBuy();
                break;
            case :info:
                showInfo(self.item);
                break;
        }  
    }

    function doBuy() as Void {
        var player = getApp().getPlayer();
        var cost = item.getValue();
        var can_buy = player.doGoldDelta(-cost);
        if (can_buy) {
            player.addInventoryItem(item);
            merchant.removeSellableItem(item);
            var index = buyMenu.findItemById(item);
            buyMenu.deleteItem(index);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else {
            var dialog = new WatchUi.Confirmation("You don't have enough gold to buy this item.");
            // TODO create a new view that shows text and an accept icon at the bottom
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
                doSell();
                break;
            case :info:
                showInfo(self.item);
                break;
        }  
    }

    function doSell() as Void {
        var player = getApp().getPlayer();
        var value = item.getSellValue();
        player.doGoldDelta(value);
        player.removeInventoryItem(item);
        merchant.addSellableItem(item);
        var index = sellMenu.findItemById(item);
        sellMenu.deleteItem(index);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
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