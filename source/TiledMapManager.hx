package;
import haxe.io.Eof;
import sys.io.File;

class TiledMapManager {
	public var tiledLayer1:Array<Array<Int>>;
	public var tiledLayer2:Array<Array<Int>>;
	
	public static var _manager = null;
	
	public static function get():TiledMapManager {
		if (_manager == null) {
			_manager = new TiledMapManager();
		}
		return _manager;
	}
	
	public function new() {
		tiledLayer1 = new Array<Array<Int>>();
		tiledLayer2 = new Array<Array<Int>>();
		
		var fin = File.read("assets/data/world_background.csv");
		var fin2 = File.read("assets/data/world_foreground.csv");
		
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
	
	public function getTileObject(x:Int, y:Int) {
		var builtArray:Array<Array<Int>> = new Array<Array<Int>>();
		var builtArray2:Array<Array<Int>> = new Array<Array<Int>>();
		
		var sx = 11 * x + 2;
		var sy = 11 * y;
		
		for (i in 0...10) {
			builtArray.push(tiledLayer1[sy + i].slice(sx, sx + 10));
			builtArray2.push(tiledLayer2[sy + i].slice(sx, sx + 10));
		}
		return {bg: builtArray, fg: builtArray2};
	}
}