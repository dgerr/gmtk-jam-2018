package;

import openfl.utils.Object;

class WorldConstants {
	public static var shrineLocationMap:Array<Object> =
		[ {tx: 1, ty: 0, x: 5, y: 3, id: "shrine1"},
		  {tx: 2, ty: 0, x: 7, y: 5, id: "shrine2"}];
		  
	public static var shrineInfo:Map<String, Object> =
		["shrine1" => {tx_start: 0, ty_start: 2, x_start: 4, y_start: 9},
		 "shrine2" => {tx_start: 0, ty_start: 2, x_start: 4, y_start: 9}];
	
	public static var specialTileTypes:Map<Int, String> =
		[ 67 => "crate" ];
}