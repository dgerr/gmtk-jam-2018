package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.Object;

class Tile extends FlxSpriteGroup {
	public static inline var TILE_WIDTH:Int = 16;
	public static inline var TILE_HEIGHT:Int = 16;
	public static inline var TILE_SCALE:Int = 4;
	
	public static inline var NUM_TILES_PER_TILEMAP_ROW = 24;
	public function new(tileObject:Object):Void {
		super();
		
		var bg:Array<Array<Int>> = tileObject.bg;
		var fg:Array<Array<Int>> = tileObject.fg;
		
		var srcBitmapData:BitmapData = Assets.getBitmapData("assets/images/tiles.png");
		
		var blit:BitmapData = new BitmapData(TILE_WIDTH * 10, TILE_HEIGHT * 10);
		var scaledTile:BitmapData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT);
		
		for (i in 0...bg.length) {
			for (j in 0...bg[i].length) {
				blit.copyPixels(srcBitmapData, new Rectangle(TILE_HEIGHT * (bg[i][j] % NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH * Std.int(bg[i][j] / NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH,
															 TILE_HEIGHT),
								new Point(TILE_HEIGHT * j, TILE_WIDTH * i));
				blit.copyPixels(srcBitmapData, new Rectangle(TILE_HEIGHT * (fg[i][j] % NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH * Std.int(fg[i][j] / NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH,
															 TILE_HEIGHT),
								new Point(TILE_HEIGHT * j, TILE_WIDTH * i), null, null, true);
			}
		}
		var mx:Matrix = new Matrix();
		mx.scale(TILE_SCALE, TILE_SCALE);
		scaledTile.draw(blit, mx);
		
		var spr = new FlxSprite();
		spr.loadGraphic(scaledTile);
		add(spr);
	}
}