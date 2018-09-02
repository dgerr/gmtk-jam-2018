package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import openfl.Assets;
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
	
	public var shadows:Array<ShadowPlayer>;
	
	public var state:State = State.Free;
	public var playerDirection:Object;
	public var facing:Object;
	public var animFrames:Int;
	
	public var FRAMES_BETWEEN_TILE_MOVE:Int = 4;
	public var FRAMES_BETWEEN_TILE_SWITCH:Int = 15;
	public var FRAMES_TO_LOCK_MOVEMENT:Int = 9;
	
	public var tileCoords:Object;
	public var respawnTileCoords:Object;
	
	public var currentTile:Tile;
	public var nextTile:Tile;
	public var frameCount:Int = 0;
	public var lockMoveFrameCount:Int = 0;
	public var moveCount:Int = 0;
	
	public var showingDialogBox:Bool = false;
	public var dialogBox:DialogBox = null;
	
	public var animatingObjects:Array<WorldObject>;
	public var animatingDirections:Array<Object>;
	
	public var keyIndicator:FlxSprite;
	public var keyIndicatorAttached:Bool = false;
	
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
		
		shadows = new Array<ShadowPlayer>();
		
		entityLayer.add(p);
		facing = {x: 0, y: 1};
		
		keyIndicator = new FlxSprite();
		keyIndicator.loadGraphic(Utilities.scaleBitmapData(Assets.getBitmapData("assets/images/key_indicators.png"), 3, 3), true, 30, 30);
		keyIndicator.animation.add("z", [0], 1, true);
		keyIndicator.animation.add("r", [1], 1, true);
		keyIndicator.animation.play("z");
		
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
		p.x = Tile.REAL_TILE_WIDTH * p.loc.x;
		p.y = Tile.REAL_TILE_HEIGHT * p.loc.y;
	}
	
	private function tryObjectMove(wo:WorldObject, direction:Object):Array<WorldObject> {
		var nextLoc = {x: wo.loc.x + direction.x, y: wo.loc.y + direction.y};
		
		if (direction.x == -1) {
			if (wo.type != "zombie") wo._sprite.animation.play("l");
			if (wo.type == "player") facing = {x: -1, y: 0};
		} else if (direction.x == 1) {
			if (wo.type != "zombie") wo._sprite.animation.play("r");
			if (wo.type == "player") facing = {x: 1, y: 0};
		} else if (direction.y == 1) {
			if (wo.type != "zombie") wo._sprite.animation.play("d");
			if (wo.type == "player") facing = {x: 0, y: 1};
		} else {
			if (wo.type != "zombie") wo._sprite.animation.play("u");
			if (wo.type == "player") facing = {x: 0, y: -1};
		}
		
		if (currentTile.isInBounds(nextLoc)) {
			var tileObject = currentTile.getSquare(nextLoc);
			if (!currentTile.isTerrainPathable(nextLoc)) {
				// collision with solid object
				return [];
			}
			if (tileObject.object != null) {
				if (WorldObject.isPushable(tileObject.object)) {
					if (!currentTile.isPathable({x: nextLoc.x + direction.x, y: nextLoc.y + direction.y})) {
						return [];
					} else {
						return [wo, tileObject.object];
					}
				} else if (WorldObject.isSolid(tileObject.object)) {
					// collision with unpushable WorldObject
					return [];
				}
			}
			return [wo];
		}
		return [];
	}
	
	private function startPlayerMove() {
		if (state != State.Free) {
			return;
		}
		
		var sortedPlayers = new Array<WorldObject>();
		sortedPlayers.push(p);
		for (shadow in shadows) {
			sortedPlayers.push(shadow);
		}
		sortedPlayers.sort(function(wo1, wo2) {
			return Std.int((wo2.loc.x - wo1.loc.x) * playerDirection.x + (wo2.loc.y - wo1.loc.y) * playerDirection.y);
		});
		
		for (obj in sortedPlayers) {
			var pushedObjects:Array<WorldObject> = tryObjectMove(obj, playerDirection);
			
			if (pushedObjects.length > 0) {
				for (object in pushedObjects) {
					animatingObjects.push(object);
					animatingDirections.push(Utilities.cloneDirection(playerDirection));
					object.loc.x += playerDirection.x;
					object.loc.y += playerDirection.y;
				}
				state = State.PlayerMoving;
				lockMoveFrameCount = FRAMES_TO_LOCK_MOVEMENT;
				animFrames = FRAMES_BETWEEN_TILE_MOVE;
			}
		}
		
		if (state == State.Free) {
			var nextLoc = {x: p.loc.x + playerDirection.x, y: p.loc.y + playerDirection.y};
			if (!currentTile.isInBounds(nextLoc)) {
				startShift();
			}
		} else {
			++moveCount;
		}
	}
	
	private function startShift() {
		state = State.ShiftingTile;
		animFrames = FRAMES_BETWEEN_TILE_SWITCH;
		tileCoords.x += playerDirection.x;
		tileCoords.y += playerDirection.y;
			
		nextTile = new Tile(p, TiledMapManager.get().getTileObject(tileCoords.x, tileCoords.y));
		backgroundLayer.add(nextTile);
		nextTile.x = Main.GAME_WIDTH * playerDirection.x;
		nextTile.y = Main.GAME_HEIGHT * playerDirection.y;
		nextTile.changeAllSquares(292, 23);
	}
	
	public function handleMovement():Void {
		var _up = FlxG.keys.anyJustPressed([UP, W]) || (lockMoveFrameCount == 0 && FlxG.keys.anyPressed([UP, W]));
        var _down = FlxG.keys.anyJustPressed([DOWN, S]) || (lockMoveFrameCount == 0 && FlxG.keys.anyPressed([DOWN, S]));
        var _left = FlxG.keys.anyJustPressed([LEFT, A]) || (lockMoveFrameCount == 0 && FlxG.keys.anyPressed([LEFT, A]));
        var _right = FlxG.keys.anyJustPressed([RIGHT, D]) || (lockMoveFrameCount == 0 && FlxG.keys.anyPressed([RIGHT, D]));
		
		if (showingDialogBox) {
			dialogBox.handleInput();
			return;
		}
		
		if (state == State.Free) {
			if (_up && !_down) {
				playerDirection = {x: 0, y: -1};
				startPlayerMove();
			}
			if (state == State.Free && !_up && _down) {
				playerDirection = {x: 0, y: 1};
				startPlayerMove();
			}
			if (state == State.Free && _left && !_right) {
				playerDirection = {x: -1, y: 0};
				startPlayerMove();
			}
			if (state == State.Free && !_left && _right) {
				playerDirection = {x: 1, y: 0};
				startPlayerMove();
			}
			if (FlxG.keys.anyJustPressed([R]) && state == State.Free) {
				killPlayer();
			}
			if (FlxG.keys.anyJustPressed([Z]) && state == State.Free) {
				searchForDialog();
			}
			if (FlxG.keys.anyJustPressed([X]) && state == State.Free) {
				state = State.CastingCane;
			}
		}
		if (state == State.Free) {
			refreshKeyIndicator();
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
					currentTile.removeObjectsAtLocOtherThan(animatingObjects[i]);
				}
				if (currentTile.getObjectAtLoc(p.loc) != null && currentTile.getObjectAtLoc(p.loc).type == "fireball") {
					currentTile.removeObjectsAtLoc(p.loc);
					killPlayer();
				}
				animatingObjects.splice(0, animatingObjects.length);
				animatingDirections.splice(0, animatingDirections.length);
				state = State.StartResolving;
				snapPlayerToTile();
				startResolveMove();
			}
		}
		if (state == State.EnemyMoving) {
			--animFrames;
			var amtToMove = Std.int(Tile.TILE_WIDTH * Tile.TILE_SCALE / FRAMES_BETWEEN_TILE_MOVE);
			
			for (i in 0...animatingObjects.length) {
				animatingObjects[i].x += animatingDirections[i].x * amtToMove;
				animatingObjects[i].y += animatingDirections[i].y * amtToMove;
			}
			if (animFrames == 0) {
				var i = 0;
				while (i < animatingObjects.length) {
					var wo:WorldObject = animatingObjects[i];
					if (wo.type == "zombie" && (Math.abs(p.loc.x - wo.loc.x) + Math.abs(p.loc.y - wo.loc.y)) <= 1) {
						var p:Particle = new Particle("particles/heart.png", animatingObjects[i].x + Tile.REAL_TILE_WIDTH / 2 - 20, animatingObjects[i].y - 15, 1,
													  function(p) { p.y -= (0.6 - 0.024 * p.frameNumber); p.alpha -= 0.02; });
						particleLayer.add(p);
					} else if (wo.type == "fireball") {
						if (p.loc.x == wo.loc.x && p.loc.y == wo.loc.y) {
							killPlayer();
							currentTile.worldObjectsLayer.remove(wo);
							currentTile.worldObjects.remove(wo);
							animatingObjects.splice(i, 1);
							animatingDirections.splice(i, 1);
							--i;
						} else if (!currentTile.isPathableFGOnly(wo.loc)) {
							currentTile.worldObjectsLayer.remove(wo);
							currentTile.worldObjects.remove(wo);
							animatingObjects.splice(i, 1);
							animatingDirections.splice(i, 1);
							--i;
						}
					}
					currentTile.removeObjectsAtLocOtherThan(animatingObjects[i]);
					++i;
				}
				animatingObjects.splice(0, animatingObjects.length);
				animatingDirections.splice(0, animatingDirections.length);
				givePlayerControl();
			}
		}
	}
	
	public function startResolveMove() {
		if (state != State.StartResolving) {
			return;
		}
		
		var sortedZombies = new Array<WorldObject>();
		for (obj in currentTile.worldObjects) {
			if (obj.type == "zombie") {
				sortedZombies.push(obj);
			}
		}
		
		for (zombie in sortedZombies) {
			var dx = p.loc.x - zombie.loc.x;
			var dy = p.loc.y - zombie.loc.y;
			
			var sdx = (dx < 0 ? -1 : (dx > 0 ? 1 : 0));
			var sdy = (dy < 0 ? -1 : (dy > 0 ? 1 : 0));
			
			var tryX = {x: sdx, y: 0};
			var tryY = {x: 0, y: sdy};
			
			var moveX = tryObjectMove(zombie, tryX);
			var moveY = tryObjectMove(zombie, tryY);
			
			var moveStrategy = "none";
			if (Math.abs(dx) > Math.abs(dy) && moveX.length > 0) {
				moveStrategy = "x";
			} else if (Math.abs(dy) > Math.abs(dx) && moveY.length > 0) {
				moveStrategy = "y";
			} else if (moveX.length > 0) {
				moveStrategy = "x";
			} else if (moveY.length > 0) {
				moveStrategy = "y";
			}
			if (moveStrategy == "x") {
				for (object in moveX) {
					animatingObjects.push(object);
					animatingDirections.push(Utilities.cloneDirection(tryX));
					object.loc.x += sdx;
				}
				state = State.EnemyMoving;
				animFrames = FRAMES_BETWEEN_TILE_MOVE;
			} else if (moveStrategy == "y") {
				for (object in moveY) {
					animatingObjects.push(object);
					animatingDirections.push(Utilities.cloneDirection(tryY));
					object.loc.y += sdy;
				}
				state = State.EnemyMoving;
				animFrames = FRAMES_BETWEEN_TILE_MOVE;
			} else {
				var p:Particle = new Particle("particles/heart.png", zombie.x + Tile.REAL_TILE_WIDTH / 2 - 20, zombie.y - 15, 1,
													  function(p) { p.y -= (0.6 - 0.024 * p.frameNumber); p.alpha -= 0.02; });
				particleLayer.add(p);
			}
		}
		
		var i = currentTile.worldObjects.length - 1;
		while (i > 0) {
			var worldObject = currentTile.worldObjects[i];
			if (worldObject.type == "fireball") {
				state = State.EnemyMoving;
				animFrames = FRAMES_BETWEEN_TILE_MOVE;
				if (p.loc.x == worldObject.loc.x && p.loc.y == worldObject.loc.y) {
					killPlayer();
					currentTile.worldObjectsLayer.remove(worldObject);
					currentTile.worldObjects.splice(i, 1);
				} else {
					animatingObjects.push(worldObject);
					var dir = Utilities.directionToObject(worldObject.params.get("direction"));
					animatingDirections.push(dir);
					worldObject.loc.x += dir.x;
					worldObject.loc.y += dir.y;
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
														 ["x" => Std.string(worldObject.loc.x + dir.x),
														  "y" => Std.string(worldObject.loc.y + dir.y),
														  "direction" => dirString]);
					currentTile.addWorldObject(wo);
				}
			}
		}
		
		if (state != State.EnemyMoving) {
			givePlayerControl();
		}
	}
	
	public function castCane() {
		if (state != State.CastingCane) {
			return;
		}
		if (!GameState.get().unlockedStaff) {
			return;
		}
		var nx:Int = p.loc.x + playerDirection.x;
		var ny:Int = p.loc.y + playerDirection.y;
		
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
			++moveCount;
			state = State.StartResolving;
			startResolveMove();
		}
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
			playerDirection = {x: 0, y: -1};
			castCane();
		}
		if (!_up && _down) {
			playerDirection = {x: 0, y: 1};
			castCane();
		}
		if (_left && !_right) {
			playerDirection = {x: -1, y: 0};
			castCane();
		}
		if (!_left && _right) {
			playerDirection = {x: 1, y: 0};
			castCane();
		}
	}
	
	public function shiftTile() {
		if (state != State.ShiftingTile) {
			return;
		}
		--animFrames;
		
		var dx = Main.GAME_WIDTH / FRAMES_BETWEEN_TILE_SWITCH * -playerDirection.x;
		var dy = Main.GAME_HEIGHT / FRAMES_BETWEEN_TILE_SWITCH * -playerDirection.y;
		currentTile.x += dx;
		currentTile.y += dy;
		nextTile.x += dx;
		nextTile.y += dy;
		particleLayer.x += dx;
		particleLayer.y += dy;
		p.x += dx * (1.0 - Tile.TILE_WIDTH / FRAMES_BETWEEN_TILE_SWITCH / Main.GAME_WIDTH);
		p.y += dy * (1.0 - Tile.TILE_HEIGHT / FRAMES_BETWEEN_TILE_SWITCH / Main.GAME_HEIGHT);
		
		if (animFrames == 0) {
			//currentTile.destroy();
			currentTile = nextTile;
			currentTile.x = 0;
			currentTile.y = 0;
			particleLayer.x = 0;
			particleLayer.y = 0;
			for (particle in particleLayer) {
				particle.destroy();
			}
			nextTile = null;
			givePlayerControl();
			p.loc.x -= 9 * playerDirection.x;
			p.loc.y -= 9 * playerDirection.y;
			if (currentTile.getSquare(p.loc).fg != 23) {
				currentTile.changeAllSquares(23, 292);
			}
			respawnTileCoords = Utilities.cloneDirection(p.loc);
			snapPlayerToTile();
		}
	}
	public function refreshKeyIndicator() {
		var potentialPartner = currentTile.getObjectAtLoc({x: p.loc.x + facing.x, y: p.loc.y + facing.y});
		if (potentialPartner != null && (potentialPartner.type == "cat" || potentialPartner.type == "catStatue")) {
			if (!keyIndicatorAttached) {
				interfaceLayer.add(keyIndicator);
			}
			keyIndicator.x = potentialPartner.x + Tile.REAL_TILE_WIDTH / 2 - 15;
			keyIndicator.y = potentialPartner.y - 25 + (potentialPartner.type == "catStatue" ? -Tile.REAL_TILE_HEIGHT : 0);
			keyIndicatorAttached = true;
		} else {
			if (keyIndicatorAttached) {
				interfaceLayer.remove(keyIndicator);
			}
			keyIndicatorAttached = false;
		}
	}
	
	public function givePlayerControl() {
		state = State.Free;
		
		refreshKeyIndicator();
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
		for (object in currentTile.worldObjects) {
			if (object.type == "zombie") {
				object.loc.x = Std.parseInt(object.params["ox"]);
				object.loc.y = Std.parseInt(object.params["oy"]);
				object.x = Tile.REAL_TILE_WIDTH * object.loc.x;
				object.y = Tile.REAL_TILE_HEIGHT * object.loc.y;
			}
		}
		p.loc = Utilities.cloneDirection(respawnTileCoords);
		snapPlayerToTile();
	}
	
	public function searchForDialog() {
		var potentialPartner = currentTile.getObjectAtLoc({x: p.loc.x + facing.x, y: p.loc.y + facing.y});
		if (potentialPartner == null) {
			return;
		}
		if (potentialPartner.type == "cat" || potentialPartner.type == "catStatue") {
			if (potentialPartner.params["type"] == "normal") {
				showDialogBox(potentialPartner.type, potentialPartner.params["text"].split("|"));
			} else {
				showDialogBox(potentialPartner.type, getSpecialDialog(potentialPartner.params["type"]));
			}
		}
	}
	
	public function getSpecialDialog(type:String):Array<String> {
		if (type == "elder") {
			if (!GameState.get().unlockedStaff && GameState.get().shrinesBeaten >= 3) {
				GameState.get().unlockedStaff = true;
				return ["You're making excellent progress. Let me teach you an ancient magic spell...",
				        "(You can use the [Kitten Box] ability! Press 'X' followed by a direction to summon a pushable crate!)",
						"I wish you luck on your adventure. Now that you can summon boxes, seek out the shrine in our village to the southwest!"];
			}
			if (!GameState.get().shrineProgress.exists("shrine1")) {
				return ["Please, adventurer! Help us rescue the 8 guardian cat spirits!", "I think I saw a shrine to the east. Try wandering that way."];
			} else if (!GameState.get().shrineProgress.exists("shrine3")) {
				return ["Good to see you again!", "Looking for another shrine? Try wandering to the north."];
			} else if (!GameState.get().shrineProgress.exists("shrine2")) {
				return ["Ah, you look like you're doing well!", "Looking for another shrine? Try wandering to the northwest."];
			}
			return ["Unfortunately, I'm an old cat. I haven't the energy to explore the world anymore. You'll need to find the other shrines on your own."];
		}
		trace("Unknown type " + type);
		return ["..."];
	}
	
	public function showDialogBox(type:String, text:Array<String>) {
		showingDialogBox = true;
		dialogBox = new DialogBox(type, text, function() { showingDialogBox = false; },
		                          function() { showingDialogBox = false; handleMovement(); });
		
		interfaceLayer.add(dialogBox);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		handleMovement();
		resolveCast();
		shiftTile();
		
		spawnParticleEffects();
		++frameCount;
		if (lockMoveFrameCount > 0) {
			--lockMoveFrameCount;
		}
	}
}