package;

import flixel.FlxSprite;

class ZombieCat extends WorldObject {
	public function new(params:Map<String, String>):Void {
		super(null, "zombie", params);
		
		var spriteData = TiledMapManager.get().generateBitmapDataFromFrames([339, 363]);
		_sprite = new FlxSprite();
		_sprite.loadGraphic(spriteData, true, Tile.TILE_WIDTH * Tile.TILE_SCALE, Tile.TILE_HEIGHT * Tile.TILE_SCALE);
		
		_sprite.animation.add("stand", [0, 0, 0, 1, 1, 1], 2, true);
		_sprite.animation.play("stand");
		
		add(_sprite);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}