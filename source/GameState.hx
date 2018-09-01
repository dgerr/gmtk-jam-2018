package;
import openfl.utils.Object;

class GameState {
	public static var _manager = null;
	
	public var shrineProgress:Map<String, Int>;
	
	public var currentShrine:Int = -1;
	public var overworldPosition:Object;
	
	public static function get():GameState {
		if (_manager == null) {
			_manager = new GameState();
		}
		return _manager;
	}
	
	public function new() {
		shrineProgress = new Map<String, Int>();
		
		overworldPosition = {tx: 1, ty: 1, x: 4, y: 4};
	}
}