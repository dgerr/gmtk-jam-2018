package;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
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
	StartResolving;
	EndResolving;
	ShiftingTile;
	CastingCane;
	Locked;
}
class AbstractPlayState extends FlxTransitionableState {
	
	public var backgroundLayer:FlxSpriteGroup;
	public var entityLayer:FlxSpriteGroup;
	public var particleLayer:FlxSpriteGroup;
	public var interfaceLayer:FlxSpriteGroup;
	
	public var p:Player;
	
	public var state:State = State.Free;
	public var direction:Object;
	public var facing:Object;
	public var animFrames:Int;
	
	public var FRAMES_BETWEEN_TILE_MOVE:Int = 4;
	public var FRAMES_BETWEEN_TILE_SWITCH:Int = 15;
	
	public var tileCoords:Object;
	public var localTileCoords:Object;
	public var respawnTileCoords:Object;
	
	public var currentTile:Tile;
	public var nextTile:Tile;
	public var frameCount:Int = 0;
	public var moveCount:Int = 0;
	
	public var showingDialogBox:Bool = false;
	public var dialogBox:DialogBox = null;
	
	public var animatingObjects:Array<WorldObject>;
	public var animatingDirections:Array<Object>;
	
	public override function create():Void {
		super.create();
		
		backgroundLayer = new FlxSpriteGroup();
		entityLayer = new FlxSpriteGroup();
		particleLayer = new FlxSpriteGroup();
		interfaceLayer = new FlxSpriteGroup();
		
		add(backgroundLayer);
		add(entityLayer);
		add(particleLayer);
		add(interfaceLayer);
		
		animatingObjects = new Array<WorldObject>();
		animatingDirections = new Array<Object>();
		
		p = new Player();
		
		entityLayer.add(p);
		facing = {x: 0, y: 1};
		
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
		p.x = Tile.REAL_TILE_WIDTH * localTileCoords.x;
		p.y = Tile.REAL_TILE_HEIGHT * localTileCoords.y;
	}
	
	private function startPlayerMove() {
		localTileCoords.x += direction.x;
		localTileCoords.y += direction.y;
		
		if (direction.x == -1) {
			p._sprite.animation.play("l");
			facing = {x: -1, y: 0};
		} else if (direction.x == 1) {
			p._sprite.animation.play("r");
			facing = {x: 1, y: 0};
		} else if (direction.y == 1) {
			p._sprite.animation.play("d");
			facing = {x: 0, y: 1};
		} else {
			p._sprite.animation.play("u");
			facing = {x: 0, y: -1};
		}
		
		if (localTileCoords.x >= 0 && localTileCoords.y >= 0 &&
		    localTileCoords.x < 10 && localTileCoords.y < 10) {
			var tileObject = currentTile.getSquare(localTileCoords);
			if (!currentTile.isTerrainPathable(localTileCoords)) {
				// collision with solid object
				state = State.Free;
				localTileCoords.x -= direction.x;
				localTileCoords.y -= direction.y;
				return;
			}
			if (tileObject.object != null) {
				if (WorldObject.isPushable(tileObject.object)) {
					if (!currentTile.isPathable({x: localTileCoords.x + direction.x, y: localTileCoords.y + direction.y})) {
						state = State.Free;
						localTileCoords.x -= direction.x;
						localTileCoords.y -= direction.y;
						return;
					} else {
						animatingObjects.push(tileObject.object);
						animatingDirections.push(Utilities.cloneDirection(direction));
					}
				} else if (WorldObject.isSolid(tileObject.object)) {
					// collision with unpushable WorldObject
					state = State.Free;
					localTileCoords.x -= direction.x;
					localTileCoords.y -= direction.y;
					return;
				}
			}
			animatingObjects.push(p);
			animatingDirections.push(Utilities.cloneDirection(direction));
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
		nextTile.changeAllSquares(292, 23);
	}
	
	public function handleMovement():Void {
		var _up = FlxG.keys.anyJustPressed([UP, W]);
        var _down = FlxG.keys.anyJustPressed([DOWN, S]);
        var _left = FlxG.keys.anyJustPressed([LEFT, A]);
        var _right = FlxG.keys.anyJustPressed([RIGHT, D]);
		
		if (showingDialogBox) {
			dialogBox.handleInput();
			return;
		}
		
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
			if (FlxG.keys.anyJustPressed([Z]) && state == State.Free) {
				searchForDialog();
			}
			if (FlxG.keys.anyJustPressed([X]) && state == State.Free) {
				state = State.CastingCane;
			}
		}
		if (state == State.PlayerMoving) {
			--animFrames;
			var amtToMove = Std.int(Tile.TILE_WIDTH * Tile.TILE_SCALE / FRAMES_BETWEEN_TILE_MOVE);
			
			for (i in 0...animatingObjects.length) {
				animatingObjects[i].x += animatingDirections[i].x * amtToMove;
				animatingObjects[i].y += animatingDirections[i].y * amtToMove;
			}
			if (animFrames == 0) {
				for (i in 0...animatingObjects.length) {
					var newLoc:Object = {x: animatingObjects[i].localX + animatingDirections[i].x,
					                     y: animatingObjects[i].localY + animatingDirections[i].y};
					currentTile.removeObjectsAtLoc(newLoc);
					
					animatingObjects[i].localX += animatingDirections[i].x;
					animatingObjects[i].localY += animatingDirections[i].y;
				}
				if (currentTile.getObjectAtLoc(localTileCoords) != null && currentTile.getObjectAtLoc(localTileCoords).type == "fireball") {
					currentTile.removeObjectsAtLoc(localTileCoords);
					killPlayer();
				}
				animatingObjects.splice(0, animatingObjects.length);
				animatingDirections.splice(0, animatingDirections.length);
				state = State.StartResolving;
				snapPlayerToTile();
				startResolveMove();
			}
		}
	}
	
