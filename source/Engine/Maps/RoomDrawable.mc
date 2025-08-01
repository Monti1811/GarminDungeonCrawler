import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;


class RoomDrawable extends WatchUi.Drawable {

    private var _tile_width as Number;
    private var _tile_height as Number;

    private var _map_string as Array<String>?;
    private var _font as FontReference?;


    function initialize(options as Dictionary?) {
        Drawable.initialize(options);
        _tile_width = options[:tile_width];
        _tile_height = options[:tile_height];
        _map_string = options[:map_string] as Array<String>;

        printRoom();

        _font = WatchUi.loadResource($.Rez.Fonts.dungeon);

    }

    function freeMemory() as Void {
        _map_string = null;
        _font = null;
    }

    function printRoom() as Void {
        System.println("Printing room");
        for (var i = 0; i < _map_string.size(); i++) {
            System.println(_map_string[i]);
        }
    }

    function updateToNewRoom(options as Dictionary) as Void {
        _map_string = options[:map_string] as Array<String>;
    }

    function drawItem(dc as Dc, item as Item) as Void {
        var item_pos = item.getPos();
        var item_sprite_ref = item.getSpriteRef();
        var item_sprite_offset  = item.getSpriteOffset();
        dc.drawBitmap(
                item_pos[0] * _tile_width - item_sprite_offset[0], 
                item_pos[1] * _tile_height - item_sprite_offset[1], 
                item_sprite_ref
        );
    }

    function drawItems(dc as Dc, items as Dictionary<Point2D, Item>) as Void {
        var item_values = items.values() as Array<Item>;
        for (var i = 0; i < item_values.size(); i++) {
            var item = item_values[i];
            drawItem(dc, item);
        }
    }

    function drawEnemy(dc as Dc, enemy as Enemy) as Void {
        var enemy_pos = enemy.getPos();
        var enemy_sprite_ref = enemy.getSpriteRef();
        var enemy_sprite_offset = enemy.getSpriteOffset();
        dc.drawBitmap(
                enemy_pos[0] * _tile_width - enemy_sprite_offset[0], 
                enemy_pos[1] * _tile_height - enemy_sprite_offset[1], 
                enemy_sprite_ref
        );
        drawEnemyHealth(dc, enemy);
    }

    function drawEnemies(dc as Dc, enemies as Dictionary<Point2D, Enemy>) as Void {
        var enemy_values = enemies.values() as Array<Enemy>;
        for (var i = 0; i < enemy_values.size(); i++) {
            var enemy = enemy_values[i];
            drawEnemy(dc, enemy);
        }
    }

    function drawEnemyHealth(dc as Dc, enemy as Enemy) as Void {
        // Draw a small healthbar below the enemy, size 16x2
        var enemy_pos = enemy.getPos();
        var health_percent = enemy.getHealthPercent();
        var bar_percent = (16 * health_percent).toNumber();
        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_BLACK);
        dc.fillRectangle(enemy_pos[0] * _tile_width, enemy_pos[1] * _tile_height + _tile_height, bar_percent, 2);
    }

    function drawNPC(dc as Dc, npc as NPC) as Void {
        var npc_pos = npc.getPos();
        var npc_sprite_ref = npc.getSpriteRef();
        var npc_sprite_offset = npc.getSpriteOffset();
        dc.drawBitmap(
                npc_pos[0] * _tile_width - npc_sprite_offset[0], 
                npc_pos[1] * _tile_height - npc_sprite_offset[1], 
                npc_sprite_ref
        );
    }

    function drawNPCs(dc as Dc, npcs as Dictionary<Point2D, NPC>) as Void {
        var npc_values = npcs.values() as Array<NPC>;
        for (var i = 0; i < npc_values.size(); i++) {
            var npc = npc_values[i];
            drawNPC(dc, npc);
        }
    }

    function draw(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        for (var i = 0; i < _map_string.size(); i++) {
            dc.drawText(0, i * 16, _font, _map_string[i], Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawAll(dc as Dc, room as Room) as Void {

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
        for (var i = 0; i < _map_string.size(); i++) {
            dc.drawText(0, i * 16, _font, _map_string[i], Graphics.TEXT_JUSTIFY_LEFT);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawItems(dc, room.getItems());
        drawEnemies(dc, room.getEnemies());
        drawNPCs(dc, room.getNPCs());
    }


}
