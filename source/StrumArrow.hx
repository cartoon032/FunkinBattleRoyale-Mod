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
	var KeyReminder:FlxText = new FlxText(0, 0, Note.swagWidth[PlayState.mania], "A", 20);
	var keyTween:FlxTween;
	var ShowKey:Bool;
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

	public function RefreshSprite(){
		var curAnim = animation.curAnim.name;
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
	}

	public static var arrowIDs:Array<String> = ['LEFT','DOWN','UP',"RIGHT"];
	public static var arrowIDsBackup:Array<String> = ['LEFT','DOWN','UP',"RIGHT"];
	public function init(?showkey:Int = 0){
		TitleState.loadNoteAssets();
		if (frames == null) frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);

		antialiasing = true;
		switch (PlayState.mania)
		{
			case 0:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT'];
			case 1:
				if(FlxG.save.data.swapUpDown){
					arrowIDs = ['LEFT','UP','RIGHT','LEFT','DOWN','RIGHT'];
					arrowIDsBackup = ['LEFT','UP','RIGHT','LEFT','DOWN','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','RIGHT','LEFT','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','RIGHT','LEFT','UP','RIGHT'];
				}
			case 2:
				if(FlxG.save.data.swapUpDown){
					arrowIDs = ['LEFT','UP','RIGHT','SPACE','LEFT','DOWN','RIGHT'];
					arrowIDsBackup = ['LEFT','UP','RIGHT','UP','LEFT','DOWN','RIGHT'];
				}
				else{
					arrowIDs = ['LEFT','DOWN','RIGHT','SPACE','LEFT','UP','RIGHT'];
					arrowIDsBackup = ['LEFT','DOWN','RIGHT','UP','LEFT','UP','RIGHT'];
				}
			case 3:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','SPACE','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','UP','LEFT','DOWN','UP','RIGHT'];
			case 4:
				arrowIDs = ['LEFT','DOWN','SPACE','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','UP','RIGHT'];
			case 5:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 6:
				arrowIDs = ['SPACE'];
				arrowIDsBackup = ['UP'];
			case 7:
				arrowIDs = ['LEFT','RIGHT'];
				arrowIDsBackup = ['LEFT','RIGHT'];
			case 8:
				arrowIDs = ['LEFT','SPACE','RIGHT'];
				arrowIDsBackup = ['LEFT','UP','RIGHT'];
			case 9:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','EDOWN','EUP','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','DOWN','UP','LEFT','DOWN','UP','RIGHT'];
			case 10:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','EDOWN','ESPACE','EUP','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','DOWN','UP','UP','LEFT','DOWN','UP','RIGHT'];
			case 11:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 12:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','ESPACE','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 13:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','ERIGHT','ELEFT','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','RIGHT','LEFT','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 14:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','ERIGHT','ESPACE','ELEFT','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','RIGHT','UP','LEFT','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 15:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 16:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','ESPACE','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','UP','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 17:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','SPACE','ESPACE','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','UP','UP','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
			case 18:
				arrowIDs = ['LEFT','DOWN','UP','RIGHT','ELEFT','EDOWN','EUP','ERIGHT','ELEFT','EDOWN','ESPACE','EUP','ERIGHT','ELEFT','EDOWN','EUP','ERIGHT','LEFT','DOWN','UP','RIGHT'];
				arrowIDsBackup = ['LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','UP','RIGHT','LEFT','DOWN','UP','RIGHT','LEFT','DOWN','UP','RIGHT'];
		}
		setGraphicSize(Std.int(width * Note.noteScale[PlayState.mania]));
		// for 4k
		animation.addByPrefix('static', 'arrow' + arrowIDsBackup[id] + '0');
		animation.addByPrefix('pressed', arrowIDsBackup[id].toLowerCase() + ' press', 24, false);
		animation.addByPrefix('confirm', arrowIDsBackup[id].toLowerCase() + ' confirm', 24, false);

		animation.addByPrefix('static', 'arrow' + arrowIDs[id] + '0');
		animation.addByPrefix('static', 'arrow' + Note.noteNames[id].toUpperCase() + '0'); // for when second static note exist
		animation.addByPrefix('pressed', Note.noteNames[id] + ' press', 24, false);
		animation.addByPrefix('confirm', Note.noteNames[id] + ' confirm', 24, false);

		KeyReminder.setFormat(CoolUtil.font, 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		KeyReminder.borderSize = 2;
		KeyReminder.borderQuality = 2;
		KeyReminder.scrollFactor.set();
		if(PlayState.instance.playerNoteCamera != null)KeyReminder.cameras = [PlayState.instance.playerNoteCamera];
		if(showkey == 1){
			ShowKey = true;
			ShowKeyReminder();
		}
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
	override function draw(){
		super.draw();
		if(KeyReminder != null && ShowKey){
			KeyReminder.x = this.x;
			KeyReminder.draw();
		}
	}
	public function ShowKeyReminder(){
		KeyReminder.alpha = 1;
		KeyReminder.y = this.y;
		KeyReminder.text = GetKey(id);
		if(keyTween != null) keyTween.cancel();
		if(PlayState.instance.downscroll)keyTween = FlxTween.tween(KeyReminder, {alpha: 0,y:this.y + 200}, 1, {startDelay: 4 + (0.05 * id),ease: FlxEase.quadInOut});
		else keyTween = FlxTween.tween(KeyReminder, {alpha: 0,y:this.y - 200}, 1, {startDelay: 4 + (0.05 * id),ease: FlxEase.quadInOut});
	}
	function GetKey(Number:Int){
		var keylist:Array<String> = ["A","S","W","D"];
		var keylistAlt:Array<String> = [];
		switch(PlayState.mania)
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
			case 9:
				keylist = [FlxG.save.data.EX0Bind, FlxG.save.data.EX1Bind, FlxG.save.data.EX2Bind, FlxG.save.data.EX3Bind, FlxG.save.data.EX5Bind, FlxG.save.data.EX6Bind, FlxG.save.data.EX8Bind, FlxG.save.data.EX9Bind, FlxG.save.data.EX10Bind, FlxG.save.data.EX11Bind];
			case 10:
				keylist = [FlxG.save.data.EX0Bind, FlxG.save.data.EX1Bind, FlxG.save.data.EX2Bind, FlxG.save.data.EX3Bind, FlxG.save.data.EX5Bind, FlxG.save.data.N4Bind, FlxG.save.data.EX6Bind, FlxG.save.data.EX8Bind, FlxG.save.data.EX9Bind, FlxG.save.data.EX10Bind, FlxG.save.data.EX11Bind];
			case 11:
				keylist = [FlxG.save.data.EX0Bind, FlxG.save.data.EX1Bind, FlxG.save.data.EX2Bind, FlxG.save.data.EX3Bind, FlxG.save.data.EX4Bind, FlxG.save.data.EX5Bind, FlxG.save.data.EX6Bind, FlxG.save.data.EX7Bind, FlxG.save.data.EX8Bind, FlxG.save.data.EX9Bind, FlxG.save.data.EX10Bind, FlxG.save.data.EX11Bind];
			case 12:
				keylist = [FlxG.save.data.EX0Bind, FlxG.save.data.EX1Bind, FlxG.save.data.EX2Bind, FlxG.save.data.EX3Bind, FlxG.save.data.EX4Bind, FlxG.save.data.EX5Bind, FlxG.save.data.N4Bind, FlxG.save.data.EX6Bind, FlxG.save.data.EX7Bind, FlxG.save.data.EX8Bind, FlxG.save.data.EX9Bind, FlxG.save.data.EX10Bind, FlxG.save.data.EX11Bind];
			case 13:
				keylist = ["Q","W","E","R","S","D","F","J","K","L","U","I","O","P"];
			case 14:
				keylist = ['Q','W','E','R','S','D','F','SPACE','J','K','L','U','I','O','P'];
			case 15:
				keylist = ['Q','W','E','R','A','S','D','F','J','K','L','SEMICOLON','U','I','O','P'];
			case 16:
				keylist = ['Q','W','E','R','A','S','D','F','SPACE','J','K','L','SEMICOLON','U','I','O','P'];
			case 17:
				keylist = ['Q','W','E','R','A','S','D','F','V','N','J','K','L','SEMICOLON','U','I','O','P'];
			case 18:
				keylist = ['Q','W','E','R','A','S','D','F','C','V','SPACE','N','M','J','K','L','SEMICOLON','U','I','O','P'];
		}
		return (keylist[Number] != null ? keylist[Number] : "WTF!?") + (keylistAlt[Number] != null ? "\n" + keylistAlt[Number] : "");
	}
}