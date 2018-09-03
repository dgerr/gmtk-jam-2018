package;
import flixel.FlxG;

class SoundManager {
	public static var _manager:SoundManager = null;
	
	public static var currentMusic:String = null;
	
	public static var soundMap:Map<String, String>;
	
	public static function get():SoundManager {
		if (_manager == null) {
			_manager = new SoundManager();
		}
		return _manager;
	}
	
	public function new() {
		soundMap = new Map<String, String>();
		
		soundMap["step"] = "assets/sounds/step.mp3";
		soundMap["gate"] = "assets/sounds/gate.mp3";
		soundMap["mew"] = "assets/sounds/mew.mp3";
		soundMap["stairs"] = "assets/sounds/stairs.mp3";
		soundMap["advance"] = "assets/sounds/advance.mp3";
		soundMap["victory"] = "assets/sounds/victory.mp3";
		soundMap["puff"] = "assets/sounds/puff.mp3";

		soundMap["shrine"] = "assets/music/shrine.mp3";
		soundMap["overworld"] = "assets/music/silly_song4.mp3";
	}
	
	public function stopMusic() {
		FlxG.sound.music.stop();
	}
	
	public function playMusic(musicName:String):Void {
		var volume:Float = 1.0;
		volume = 0.6;
		if (musicName == "shrine") volume = 0.15;
		FlxG.sound.playMusic(soundMap[musicName], volume);
	}

	public function playSound(soundName:String):Void {
		if (!soundMap.exists(soundName)) {
			trace("No sound with key " + soundName);
			return;
		}
		var volume:Float = 1.0;
		if (soundName == "puff") volume = 0.15;
		if (soundName == "advance") volume = 0.3;
		FlxG.sound.load(soundMap[soundName], volume).play();
	}
}