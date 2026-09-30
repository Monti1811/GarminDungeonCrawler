import Toybox.Lang;
import Toybox.WatchUi;

class Blacksmith extends NPC {

	var forge_menu as WatchUi.Menu2? = null;

	function initialize() {
		NPC.initialize();
		self.id = 2;
		self.name = "Blacksmith";
		self.description = "A sturdy smith who can temper your equipment.";
		self.dialog = "Bring me ore and gold, and I shall temper your blade.";
	}

	function getSprite() as ResourceId {
		return $.Rez.Drawables.blacksmith;
	}

	function getForgeTitle() as String {
		return "Forge (" + $.getApp().getPlayer().getGold() + " gold)";
	}

	function updateForgeTitle() as Void {
		var menu = forge_menu;
		if (menu != null) {
			menu.setTitle(getForgeTitle());
		}
	}

	function closeForge() as Void {
		forge_menu = null;
	}

	function onInteract() as Void {
		DebugLogger.println("Interacting with blacksmith");
		var smithMenu = new WatchUi.Menu2({:title=>getForgeTitle()});
		smithMenu.addItem(new WatchUi.MenuItem("Upgrade", "Upgrade your equipment", :upgrade, null));
		smithMenu.addItem(new WatchUi.MenuItem("Talk", "Talk with the blacksmith", :talk, null));
		forge_menu = smithMenu;
		WatchUi.pushView(smithMenu, new DCBlacksmithDelegate(self), WatchUi.SLIDE_UP);
	}

	function deepcopy() as Entity {
		var npc = new Blacksmith();
		npc.name = name;
		npc.pos = pos;
		return npc;
	}

}
