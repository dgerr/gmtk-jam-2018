package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

class Player extends FlxSpriteGroup {
	public var spriteData:BitmapData;
	public var _sprite:FlxSprite;
	
	public function new():Void {
		super();
		
		var rawSpriteData = Assets.getBitmapData("assets/images/cat_8.png");
		
		var mx:Matrix = new Matrix();
		mx.scale(Tile.TILE_SCALE, Tile.TILE_SCALE);

		var spriteData:BitmapData = new BitmapData(rawSpriteData.width * Tile.TILE_SCALE, rawSpriteData.height * Tile.TILE_SCALE, true, 0x000000);
		spriteData.draw(rawSpriteData, mx);
		_sprite = new FlxSprite();
		_sprite.loadGraphic(spriteData, true, Tile.TILE_WIDTH * Tile.TILE_SCALE, Tile.TILE_HEIGHT * Tile.TILE_SCALE);
		
		_sprite.animation.add("l", [3, 7], 3, false);
		_sprite.animation.add("r", [2, 6], 3, false);
		_sprite.animation.add("u", [1, 5], 3, false);
		_sprite.animation.add("d", [0, 4], 3, false);
		_sprite.animation.add("stand", [0], 3, false);
		
		add(_sprite);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}