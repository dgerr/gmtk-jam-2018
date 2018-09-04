package;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
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
		
		FlxTransitionableState.defaultTransIn = new TransitionData();
		FlxTransitionableState.defaultTransOut = new TransitionData();

		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		
		FlxTransitionableState.defaultTransIn.color = FlxColor.BLACK;
		FlxTransitionableState.defaultTransOut.color = FlxColor.BLACK;
		#if html5
		FlxTransitionableState.defaultTransIn.type = flixel.addons.transition.TransitionType.FADE;
		FlxTransitionableState.defaultTransOut.type = flixel.addons.transition.TransitionType.FADE;
		#else
		FlxTransitionableState.defaultTransIn.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransOut.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransIn.tileData = { asset: diamond, width: 32, height: 32 };
		FlxTransitionableState.defaultTransOut.tileData = { asset: diamond, width: 32, height: 32 };
		#end
		transOut = FlxTransitionableState.defaultTransOut;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (!starting && FlxG.keys.anyJustPressed([Z, ENTER])) {
			FlxG.switchState(new OverworldPlayState());
		}
	}
}