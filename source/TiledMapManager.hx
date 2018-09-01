package;
import haxe.io.Eof;
import openfl.utils.Object;
import sys.io.File;

class TiledMapManager {
	public var tiledLayer1:Array<Array<Int>>;
	public var tiledLayer2:Array<Array<Int>>;
	public var path:String = null;
	
	public var collisionMap:Map<Int, Bool>;
	
	public static var _manager = null;
	
	public static function get():TiledMapManager {
		if (_manager == null) {
			_manager = new TiledMapManager();
		}
		return _manager;
	}
	
	public function new() {
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
	}
	
	public function getTileObject(x:Int, y:Int):Object {
		if (path == null) {
			trace("Must load a tileset first!");
			return null;
		}
		var builtArray:Array<Array<Int>> = new Array<Array<Int>>();
		var builtArray2:Array<Array<Int>> = new Array<Array<Int>>();
		
		var sx = 11 * x + (path == "world" ? 2 : 0);
		var sy = 11 * y;
		
		for (i in 0...10) {
			builtArray.push(tiledLayer1[sy + i].slice(sx, sx + 10));
			builtArray2.push(tiledLayer2[sy + i].slice(sx, sx + 10));
		}
		return {bg: builtArray, fg: builtArray2};
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
}