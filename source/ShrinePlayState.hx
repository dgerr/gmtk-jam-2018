package;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class ShrinePlayState extends PlayState {
	public var shrineID:String;
	
	override public function create():Void {
		super.create();
		
		backgroundLayer = new FlxSpriteGroup();
		entityLayer = new FlxSpriteGroup();
		
		TiledMapManager.get().loadTileSet(shrineID);
		tileCoords = {x: WorldConstants.shrineInfo[shrineID].tx_start, y: WorldConstants.shrineInfo[shrineID].ty_start};
		localTileCoords = {x: WorldConstants.shrineInfo[shrineID].x_start, y: WorldConstants.shrineInfo[shrineID].y_start};
		currentTile = new Tile(TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
		
		add(backgroundLayer);
		add(entityLayer);
		
		p = new Player();
		
		entityLayer.add(p);
		
		backgroundLayer.add(currentTile);
		
		snapPlayerToTile();
	}
	
	public override function resolveMove() {
		if (state != PlayState.State.Resolving) {
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
		
		if (tileInfo.fg == 312) {
			GameState.get().shrineProgress[shrineID] = 100;
			state = PlayState.State.Locked;
			FlxG.switchState(new PlayState());
		}

		for (shrineLocation in WorldConstants.shrineLocationMap) {
			if (tileCoords.x == shrineLocation.tx && tileCoords.y == shrineLocation.ty &&
			    localTileCoords.x == shrineLocation.x && localTileCoords.y == shrineLocation.y) {
				GameState.get().overworldPosition = {tx: tileCoords.x, ty: tileCoords.y, x: localTileCoords.x, y: localTileCoords.y - 1};
				FlxG.switchState(new ShrinePlayState(shrineLocation.id));
				state = PlayState.State.Locked;
			}
		}
		if (state == PlayState.State.Resolving) {
			state = PlayState.State.Free;
		}
	}

	private override function startShift() {
		tileCoords.x += direction.x;
		tileCoords.y += direction.y;
		
		if (TiledMapManager.get().hasTileObjectAt(tileCoords.x, tileCoords.y)) {
			state = PlayState.State.ShiftingTile;
			animFrames = FRAMES_BETWEEN_TILE_SWITCH;
				
			nextTile = new Tile(TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
			backgroundLayer.add(nextTile);
			nextTile.x = Main.GAME_WIDTH * direction.x;
			nextTile.y = Main.GAME_HEIGHT * direction.y;
		} else {
			state = PlayState.State.Locked;
			FlxG.switchState(new PlayState());
		}
	}

	public function new(shrineID:String) {
		super();
		
		this.shrineID = shrineID;
	}
}