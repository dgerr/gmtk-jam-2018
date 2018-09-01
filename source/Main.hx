package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public static inline var GAME_WIDTH:Int = 640;
	public static inline var GAME_HEIGHT:Int = 640;
	
	public function new() {
		super();
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true));
	}
}