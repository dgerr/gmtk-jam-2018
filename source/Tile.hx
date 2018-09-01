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
	
	public var worldObjects:Array<WorldObject>;
	public var worldObjectsLayer:FlxSpriteGroup;
	
	public function new(tileObject:Object):Void {
		super();
		
		this.tileObject = tileObject;
		worldObjects = new Array<WorldObject>();
		worldObjectsLayer = new FlxSpriteGroup();
		
		var bg:Array<Array<Int>> = tileObject.bg;
		var fg:Array<Array<Int>> = tileObject.fg;
		
		tileCount = new Map<Int, Int>();
		
		srcBitmapData = Assets.getBitmapData("assets/images/tiles.png");
		
		var blit:BitmapData = new BitmapData(TILE_WIDTH * 10, TILE_HEIGHT * 10);
		var blit2:BitmapData = new BitmapData(TILE_WIDTH * 10, TILE_HEIGHT * 10, true, 0);
		bgDisplayData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT);
		fgDisplayData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, true, 0);
		
		var mx:Matrix = new Matrix();
		mx.scale(TILE_SCALE, TILE_SCALE);
		
		for (i in 0...bg.length) {
			for (j in 0...bg[i].length) {
				blit.copyPixels(srcBitmapData, new Rectangle(TILE_WIDTH * (bg[i][j] % NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_HEIGHT * Std.int(bg[i][j] / NUM_TILES_PER_TILEMAP_ROW),
				                                             TILE_WIDTH,
															 TILE_HEIGHT),
								new Point(TILE_HEIGHT * j, TILE_WIDTH * i));
				
				if (WorldConstants.specialTileTypes.exists(fg[i][j])) {
					var tileData:BitmapData = new BitmapData(TILE_WIDTH, TILE_HEIGHT, true, 0);
					tileData.copyPixels(srcBitmapData, new Rectangle(TILE_HEIGHT * (fg[i][j] % NUM_TILES_PER_TILEMAP_ROW),
																     TILE_WIDTH * Std.int(fg[i][j] / NUM_TILES_PER_TILEMAP_ROW),
																     TILE_WIDTH,
																     TILE_HEIGHT),
									    new Point(0, 0), null, null, true);
					var scaledTileData:BitmapData = new BitmapData(TILE_WIDTH * TILE_SCALE, TILE_HEIGHT * TILE_SCALE, true, 0);
					scaledTileData.draw(tileData, mx);
					var worldObject:WorldObject = new WorldObject(scaledTileData, WorldConstants.specialTileTypes[fg[i][j]]);
					worldObject.localX = j;
					worldObject.localY = i;
					worldObjects.push(worldObject);
					worldObjectsLayer.add(worldObject);
					worldObject.x = TILE_WIDTH * TILE_SCALE * j;
					worldObject.y = TILE_HEIGHT * TILE_SCALE * i;
					fg[i][j] = -1;
				} else {
					blit2.copyPixels(srcBitmapData, new Rectangle(TILE_HEIGHT * (fg[i][j] % NUM_TILES_PER_TILEMAP_ROW),
																  TILE_WIDTH * Std.int(fg[i][j] / NUM_TILES_PER_TILEMAP_ROW),
																  TILE_WIDTH,
																  TILE_HEIGHT),
									 new Point(TILE_HEIGHT * j, TILE_WIDTH * i), null, null, true);
				}
				
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
		bgDisplayData.draw(blit, mx);
		fgDisplayData.draw(blit2, mx);
		
		var bgS = new FlxSprite();
		bgS.loadGraphic(bgDisplayData);
		add(bgS);
		
		var fgS = new FlxSprite();
		fgS.loadGraphic(fgDisplayData);
		add(fgS);
		
		add(worldObjectsLayer);
	}
	
	public function getSquare(loc:Object):Object {
		var objToReturn:Object = {bg: tileObject.bg[loc.y][loc.x], fg: tileObject.fg[loc.y][loc.x]};
		for (i in worldObjects) {
			if (i.localX == loc.x && i.localY == loc.y) {
				objToReturn.object = i;
			}
		}
		return objToReturn;
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
		
		var blit:BitmapData = new BitmapData(TILE_WIDTH, TILE_HEIGHT, true, 0);
		if (layer == "bg") {
			bgDisplayData.fillRect(new Rectangle(TILE_WIDTH * TILE_SCALE * loc.x, TILE_HEIGHT * TILE_SCALE * loc.y, TILE_WIDTH * TILE_SCALE, TILE_HEIGHT * TILE_SCALE), 0);
		} else if (layer == "fg") {
			fgDisplayData.fillRect(new Rectangle(TILE_WIDTH * TILE_SCALE * loc.x, TILE_HEIGHT * TILE_SCALE * loc.y, TILE_WIDTH * TILE_SCALE, TILE_HEIGHT * TILE_SCALE), 0);
		}
		if (value >= 0) {
			blit.copyPixels(srcBitmapData, new Rectangle(TILE_WIDTH * (value % NUM_TILES_PER_TILEMAP_ROW),
														 TILE_HEIGHT * Std.int(value / NUM_TILES_PER_TILEMAP_ROW),
														 TILE_WIDTH,
														 TILE_HEIGHT),
							new Point(0, 0));
		}
		var mx:Matrix = new Matrix();
		mx.translate(TILE_WIDTH * loc.x, TILE_HEIGHT * loc.y);
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
	
	public function isPathable(loc:Object):Bool {
		var squareObj = getSquare(loc);
		if (TiledMapManager.get().isSolid(squareObj.bg) || TiledMapManager.get().isSolid(squareObj.fg) || squareObj.object != null) {
			return false;
		}
		return true;
	}
}