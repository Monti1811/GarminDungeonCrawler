import Toybox.Lang;

class Merchant extends NPC {
	
	var items as Array<Item> = [];

	function initialize() {
		NPC.initialize();
		self.dialog = "Hello, traveler!";
		addRandomItems();
	}

	function addRandomItems() as Void {
		var amount = MathUtil.random(1, 5);
		for (var i = 0; i < amount; i++) {
			var item = Items.createRandomWeightedItem(4);
			items.add(item);
		}
	}	

	function getSellableItems() as Array<Item> {
		return items;
	}

	function addSellableItem(item as Item) as Void {
		items.add(item);
	}

	function removeSellableItem(item as Item) as Void {
		items.remove(item);
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.Merchant;
	}

	function onInteract() as Void {
		System.println("Interacting with merchant");
		var shopMenu = new WatchUi.Menu2({:title=>"Shop"});
		shopMenu.addItem(new WatchUi.MenuItem("Buy", "Buy an item", :buy, null));
		shopMenu.addItem(new WatchUi.MenuItem("Sell", "Sell an item", :sell, null));
		shopMenu.addItem(new WatchUi.MenuItem("Talk", "Talk with the merchant", :talk, null));
		WatchUi.pushView(shopMenu, new DCShopDelegate(self), WatchUi.SLIDE_UP);
	}

	function deepcopy() as Entity {
		var npc = new Merchant();
		npc.name = name;
		npc.pos = pos;
		npc.items = items;
		return npc;
	}

	function save() as Dictionary {
		var save_data = NPC.save();
		var items_data = [] as Array<Dictionary>;
		for (var i = 0; i < items.size(); i++) {
			var item = items[i];
			items_data.add(item.save());
		}
		save_data["items"] = items_data;
		save_data["dialog"] = dialog;
		return save_data;
	}

	function onLoad(save_data as Dictionary) as Void {
		NPC.onLoad(save_data);
		var items_data = save_data["items"] as Array<Dictionary>?;
		if (items_data != null && items_data.size() > 0) {
			items = [] as Array<Item>;
			for (var i = 0; i < items_data.size(); i++) {
				var item = Item.load(items_data[i]);
				items.add(item);
			}
		}
		if (save_data["dialog"] != null) {
			dialog = save_data["dialog"] as String;
		}
	}
	
}