package;

import flixel.FlxSprite;
import openfl.display.BitmapData;

class WorldObject extends FlxSprite {
	public var type:String;
	public var localX: Int;
	public var localY: Int;
	public var params:Map<String, String>;
	
	public function new(bitmapData:BitmapData, type:String, params:Map<String, String>):Void {
		super();
		this.type = type;
		this.params = params;
		this.localX = Std.parseInt(params["x"]);
		this.localY = Std.parseInt(params["y"]);
		
		loadGraphic(bitmapData);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}