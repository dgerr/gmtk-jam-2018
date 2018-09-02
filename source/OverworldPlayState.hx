package;

import flixel.FlxG;

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
	
	public override function startResolveMove() {
		if (state != AbstractPlayState.State.StartResolving) {
			return;
		}

		for (shrineLocation in WorldConstants.shrineLocationMap) {
			if (tileCoords.x == shrineLocation.tx && tileCoords.y == shrineLocation.ty &&
			    p.loc.x == shrineLocation.x && p.loc.y == shrineLocation.y) {
				GameState.get().overworldPosition = {tx: tileCoords.x, ty: tileCoords.y, x: p.loc.x, y: p.loc.y + 1};
				FlxG.switchState(new ShrinePlayState(shrineLocation.id));
				state = AbstractPlayState.State.Locked;
			}
		}
		super.startResolveMove();
	}
}