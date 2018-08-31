package;

import flixel.FlxState;
import flixel.FlxG;

class PlayState extends FlxState {
	public var p:Player;
	
	override public function create():Void {
		super.create();
		
		p = new Player();
		
		add(p);
	}
	
	public function handleMovement():Void {
		var _up = FlxG.keys.anyPressed([UP, W]);
        var _down = FlxG.keys.anyPressed([DOWN, S]);
        var _left = FlxG.keys.anyPressed([LEFT, A]);
        var _right = FlxG.keys.anyPressed([RIGHT, D]);
		
		if (_up && !_down) {
			p.y -= 4;
		}
		if (!_up && _down) {
			p.y += 4;
		}
		if (_left && !_right) {
			p.x -= 4;
		}
		if (!_left && _right) {
			p.x += 4;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		handleMovement();
	}
}