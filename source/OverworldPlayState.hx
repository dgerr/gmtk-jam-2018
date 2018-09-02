package;

class OverworldPlayState extends AbstractPlayState {
	override public function create():Void {
		super.create();
		
		TiledMapManager.get().loadTileSet("world");
		
		tileCoords = {x: GameState.get().overworldPosition.tx, y: GameState.get().overworldPosition.ty};
		p.loc = {x: GameState.get().overworldPosition.x, y: GameState.get().overworldPosition.y};
		respawnTileCoords = Utilities.cloneDirection(p.loc);
		
		currentTile = new Tile(p, TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
		
		backgroundLayer.add(currentTile);
		snapPlayerToTile();
	}
}