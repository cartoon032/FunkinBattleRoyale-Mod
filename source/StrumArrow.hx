package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
// import flixel.math.FlxMath;
import flixel.util.FlxColor;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flash.display.BitmapData;
import sys.io.File;

class StrumArrow extends FlxSprite{
	public static var defColor:FlxColor = 0xFFFFFFFF;
	var noteColor:FlxColor = 0xFFFFFFFF; 
	var KeyReminder:FlxText = new FlxText(0, 0, Note.swagWidth[PlayState.playermania], "A", 20);
	var keyTween1:FlxTween;
	var keyTween2:FlxTween;
	var keyTween3:FlxTween;
	var ShowKey:Bool;
	public static var confirmArrowOffset:Int = 0;
	public var id:Int = 0; 
	static var path_:String = "mods/noteassets";
	override public function new(nid:Int = 0,?x:Float = 0,?y:Float = 0){
		super(x,y);
		id = nid;
	}
	public function changeSprite(?name:String = "default"){
		try{
		var curAnim = animation.curAnim.name;
		if (name == 'default' || (!FileSystem.exists('${path_}/${name}.png') || !FileSystem.exists('${path_}/${name}.xml'))){
			frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/T_Mod_NOTE_assets.png')),File.getContent("assets/shared/images/T_Mod_NOTE_assets.xml"));
		}else{
			frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('${path_}/${name}.png')),File.getContent('${path_}/${name}.xml'));
		}
		// for 4k
		animation.addByPrefix('static', 'arrow' + arrowIDsBackup[id] + '0');
		animation.addByPrefix('pressed', arrowIDsBackup[id].toLowerCase() + ' press', 24, false);
		animation.addByPrefix('confirm', arrowIDsBackup[id].toLowerCase() + ' confirm', 24, false);

