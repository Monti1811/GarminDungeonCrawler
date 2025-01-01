import Toybox.Lang;

module Main {

	function createNewGame(player as Player) as Void {
		var app = getApp();
		app.setPlayer(player);
		app.setCurrentDungeon(createNewDungeon());
	}

	function startGame() as Void {
		Log.log("Game started");
	}

	function createNewDungeon() as Dungeon {
		var size_x = MathUtil.random(3, 5);
		var size_y = MathUtil.random(3, 5);
		var dungeon = new Dungeon(size_x, size_y);
		dungeon.addRoom(new Room(null), [0,0], {LEFT =>[1,0]});
		dungeon.addRoom(new Room(null));
		dungeon.addRoom(new Room(null));
		return dungeon;
	}

	function createRandomRoom() as Room {
		var room = new Room(null);
		var num_items = MathUtil.random(0, 3);
		for (var i = 0; i < num_items; i++) {
			room.addItem(new Item("Item " + i));
		}
		return room;
	}
}