package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.display.BitmapData;

class DialogBox extends FlxSpriteGroup {
	public static inline var TEXT_PADDING_X:Int = 25;
	public static inline var TEXT_PADDING_Y:Int = 20;
	
	public var bgSprite:FlxSprite;
	public var text:FlxText;
	public var callback:Void -> Void = null;
	public var abortCallback:Void -> Void = null;
	
	public function new(message:String, callback:Void -> Void, abortCallback:Void -> Void) {
		super();
		
		this.callback = callback;
		this.abortCallback = abortCallback;
		
		var bitmapData:BitmapData = Assets.getBitmapData("assets/images/dialogbox.png");
		bgSprite = new FlxSprite();
		bgSprite.loadGraphic(Utilities.scaleBitmapData(bitmapData, Tile.TILE_SCALE, Tile.TILE_SCALE));
		
		this.add(bgSprite);
		
		this.y = Main.GAME_HEIGHT - (bitmapData.height * Tile.TILE_SCALE);
		
		text = new FlxText(TEXT_PADDING_X, TEXT_PADDING_Y, Main.GAME_WIDTH - 2 * TEXT_PADDING_X, message, 16);
		text.setFormat(null, 16, FlxColor.BLACK);
		this.add(text);
	}
	
	public function handleInput() {
		var advance = FlxG.keys.anyJustPressed([Z, ENTER]);
		var abort = FlxG.keys.anyJustPressed([LEFT, RIGHT, UP, DOWN, A, S, D, W]);
		
		if (advance) {
			if (callback != null) callback();
		}
		if (abort) {
			if (abortCallback != null) abortCallback();
		}
	}
}