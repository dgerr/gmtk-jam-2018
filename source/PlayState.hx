package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import openfl.utils.Object;

enum State {
	Free;
	PlayerMoving;
	EnemyMoving;
	Resolving;
	ShiftingTile;
}
class PlayState extends FlxState {
	
	public var backgroundLayer:FlxSpriteGroup;
	
	public var entityLayer:FlxSpriteGroup;
	public var p:Player;
	
	public var state:State = State.Free;
	public var direction:Object;
	public var animFrames:Int;
	
	public var FRAMES_BETWEEN_TILE_MOVE:Int = 4;
	public var FRAMES_BETWEEN_TILE_SWITCH:Int = 15;
	
	public var tileCoords:Object = {x: 1, y: 1};
	public var localTileCoords:Object = {x: 4, y: 4};
	
	public var currentTile:Tile;
	public var nextTile:Tile;
	
	override public function create():Void {
		super.create();
		
		backgroundLayer = new FlxSpriteGroup();
		entityLayer = new FlxSpriteGroup();
		
		currentTile = new Tile(TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
		
		add(backgroundLayer);
		add(entityLayer);
		
		p = new Player();
		
		entityLayer.add(p);
		
		backgroundLayer.add(currentTile);
		
		snapPlayerToTile();
	}
	
	private function snapPlayerToTile() {
		p.x = Tile.TILE_WIDTH * Tile.TILE_SCALE * localTileCoords.x;
		p.y = Tile.TILE_HEIGHT * Tile.TILE_SCALE * localTileCoords.y;
	}
	
	private function startPlayerMove() {
		localTileCoords.x += direction.x;
		localTileCoords.y += direction.y;
		
		if (localTileCoords.x >= 0 && localTileCoords.y >= 0 &&
		    localTileCoords.x < 10 && localTileCoords.y < 10) {
			state = State.PlayerMoving;
			animFrames = FRAMES_BETWEEN_TILE_MOVE;
		} else {
			state = State.ShiftingTile;
			animFrames = FRAMES_BETWEEN_TILE_SWITCH;
			tileCoords.x += direction.x;
			tileCoords.y += direction.y;
			
			nextTile = new Tile(TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
			backgroundLayer.add(nextTile);
			nextTile.x = Main.GAME_WIDTH * direction.x;
			nextTile.y = Main.GAME_HEIGHT * direction.y;
		}
	}
	
	public function handleMovement():Void {
		var _up = FlxG.keys.anyJustPressed([UP, W]);
        var _down = FlxG.keys.anyJustPressed([DOWN, S]);
        var _left = FlxG.keys.anyJustPressed([LEFT, A]);
        var _right = FlxG.keys.anyJustPressed([RIGHT, D]);
		
		if (state == State.Free) {
			if (_up && !_down) {
				direction = {x: 0, y: -1};
				startPlayerMove();
			}
			if (!_up && _down) {
				direction = {x: 0, y: 1};
				startPlayerMove();
			}
			if (_left && !_right) {
				direction = {x: -1, y: 0};
				startPlayerMove();
			}
			if (!_left && _right) {
				direction = {x: 1, y: 0};
				startPlayerMove();
			}
		}
		if (state == State.PlayerMoving) {
			--animFrames;
			var amtToMove = Std.int(Tile.TILE_WIDTH * Tile.TILE_SCALE / FRAMES_BETWEEN_TILE_MOVE);
			
			p.x += direction.x * amtToMove;
			p.y += direction.y * amtToMove;
			if (animFrames == 0) {
				state = State.Free;
				snapPlayerToTile();
			}
		}
	}
	
	public function shiftTile() {
		if (state != State.ShiftingTile) {
			return;
		}
		--animFrames;
		
		var dx = Main.GAME_WIDTH / FRAMES_BETWEEN_TILE_SWITCH * -direction.x;
		var dy = Main.GAME_HEIGHT / FRAMES_BETWEEN_TILE_SWITCH * -direction.y;
		currentTile.x += dx;
		currentTile.y += dy;
		nextTile.x += dx;
		nextTile.y += dy;
		p.x += dx * (1.0 - Tile.TILE_WIDTH / FRAMES_BETWEEN_TILE_SWITCH / Main.GAME_WIDTH);
		p.y += dy * (1.0 - Tile.TILE_HEIGHT / FRAMES_BETWEEN_TILE_SWITCH / Main.GAME_HEIGHT);
		
		if (animFrames == 0) {
			currentTile = nextTile;
			currentTile.x = 0;
			currentTile.y = 0;
			nextTile = null;
			state = State.Free;
			localTileCoords.x -= 10 * direction.x;
			localTileCoords.y -= 10 * direction.y;
			snapPlayerToTile();
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		handleMovement();
		shiftTile();
	}
}