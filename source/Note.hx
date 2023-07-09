package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var noteID:Int = 0;
	public static var lastNoteID:Int = 0;
	// public var skipXAdjust:Bool = false;
	public var skipXAdjust(get,set):Bool;
	public var updateX:Bool = true;
	public function get_skipXAdjust(){return !updateX;}
	public function set_skipXAdjust(vari){return updateX = !vari;}
	public var updateY:Bool = true;
	public var updateAlpha:Bool = true;
	public var updateAngle:Bool = true;
	public var updateScrollFactor:Bool = true;
	public var updateCam:Bool = true;
	public var clipSustain:Bool = true;
	public var updateAIPress:Bool = false;
	public var lockToStrum:Bool = true;
	public var mainstuffisset:Bool = false;

	public var mustPress:Bool = false;
	public var ourNote:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var shouldntBeHit:Bool = false;
	public var isPressed:Bool = false;
	// public var playerNote:Bool = false;
	public var type:Dynamic = 0; // Used for scriptable arrows
	public var ArrayType:Array<Int> = [];
	public var isSustainNoteEnd:Bool = false;
	public var isSustainNoteStart:Bool = false;
	public var parentNoteWidth:Float = 0;

	public static var mania:Int = 0;
	public var inCharter:Bool = false;

	public static var swagWidth:Array<Float> = [160 * 0.7,120 * 0.7,110 * 0.7,95 * 0.7,130 * 0.7,100 * 0.7,200 * 0.7,180 * 0.7,170 * 0.7,70 * 0.7,70 * 0.7,70 * 0.7,70 * 0.7,40 * 0.7,40 * 0.7,40 * 0.7,40 * 0.7,40 * 0.7,40 * 0.7];
	public static var noteScale:Array<Float> = [0.7,0.6,0.58,0.5,0.65,0.55,0.7,0.7,0.7,0.35,0.35,0.35,0.35,0.2,0.18,0.18,0.18,0.18,0.18];
	public static var longnoteScale:Array<Float> = [1.5,1.75,2,2.25,1.625,2.125,1.5,1.5,1.5,2.9,2.9,2.9,2.9,2.9,4.75,4.75,4.75,4.75,4.75];
	public static var noteNames:Array<String> = ['purple','aqua','green','red','white','yellow','pink','blue','orange'];
	public var skipNote:Bool = true;
	public var childNotes:Array<Note> = [];
	public var parentNote:Note = null;
	public var parentSprite:FlxSprite = null;
	public var distanceToSprite:Float = 0; // This is inverted because i am dumb and stupid and dumb
	public var showNote = true;
	public var info:Array<Dynamic> = [];
	public var rawNote:Array<Dynamic> = [];
	
	public var rating:String = "shit";
	public var eventNote:Bool = false;
	public var aiShouldPress:Bool = true;
	var ntText:FlxText;

	public function loadFrames(){
		if (frames == null){
			try{
				if (shouldntBeHit && FlxG.save.data.useBadArrowTex) {frames = FlxAtlasFrames.fromSparrow(NoteAssets.badImage,NoteAssets.badXml);}
			}catch(e){trace("Couldn't load bad arrow sprites, recoloring arrows instead!");}
			try{
				if(frames == null && shouldntBeHit) {color = 0x220011;}
				if (frames == null) frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
			}catch(e) {
				try{
					TitleState.loadNoteAssets(true);
					if(shouldntBeHit) {color = 0x220011;}
					frames = FlxAtlasFrames.fromSparrow(NoteAssets.image,NoteAssets.xml);
				}catch(e){
					MainMenuState.handleError("Unable to load note assets, please restart your game!");
				}
			}
		}

		// The color is definitely lightblue atleast fucking ninja color bind or sth
		animation.addByPrefix('aquaScroll', 'blue0');
		animation.addByPrefix('aquaholdend', 'blue hold end');
		animation.addByPrefix('aquahold', 'blue hold piece');

		if(PlayState.mania != 0){// For when playing MultiKey and custom note don't exist
			animation.addByPrefix('whiteScroll', 'green0');
			animation.addByPrefix('whiteholdend', 'green hold end');
			animation.addByPrefix('whitehold', 'green hold piece');
			animation.addByPrefix('yellowScroll', 'purple0');
			animation.addByPrefix('yellowholdend', 'pruple end hold'); // Fucking default names
			animation.addByPrefix('yellowholdend', 'purple hold end');
			animation.addByPrefix('yellowhold', 'purple hold piece');
			animation.addByPrefix('pinkScroll', 'blue0');	// default down color :ew:
			animation.addByPrefix('pinkholdend', 'blue hold end');
			animation.addByPrefix('pinkhold', 'blue hold piece');
			animation.addByPrefix('pinkScroll', 'aqua0');
			animation.addByPrefix('pinkholdend', 'aqua hold end');
			animation.addByPrefix('pinkhold', 'aqua hold piece');
			animation.addByPrefix('blueScroll', 'green0');
			animation.addByPrefix('blueholdend', 'green hold end');
			animation.addByPrefix('bluehold', 'green hold piece');
			animation.addByPrefix('orangeScroll', 'red0');
			animation.addByPrefix('orangeholdend', 'red hold end');
			animation.addByPrefix('orangehold', 'red hold piece');
		}

		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('aquaScroll', 'aqua0');
		animation.addByPrefix('purpleScroll', 'purple0');
		animation.addByPrefix('whiteScroll', 'white0');
		animation.addByPrefix('yellowScroll', 'yellow0');
		animation.addByPrefix('pinkScroll', 'pink0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('orangeScroll', 'orange0');
		animation.addByPrefix('limeScroll', 'lime0');
		animation.addByPrefix('cyanScroll', 'cyan0');
		animation.addByPrefix('magentaScroll', 'magenta0');
		animation.addByPrefix('tangoScroll', 'tango0');
		animation.addByPrefix('wintergreenScroll', 'wintergreen0');
		animation.addByPrefix('canaryScroll', 'canary0');
		animation.addByPrefix('scarletScroll', 'scarlet0');
		animation.addByPrefix('violetScroll', 'violet0');
		animation.addByPrefix('erinScroll', 'erin0');

		animation.addByPrefix('purpleholdend', 'pruple end hold'); // Fucking default names
		animation.addByPrefix('purpleholdend', 'purple end hold');
		animation.addByPrefix('aquaholdend', 'aqua hold end');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('whiteholdend', 'white hold end');
		animation.addByPrefix('yellowholdend', 'yellow hold end');
		animation.addByPrefix('pinkholdend', 'pink hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');
		animation.addByPrefix('orangeholdend', 'orange hold end');
		animation.addByPrefix('limeholdend', 'lime hold end');
		animation.addByPrefix('cyanholdend', 'cyan hold end');
		animation.addByPrefix('magentaholdend', 'magenta hold end');
		animation.addByPrefix('tangoholdend', 'tango hold end');
		animation.addByPrefix('wintergreenholdend', 'wintergreen hold end');
		animation.addByPrefix('canaryholdend', 'canary hold end');
		animation.addByPrefix('scarletholdend', 'scarlet hold end');
		animation.addByPrefix('violetholdend', 'violet hold end');
		animation.addByPrefix('erinholdend', 'erin hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('aquahold', 'aqua hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('whitehold', 'white hold piece');
		animation.addByPrefix('yellowhold', 'yellow hold piece');
		animation.addByPrefix('pinkhold', 'pink hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');
		animation.addByPrefix('orangehold', 'orange hold piece');
		animation.addByPrefix('limehold', 'lime hold piece');
		animation.addByPrefix('cyanhold', 'cyan hold piece');
		animation.addByPrefix('magentahold', 'magenta hold piece');
		animation.addByPrefix('tangohold', 'tango hold piece');
		animation.addByPrefix('wintergreenhold', 'wintergreen hold piece');
		animation.addByPrefix('canaryhold', 'canary hold piece');
		animation.addByPrefix('scarlethold', 'scarlet hold piece');
		animation.addByPrefix('violethold', 'violet hold piece');
		animation.addByPrefix('erinhold', 'erin hold piece');

	}
	dynamic public function hit(?charID:Int = 0,note:Note,?useAlt:Bool = false,?ArrayID:Int){
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums
		var anim = if(useAlt) noteAnimsAlt else noteAnims;
		if(!shouldntBeHit)PlayState.charAnim(charID,anim[noteData],true); // Play animation
	}
	dynamic public function susHit(?charID:Int = 0,note:Note){ // Played every update instead of every time the strumnote is hit
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums
	}

	dynamic public function miss(?charID:Int = 0,?note:Null<Note> = null,?useAlt:Bool = false,?ArrayID:Int){
		var anim = if(useAlt) noteAnimsAlt else noteAnims;
		PlayState.charAnim(charID,anim[noteData] + "miss",true);// Play animation
	}
	// Array of animations, to be used above
	public static var noteAnims:Array<String> = ['singLEFT','singDOWN','singUP','singRIGHT']; 
	public static var noteAnimsAlt:Array<String> = noteAnims; 
	public var killNote = false;

	inline function callInterp(func:String,?args:Array<Dynamic>){
		if(!inCharter && PlayState.instance != null) PlayState.instance.callInterp(func,args);
	} 

	static var psychChars:Array<Int> = [1,0,2]; // Psych uses different character ID's than SE

	public function new(strumTime:Float, _noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false,?_type:Dynamic = 0,?_rawNote:Array<Dynamic> = null,?playerNote:Bool = false)
		{try{
		if(!inCharter)
		{
			switch(PlayState.SONG.mania)
			{
				default:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT'];
				case 1:
					if(FlxG.save.data.swapUpDown) noteAnims = ['singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT'];
					else noteAnims = ['singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT'];
				case 2:
					if(FlxG.save.data.swapUpDown) noteAnims = ['singLEFT','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singRIGHT'];
					else noteAnims = ['singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT'];
				case 3:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT'];
				case 4:
					noteAnims = ['singLEFT','singDOWN','singSPACE','singUP','singRIGHT'];
				case 5:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 6:
					noteAnims = ['singSPACE'];
				case 7:
					noteAnims = ['singLEFT','singRIGHT'];
				case 8:
					noteAnims = ['singLEFT','singSPACE','singRIGHT'];
				case 9:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
				case 10:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singSPACE','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
				case 11:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 12:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singSPACE','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 13:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 14:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 15:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 16:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 17:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singSPACE','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				case 18:
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singSPACE','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
			}
			if (PlayState.instance.ADOFAIMode)
			{
				switch(PlayState.SongOGmania)
				{
					default:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT'];
					case 1:
						if(FlxG.save.data.swapUpDown) noteAnims = ['singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT'];
						else noteAnims = ['singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT'];
					case 2:
						if(FlxG.save.data.swapUpDown) noteAnims = ['singLEFT','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singRIGHT'];
						else noteAnims = ['singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT'];
					case 3:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT'];
					case 4:
						noteAnims = ['singLEFT','singDOWN','singSPACE','singUP','singRIGHT'];
					case 5:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 6:
						noteAnims = ['singSPACE'];
					case 7:
						noteAnims = ['singLEFT','singRIGHT'];
					case 8:
						noteAnims = ['singLEFT','singSPACE','singRIGHT'];
					case 9:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
					case 10:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singSPACE','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
					case 11:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 12:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singSPACE','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 13:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 14:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 15:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 16:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 17:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singSPACE','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					case 18:
						noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singSPACE','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				}
			}
			mania = PlayState.SONG.mania;
			noteAnimsAlt = noteAnims;
		}
		var nameMania = if(inCharter) ChartingState.tempMania else mania;
		switch (nameMania)
		{
			case 0:
				noteNames = ['purple','aqua','green','red'];
			case 1: 
				if(FlxG.save.data.swapUpDown) noteNames = ['purple','green','red','yellow','aqua','orange'];
				else noteNames = ['purple','aqua','red','yellow','green','orange'];
			case 2: 
				if(FlxG.save.data.swapUpDown) noteNames = ['purple','green','red','white','yellow','aqua','orange'];
				else noteNames = ['purple','aqua','red','white','yellow','green','orange'];
			case 3: 
				noteNames = ['purple','aqua','green','red','white','yellow','pink','blue','orange'];
			case 4:
				noteNames = ['purple','aqua','white','green','red'];
			case 5:
				noteNames = ['purple','aqua','green','red','yellow','pink','blue','orange'];
			case 6:
				noteNames = ['white'];
			case 7:
				noteNames = ['purple','red'];
			case 8:
				noteNames = ['purple','white','red'];
			case 9:
				noteNames = ['purple','aqua','green','red','cyan','magenta','yellow','pink','blue','orange'];
			case 10:
				noteNames = ['purple','aqua','green','red','cyan','white','magenta','yellow','pink','blue','orange'];
			case 11:
				noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','yellow','pink','blue','orange'];
			case 12:
				noteNames = ['purple','aqua','green','red','lime','cyan','wintergreen','magenta','tango','yellow','pink','blue','orange'];
			case 13:
				noteNames = ['purple','aqua','green','red','lime','cyan','tango','canary','magenta','tango','yellow','pink','blue','orange'];
			case 14:
				noteNames = ['purple','aqua','green','red','lime','cyan','tango','wintergreen','canary','magenta','tango','yellow','pink','blue','orange'];
			case 15:
				noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 16:
				noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','wintergreen','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 17:
				noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','white','wintergreen','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 18: // 21K
				noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','lime','cyan','wintergreen','violet','erin','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
		}
		super();

		if(inCharter)
		{
			ntText = new FlxText(0, 0, 0, "", 12);
			ntText.setFormat(CoolUtil.font, 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		if (prevNote == null)
			prevNote = this;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		mustPress = ourNote = playerNote; 
		type = _type;
		this.inCharter = inCharter;
		if(_rawNote == null){
			this.rawNote = [strumTime,_noteData,0];
		}else{
			this.rawNote = _rawNote;
		}

		if(Std.isOfType(_type,String)) _type = _type.toLowerCase();

		this.noteData = _noteData % noteNames.length;
		shouldntBeHit = (isSustainNote && prevNote.shouldntBeHit || rawNote[4] == "death" || (PlayState.SONG.multichar == null && (_type == 1 || _type == "hurt note" || _type == "hurt" || _type == true)));
		
		if(inCharter){
			this.strumTime = strumTime;
			showNote = true;
		}else{
			this.strumTime = Math.round(strumTime);

			if(PlayState.ExtraChar != [] || PlayState.stateType == 3){
				updateAIPress = true;
				hit = function(?charID:Int = 0,note:Note,?useAlt:Bool = false,?ArrayID:Int){
					var ThatGuy:Dynamic = if(ArrayID != null) ArrayID else type;
					switch (charID) {
						case 0:PlayState.instance.BFStrumPlayAnim(noteData);
						case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
					}; // Strums
					var anim = if(useAlt) noteAnimsAlt else noteAnims;
					if(Std.isOfType(type,Array))
						for(i in 0...type.length){if(!shouldntBeHit)PlayState.charAnim(charID,anim[noteData],true,Std.int(ThatGuy[i]));} // Play animation
					else
						if(!shouldntBeHit)PlayState.charAnim(charID,anim[noteData],true,Std.int(ThatGuy)); // Play animation
				}
				miss = function(?charID:Int = 0,?note:Null<Note> = null,?useAlt:Bool = false,?ArrayID:Int){
					var ThatGuy:Dynamic = if(ArrayID != null) ArrayID else type;
					var anim = if(useAlt) noteAnimsAlt else noteAnims;
					if(Std.isOfType(type,Array))
						for(i in 0...type.length){PlayState.charAnim(charID,anim[noteData] + "miss",true,Std.int(ThatGuy[i]));} // Play animation
					else
						PlayState.charAnim(charID,anim[noteData] + "miss",true,Std.int(ThatGuy)); // Play animation
				}
				if(PlayState.instance.COOPMode && PlayState.SONG.multichar != null && mustPress){
					ArrayType = if(Std.isOfType(type,Array)) type else if(Std.isOfType(type,Int)) [type] else [];
					if((!ArrayType.contains(PlayState.onlinecharacterID) && PlayState.stateType != 3) || (!ArrayType.contains(onlinemod.OnlineLobbyState.CharID) && PlayState.stateType == 3)){
						updateAlpha = false;
						alpha = 0.1;
						mustPress = false;
					}
				}
			}
			else if(PlayState.instance.ADOFAIMode){
				hit = function(?charID:Int = 0,note:Note,?useAlt:Bool = false,?ArrayID:Int){
					switch (charID) {
						case 0:PlayState.instance.BFStrumPlayAnim(noteData);
						case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
					}; // Strums
					PlayState.charAnim(charID,noteAnims[Std.int(rawNote[1] % noteAnims.length)],true); // Play animation
				}
				miss = function(?charID:Int = 0,?note:Null<Note> = null,?useAlt:Bool = false,?ArrayID:Int){
					PlayState.charAnim(charID,noteAnims[Std.int(rawNote[1] % noteAnims.length)] + "miss",true); // Play animation
				}
			}

			showNote = !(!playerNote && !FlxG.save.data.oppStrumLine);
			if((rawNote[1] == -1 || rawNote[2] == "eventNote")){ // Psych event notes, These should not be shown, and should not appear on the player's side
				
				if(rawNote[2] == "eventNote")rawNote.remove(2);
				callInterp("eventNoteCheckType",[this,rawNote]);
				shouldntBeHit = false; // Make sure it doesn't become a hurt note
				showNote = false; // Don't show the note
				this.noteData = 1; // Set it to 0, to prevent issues
				mustPress = false; // The player CANNOT recieve this note
				eventNote = true; // Just an identifier
				aiShouldPress = true;
				type =rawNote[2];
				// _update = function(elapsed:Float){if (strumTime <= Conductor.songPosition) wasGoodHit = true;};
				frames = new flixel.graphics.frames.FlxFramesCollection(FlxGraphic.fromRectangle(1,1,0x01000000,false,"blank.mp4"));
				switch (Std.string(rawNote[2]).toLowerCase()) {
					case "play animation" | "playanimation"| "playanim" | "animation" | "anim": {
						try{
							// Info can be set to anything, it's being used for storing the Animation and character
							info = [rawNote[3],
								// Psych uses different character ID's than SE, more charts will be coming from Psych than SE
								switch(Std.string(rawNote[4]).toLowerCase()){
									case "dad","opponent","0":1;
									case "gf","girlfriend","2":2;
									default:0;
								}
							]; 
						}catch(e){info = [rawNote[3],0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){trace('Playing ${info[0]} for ${info[1]}');PlayState.charAnim(info[1],info[0],true);}; 
					}
					case "hey","hey!": {
						try{
							// Info can be set to anything, it's being used for storing the Animation and character
							info = [
								// Psych uses different character ID's than SE, more charts will be coming from Psych than SE
								switch(Std.string(rawNote[4]).toLowerCase()){
									case "dad","opponent","1":1;
									case "gf","girlfriend","2":2;
									default:0;
								}
							]; 
						}catch(e){info = [rawNote[3]];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){PlayState.charAnim(info[0],(if(info[0] == 2) "cheer" else "hey"),true);}; 
					}
					case "changebpm" | "bgm change": {
						try{
							info = [(if(rawNote[4] != "" && !Math.isNaN(Std.parseFloat(rawNote[4])))Std.parseFloat(rawNote[4]) else Std.parseFloat(rawNote[3]))]; 
						}catch(e){info = [120,0];}
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){Conductor.changeBPM(info[0]);}; 
						trace('BPM note processed');
					}/* 
					case "changecharacter" | "change character" | "changechar" | "change char": {
						try{
							info = [Std.string(rawNote[3]),rawNote[4]];
							var _char = PlayState.getCharFromID(info[0]);
							if(_char == null || _char.curCharacter == "lonely" || _char.lonely){ // If this character isn't enabled, no reason to allow switching for it
								killNote = true;
							}else{
								var id = PlayState.getCharID(info[0]);
								info[0]=id;
								var name = info[1];
								if(PlayState.instance.cachedChars[id][name] == null){ // Absolutely no reason to cache the character again if it's already cached
									trace('Caching ${rawNote[3]}/${id}:${name} for changeChar note');

									var psChar = PlayState.getCharFromID(id);
									var cachingChar:Character = {x:psChar.x, y:psChar.y,character:name,isPlayer:psChar.isPlayer,charType:psChar.charType};
									PlayState.instance.cachedChars[id][name] = cachingChar;
									trace('Finished caching $name');
								}
								hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){
									var _char:Character = PlayState.instance.cachedChars[info[0]][info[1]];
									if(_char == null){return;}
									// PlayState.charSet(charID,"visible",false);
									PlayState.instance.members[PlayState.instance.members.indexOf(PlayState.getCharFromID(info[0]))] = _char;
									var _oldChar:Character = PlayState.getCharFromID(id);
									Reflect.setProperty(PlayState,PlayState.getCharVariName(info[0]),_char);
									try{
										_char.playAnim(_oldChar.animName,_oldChar.animation.curAnim.curFrame / _oldChar.animation.curAnim.frames.length);
									}catch(e){}
									_char.callInterp('changeChar',[_oldChar]); // Allows the character to play an animation or something upon change
									PlayState.instance.callInterp('changeChar',[_char,_oldChar,id]);
									// PlayState.instance.add(_char);
								};

							}
							
						}catch(e){
							trace('Error trying to add char change note for ${rawNote[4]} -> ${rawNote[3]}:${e.message}');
						}
					} */
					case "camflash" | "cameraflash" | "camera flash": {
						try{
							info = [Std.parseFloat(rawNote[3]),(if( Math.isNaN(Std.parseInt(rawNote[4]))) 0xFFFFFF else Std.parseInt(rawNote[4]))]; 
						}catch(e){info = [1];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){if(FlxG.save.data.distractions && FlxG.save.data.flashingLights) FlxG.camera.flash(info[2],info[1]);}; 

					}
					case "set camzoom" | "setcamzoom" | "camzoom": {
						try{
							info = [Std.parseFloat(rawNote[3])];
							if(Math.isNaN(info[0])) info[0] = 0.7;
						}catch(e){info = [0.7];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){PlayState.instance.defaultCamZoom = info[0];}; 

					}
					case "addcamerazoom" | "add camera zoom" | "add cam zoom" | "addcamzoom": {
						try{
							info = [Std.parseFloat(rawNote[3])]; 
							if(Math.isNaN(info[0])) info[0] = 0.05;
						}catch(e){info = [0.05];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){PlayState.instance.defaultCamZoom += info[0];}; 

					}
					case "screenshake" | "screen shake" | "shake screen": {
						try{
							info = [Std.parseFloat(rawNote[3]),Std.parseFloat(rawNote[4])];
							if(Math.isNaN(info[0])) info[0] = 0; 
							if(Math.isNaN(info[1])) info[1] = 0; 
						}catch(e){info = [0.7];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){if(FlxG.save.data.distractions) FlxG.camera.shake(info[0],info[1]);}; 
						trace('BPM note processed');
					}
					case "camera follow pos" | "camfollowpos" | "cam follow" | "cam follow position": {
						try{
							info = [Std.parseFloat(rawNote[3]),Std.parseFloat(rawNote[4])];
							if(Math.isNaN(info[0])) info[0] = 0; 
							if(Math.isNaN(info[1])) info[1] = 0; 
						}catch(e){info = [0,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){
							
							PlayState.instance.moveCamera = (info[0] == 0 && info[1] == 0);
							if(info[0] != 0 )PlayState.instance.camFollow.x = info[0];
							if(info[1] != 0 )PlayState.instance.camFollow.y = info[1];
						}; 

					}
					case "changescrollspeed": {
						try{
							info = [Std.parseFloat(rawNote[4])]; 
						}catch(e){info = [2,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){PlayState.SONG.speed = info[0];}; 
						trace('BPM note processed');
					}
					case 'script','hscript':{
						info = [rawNote[4]]; 
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){PlayState.instance.parseRun(rawNote[4]);}; 
					}
					default:{ // Don't trigger hit animation
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false,?ArrayID:Int){trace('Hit an empty event note ${note.type}.');return;};
					}
				}
			}
		}

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (this.strumTime < 0 )
			this.strumTime = 0;
		if(PlayState.SONG != null && shouldntBeHit && PlayState.SONG.inverthurtnotes) mustPress=!mustPress;

		if(!inCharter && rawNote != null && PlayState.instance != null) PlayState.instance.callInterp("noteCreate",[this,rawNote]);
		if(killNote)return;
		if(!eventNote){
			lastNoteID++;
			noteID = lastNoteID;
		}
		else
		noteID = -40;

		//defaults if no noteStyle was found in chart
		loadFrames();

		setGraphicSize(Std.int(width * noteScale[mania]));
		updateHitbox();
		antialiasing = true;

		var noteName = noteNames[noteData];
		if(eventNote || noteData == -1) noteName = "white";
		x+= swagWidth[mania] * noteData;
		animation.play(noteName + "Scroll");

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS 
		flipY = (FlxG.save.data.downscroll && sustainNote);

		if (isSustainNote && prevNote != null)
			{
				if(updateAlpha)alpha = 0.6;
				// Funni downscroll flip when sussy note
				flipY = (FlxG.save.data.downscroll);
				

				animation.play(noteName + "holdend");
				isSustainNoteEnd = true;
				prevNote.isSustainNoteStart = true;
				updateHitbox();

				parentNoteWidth = prevNote.width;

				if (prevNote.isSustainNote)
				{
					parentNoteWidth = prevNote.parentNoteWidth;
					prevNote.animation.play(noteName + "hold");
					if (prevNote.parentNote != null){
						prevNote.parentNote.childNotes.push(this);
						this.parentNote = prevNote.parentNote;
					}else{
						prevNote.childNotes.push(this);
						this.parentNote = prevNote;
					}
					prevNote.isSustainNoteEnd = prevNote.isSustainNoteStart = false;
					prevNote.scale.y *= Conductor.stepCrochet / 100 * longnoteScale[mania] * (PlayState.instance.scrollspeed / PlayState.songspeed);
					prevNote.updateHitbox();

					prevNote.offset.x = prevNote.frameWidth * 0.5;
				}
			}
		if(rawNote != null && PlayState.instance != null) PlayState.instance.callInterp("noteAdd",[this,rawNote]);
		visible = false;
		offset.x = frameWidth * 0.5;
	}catch(e){MainMenuState.handleError('Caught "Note create" crash: ${e.message}');}}

	var missedNote:Bool = false;
	override function draw(){
		if(!(eventNote && !inCharter) && showNote){
			super.draw();
		}
		if(ntText != null && inCharter && FlxG.save.data.showNoteType){ntText.x = this.x;ntText.y = this.y;ntText.draw();}
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch(inCharter){
			case true:
				wasGoodHit = (strumTime <= Conductor.songPosition);
				alpha = (wasGoodHit ? 0.7 : 1);
				visible = true;
				skipNote = false;
				if(type != ntText.text)ntText.text = type;
				if(Std.isOfType(type,Array)) ntText.color = 0x00FFFF; else if(Std.isOfType(type,Int)) ntText.color = 0x00FF00; else ntText.color = 0xFFFFFF;
			case false: if (!skipNote || isOnScreen()){ // doesn't calculate anything until they're on screen
				skipNote = false;
				visible = (!eventNote && showNote);
				callInterp("noteUpdate",[this]);
				if(updateAIPress)
					aiShouldPress = updateAIPress = PlayState.ShouldAIPress[if(ourNote) 0 else 1][ArrayType[0]];
				if (mustPress && !eventNote)
				{
					// ass
					if (shouldntBeHit)
					{
						if (strumTime - Conductor.songPosition <= (45 * Conductor.timeScale) && strumTime - Conductor.songPosition >= (-45 * Conductor.timeScale))
							canBeHit = true;
						else
							canBeHit = false;
					}else{
						if ((isSustainNote && (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5)) ) ||
							strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + Conductor.safeZoneOffset  )
								canBeHit = true;

						if (!wasGoodHit && strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale){
							canBeHit = false;
							tooLate = true;
							skipNote = true;
							if (!shouldntBeHit)
							{
								PlayState.instance.health += PlayState.SONG.noteMetadata.tooLateHealth;
								PlayState.instance.vocals.volume = 0;
								PlayState.instance.noteMiss(noteData, this);
							}
							// FlxTween.tween(this,{alpha:0},0.2,{onComplete:(_)->{
							PlayState.instance.notes.remove(this, true);
							destroy();
							// }});
						}
					}
				}
				else if(eventNote){
					if (strumTime <= Conductor.songPosition){
						this.hit(1,this);
						this.destroy();
					}
				}
				else if (aiShouldPress && PlayState.dadShow /* && !PlayState.p2canplay */ && strumTime <= Conductor.songPosition)
				{
					hit(if(ourNote) 0 else 1,this);
					callInterp("noteHitDad",[PlayState.dad,this]);
					PlayState.dad.holdTimer = 0;

					if(PlayState.instance.dadhitSound && !shouldntBeHit){
						if(isSustainNoteStart) FlxG.sound.play(PlayState.holdSoundEff,FlxG.save.data.hitVol).x = (FlxG.camera.x) + (FlxG.width * ((noteData + 1) / PlayState.keyAmmo[PlayState.mania]));
						else if(!isSustainNote) FlxG.sound.play(PlayState.hitSoundEff,FlxG.save.data.hitVol).x = (FlxG.camera.x) + (FlxG.width * ((noteData + 1) / PlayState.keyAmmo[PlayState.mania]));
					}
					if (PlayState.dad.useVoices){PlayState.dad.voiceSounds[noteData].play(1);PlayState.dad.voiceSounds[noteData].time = 0;PlayState.instance.vocals.volume = 0;}else if (PlayState.SONG.needsVoices) PlayState.instance.vocals.volume = FlxG.save.data.voicesVol;

					PlayState.instance.notes.remove(this, true);
					destroy();
				}
				callInterp("noteUpdateAfter",[this]);
			}
		}
	}
}