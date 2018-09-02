package;

import openfl.utils.Object;

class WorldConstants {
	public static var shrineLocationMap:Array<Object> =
		[ {tx: 4, ty: 3, x: 5, y: 3, id: "shrine1"},
		  {tx: 5, ty: 3, x: 7, y: 5, id: "shrine2"},
		  {tx: 5, ty: 5, x: 7, y: 6, id: "shrine3"},
		  {tx: 4, ty: 1, x: 4, y: 4, id: "shrine4"},
		  {tx: 2, ty: 3, x: 4, y: 4, id: "shrine5"},
		  {tx: 2, ty: 2, x: 4, y: 4, id: "shrine6"}];
		  
	public static var shrineInfo:Map<String, Object> =
		["shrine1" => {tx_start: 0, ty_start: 2, x_start: 4, y_start: 9},
		 "shrine2" => {tx_start: 0, ty_start: 2, x_start: 4, y_start: 9},
		 "shrine3" => {tx_start: 0, ty_start: 2, x_start: 4, y_start: 9},
		 "shrine4" => {tx_start: 1, ty_start: 2, x_start: 5, y_start: 9},
		 "shrine5" => {tx_start: 0, ty_start: 1, x_start: 5, y_start: 9}];
	
	public static var tileAnimationFrames:Map<Int, Array<Int>> =
		[484 => [484, 485, 486], 508 => [508, 509, 510], 532 => [532, 533, 534]];
	
	public static var specialTileTypes:Map<Int, String> =
		[ 67 => "crate", 91 => "playerCrate", 296 => "cannon",
		  336 => "cat", 337 => "cat", 338 => "cat", 360 => "cat", 361 => "cat", 362 => "cat" ];
	
	public static var shrinesWithPermanentGates:Array<String> = ["shrine5"];
	
	public static var START_LOCATION:Object = {tx: 2, ty: 3, x: 4, y: 5};
}