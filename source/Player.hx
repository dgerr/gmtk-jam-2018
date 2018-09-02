package;

import flixel.FlxSprite;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

class Player extends WorldObject {
	public var spriteData:BitmapData;
	
	public function new():Void {
		super(null, "player", null);
		
		var rawSpriteData = Assets.getBitmapData("assets/images/cat_8.png");
		
		var mx:Matrix = new Matrix();
		mx.scale(Tile.TILE_SCALE, Tile.TILE_SCALE);

		var spriteData:BitmapData = new BitmapData(rawSpriteData.width * Tile.TILE_SCALE, rawSpriteData.height * Tile.TILE_SCALE, true, 0x000000);
		spriteData.draw(rawSpriteData, mx);
		_sprite = new FlxSprite();
		_sprite.loadGraphic(spriteData, true, Tile.TILE_WIDTH * Tile.TILE_SCALE, Tile.TILE_HEIGHT * Tile.TILE_SCALE);
		
		_sprite.animation.add("l", [3, 12], 3, false);
		_sprite.animation.add("r", [2, 11], 3, false);
		_sprite.animation.add("u", [1, 10], 3, false);
		_sprite.animation.add("d", [0, 9], 3, false);
		_sprite.animation.add("stand", [0], 1, true);
		
		add(_sprite);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}