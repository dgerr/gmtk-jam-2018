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
		
		if (!GameState.get().seenStartCutscene) {
			GameState.get().seenStartCutscene = true;
			p._sprite.animation.play("r");
			
			showDialogBox("normal", ["ELDER: Adventurer! You look very brave and strong...can you help us?",
			                         "We residents of this town have been cursed to be cats forever.",
									 "Only by seeking the treasures of the eight shrines can the curse be lifted...but it's simply too dangerous for us!",
									 "Wait, you're a cat too...",
									 "Were you a cat before you entered the town? Or...?",
									 "...", "... ...",
									 "Well, whatever...",
									 "Please, help us!",
									 "We'll help you however you can!",
									 "Once you collect a few treasures, I can teach you a magic spell!",
									 "We're counting on you, meow!!"]);
		}
		if (GameState.get().shrinesBeaten == 8 && !GameState.get().seenEndCutscene) {
			GameState.get().seenEndCutscene = true;
			p._sprite.animation.play("r");
			
			showDialogBox("normal", ["(You present the statue with all eight treasures...)",
			                         "...", "... ...", "The statue glows approvingly!", "The curse is lifted!",
									 "ELDER: Adventurer! We can't thank you enough!",
									 "The curse is lifted, and we can all return to our true forms now!",
									 "Our town is truly in your debt.",
									 "... ...",
									 "I see...you're wondering why we're still cats.", "...",
									 "Well... ... we've been cats for so many years, we actually realized...",
									 "...that we kind of enjoy being cats...",
									 "... ...",
									 "...But we can't thank you enough!!!",
									 "You're welcome here anytime, meow!"]);
		}
		
		SoundManager.get().playMusic("overworld");
	}
	
	public override function startResolveMove() {
		if (state != AbstractPlayState.State.StartResolving) {
			return;
		}

		for (shrineLocation in WorldConstants.shrineLocationMap) {
			if (tileCoords.x == shrineLocation.tx && tileCoords.y == shrineLocation.ty &&
			    p.loc.x == shrineLocation.x && p.loc.y == shrineLocation.y) {
				GameState.get().overworldPosition = {tx: tileCoords.x, ty: tileCoords.y, x: p.loc.x, y: p.loc.y + 1};
				SoundManager.get().playSound("stairs");
				FlxG.switchState(new ShrinePlayState(shrineLocation.id));
				state = AbstractPlayState.State.Locked;
			}
		}
		super.startResolveMove();
	}
}