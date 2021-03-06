package;

import flixel.FlxG;
import flixel.util.FlxTimer;

using AbstractPlayState.State;

class ShrinePlayState extends AbstractPlayState {
	public var shrineID:String;
	public var savePassedChecks:Bool = false;
	
	override public function create():Void {
		super.create();
		
		TiledMapManager.get().loadTileSet(shrineID);
		
		p.tileCoords = {x: WorldConstants.shrineInfo[shrineID].tx_start, y: WorldConstants.shrineInfo[shrineID].ty_start};
		p.loc = {x: WorldConstants.shrineInfo[shrineID].x_start, y: WorldConstants.shrineInfo[shrineID].y_start};
		respawnTileCoords = Utilities.cloneDirection(p.loc);

		currentTile = new Tile(p, TiledMapManager.get().getTileObject(p.tileCoords.x, p.tileCoords.y));
		
		backgroundLayer.add(currentTile);
		snapPlayerToTile();
		
		SoundManager.get().playMusic("shrine");
	}
	
	public override function startResolveMove() {
		if (state != State.StartResolving) {
			return;
		}
		super.startResolveMove();
		
		var tileInfo = currentTile.getSquare(p.loc);
		var passedChecks = true;
		
		for (obj in currentTile.worldObjects) {
			if ((obj.type == "zombie" || obj.type == "shadow") && (animatedObjects != null && animatedObjects.indexOf(obj) != -1)) {
				var objTileInfo = currentTile.getSquare(obj.loc);
				
				if (objTileInfo.bg == 289) {
					currentTile.setSquare(obj.loc, 290);
				} else if (objTileInfo.bg == 290) {
					currentTile.changeAllSquares(289, 314);
					currentTile.changeAllSquares(290, 314);
				}
			}
		}
		
		// check red squares
		if (tileInfo.bg == 289) {
			currentTile.setSquare(p.loc, 290);
			SoundManager.get().playSound("tile");
		} else if (tileInfo.bg == 290) {
			currentTile.changeAllSquares(289, 314);
			currentTile.changeAllSquares(290, 314);
		}
		if (currentTile.getNumTiles(289) == 0 && currentTile.getNumTiles(314) == 0) {
			currentTile.changeAllSquares(290, 324);
		}
		if (currentTile.getNumTiles(289) > 0 || currentTile.getNumTiles(314) > 0) {
			passedChecks = false;
			if (currentTile.getNumTiles(314) > 0) {
				p.addKeyIndicator();
			} else {
				p.removeKeyIndicator();
			}
		}
		
		// check switches
		if (currentTile.getNumTiles(294) > 0) {
			for (i in 0...currentTile.tileObject.bg.length) {
				for (j in 0...currentTile.tileObject.bg[i].length) {
					if (currentTile.tileObject.fg[i][j] == 294 && (currentTile.isPathable({x: j, y: i}) && (p.loc.x != j || p.loc.y != i))) {
						passedChecks = false;
						break;
					}
				}
			}
		}
		
		// spawn shadow clones
		if (tileInfo.fg == 318) {
			currentTile.removeObjectsOfType("shadow");
			shadows.splice(0, shadows.length);
			for (i in 0...currentTile.tileObject.bg.length) {
				for (j in 0...currentTile.tileObject.bg[i].length) {
					if (currentTile.tileObject.fg[i][j] == 319 && currentTile.isPathable({x: j, y: i})) {
						var wo:ShadowPlayer = new ShadowPlayer(["x" => Std.string(j), "y" => Std.string(i)]);
						wo.type = "shadow";
						currentTile.addWorldObject(wo);
						shadows.push(wo);
					}
				}
			}
		}
		if (FlxG.keys.pressed.C) passedChecks = true;
		
		if (!savePassedChecks || WorldConstants.shrinesWithPermanentGates.indexOf(shrineID) == -1) {
			if (passedChecks) {
				savePassedChecks = true;
				if (currentTile.getNumTiles(292) > 0) {
					SoundManager.get().playSound("gate");
				}
				currentTile.changeAllSquares(292, 23);
			} else {
				if (currentTile.getNumTiles(23) > 0) {
					SoundManager.get().playSound("gate");
				}
				currentTile.changeAllSquares(23, 292);
			}
		}
		
		if (tileInfo.fg == 312) {
			if (!GameState.get().shrineProgress.exists(shrineID)) {
				GameState.get().shrineProgress[shrineID] = 100;
				GameState.get().shrinesBeaten += 1;
			}
			state = State.Locked;
			currentTile.changeAllSquares(312, -1);
			p._sprite.animation.play("aloft");
			SoundManager.get().stopMusic();
			SoundManager.get().playSound("victory");
			if (GameState.get().shrinesBeaten == 8 && !GameState.get().seenEndCutscene) {
				GameState.get().overworldPosition = {tx: 3, ty: 3, x: 5, y: 4};
			}
			new FlxTimer().start(7, function(t:FlxTimer) { FlxG.switchState(new OverworldPlayState()); }, 1);
		}

		if (state == State.StartResolving) {
			state = State.Free;
		}
	}
	
	public override function killPlayer() {
		super.killPlayer();
		
		currentTile.removeObjectsOfType("shadow");
		currentTile.changeAllSquares(290, 289);
		currentTile.changeAllSquares(314, 289);
		currentTile.changeAllSquares(324, 289);
	}

	private override function startShift() {
		p.tileCoords.x += playerDirection.x;
		p.tileCoords.y += playerDirection.y;
		
		if (!TiledMapManager.get().hasTileObjectAt(p.tileCoords.x, p.tileCoords.y)) {
			state = State.Locked;
			FlxG.switchState(new OverworldPlayState());
			return;
		}
		p.tileCoords.x -= playerDirection.x;
		p.tileCoords.y -= playerDirection.y;
		savePassedChecks = false;
		super.startShift();
	}

	public function new(shrineID:String) {
		super();
		
		this.shrineID = shrineID;
	}
}