		animation.addByPrefix('static', 'arrow' + arrowIDs[id] + '0');
		animation.addByPrefix('static', 'arrow' + Note.noteNames[id].toUpperCase() + '0'); // for when second static note exist
		animation.addByPrefix('pressed', Note.noteNames[id] + ' press', 24, false);
		animation.addByPrefix('confirm', Note.noteNames[id] + ' confirm', 24, false);
		animation.play(curAnim);
		centerOffsets();
		}catch(e){
			MainMenuState.handleError('Error while changing sprite for arrow:\n ${e.message}');
		}
	}

	public function RefreshSprite(mania:Int){
		if(NoteAssets.image[mania] == null || NoteAssets.xml[mania] == null)
			frames = FlxAtlasFrames.fromSparrow(NoteAssets.image[0],NoteAssets.xml[0]);
		else
			frames = FlxAtlasFrames.fromSparrow(NoteAssets.image[mania],NoteAssets.xml[mania]);
		updateHitbox();
		setArrowName(mania);
		// for 4k
		animation.addByPrefix('static', 'arrow' + arrowIDsBackup[id] + '0');
		animation.addByPrefix('pressed', arrowIDsBackup[id].toLowerCase() + ' press', 24, false);
		animation.addByPrefix('confirm', arrowIDsBackup[id].toLowerCase() + ' confirm', 24, false);

		animation.addByPrefix('static', 'arrow' + arrowIDs[id] + '0');
		animation.addByPrefix('static', 'arrow' + Note.noteNames[id].toUpperCase() + '0'); // for when second static note exist
		animation.addByPrefix('pressed', Note.noteNames[id] + ' press', 24, false);
		animation.addByPrefix('confirm', Note.noteNames[id] + ' confirm', 24, false);
		playStatic();
	}

	public static var arrowIDs:Array<String> = ['LEFT','DOWN','UP',"RIGHT"];
	public static var arrowIDsBackup:Array<String> = ['LEFT','DOWN','UP',"RIGHT"];
	public function init(?showkey:Int = 0){
		TitleState.loadNoteAssets();
		antialiasing = true;
		var _mania = (showkey == 1 ? PlayState.playermania : PlayState.mania);
		var _NoteNames = (showkey == 1 ? Note.playernoteNames : Note.noteNames);
		if(NoteAssets.image[_mania] == null || NoteAssets.xml[_mania] == null)
			frames = FlxAtlasFrames.fromSparrow(NoteAssets.image[0],NoteAssets.xml[0]);
		else
			frames = FlxAtlasFrames.fromSparrow(NoteAssets.image[_mania],NoteAssets.xml[_mania]);
		setArrowName(_mania);
		// setGraphicSize(Std.int(width * Note.noteScale[_mania]));
		scale.x = scale.y = Note.noteScale[_mania];
		// for 4k
		animation.addByPrefix('static', 'arrow' + arrowIDsBackup[id] + '0');
		animation.addByPrefix('pressed', arrowIDsBackup[id].toLowerCase() + ' press', 24, false);
		animation.addByPrefix('confirm', arrowIDsBackup[id].toLowerCase() + ' confirm', 24, false);

		animation.addByPrefix('static', 'arrow' + arrowIDs[id] + '0');
		animation.addByPrefix('static', 'arrow' + _NoteNames[id].toUpperCase() + '0'); // for when second static note exist
		animation.addByPrefix('pressed', _NoteNames[id] + ' press', 24, false);
		animation.addByPrefix('confirm', _NoteNames[id] + ' confirm', 24, false);

		if(showkey == 1){
			if(PlayState.instance.playerNoteCamera != null)KeyReminder.cameras = [PlayState.instance.playerNoteCamera];
			KeyReminder.alpha = 0;

			ShowKey = true;
			ShowKeyReminder();
		}
	}
	public function playStatic(){
		animation.play("static");
		centerOffsets();
	}
	public function press(){
		animation.play("pressed");
		centerOffsets();
	}
	public function confirm(){
		animation.play("confirm");

		centerOffsets();
		offset.x -= confirmArrowOffset;
		offset.y -= confirmArrowOffset;
	}
	override function draw(){
		super.draw();
		if(KeyReminder != null && ShowKey){
			KeyReminder.x = this.x;
			KeyReminder.draw();
		}
	}
	public function ShowKeyReminder(){
		KeyReminder.angle = -45;
		KeyReminder.y = this.y;
		KeyReminder.text = GetKey(id);
		KeyReminder.setFormat(CoolUtil.font, Std.int(30 * (1 - (KeyReminder.text.length * 0.05)) ), FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if(keyTween1 != null) keyTween1.cancel();
		if(keyTween2 != null) keyTween2.cancel();
		if(keyTween3 != null) keyTween3.cancel();
		keyTween1 = FlxTween.tween(KeyReminder, {alpha: 1,angle:0}, 1, {ease: FlxEase.circOut, startDelay: 0.25 + (0.05 * id)});
		keyTween2 = FlxTween.tween(KeyReminder, {y: KeyReminder.y + 40}, 4, {ease: FlxEase.circOut, startDelay: 0.25 + (0.05 * id),onComplete:function(_){
			if(PlayState.instance.downscroll)keyTween3 = FlxTween.tween(KeyReminder, {alpha: 0,y:KeyReminder.y + 200}, 0.5);
			else keyTween3 = FlxTween.tween(KeyReminder, {alpha: 0,y:KeyReminder.y - 200}, 0.5);
		}});
	}
	public function setArrowName(mania:Int) {
		switch (mania)
		{
			case 0:
				confirmArrowOffset = 13;
				arrowIDs = ['LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT'];
			case 1:
				confirmArrowOffset = 16;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','UP','RIGHT','LEFT','DOWN','RIGHT'];
					arrowIDsBackup = ['LEFT','UP','RIGHT','LEFT','DOWN','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','RIGHT','LEFT','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','RIGHT','LEFT','UP','RIGHT'];
				}
			case 2:
				confirmArrowOffset = 15;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','UP','RIGHT','SPACE','LEFT','DOWN','RIGHT'];
					arrowIDsBackup = ['LEFT','UP','RIGHT','UP','LEFT','DOWN','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','RIGHT','SPACE','LEFT','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','RIGHT','UP','LEFT','UP','RIGHT'];
				}
			case 3:
				confirmArrowOffset = 22;
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','SPACE','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','UP','LEFT','DOWN','UP','RIGHT'];
			case 4:
				confirmArrowOffset = 18;
				arrowIDs = ['LEFT','DOWN','SPACE','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','UP','RIGHT'];
			case 5:
				confirmArrowOffset = 20;
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 6:
				confirmArrowOffset = 13;
				arrowIDs = ['SPACE'];
				arrowIDsBackup = ['UP'];
			case 7:
				confirmArrowOffset = 13;
				arrowIDs = ['LEFT','RIGHT'];
				arrowIDsBackup = ['LEFT','RIGHT'];
			case 8:
				confirmArrowOffset = 13;
				arrowIDs = ['LEFT','SPACE','RIGHT'];
				arrowIDsBackup = ['LEFT','UP','RIGHT'];
			case 9:
				confirmArrowOffset = 22;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','EUP','EDOWN','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','UP','DOWN','LEFT','DOWN','UP','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','EDOWN','EUP','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','DOWN','UP','LEFT','DOWN','UP','RIGHT'];
				}
			case 10:
				confirmArrowOffset = 22;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','EUP','ESPACE','EDOWN','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','UP','UP','DOWN','LEFT','DOWN','UP','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','EDOWN','ESPACE','EUP','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','DOWN','UP','UP','LEFT','DOWN','UP','RIGHT'];
				}
			case 11:
				confirmArrowOffset = 22;
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 12:
				confirmArrowOffset = 26;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','ERIGHT','ESPACE','ELEFT','ERIGHT','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','RIGHT','UP','LEFT','RIGHT','LEFT','DOWN','UP','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','ESPACE','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
				}
			case 13:
				confirmArrowOffset = 30;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','ERIGHT','SPACE','ESPACE','ELEFT','ERIGHT','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','RIGHT','UP','UP','LEFT','RIGHT','LEFT','DOWN','UP','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','ERIGHT','ELEFT','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','RIGHT','LEFT','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
				}
			case 14:
				confirmArrowOffset = 30;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','ERIGHT','EUP','ESPACE','EUP','ELEFT','ERIGHT','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','RIGHT','UP','UP','UP','LEFT','RIGHT','LEFT','DOWN','UP','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','ERIGHT','ESPACE','ELEFT','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','RIGHT','UP','LEFT','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
				}
			case 15:
				confirmArrowOffset = 30;
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 16:
				confirmArrowOffset = 30;
				if(FlxG.save.data.AltMK){
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ESPACE','ELEFT','SPACE','EDOWN','ESPACE','EUP','SPACE','ERIGHT','ESPACE','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','UP','LEFT','UP','DOWN','UP','UP','UP','RIGHT','UP','LEFT','DOWN','UP','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','ESPACE','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','UP','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
				}
			case 17:
				confirmArrowOffset = 30;
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','SPACE','ESPACE','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','UP','UP','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 18:
				confirmArrowOffset = 30;
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','ELEFT','EDOWN','ESPACE','EUP','ERIGHT','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
		}
	}
	function GetKey(Number:Int){
		var keylist:Array<String> = ["A","S","W","D"];
		var keylistAlt:Array<String> = [];
		switch(PlayState.playermania)
		{
			case 0:
				keylist = [FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
				keylistAlt = [FlxG.save.data.AltleftBind, FlxG.save.data.AltdownBind, FlxG.save.data.AltupBind, FlxG.save.data.AltrightBind];
			case 1:
				keylist = [FlxG.save.data.L1Bind, FlxG.save.data.D1Bind, FlxG.save.data.R1Bind, FlxG.save.data.L2Bind, FlxG.save.data.U1Bind, FlxG.save.data.R2Bind];
			case 2:
				keylist = [FlxG.save.data.L1Bind, FlxG.save.data.D1Bind, FlxG.save.data.R1Bind, FlxG.save.data.N4Bind, FlxG.save.data.L2Bind, FlxG.save.data.U1Bind, FlxG.save.data.R2Bind];
			case 3:
				keylist = [FlxG.save.data.N0Bind, FlxG.save.data.N1Bind, FlxG.save.data.N2Bind, FlxG.save.data.N3Bind, FlxG.save.data.N4Bind, FlxG.save.data.N5Bind, FlxG.save.data.N6Bind, FlxG.save.data.N7Bind, FlxG.save.data.N8Bind];
			case 4:
				keylist = [FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.N4Bind ,FlxG.save.data.upBind, FlxG.save.data.rightBind];
				keylistAlt = [FlxG.save.data.AltleftBind, FlxG.save.data.AltdownBind, "",FlxG.save.data.AltupBind, FlxG.save.data.AltrightBind];
			case 5:
				keylist = [FlxG.save.data.N0Bind, FlxG.save.data.N1Bind, FlxG.save.data.N2Bind, FlxG.save.data.N3Bind, FlxG.save.data.N5Bind, FlxG.save.data.N6Bind, FlxG.save.data.N7Bind, FlxG.save.data.N8Bind];
			case 6:
				keylist = ["AnyKey Go Ham"];
			case 7:
				keylist = [FlxG.save.data.leftBind, FlxG.save.data.rightBind];
			case 8:
				keylist = [FlxG.save.data.leftBind, FlxG.save.data.N4Bind, FlxG.save.data.rightBind];
			default:
				keylist = FlxG.save.data.keys[PlayState.playermania - 9];
		}
		return (keylist[Number] != null ? keylist[Number] : "WTF!?") + (keylistAlt[Number] != null ? "\n" + keylistAlt[Number] : "");
	}
}