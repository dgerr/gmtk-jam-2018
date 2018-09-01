package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite {
	public function new():Void {
		super();
		
		makeGraphic((Tile.TILE_WIDTH - 2) * Tile.TILE_SCALE, (Tile.TILE_HEIGHT - 2) * Tile.TILE_SCALE, FlxColor.RED);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}