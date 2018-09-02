package;

import flixel.FlxSprite;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.utils.Object;

class Particle extends FlxSprite {
	private var duration:Float;
	private var fn:Particle -> Void = null;
	public var frameNumber:Int = 0;
	
    public function new(path:String, ?X:Float = 0, ?Y:Float = 0, ?duration:Float, ?fn:Particle -> Void,
	                    ?animationInfo:Object = null) {
        super(X, Y);
		this.duration = duration;
		this.fn = fn;
		
		var bitmapData:BitmapData = Assets.getBitmapData("assets/images/" + path);
		
		if (animationInfo == null) {
			this.loadGraphic(bitmapData);
		} else {
			if (animationInfo.cols == null || animationInfo.rows == null || animationInfo.animation == null) {
				trace("Must supply an object with 'rows', 'cols', and 'animation' set: e.g. {rows: 3, cols: 3, animation: [0,1,2]}");
				trace("Supplied object: " + animationInfo);
				return;
			}
			this.loadGraphic(bitmapData, true, Std.int(bitmapData.width / animationInfo.cols), Std.int(bitmapData.height / animationInfo.rows));
			this.animation.add("normal", animationInfo.animation, 2, true);
			this.animation.play("normal");
		}
    }
	public override function update(elapsed:Float):Void {
		this.duration -= elapsed;
		++frameNumber;
		if (this.duration <= 0) {
			this.destroy();
		} else {
			if (this.fn != null) {
				this.fn(this);
			}
		}
	}
}