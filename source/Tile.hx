package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.Object;

class Tile extends FlxSpriteGroup {
	public static inline var TILE_WIDTH:Int = 16;
	public static inline var TILE_HEIGHT:Int = 16;
	public static inline var TILE_SCALE:Int = 4;
	
	public static inline var REAL_TILE_WIDTH:Int = TILE_WIDTH * TILE_SCALE;
	public static inline var REAL_TILE_HEIGHT:Int = TILE_HEIGHT * TILE_SCALE;
	
	public static inline var NUM_TILES_PER_TILEMAP_ROW = 24;
	public var tileObject:Object;

	public var bgDisplayData:BitmapData;
	public var fgDisplayData:BitmapData;
	
	public var widthInTiles:Int;
	public var heightInTiles:Int;
	
	public var tileCount:Map<Int, Int>;
	
	public var playerRef:Player;
	public var worldObjects:Array<WorldObject>;
	public var worldObjectsLayer:FlxSpriteGroup;
	public var topObjectsLayer:FlxSpriteGroup;
		
	public var bgS:FlxSprite;
	public var fgS:FlxSprite;
	
	public function new(playerRef:Player, tileObject:Object):Void {
		super();
		
		widthInTiles = 10;
		heightInTiles = 10;
		
		this.playerRef = playerRef;
		this.tileObject = tileObject;
		worldObjects = new Array<WorldObject>();
		worldObjectsLayer = new FlxSpriteGroup();
		topObjectsLayer = new FlxSpriteGroup();
		
		var srcBitmapData:BitmapData = TiledMapManager.get().tileBitmapData;
		
		var bg:Array<Array<Int>> = tileObject.bg;
		var fg:Array<Array<Int>> = tileObject.fg;
		var fg2:Array<Array<Int>> = tileObject.fg2;
		
		tileCount = new Map<Int, Int>();
		
		var blit:BitmapData = new BitmapData(TILE_WIDTH * 10, TILE_HEIGHT * 10);
		var blit2:BitmapData = new BitmapData(TILE_WIDTH * 10, TILE_HEIGHT * 10, true, 0);
		bgDisplayData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT);
		fgDisplayData = new BitmapData(Main.GAME_WIDTH, Main.GAME_HEIGHT, true, 0);
		
		var mx:Matrix = new Matrix();
		mx.scale(TILE_SCALE, TILE_SCALE);
		
		for (i in 0...bg.length) {
			for (j in 0...bg[i].length) {
				blit.copyPixels(srcBitmapData, TiledMapManager.getRectangleOfValue(bg[i][j]),
								new Point(TILE_HEIGHT * j, TILE_WIDTH * i));
				
				var fgs = [fg];
				if (fg2 != null) fgs.push(fg2);
				
				for (source in fgs) {
					var isWorldObject = false;
					var woBitmapData:BitmapData = null;
					var woAnimationFrames:Int = 0;
					if (source[i][j] == 339) {
						// zombie cat
						var zombieCat:ZombieCat = new ZombieCat(["x" => Std.string(j), "y" => Std.string(i), "ox" => Std.string(j), "oy" => Std.string(i)]);
						addWorldObject(zombieCat);
						source[i][j] = -1;
						continue;
					}
					if (WorldConstants.tileAnimationFrames.exists(source[i][j])) {
						isWorldObject = true;
						var frames:Array<Int> = WorldConstants.tileAnimationFrames[source[i][j]];
						woBitmapData = TiledMapManager.get().generateBitmapDataFromFrames(frames);
						woAnimationFrames = frames.length;
					} else if (WorldConstants.specialTileTypes.exists(source[i][j])) {
						isWorldObject = true;
						var direction = "east";
						if (tileObject.params[i][j].exists("direction")) {
							direction = tileObject.params[i][j].get("direction");
						}
						woBitmapData = TiledMapManager.get().getTileBitmapData(source[i][j], direction);
					}

					if (isWorldObject) {
						if (tileObject.params[i][j].exists("type") && tileObject.params[i][j].get("type") == "guard") {
							if (GameState.get().unlockedStaff) {
								tileObject.params[i][j].set("x", "4");
								tileObject.params[i][j].set("y", "7");
							}
						}
						var worldObject:WorldObject = new WorldObject(woBitmapData, WorldConstants.specialTileTypes[source[i][j]], tileObject.params[i][j], woAnimationFrames);
						addWorldObject(worldObject);
						source[i][j] = -1;
					} else {
						blit2.copyPixels(srcBitmapData, TiledMapManager.getRectangleOfValue(source[i][j]),
										 new Point(TILE_HEIGHT * j, TILE_WIDTH * i), null, null, true);
					}
				}
				fgs.push(bg);
				for (arr in fgs) {
					if (arr[i][j] != -1) {
						if (!tileCount.exists(arr[i][j])) {
							tileCount[arr[i][j]] = 1;
						} else {
							tileCount[arr[i][j]] += 1;
						}
					}
				}
			}
		}
		bgDisplayData.draw(blit, mx);
		fgDisplayData.draw(blit2, mx);
		
		bgS = new FlxSprite();
		bgS.loadGraphic(bgDisplayData);
		add(bgS);
		
