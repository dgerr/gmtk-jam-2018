package;
import flixel.FlxG;

import flixel.system.FlxSound;

class SoundManager {
	public static var _manager:SoundManager = null;
	
	public static var currentMusic:FlxSound = null;
	
	public static var soundMap:Map<String, FlxSound>;
	
	public static function get():SoundManager {
		if (_manager == null) {
			_manager = new SoundManager();
		}
		return _manager;
	}
	
	public function new() {
		soundMap = new Map<String, FlxSound>();
		
		soundMap["step"] = FlxG.sound.load(AssetPaths.tile__wav);

		soundMap["shrine"] = FlxG.sound.load(AssetPaths.shrine__wav);
	}
	
	public function stopMusic() {
		currentMusic.stop();
		currentMusic = null;
	}
	
	public function playMusic(musicName:String):Void {
		if (currentMusic != null) {
			currentMusic.stop();
		}
		if (!soundMap.exists(musicName)) {
			trace("No music with key " + musicName);
			return;
		}
		trace("playing" + soundMap[musicName]);
		currentMusic = soundMap[musicName];
		currentMusic.play();
	}

	public function playSound(soundName:String):Void {
		if (!soundMap.exists(soundName)) {
			trace("No sound with key " + soundName);
			return;
		}
		soundMap[soundName].play();
	}
}