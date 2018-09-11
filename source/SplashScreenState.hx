package;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import openfl.Assets;

class SplashScreenState extends FlxTransitionableState {
	public var starting:Bool = false;
	
	override public function create():Void {
		super.create();
		
		var spriteData:BitmapData = Utilities.scaleBitmapData(Assets.getBitmapData("assets/images/kq2.png"), 4, 4);
		
		var screen:FlxSprite = new FlxSprite();
		screen.loadGraphic(spriteData, true, Main.GAME_WIDTH, Main.GAME_HEIGHT);
		screen.animation.add("normal", [0, 1, 2, 3], 4);
		screen.animation.play("normal");
		
		add(screen);
		
		var textBG = new FlxSprite();
		textBG.makeGraphic(540, 50, FlxColor.BLACK);
		textBG.x = (Main.GAME_WIDTH - 540) / 2;
		textBG.y = 575;
		this.add(textBG);
		
		var text = new FlxText(76, 575, 640, "Press Z to start!", 54);
		text.setFormat("assets/pixelfont.TTF", 54, FlxColor.WHITE);
		this.add(text);

		var diamond:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData("assets/images/diamond.png"));
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		
		FlxTransitionableState.defaultTransIn = new TransitionData();
		FlxTransitionableState.defaultTransOut = new TransitionData();
		FlxTransitionableState.defaultTransIn.color = FlxColor.BLACK;
		FlxTransitionableState.defaultTransOut.color = FlxColor.BLACK;
		FlxTransitionableState.defaultTransIn.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransOut.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransIn.tileData = { asset: diamond, width: 32, height: 32 };
		FlxTransitionableState.defaultTransOut.tileData = { asset: diamond, width: 32, height: 32 };
		transOut = FlxTransitionableState.defaultTransOut;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		#if (web || desktop)
		if (!starting && (FlxG.keys.anyJustPressed([Z, ENTER]) || (FlxG.onMobile && FlxG.swipes.length > 0))) {
			FlxG.switchState(new OverworldPlayState());
		}
		#end
		#if mobile
		if (!starting && FlxG.onMobile && FlxG.swipes.length > 0) {
			FlxG.switchState(new OverworldPlayState());
		}
		#end
	}
}