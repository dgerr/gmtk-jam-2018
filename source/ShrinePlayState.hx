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