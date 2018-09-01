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
	public var tileObject:Object;
	
	public var srcBitmapData:BitmapData;
	
	public var bgDisplayData:BitmapData;
	public var fgDisplayData:BitmapData;
	
	public var tileCount:Map<Int, Int>;
	
	public function new(tileObject:Object):Void {
		super();
		
		this.tileObject = tileObject;
		
		var bg:Array<Array<Int>> = tileObject.bg;
		var fg:Array<Array<Int>> = tileObject.fg;
		
		tileCount = new Map<Int, Int>();
		
		srcBitmapData = Assets.getBitmapData("assets/images/tiles.png");
		
		var blit:BitmapData = new BitmapData(TILE_WIDTH * 10, TILE_HEIGHT * 10);
		var blit2:BitmapData = new BitmapData(TILE_WIDTH * 10, TILE_HEIGHT * 10, true, 0);
		bgDisplayData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT);
		fgDisplayData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, true, 0);
		
		for (i in 0...bg.length) {
			for (j in 0...bg[i].length) {
				blit.copyPixels(srcBitmapData, new Rectangle(TILE_WIDTH * (bg[i][j] % NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_HEIGHT * Std.int(bg[i][j] / NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH,
															 TILE_HEIGHT),
								new Point(TILE_HEIGHT * j, TILE_WIDTH * i));
				blit2.copyPixels(srcBitmapData, new Rectangle(TILE_HEIGHT * (fg[i][j] % NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH * Std.int(fg[i][j] / NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH,
															 TILE_HEIGHT),
								new Point(TILE_HEIGHT * j, TILE_WIDTH * i), null, null, true);
				
				if (!tileCount.exists(bg[i][j])) {
					tileCount[bg[i][j]] = 1;
				} else {
					tileCount[bg[i][j]] += 1;
				}

				if (!tileCount.exists(fg[i][j])) {
					tileCount[fg[i][j]] = 1;
				} else {
					tileCount[fg[i][j]] += 1;
				}
			}
		}
		var mx:Matrix = new Matrix();
		mx.scale(TILE_SCALE, TILE_SCALE);
		bgDisplayData.draw(blit, mx);
		fgDisplayData.draw(blit2, mx);
		
		var bgS = new FlxSprite();
		bgS.loadGraphic(bgDisplayData);
		add(bgS);
		
		var fgS = new FlxSprite();
		fgS.loadGraphic(fgDisplayData);
		add(fgS);
	}
	
	public function getSquare(loc:Object):Object {
		return {bg: tileObject.bg[loc.y][loc.x], fg: tileObject.fg[loc.y][loc.x]};
	}
	
	public function setSquare(loc:Object, value:Int, layer:String = "bg") {
		// Sets the square at position 'loc' to 'value'.
		var tileObjectLayer = tileObject.bg;
		if (layer == "bg") {
			tileObjectLayer = tileObject.bg;
		} else if (layer == "fg") {
			tileObjectLayer = tileObject.fg;
		}
		
		tileCount[tileObjectLayer[loc.y][loc.x]] -= 1;
		if (!tileCount.exists(value)) {
			tileCount[value] = 1;
		} else {
			tileCount[value] += 1;
		}
		tileObjectLayer[loc.y][loc.x] = value;
		
		var blit:BitmapData = new BitmapData(TILE_WIDTH, TILE_HEIGHT, true);
		if (value >= 0) {
			blit.copyPixels(srcBitmapData, new Rectangle(TILE_WIDTH * (value % NUM_TILES_PER_TILEMAP_ROW),
														 TILE_HEIGHT * Std.int(value / NUM_TILES_PER_TILEMAP_ROW),
														 TILE_WIDTH,
														 TILE_HEIGHT),
							new Point(0, 0));
		}
		var mx:Matrix = new Matrix();
		mx.translate(TILE_HEIGHT * loc.x, TILE_WIDTH * loc.y);
		mx.scale(TILE_SCALE, TILE_SCALE);
		
		if (layer == "bg") {
			bgDisplayData.draw(blit, mx);
		} else if (layer == "fg") {
			fgDisplayData.draw(blit, mx);
		}
	}
	
	public function changeAllSquares(oldValue:Int, newValue:Int) {
		// Changes all tiles with value 'oldValue' to value 'newValue'.
		for (i in 0...tileObject.bg.length) {
			for (j in 0...tileObject.bg[i].length) {
				if (tileObject.bg[j][i] == oldValue) {
					setSquare({x: i, y: j}, newValue, "bg");
				}
				if (tileObject.fg[j][i] == oldValue) {
					setSquare({x: i, y: j}, newValue, "fg");
				}
			}
		}
	}
	
	public function getNumTiles(value:Int) {
		if (!tileCount.exists(value)) {
			return 0;
		}
		return tileCount[value];
	}
}