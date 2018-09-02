package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import openfl.display.BitmapData;
import openfl.utils.Object;

class WorldObject extends FlxSpriteGroup {
	public var type:String;
	public var loc: Object;
	public var params:Map<String, String>;
	public var _sprite:FlxSprite;
	
	public function new(bitmapData:BitmapData, type:String, params:Map<String, String>,
					    ?animationFrames:Int = 0):Void {
		super();
		
		this.type = type;
		this.params = params;
		
		if (params != null) {
			loc = {x: Std.parseInt(params["x"]), y: Std.parseInt(params["y"])};
		}
		_sprite = new FlxSprite();
		
		if (bitmapData != null) {
			if (animationFrames <= 0) {
				_sprite.loadGraphic(bitmapData);
			} else {
				var animation:Array<Int> = new Array<Int>();
				for (i in 0...animationFrames) {
					animation.push(i);
				}
				_sprite.loadGraphic(bitmapData, true, Std.int(bitmapData.width / animationFrames), bitmapData.height);
				_sprite.animation.add("normal", animation, 4, true);
				_sprite.animation.play("normal");
			}
			
			add(_sprite);
		}
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