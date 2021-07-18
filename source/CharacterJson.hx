package;

typedef CharacterJson =
{
	var spirit_trail:Bool;
	var flip_x:Bool;
	var flip:Dynamic; // Controls if the character should be flipped when on the player's side
	var clone:String;
	var animations:Array<CharJsonAnimation>;
	var animations_offsets:Array<CharJsonAnimOffsets>;
	var sing_duration:Float;
	var scale:Float;
	var no_antialiasing:Bool;
	var dance_idle:Bool;
	var alt_anims:Bool;
	var common_stage_offset:Array<Float>;
	var cam_pos:Array<Float>;
	var char_pos:Array<Float>;
	var cam_pos1:Array<Float>;
	var char_pos1:Array<Float>;
	var cam_pos2:Array<Float>;
	var char_pos2:Array<Float>;
	var cam_pos3:Array<Float>;
	var char_pos3:Array<Float>;
	var custom_misses:Int;
	var flip_notes:Bool; // Tells the game if it should flip left and right notes on the right

}
typedef IfStatement = {
	var	variable:String;
	var	type:String;
	var	value:Dynamic;
	var check:Int; // 0 = beat, 1 = step
} 
typedef CharJsonAnimation ={
	var ifstate:IfStatement;
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var stage:String; // Set on specific stage
	var song:String; // Set on specific songname
	var char_side:Dynamic; // Set song specific side, 0 for BF, 1 for Dad, 2 for GF, 3 for disabled
	var oneshot:Bool; // Should animation overlap everything?
}
typedef CharJsonAnimOffsets ={
	var anim:String;
	var player1:Array<Float>;
	var player2:Array<Float>;
}