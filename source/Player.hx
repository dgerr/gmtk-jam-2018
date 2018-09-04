package;

import flixel.FlxSprite;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.utils.Object;

class Player extends WorldObject {
	public var spriteData:BitmapData;
	
	public var tileCoords:Object;
	
	public var keyIndicator:FlxSprite;
	public var keyIndicatorAttached:Bool = false;
	
	public function new():Void {
		super(null, "player", null);
		
		var rawSpriteData = Assets.getBitmapData("assets/images/cat_8.png");
		
		var mx:Matrix = new Matrix();
		mx.scale(Tile.TILE_SCALE, Tile.TILE_SCALE);
		
		keyIndicator = new FlxSprite();
		keyIndicator.loadGraphic(Utilities.scaleBitmapData(Assets.getBitmapData("assets/images/key_indicators.png"), 3, 3), true, 30, 30);
		keyIndicator.animation.add("z", [0], 1, true);
		keyIndicator.animation.add("r", [1], 1, true);
		keyIndicator.animation.play("r");
		
		keyIndicator.x = Tile.REAL_TILE_WIDTH / 2 - 15;
		keyIndicator.y = -35;

		var spriteData:BitmapData = new BitmapData(rawSpriteData.width * Tile.TILE_SCALE, rawSpriteData.height * Tile.TILE_SCALE, true, 0x000000);
		spriteData.draw(rawSpriteData, mx);
		_sprite = new FlxSprite();
		_sprite.loadGraphic(spriteData, true, Tile.TILE_WIDTH * Tile.TILE_SCALE, Tile.TILE_HEIGHT * Tile.TILE_SCALE);
		
		_sprite.animation.add("l", [3, 12], 3, false);
		_sprite.animation.add("r", [2, 11], 3, false);
		_sprite.animation.add("u", [1, 10], 3, false);
		_sprite.animation.add("d", [0, 9], 3, false);
		_sprite.animation.add("aloft", [4, 13], 1, true);
		_sprite.animation.add("stand", [0], 4, true);
		
		add(_sprite);
	}
	
	public function addKeyIndicator() {
		if (!keyIndicatorAttached) {
			add(keyIndicator);
		}
		keyIndicatorAttached = true;
	}
	
	public function removeKeyIndicator() {
		if (keyIndicatorAttached) {
			remove(keyIndicator);
		}
		keyIndicatorAttached = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}