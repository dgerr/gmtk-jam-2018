package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class Player extends FlxSprite {
	public function new():Void {
		super();
		
		makeGraphic(32, 32, FlxColor.RED);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}