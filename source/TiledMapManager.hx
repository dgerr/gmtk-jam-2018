package;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import haxe.io.Eof;
import openfl.Assets;
import openfl.geom.Rectangle;
import openfl.utils.Object;
import sys.FileStat;
import sys.FileSystem;
import sys.io.File;

class TiledMapManager {
	public var tiledLayer1:Array<Array<Int>>;
	public var tiledLayer2:Array<Array<Int>>;
	public var path:String = null;
	
	public var params:Array<Map<String, String>>;
	
	public var tileBitmapData:BitmapData;
	
	public var collisionMap:Map<Int, Bool>;
	
	public static var _manager = null;
	
	public static function get():TiledMapManager {
		if (_manager == null) {
			_manager = new TiledMapManager();
		}
		return _manager;
	}
	
	public function new() {
		tileBitmapData = Assets.getBitmapData("assets/images/tiles.png");
		
		collisionMap = new Map<Int, Bool>();
		
		var fin = File.read("assets/data/solid_tiles.csv");
		var line = fin.readLine().split(",");
		for (i in line) {
			collisionMap[Std.parseInt(i)] = true;
		}
	}
	
	public function loadTileSet(path:String) {
		this.path = path;
		tiledLayer1 = new Array<Array<Int>>();
		tiledLayer2 = new Array<Array<Int>>();
		params = new Array<Map<String, String>>();
		
		var fin = File.read("assets/data/" + path + "_background.csv");
		var fin2 = File.read("assets/data/" + path + "_foreground.csv");
		
		try {
			while (true) {
				var line = fin.readLine().split(",");
				var line2 = fin2.readLine().split(",");
				
				var build1 = [];
				var build2 = [];
				for (i in line) {
					build1.push(Std.parseInt(i));
				}
				for (i in line2) {
					build2.push(Std.parseInt(i));
				}
				
				tiledLayer1.push(build1);
				tiledLayer2.push(build2);
			}
		} catch (e:Eof) { }
		
		var params_path = "assets/data/" + path + "_params.csv";
		if (FileSystem.exists(params_path)) {
			var params_fin = File.read(params_path);
			try {
				while (true) {
					var line = params_fin.readLine().split(",");
					if (line.length > 3) {
						var builtObject = new Map<String, String>();
						for (pair in line) {
							var pairSplit = pair.split(":");
							builtObject[pairSplit[0]] = pairSplit[1];
						}
						params.push(builtObject);
					}
				}
			} catch (e:Eof) { }
		}
	}
	
	public function getTileBitmapData(value:Int, ?direction:String = "east"):BitmapData {
		var bitmapData:BitmapData = new BitmapData(Tile.TILE_WIDTH, Tile.TILE_HEIGHT, true, 0);
		bitmapData.copyPixels(tileBitmapData, getRectangleOfValue(value), new Point(0, 0));
		
		var returnBitmapData:BitmapData = new BitmapData(Tile.TILE_WIDTH * Tile.TILE_SCALE, Tile.TILE_HEIGHT * Tile.TILE_SCALE, true, 0);
		var mx:Matrix = new Matrix();
		mx.translate( -Tile.TILE_WIDTH / 2, -Tile.TILE_HEIGHT / 2);
		
		if (direction == "north") {
			mx.rotate(3 * Math.PI / 2);
		} else if (direction == "west") {
			mx.rotate(Math.PI);
		} else if (direction == "south") {
			mx.rotate(Math.PI / 2);
		}
		mx.translate(Tile.TILE_WIDTH / 2, Tile.TILE_HEIGHT / 2);
		mx.scale(Tile.TILE_SCALE, Tile.TILE_SCALE);
		returnBitmapData.draw(bitmapData, mx);
		
		return returnBitmapData;
	}
	
	public function getTileObject(x:Int, y:Int):Object {
		if (path == null) {
			trace("Must load a tileset first!");
			return null;
		}
		var builtArray:Array<Array<Int>> = new Array<Array<Int>>();
		var builtArray2:Array<Array<Int>> = new Array<Array<Int>>();
		var builtParamsArray:Array<Array<Map<String, String>>> = new Array<Array<Map<String, String>>>();
		
		var sx = 11 * x;
		var sy = 11 * y;
		
		for (i in 0...10) {
			builtArray.push(tiledLayer1[sy + i].slice(sx, sx + 10));
			builtArray2.push(tiledLayer2[sy + i].slice(sx, sx + 10));
		}
		for (i in 0...10) {
			builtParamsArray.push(new Array<Map<String, String>>());
			for (j in 0...10) {
				builtParamsArray[i].push(["x" => Std.string(j), "y" => Std.string(i)]);
				for (param in params) {
					if (Std.parseInt(param["tx"]) == x && Std.parseInt(param["ty"]) == y && Std.parseInt(param["x"]) == j && Std.parseInt(param["y"]) == i) {
						builtParamsArray[i][j] = param;
					}
				}
			}
		}
		return {bg: builtArray, fg: builtArray2, params: builtParamsArray};
	}
	
	public function hasTileObjectAt(x:Int, y:Int):Bool {
		if (path == null) {
			trace("Must load a tileset first!");
			return null;
		}
		
		var sx = 11 * x + (path == "world" ? 2 : 0);
		var sy = 11 * y;
		
		return sx >= 0 && sy >= 0 && sy < tiledLayer1.length && sx < tiledLayer1[sy].length;
	}
	
	public function isSolid(value:Int) {
		return collisionMap.exists(value);
	}
	
	public static function getRectangleOfValue(value:Int):Rectangle {
		return new Rectangle(Tile.TILE_WIDTH * (value % Tile.NUM_TILES_PER_TILEMAP_ROW),
		                     Tile.TILE_HEIGHT * Std.int(value / Tile.NUM_TILES_PER_TILEMAP_ROW),
							 Tile.TILE_WIDTH,
							 Tile.TILE_HEIGHT);
	}
}