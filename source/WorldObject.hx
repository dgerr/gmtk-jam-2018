package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import openfl.display.BitmapData;

class WorldObject extends FlxSpriteGroup {
	public var type:String;
	public var localX: Int = 0;
	public var localY: Int = 0;
	public var params:Map<String, String>;
	
	public function new(bitmapData:BitmapData, type:String, params:Map<String, String>):Void {
		super();
		if (bitmapData == null) return;
		
		this.type = type;
		this.params = params;
		this.localX = Std.parseInt(params["x"]);
		this.localY = Std.parseInt(params["y"]);
		
		var sp:FlxSprite = new FlxSprite();
		sp.loadGraphic(bitmapData);
		
		add(sp);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}