	public function startResolveMove() {
		if (state != State.StartResolving) {
			return;
		}

		moveCount += 1;
		for (shrineLocation in WorldConstants.shrineLocationMap) {
			if (tileCoords.x == shrineLocation.tx && tileCoords.y == shrineLocation.ty &&
			    localTileCoords.x == shrineLocation.x && localTileCoords.y == shrineLocation.y) {
				GameState.get().overworldPosition = {tx: tileCoords.x, ty: tileCoords.y, x: localTileCoords.x, y: localTileCoords.y + 1};
				FlxG.switchState(new ShrinePlayState(shrineLocation.id));
				state = State.Locked;
			}
		}
		
		if (state == State.StartResolving) {
			var i = currentTile.worldObjects.length - 1;
			while (i > 0) {
				var worldObject = currentTile.worldObjects[i];
				if (worldObject.type == "fireball") {
					var dir = Utilities.directionToObject(worldObject.params.get("direction"));
					worldObject.x += Tile.REAL_TILE_WIDTH * dir.x;
					worldObject.y += Tile.REAL_TILE_HEIGHT * dir.y;
					
					if (localTileCoords.x == worldObject.localX + dir.x && localTileCoords.y == worldObject.localY + dir.y) {
						killPlayer();
						currentTile.worldObjectsLayer.remove(worldObject);
						currentTile.worldObjects.splice(i, 1);
					} else if (!currentTile.isPathableFGOnly({x: worldObject.localX + dir.x, y: worldObject.localY + dir.y})) {
						currentTile.worldObjectsLayer.remove(worldObject);
						currentTile.worldObjects.splice(i, 1);
					} else {
						worldObject.localX += dir.x;
						worldObject.localY += dir.y;
					}
				}
				--i;
			}
			
			for (worldObject in currentTile.worldObjects) {
				if (worldObject.type == "cannon") {
					if ((moveCount + Std.parseInt(worldObject.params.get("offset"))) % Std.parseInt(worldObject.params.get("frequency")) == 0) {
						var dirString = worldObject.params.get("direction");
						var dir = Utilities.directionToObject(dirString);
						var wo:WorldObject = new WorldObject(TiledMapManager.get().getTileBitmapData(297, dirString), "fireball",
															 ["x" => Std.string(worldObject.localX + dir.x),
															  "y" => Std.string(worldObject.localY + dir.y),
															  "direction" => dirString]);
						currentTile.addWorldObject(wo);
					}
				}
			}
			
			state = State.Free;
		}
	}
	
