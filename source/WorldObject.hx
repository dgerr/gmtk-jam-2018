package;

import flixel.FlxSprite;
import openfl.display.BitmapData;

class WorldObject extends FlxSprite {
	public var type:String;
	public var localX: Int;
	public var localY: Int;
	
	public function new(bitmapData:BitmapData, type:String):Void {
		super();
		this.type = type;
		
		loadGraphic(bitmapData);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}