package;

import openfl.utils.Object;

class GameState {
	public static var _manager = null;
	
	public var shrineProgress:Map<String, Int>;
	public var shrinesBeaten:Int = 0;
	
	public var currentShrine:Int = -1;
	public var overworldPosition:Object;
	public var unlockedStaff:Bool = false;
	
	public var seenStartCutscene:Bool = true;
	public var seenEndCutscene:Bool = false;
	
	public static function get():GameState {
		if (_manager == null) {
			_manager = new GameState();
		}
		return _manager;
	}
	
	public function new() {
		shrineProgress = new Map<String, Int>();
		
		overworldPosition = WorldConstants.START_LOCATION;
	}
}