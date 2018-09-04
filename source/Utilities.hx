package;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.utils.Object;

class Utilities {
	public static function directionToObject(dir:String) {
		if (dir == "west") {
			return {x: -1, y: 0};
		} else if (dir == "east") {
			return {x: 1, y: 0};
		} else if (dir == "north") {
			return {x: 0, y: -1};
		} else if (dir == "south") {
			return {x: 0, y: 1};
		} else {
			trace("Unknown direction " + dir);
			return {x: 0, y: 0};
		}
	}
	
	public static function scaleBitmapData(bitmapData:BitmapData, scaleX:Int, scaleY:Int) {
		var newBitmapData:BitmapData = new BitmapData(bitmapData.width * scaleX, bitmapData.height * scaleY, true, 0);
		var mx:Matrix = new Matrix(scaleX, 0, 0, scaleY);
		newBitmapData.draw(bitmapData, mx);
		return newBitmapData;
	}
	
	public static function cloneDirection(dir:Object) {
		return {x: dir.x, y: dir.y};
	}
	
	public static function parseInt(i:String) {
		if (i == "0") {
			return 0;
		}
		return Std.parseInt(i);
	}
}