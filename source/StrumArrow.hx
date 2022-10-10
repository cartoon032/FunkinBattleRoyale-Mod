package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
// import flixel.math.FlxMath;
import flixel.util.FlxColor;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import flash.display.BitmapData;
import sys.io.File;

class StrumArrow extends FlxSprite{
	public static var defColor:FlxColor = 0xFFFFFFFF;
	var noteColor:FlxColor = 0xFFFFFFFF; 
	public var id:Int = 0; 
	static var path_:String = "mods/noteassets";
	override public function new(nid:Int = 0,?x:Float = 0,?y:Float = 0){
		super(x,y);
		id = nid;
	}
	public function changeSprite(?name:String = "default"){
		try{
		var curAnim = animation.curAnim.name;
		trace('Changing skin!');
		if (name == 'default' || (!FileSystem.exists('${path_}/${name}.png') || !FileSystem.exists('${path_}/${name}.xml'))){
			frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/T_Mod_NOTE_assets.png')),File.getContent("assets/shared/images/T_Mod_NOTE_assets.xml"));
		}else{
			frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('${path_}/${name}.png')),File.getContent('${path_}/${name}.xml'));
		}
		animation.addByPrefix('static', 'arrow' + arrowIDs[id]);
		animation.addByPrefix('pressed', Note.noteNames[id] + ' press', 24, false);
		animation.addByPrefix('confirm', Note.noteNames[id] + ' confirm', 24, false);
		animation.play(curAnim);
		centerOffsets();
		}catch(e){
			MainMenuState.handleError('Error while changing sprite for arrow:\n ${e.message}');
		}
	}

	static var arrowIDs:Array<String> = ['LEFT','DOWN','UP',"RIGHT"];
	public function init(){
		TitleState.loadNoteAssets();
		if (frames == null) frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);

		antialiasing = true;
		switch (PlayState.mania)
		{
			case 0:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT'];
			case 1:
				arrowIDs = ['LEFT','DOWN','RIGHT','LEFT','UP','RIGHT'];
			case 2:
				arrowIDs = ['LEFT','DOWN','RIGHT','SPACE','LEFT','UP','RIGHT'];
			case 3:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','SPACE','LEFT','DOWN','UP','RIGHT'];
			case 4:
				arrowIDs = ['LEFT','DOWN','SPACE','UP','RIGHT'];
			case 5:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 6:
				arrowIDs = ['SPACE'];
			case 7:
				arrowIDs = ['LEFT','RIGHT'];
			case 8:
				arrowIDs = ['LEFT','SPACE','RIGHT'];
			case 9:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','EDOWN','EUP','LEFT','DOWN','UP','RIGHT'];
			case 10:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','EDOWN','SPACE','EUP','LEFT','DOWN','UP','RIGHT'];
			case 11:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
			case 12:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','SPACE','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
		}
		setGraphicSize(Std.int(width * Note.noteScale));
		animation.addByPrefix('static', 'arrow' + arrowIDs[id]);
		animation.addByPrefix('pressed', Note.noteNames[id] + ' press', 24, false);
		animation.addByPrefix('confirm', Note.noteNames[id] + ' confirm', 24, false);
	}
	public function playStatic(){
		// color = defColor;
		animation.play("static");
		centerOffsets();
	}
	public function press(){
		// if (color != noteColor) color = noteColor;
		animation.play("pressed");
		centerOffsets();
	}
	public function confirm(){
		// if (color != noteColor) color = noteColor;
		animation.play("confirm");

		centerOffsets();
		switch(PlayState.mania)
		{
			case 0: 
				offset.x -= 13;
				offset.y -= 13;
			case 1: 
				offset.x -= 16;
				offset.y -= 16;
			case 2: 
				offset.x -= 15;
				offset.y -= 15;
			case 3: 
				offset.x -= 22;
				offset.y -= 22;
			case 4: 
				offset.x -= 18;
				offset.y -= 18;
			case 5: 
				offset.x -= 20;
				offset.y -= 20;
			case 6: 
				offset.x -= 13;
				offset.y -= 13;
			case 7: 
				offset.x -= 13;
				offset.y -= 13;
			case 8:
				offset.x -= 13;
				offset.y -= 13;
			case 9:
				offset.x -= 22;
				offset.y -= 22;
			case 10:
				offset.x -= 22;
				offset.y -= 22;
			case 11:
				offset.x -= 22;
				offset.y -= 22;
			case 12:
				offset.x -= 22;
				offset.y -= 22;
		}
	}

}