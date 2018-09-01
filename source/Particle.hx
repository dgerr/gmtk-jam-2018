package;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.Assets;
import openfl.display.BitmapData;

class Particle extends FlxSprite {
	private var duration:Float;
	private var fn:Particle -> Void;
	
    public function new(path:String, ?X:Float=0, ?Y:Float=0, ?duration:Float, ?fn:Particle -> Void) {
        super(X, Y);
		this.duration = duration;
		this.fn = fn;
		
		var bitmapData:BitmapData = Assets.getBitmapData("assets/images/" + path);
		this.loadGraphic(bitmapData);
    }
	public override function update(elapsed:Float):Void {
		this.duration -= elapsed;
		if (this.duration <= 0) {
			this.destroy();
		} else {
			this.fn(this);
		}
	}
}