		fgS = new FlxSprite();
		fgS.loadGraphic(fgDisplayData);
		add(fgS);
		
		add(worldObjectsLayer);
		add(topObjectsLayer);
	}
	
	public function getSquare(loc:Object):Object {
		var objToReturn:Object = {bg: tileObject.bg[loc.y][loc.x], fg: tileObject.fg[loc.y][loc.x], fg2: (tileObject.fg2 != null ? tileObject.fg2[loc.y][loc.x] : null)};
		for (i in worldObjects) {
			if (i.loc.x == loc.x && i.loc.y == loc.y) {
				objToReturn.object = i;
			}
		}
		if (playerRef.loc.x == loc.x && playerRef.loc.y == loc.y) {
			objToReturn.object = playerRef;
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
			bgDisplayData.fillRect(new Rectangle(REAL_TILE_WIDTH * loc.x, REAL_TILE_HEIGHT * loc.y, REAL_TILE_WIDTH, REAL_TILE_HEIGHT), 0);
		} else if (layer == "fg") {
			fgDisplayData.fillRect(new Rectangle(REAL_TILE_WIDTH * loc.x, REAL_TILE_HEIGHT * loc.y, REAL_TILE_WIDTH, REAL_TILE_HEIGHT), 0);
		}
		if (value >= 0) {
			var srcBitmapData:BitmapData = TiledMapManager.get().tileBitmapData;
			blit.copyPixels(srcBitmapData, TiledMapManager.getRectangleOfValue(value), new Point(0, 0));
		}
		var mx:Matrix = new Matrix();
		mx.translate(TILE_WIDTH * loc.x, TILE_HEIGHT * loc.y);
		mx.scale(TILE_SCALE, TILE_SCALE);
		
		if (layer == "bg") {
			bgDisplayData.draw(blit, mx);
			bgS.loadGraphic(bgDisplayData);
			
		} else if (layer == "fg") {
			fgDisplayData.draw(blit, mx);
			fgS.loadGraphic(fgDisplayData);
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
	
	public function getObjectAtLoc(loc:Object):WorldObject {
		for (worldObject in worldObjects) {
			if (worldObject.loc.x == loc.x && worldObject.loc.y == loc.y) {
				return worldObject;
			}
		}
		return null;
	}
	
	public function removeObjectsAtLoc(loc:Object) {
		for (worldObject in worldObjects) {
			if (worldObject.loc.x == loc.x && worldObject.loc.y == loc.y) {
				worldObjectsLayer.remove(worldObject);
				worldObjects.remove(worldObject);
			}
		}
	}
	
	public function removeObjectsAtLocOtherThan(wo:WorldObject) {
		for (worldObject in worldObjects) {
			if (worldObject != wo && worldObject.loc.x == wo.x && worldObject.loc.y == wo.y) {
				worldObjectsLayer.remove(worldObject);
				worldObjects.remove(worldObject);
			}
		}
	}
	
	public function removeObjectsOfType(type:String) {
		var i:Int = worldObjects.length - 1;
		while (i >= 0) {
			if (worldObjects[i].type == type) {
				worldObjectsLayer.remove(worldObjects[i]);
				worldObjects.splice(i, 1);
			}
			--i;
		}
	}
	
	public function getNumTiles(value:Int) {
		if (!tileCount.exists(value)) {
			return 0;
		}
		return tileCount[value];
	}
	
	public function isInBounds(loc:Object) {
		return loc.x >= 0 && loc.y >= 0 && loc.x < widthInTiles && loc.y < heightInTiles;
	}
	
	public function isPathableFGOnly(loc:Object):Bool {
		if (!isInBounds(loc)) {
			return false;
		}
		var squareObj = getSquare(loc);
		if (TiledMapManager.get().isSolid(squareObj.fg) || (squareObj.fg2 != null && TiledMapManager.get().isSolid(squareObj.fg2)) || (squareObj.object != null && WorldObject.isSolid(squareObj.object))) {
			return false;
		}
		return true;
	}

	public function isPathable(loc:Object):Bool {
		if (!isInBounds(loc)) {
			return false;
		}
		var squareObj = getSquare(loc);
		if (!isTerrainPathable(loc) || (squareObj.object != null && WorldObject.isSolid(squareObj.object))) {
			return false;
		}
		return true;
	}
	
	public function isTerrainPathable(loc:Object):Bool {
		var squareObj = getSquare(loc);
		if (TiledMapManager.get().isSolid(squareObj.bg) || TiledMapManager.get().isSolid(squareObj.fg) || 
		    (squareObj.fg2 != null && TiledMapManager.get().isSolid(squareObj.fg2))) {
			return false;
		}
		return true;
	}
	
	public function addWorldObject(worldObject:WorldObject) {
		worldObjects.push(worldObject);
		if (worldObject.type != "zombie") {
			worldObjectsLayer.add(worldObject);
		} else {
			topObjectsLayer.add(worldObject);
		}
		worldObject.x = REAL_TILE_WIDTH * worldObject.loc.x;
		worldObject.y = REAL_TILE_HEIGHT * worldObject.loc.y;
	}
	
	public override function destroy() {
		for (worldObject in worldObjects) {
			worldObject.destroy();
		}
		super.destroy();
	}
}