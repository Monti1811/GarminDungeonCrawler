import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;

class Room1 extends Room {


    function initialize(tile_width as Number, tile_height as Number, add_options as Dictionary?) {
        /*var map = [
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WBR, WBO, WBO, WBO, WBO, WBO, WBO, WBL, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WRI, PAS, PAS, PAS, PAS, PAS, PAS, WLE, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, WTR, WTO, WTO, WTO, WTO, WTO, WTO, WTL, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P],
            [N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P, N_P]
        ] as Array<Array<MapElement>>;*/

        // Passable is from 6x6 to 14x14
        var passable = [
            [6, 6], [7, 6], [8, 6], [9, 6], [10, 6], [11, 6], [12, 6], [13, 6],
            [6, 7], [7, 7], [8, 7], [9, 7], [10, 7], [11, 7], [12, 7], [13, 7],
            [6, 8], [7, 8], [8, 8], [9, 8], [10, 8], [11, 8], [12, 8], [13, 8],
            [6, 9], [7, 9], [8, 9], [9, 9], [10, 9], [11, 9], [12, 9], [13, 9],
            [6, 10], [7, 10], [8, 10], [9, 10], [10, 10], [11, 10], [12, 10], [13, 10],
            [6, 11], [7, 11], [8, 11], [9, 11], [10, 11], [11, 11], [12, 11], [13, 11],
            [6, 12], [7, 12], [8, 12], [9, 12], [10, 12], [11, 12], [12, 12], [13, 12],
            [6, 13], [7, 13], [8, 13], [9, 13], [10, 13], [11, 13], [12, 13], [13, 13],
            [6, 14], [7, 14], [8, 14], [9, 14], [10, 14], [11, 14], [12, 14], [13, 14]
        ];

        var walls = {
            :drawTopWall => [
                [6, 15], [7, 15], [8, 15], [9, 15], [10, 15], [11, 15], [12, 15], [13, 15]
            ],
            :drawBottomWall => [
                [6, 5], [7, 5], [8, 5], [9, 5], [10, 5], [11, 5], [12, 5], [13, 5]
            ],
            :drawLeftWall => [
                [14, 6], [14, 7], [14, 8], [14, 9], [14, 10], [14, 11], [14, 12], [14, 13], [14, 14]
            ],
            :drawRightWall => [
                [5, 6], [5, 7], [5, 8], [5, 9], [5, 10], [5, 11], [5, 12], [5, 13], [5, 14]
            ],
            :drawTopLeftWall => [
                [14, 15]
            ],
            :drawTopRightWall => [
                [5, 15]
            ],
            :drawBottomLeftWall => [
                [14, 5]
            ],
            :drawBottomRightWall => [
                [5, 5]
            ]
        };

        var map = {
            :walls => walls,
            :drawPassable => passable
        };


        var items = [
            new Helmet(),
            new Axe()
        ];
        items[0].setPos([7, 7]);
        items[1].setPos([12, 12]);

        var enemies = [
            new Frog()
        ];
        enemies[0].setPos([7, 12]);

        var options = {
            :size_x => 20,
            :size_y => 20,
            :tile_width => tile_width,
            :tile_height => tile_height,
            :start_pos => [10, 10],
            :map => map,
            :items => items,
            :enemies => enemies
        };
        SimUtil.addDictToDict(options, add_options);

        Room.initialize(options);

    }


}

