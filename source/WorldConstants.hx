package;

import openfl.utils.Object;

class WorldConstants {
	public static var shrineLocationMap:Array<Object> =
		[ {tx: 4, ty: 3, x: 6, y: 6, id: "shrine1"},
		  {tx: 2, ty: 4, x: 6, y: 3, id: "shrine2"},
		  {tx: 3, ty: 1, x: 4, y: 3, id: "shrine3"},
		  {tx: 2, ty: 5, x: 6, y: 4, id: "shrine4"},
		  {tx: 1, ty: 2, x: 4, y: 5, id: "shrine5"},
		  {tx: 5, ty: 0, x: 7, y: 2, id: "shrine6"},
		  {tx: 1, ty: 0, x: 2, y: 5, id: "shrine7"},
		  {tx: 5, ty: 5, x: 4, y: 5, id: "shrine8"}
		];
		  
	public static var shrineInfo:Map<String, Object> =
		["shrine1" => {tx_start: 0, ty_start: 3, x_start: 4, y_start: 9},
		 "shrine2" => {tx_start: 0, ty_start: 2, x_start: 4, y_start: 9},
		 "shrine3" => {tx_start: 0, ty_start: 2, x_start: 4, y_start: 9},
		 "shrine4" => {tx_start: 1, ty_start: 2, x_start: 5, y_start: 9},
		 "shrine5" => {tx_start: 0, ty_start: 1, x_start: 5, y_start: 9},
		 "shrine6" => {tx_start: 1, ty_start: 2, x_start: 4, y_start: 9},
		 "shrine7" => {tx_start: 0, ty_start: 1, x_start: 3, y_start: 9},
		 "shrine8" => {tx_start: 0, ty_start: 1, x_start: 5, y_start: 9}];
	
	public static var tileAnimationFrames:Map<Int, Array<Int>> =
		[
			// waterfall
			484 => [484, 485, 486],
			508 => [508, 509, 510],
			532 => [532, 533, 534],

			// grass
			544 => [544, 545],
			568 => [568, 569],
			570 => [570, 571],
			592 => [592, 593],
			594 => [594, 595],

			// water?
			202 => [202, 203],  // bubble
			226 => [226, 227],  // vertical
			250 => [250, 251],  // horizontal

			// npcs
			336 => [336, 360],  // glasses
			337 => [337, 361],  // scary red
			338 => [338, 362],  // small pink
			363 => [339, 363],  // zombie
			340 => [340, 364],  // ghost
			341 => [341, 365],  // farmer
			342 => [342, 366],  // elder
			343 => [343, 367],  // small purple
			344 => [344, 368],  // glasses purple
			345 => [345, 369],  // glasses orange
			346 => [346, 370],  // elder turned banker 
			347 => [347, 371],  // small tan
			348 => [348, 372],  // scary purple
			];
	
	public static var tileAnimationFPS:Map<String, Int> =
		[ "grass" => 1, "cat" => 3 ];

	public static var specialTileTypes:Map<Int, String> =
		[ 67 => "crate", 91 => "playerCrate", 296 => "cannon",
		  316 => "bridge", 317 => "bridge",
		  544 => "grass", 568 => "grass", 570 => "grass", 592 => "grass", 594 => "grass",
		  336 => "cat", 337 => "cat", 338 => "cat", 360 => "cat", 361 => "cat", 362 => "cat",
		  339 => "cat", 340 => "cat", 341 => "cat", 342 => "cat", 343 => "cat", 344 => "cat",
		  345 => "cat", 346 => "cat", 347 => "cat", 348 => "cat", 363 => "cat", 364 => "cat",
		  624 => "catStatue", 625 => "catStatue",
		  626 => "catStatue", 627 => "catStatue", 628 => "catStatue", 672 => "catStatue",
		  673 => "catStatue", 674 => "catStatue", 675 => "catStatue", 676 => "catStatue"];
	
	public static var shrinesWithPermanentGates:Array<String> = ["shrine5"];
	
	public static var START_LOCATION:Object = {tx: 3, ty: 3, x: 5, y: 4};
}