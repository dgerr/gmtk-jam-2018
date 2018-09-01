package;
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
	
	public static function cloneDirection(dir:Object) {
		return {x: dir.x, y: dir.y};
	}
}