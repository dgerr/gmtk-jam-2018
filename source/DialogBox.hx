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
	public static inline var OPTIONS_Y:Int = 72;
	
	public var bgSprite:FlxSprite;
	public var text:FlxText;
	public var messages:Array<String>;
	public var index:Int = 0;
	public var bounce:Bool = false;
	public var frameCount:Int = 0;
	public var callback:Void -> Void = null;
	public var abortCallback:Void -> Void = null;
	
	public var options:FlxSprite;
	
	public function new(messages:Array<String>, callback:Void -> Void, ?abortCallback:Void -> Void = null) {
		super();
		
		this.messages = messages;
		for (i in 0...this.messages.length) {
			this.messages[i] = StringTools.trim(this.messages[i]);
		}
		this.callback = callback;
		this.abortCallback = abortCallback;
		
		var bitmapData:BitmapData = Assets.getBitmapData("assets/images/dialogbox.png");
		bgSprite = new FlxSprite();
		bgSprite.loadGraphic(Utilities.scaleBitmapData(bitmapData, Tile.TILE_SCALE, Tile.TILE_SCALE));
		
		options = new FlxSprite();
		options.loadGraphic(Utilities.scaleBitmapData(Assets.getBitmapData("assets/images/dialogbox_options.png"), 3, 3), true, 30, 30);
		options.animation.add("next", [0], 1);
		options.animation.add("finish", [1], 1);
		options.animation.play((messages.length > 1 ? "next" : "finish"));
		options.x = Main.GAME_WIDTH - 52;
		options.y = this.y + OPTIONS_Y;
		
		this.add(bgSprite);
		add(options);
		
		this.y = Main.GAME_HEIGHT - (bitmapData.height * Tile.TILE_SCALE);
		
		text = new FlxText(TEXT_PADDING_X, TEXT_PADDING_Y, Main.GAME_WIDTH - 2 * TEXT_PADDING_X, messages[0], 16);
		text.setFormat(null, 16, FlxColor.BLACK);
		this.add(text);
	}
	
	public function handleInput() {
		var advance = FlxG.keys.anyJustPressed([Z, ENTER]);
		var abort = FlxG.keys.anyJustPressed([LEFT, RIGHT, UP, DOWN, A, S, D, W]);
		
		if (advance) {
			if (index < messages.length - 1) {
				index += 1;
				text.destroy();
				text = new FlxText(TEXT_PADDING_X, TEXT_PADDING_Y, Main.GAME_WIDTH - 2 * TEXT_PADDING_X, messages[index], 16);
				text.setFormat(null, 16, FlxColor.BLACK);
				this.add(text);
				
				if (index == messages.length - 1) {
					options.animation.play("finish");
					options.y = this.y + OPTIONS_Y;
				}
			} else {
				if (callback != null) {
					callback();
				}
				this.destroy();
			}
		}
		if (abort) {
			if (abortCallback != null && index == messages.length - 1) {
				abortCallback();
				this.destroy();
			}
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		++frameCount;
		
		if (index < messages.length - 1 && frameCount % 36 == 0) {
			bounce = !bounce;
			options.y = this.y + (bounce ? OPTIONS_Y - 10 : OPTIONS_Y);
		}
	}
}