	public function castCane() {
		if (state != State.CastingCane) {
			return;
		}
		var nx:Int = localTileCoords.x + direction.x;
		var ny:Int = localTileCoords.y + direction.y;
		
		if (currentTile.isPathable({x: nx, y: ny})) {
			currentTile.removeObjectsOfType("playerCrate");
			currentTile.removeObjectsAtLoc({x: nx, y: ny});
			var wo:WorldObject = new WorldObject(TiledMapManager.get().getTileBitmapData(91), "playerCrate",
												 ["x" => Std.string(nx),
												  "y" => Std.string(ny)]);
			currentTile.addWorldObject(wo);
			
			for (i in 0...4) {
				var p:Particle = new Particle("particles/smoke.png",
				                              wo.x - 10 + 20 * (i % 2),
											  wo.y - 10 + 20 * Std.int(i / 2),
											  0.5,
											  function(v) { v.y -= 0.5; v.alpha -= 0.1; });
				particleLayer.add(p);
			}
			state = State.StartResolving;
			startResolveMove();
		}
		
		state = State.Free;
	}
	
	public function resolveCast() {
		if (state != State.CastingCane) {
			return;
		}
		var _up = FlxG.keys.anyJustPressed([UP, W]);
        var _down = FlxG.keys.anyJustPressed([DOWN, S]);
        var _left = FlxG.keys.anyJustPressed([LEFT, A]);
        var _right = FlxG.keys.anyJustPressed([RIGHT, D]);
		
		if (_up && !_down) {
			direction = {x: 0, y: -1};
			castCane();
		}
		if (!_up && _down) {
			direction = {x: 0, y: 1};
			castCane();
		}
		if (_left && !_right) {
			direction = {x: -1, y: 0};
			castCane();
		}
		if (!_left && _right) {
			direction = {x: 1, y: 0};
			castCane();
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
		particleLayer.x += dx;
		particleLayer.y += dy;
		p.x += dx * (1.0 - Tile.TILE_WIDTH / FRAMES_BETWEEN_TILE_SWITCH / Main.GAME_WIDTH);
		p.y += dy * (1.0 - Tile.TILE_HEIGHT / FRAMES_BETWEEN_TILE_SWITCH / Main.GAME_HEIGHT);
		
		if (animFrames == 0) {
			currentTile.destroy();
			currentTile = nextTile;
			currentTile.x = 0;
			currentTile.y = 0;
			particleLayer.x = 0;
			particleLayer.y = 0;
			for (particle in particleLayer) {
				particle.destroy();
			}
			nextTile = null;
			state = State.Free;
			localTileCoords.x -= 10 * direction.x;
			localTileCoords.y -= 10 * direction.y;
			if (currentTile.getSquare(localTileCoords).fg != 23) {
				currentTile.changeAllSquares(23, 292);
			}
			respawnTileCoords = Utilities.cloneDirection(localTileCoords);
			snapPlayerToTile();
		}
	}
	
	public function spawnParticleEffects() {
		if (frameCount % 2 == 0) {
			for (row in 0...currentTile.tileObject.bg.length) {
				for (col in 0...currentTile.tileObject.bg[row].length) {
					if (currentTile.tileObject.fg[row][col] == 380) {
						var p:Particle = new Particle("particles/sparkle.png",
													  col * Tile.REAL_TILE_WIDTH + 0.1 * Tile.REAL_TILE_WIDTH + 0.8 * Std.random(Tile.REAL_TILE_WIDTH + 1),
													  row * Tile.REAL_TILE_HEIGHT + 0.1 * Tile.REAL_TILE_HEIGHT + 0.9 * Std.random(Tile.REAL_TILE_HEIGHT + 1),
													  2,
													  function(v) { v.y -= 0.3; v.alpha -= 0.05; },
													  {rows: 1, cols: 4, animation: [0, 1, 2, 3]});
						particleLayer.add(p);
					}
				}
			}
		}
	}
	
	public function killPlayer() {
		localTileCoords = Utilities.cloneDirection(respawnTileCoords);
		snapPlayerToTile();
	}
	
	public function searchForDialog() {
		var potentialPartner = currentTile.getObjectAtLoc({x: localTileCoords.x + facing.x, y: localTileCoords.y + facing.y});
		if (potentialPartner == null) {
			return;
		}
		if (potentialPartner.type == "cat") {
			if (potentialPartner.params["type"] == "normal") {
				showDialogBox(potentialPartner.params["text"].split("|"));
			}
		}
	}
	
	public function showDialogBox(text:Array<String>) {
		showingDialogBox = true;
		dialogBox = new DialogBox(text, function() { showingDialogBox = false; },
		                          function() { showingDialogBox = false; handleMovement(); });
		
		interfaceLayer.add(dialogBox);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		handleMovement();
		startResolveMove();
		resolveCast();
		shiftTile();
		
		spawnParticleEffects();
		++frameCount;
	}
}