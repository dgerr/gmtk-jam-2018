package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite {
	public static inline var GAME_WIDTH:Int = 640;
	public static inline var GAME_HEIGHT:Int = 640;
	
	public function new() {
		super();
		
		Constants.loadMap();
		
		addChild(new FlxGame(0, 0, SplashScreenState, 1, 60, 60, true));
	}
}