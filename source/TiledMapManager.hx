package;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import haxe.Json;
import haxe.io.Eof;
import openfl.Assets;
import openfl.geom.Rectangle;
import openfl.utils.Object;

class TiledMapManager {
	public var tiledLayer1:Array<Array<Int>>;
	public var tiledLayer2:Array<Array<Int>>;
	public var tiledLayer3:Array<Array<Int>> = null;
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
		
		var fin = Constants.constantsMap["solid_tiles.csv"][0].split(",");
		for (i in fin) {
			collisionMap[Std.parseInt(i)] = true;
		}
	}
	
	public function loadTileSet(path:String) {
		this.path = path;
		tiledLayer1 = new Array<Array<Int>>();
		tiledLayer2 = new Array<Array<Int>>();
		tiledLayer3 = null;
		params = new Array<Map<String, String>>();
		
		var fin = Constants.constantsMap[path + "_background.csv"];
		var fin2 = Constants.constantsMap[path + "_foreground.csv"];
		var fin3 = null;
		if (Constants.constantsMap.exists(path + "_foreground2.csv")) {
			tiledLayer3 = new Array<Array<Int>>();
			fin3 = Constants.constantsMap[path + "_foreground2.csv"];
		}
		
		try {
			for (i in 0...fin.length) {
				var line = fin[i].split(",");
				var line2 = fin2[i].split(",");
				var build1 = [];
				var build2 = [];
				for (i in line) {
					build1.push(Std.parseInt(i));
				}
				for (i in line2) {
					build2.push(Std.parseInt(i));
				}
				
				if (fin3 != null) {
					var line3 = fin3[i].split(",");
					var build3 = [];
					for (i in line3) {
						build3.push(Std.parseInt(i));
					}
					tiledLayer3.push(build3);
				}
				
				tiledLayer1.push(build1);
				tiledLayer2.push(build2);
			}
		} catch (e:Eof) { }

		var params_path = path + "_params.csv";
		if (Constants.constantsMap.exists(params_path)) {
			var params_fin = Constants.constantsMap[params_path];
			try {
				for (line in params_fin) {
					if (StringTools.trim(line) == "") {
						continue;
					}
					if (StringTools.startsWith(line, "//")) {
						continue;
					}
					var lineJSON = Json.parse(line);
					
					var builtObject = new Map<String, String>();
					for (key in Reflect.fields(lineJSON)) {
						builtObject[key] = Reflect.field(lineJSON, key);
					}
					params.push(builtObject);
				}
			} catch (e:Eof) { }
		}
	}
	
	public function getTileBitmapData(value:Int, ?direction:String = "east"):BitmapData {
		var bitmapData:BitmapData = new BitmapData(Tile.TILE_WIDTH, Tile.TILE_HEIGHT, true, 0);
		bitmapData.copyPixels(tileBitmapData, getRectangleOfValue(value), new Point(0, 0));
		
		var returnBitmapData:BitmapData = new BitmapData(Tile.REAL_TILE_WIDTH, Tile.REAL_TILE_HEIGHT, true, 0);
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
	
	public function generateBitmapDataFromFrames(values:Array<Int>):BitmapData {
		var bitmapData:BitmapData = new BitmapData(Tile.TILE_WIDTH * values.length, Tile.TILE_HEIGHT, true, 0);
		for (i in 0...values.length) {
			bitmapData.copyPixels(tileBitmapData, getRectangleOfValue(values[i]), new Point(Tile.TILE_WIDTH * i, 0));
		}
		
		var returnBitmapData:BitmapData = new BitmapData(Tile.REAL_TILE_WIDTH * values.length, Tile.REAL_TILE_HEIGHT, true, 0);
		var mx:Matrix = new Matrix();
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
		var builtArray3:Array<Array<Int>> = null;
		if (tiledLayer3 != null) builtArray3 = new Array<Array<Int>>();
		var builtParamsArray:Array<Array<Map<String, String>>> = new Array<Array<Map<String, String>>>();
		
		var sx = 11 * x;
		var sy = 11 * y;
		
		for (i in 0...10) {
			builtArray.push(tiledLayer1[sy + i].slice(sx, sx + 10));
			builtArray2.push(tiledLayer2[sy + i].slice(sx, sx + 10));
			if (tiledLayer3 != null) builtArray3.push(tiledLayer3[sy + i].slice(sx, sx + 10));
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
		return {bg: builtArray, fg: builtArray2, fg2: builtArray3, params: builtParamsArray};
	}
	
	public function hasTileObjectAt(x:Int, y:Int):Bool {
		if (path == null) {
			trace("Must load a tileset first!");
			return false;
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