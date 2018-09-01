package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import openfl.utils.Object;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;

enum State {
	Free;
	PlayerMoving;
	EnemyMoving;
	Resolving;
	ShiftingTile;
	Locked;
}
class PlayState extends FlxTransitionableState {
	
	public var backgroundLayer:FlxSpriteGroup;
	
	public var entityLayer:FlxSpriteGroup;
	public var p:Player;
	
	public var state:State = State.Free;
	public var direction:Object;
	public var animFrames:Int;
	
	public var FRAMES_BETWEEN_TILE_MOVE:Int = 4;
	public var FRAMES_BETWEEN_TILE_SWITCH:Int = 15;
	
	public var tileCoords:Object;
	public var localTileCoords:Object;
	
	public var currentTile:Tile;
	public var nextTile:Tile;
	
	public var animatingObject:WorldObject = null;
	
	
	
	override public function create():Void {
		super.create();
		
		backgroundLayer = new FlxSpriteGroup();
		entityLayer = new FlxSpriteGroup();
		
		TiledMapManager.get().loadTileSet("world");
		
		tileCoords = {x: GameState.get().overworldPosition.tx, y: GameState.get().overworldPosition.ty};
		localTileCoords = {x: GameState.get().overworldPosition.x, y: GameState.get().overworldPosition.y};
		
		currentTile = new Tile(TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
		
		add(backgroundLayer);
		add(entityLayer);
		
		p = new Player();
		
		entityLayer.add(p);
		
		backgroundLayer.add(currentTile);
		
		snapPlayerToTile();
		
		FlxTransitionableState.defaultTransIn = new TransitionData();
		FlxTransitionableState.defaultTransOut = new TransitionData();
		
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;
		
		FlxTransitionableState.defaultTransIn.color = FlxColor.BLACK;
		FlxTransitionableState.defaultTransOut.color = FlxColor.BLACK;
		FlxTransitionableState.defaultTransIn.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransOut.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransIn.tileData = { asset: diamond, width: 32, height: 32 };
		FlxTransitionableState.defaultTransOut.tileData = { asset: diamond, width: 32, height: 32 };
		transOut = FlxTransitionableState.defaultTransOut;
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
			var tileObject = currentTile.getSquare(localTileCoords);
			if (TiledMapManager.get().isSolid(tileObject.bg) || TiledMapManager.get().isSolid(tileObject.fg)) {
				// collision with solid object
				state = State.Free;
				localTileCoords.x -= direction.x;
				localTileCoords.y -= direction.y;
				return;
			}
			if (tileObject.object != null) {
				if (!currentTile.isPathable({x: localTileCoords.x + direction.x, y: localTileCoords.y + direction.y})) {
					state = State.Free;
					localTileCoords.x -= direction.x;
					localTileCoords.y -= direction.y;
					return;
				} else {
					animatingObject = tileObject.object;
				}
			}
			state = State.PlayerMoving;
			animFrames = FRAMES_BETWEEN_TILE_MOVE;
		} else {
			startShift();
		}
	}
	
	private function startShift() {
		state = State.ShiftingTile;
		animFrames = FRAMES_BETWEEN_TILE_SWITCH;
		tileCoords.x += direction.x;
		tileCoords.y += direction.y;
			
		nextTile = new Tile(TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
		backgroundLayer.add(nextTile);
		nextTile.x = Main.GAME_WIDTH * direction.x;
		nextTile.y = Main.GAME_HEIGHT * direction.y;
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
			if (animatingObject != null) {
				animatingObject.x += direction.x * amtToMove;
				animatingObject.y += direction.y * amtToMove;
			}
			if (animFrames == 0) {
				if (animatingObject != null) {
					animatingObject.localX += direction.x;
					animatingObject.localY += direction.y;
					animatingObject = null;
				}
				state = State.Resolving;
				snapPlayerToTile();
				resolveMove();
			}
		}
	}
	
	public function resolveMove() {
		if (state != State.Resolving) {
			return;
		}
		var tileInfo = currentTile.getSquare(localTileCoords);
		var passedChecks = true;
		
		// check red squares
		if (tileInfo.bg == 289) {
			currentTile.setSquare(localTileCoords, 290);
			
			if (currentTile.getNumTiles(289) > 0) {
				passedChecks = false;
			}
		}
		
		// check switches
		if (currentTile.getNumTiles(294) > 0) {
			for (i in 0...currentTile.tileObject.bg.length) {
				for (j in 0...currentTile.tileObject.bg[i].length) {
					if (currentTile.tileObject.fg[i][j] == 294 && (currentTile.isPathable({x: j, y: i}) && (localTileCoords.x != j || localTileCoords.y != i))) {
						passedChecks = false;
						break;
					}
				}
			}
		}
		
		if (passedChecks) {
			currentTile.changeAllSquares(292, 23);
		} else {
			currentTile.changeAllSquares(23, 292);
		}

		for (shrineLocation in WorldConstants.shrineLocationMap) {
			if (tileCoords.x == shrineLocation.tx && tileCoords.y == shrineLocation.ty &&
			    localTileCoords.x == shrineLocation.x && localTileCoords.y == shrineLocation.y) {
				GameState.get().overworldPosition = {tx: tileCoords.x, ty: tileCoords.y, x: localTileCoords.x, y: localTileCoords.y - 1};
				FlxG.switchState(new ShrinePlayState(shrineLocation.id));
				state = State.Locked;
			}
		}
		if (state == State.Resolving) {
			state = State.Free;
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
		resolveMove();
		shiftTile();
	}
}