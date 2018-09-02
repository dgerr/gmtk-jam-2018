package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import openfl.display.BitmapData;

class WorldObject extends FlxSpriteGroup {
	public var type:String;
	public var localX: Int = 0;
	public var localY: Int = 0;
	public var params:Map<String, String>;
	
	public function new(bitmapData:BitmapData, type:String, params:Map<String, String>,
					    ?animationFrames:Int = 0):Void {
		super();
		if (bitmapData == null) return;
		
		this.type = type;
		this.params = params;
		this.localX = Std.parseInt(params["x"]);
		this.localY = Std.parseInt(params["y"]);
		
		var sp:FlxSprite = new FlxSprite();
		if (animationFrames <= 0) {
			sp.loadGraphic(bitmapData);
		} else {
			var animation:Array<Int> = new Array<Int>();
			for (i in 0...animationFrames) {
				animation.push(i);
			}
			sp.loadGraphic(bitmapData, true, Std.int(bitmapData.width / animationFrames), bitmapData.height);
			sp.animation.add("normal", animation, 4, true);
			sp.animation.play("normal");
		}
		
		add(sp);
	}
	
	public static function isSolid(worldObject:WorldObject) {
		if (worldObject.type == "fireball") return false;
		
		return true;
	}
	
	public static function isPushable(worldObject:WorldObject) {
		return worldObject.type == "crate" || worldObject.type == "playerCrate";
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}