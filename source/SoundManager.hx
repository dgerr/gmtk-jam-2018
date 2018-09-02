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
		
		soundMap["step"] = AssetPaths.tile__wav;
		soundMap["gate"] = "assets/sounds/gate.wav";
		soundMap["mew"] = "assets/sounds/mew.wav";
		soundMap["stairs"] = "assets/sounds/stairs.wav";
		soundMap["advance"] = "assets/sounds/advance.wav";
		soundMap["victory"] = "assets/sounds/victory.wav";

		soundMap["shrine"] = AssetPaths.shrine__wav;
		soundMap["overworld"] = "assets/music/overworld_generic.wav";
	}
	
	public function stopMusic() {
		FlxG.sound.music.stop();
	}
	
	public function playMusic(musicName:String):Void {
		var volume:Float = 1.0;
		if (musicName == "shrine") volume = 0.3;
		FlxG.sound.playMusic(soundMap[musicName], volume);
	}

	public function playSound(soundName:String):Void {
		if (!soundMap.exists(soundName)) {
			trace("No sound with key " + soundName);
			return;
		}
		var volume:Float = 1.0;
		if (soundName == "advance") volume = 0.15;
		FlxG.sound.load(soundMap[soundName], 0.15).play();
	}
}