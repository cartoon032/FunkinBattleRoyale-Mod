package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
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
	public var lockToStrum:Bool = true;
	public var mainstuffisset:Bool = false;

	public var mustPress:Bool = false;
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
	public var isSustainNoteEnd:Bool = false;
	public var parentNoteWidth:Float = 0;

	public var noteScore:Float = 1;
	public static var mania:Int = 0;
	public var inCharter:Bool = false;

	public static var swagWidth:Array<Float> = [160 * 0.7,120 * 0.7,110 * 0.7,95 * 0.7,130 * 0.7,100 * 0.7,200 * 0.7,180 * 0.7,170 * 0.7,70 * 0.7,70 * 0.7,70 * 0.7,70 * 0.7];
	public static var noteScale:Float = 0.7;
	public static var longnoteScale:Float;
	public static var PURP_NOTE:Int = 0;
	public static var BLUE_NOTE:Int = 1;
	public static var GREEN_NOTE:Int = 2;
	public static var RED_NOTE:Int = 3;
	public static var noteNames:Array<String> = ['purple','aqua','green','red','white','yellow','pink','blue','orange'];
	public var skipNote:Bool = true;
	public var childNotes:Array<Note> = [];
	public var parentNote:Note = null;
	public var showNote = true;
	public var info:Array<Dynamic> = [];
	public var rawNote:Array<Dynamic> = [];
	
	public var rating:String = "shit";
	public var eventNote:Bool = false;
	public var aiShouldPress:Bool = true;


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

		animation.addByPrefix('purpleholdend', 'pruple end hold'); // Fucking default names
		animation.addByPrefix('purpleholdend', 'purple end hold');
		animation.addByPrefix('aquaholdend', 'aqua hold end');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('whiteholdend', 'white hold end');
		animation.addByPrefix('yellowholdend', 'yellow end hold');
		animation.addByPrefix('pinkholdend', 'pink hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');
		animation.addByPrefix('orangeholdend', 'orange hold end');
		animation.addByPrefix('limeholdend', 'lime end hold');
		animation.addByPrefix('cyanholdend', 'cyan hold end');
		animation.addByPrefix('magentaholdend', 'magenta hold end');
		animation.addByPrefix('tangoholdend', 'tango hold end');

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

	}
	dynamic public function hit(?charID:Int = 0,note:Note,?useAlt:Bool = false){
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums

		if(QuickOptionsSubState.getSetting("ADOFAI Chart"))
			PlayState.charAnim(charID,noteAnimsAlt[Std.int(rawNote[1] % noteAnimsAlt.length)],true); // Play animation
		else if(useAlt)
			PlayState.charAnim(charID,noteAnimsAlt[noteData],true); // Play animation
		else
			PlayState.charAnim(charID,noteAnims[noteData],true); // Play animation
	}
	dynamic public function susHit(?charID:Int = 0,note:Note){ // Played every update instead of every time the strumnote is hit
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums
	}

	dynamic public function miss(?charID:Int = 0,?note:Null<Note> = null,?useAlt:Bool = false){
		switch (charID) {
			case 0:PlayState.instance.BFStrumPlayAnim(noteData);
			case 1:if (FlxG.save.data.cpuStrums) {PlayState.instance.DadStrumPlayAnim(noteData);}
		}; // Strums

		if (QuickOptionsSubState.getSetting("ADOFAI Chart"))
			PlayState.charAnim(charID,noteAnimsAlt[Std.int(rawNote[1] % noteAnimsAlt.length)] + "miss",true);// Play animation
		else if(useAlt)
			PlayState.charAnim(charID,noteAnimsAlt[noteData] + "miss",true);// Play animation
		else
			PlayState.charAnim(charID,noteAnims[noteData] + "miss",true);// Play animation
	}
	// Array of animations, to be used above
	public static var noteAnims:Array<String> = ['singLEFT','singDOWN','singUP','singRIGHT']; 
	public static var noteAnimsAlt:Array<String> = noteAnims; 

	inline function callInterp(func:String,?args:Array<Dynamic>){
		if(!inCharter && PlayState.instance != null) PlayState.instance.callInterp(func,args);
	} 

	static var psychChars:Array<Int> = [1,0,2]; // Psych uses different character ID's than SE

	public function new(strumTime:Float, _noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false,?_type:Dynamic = 0,?_rawNote:Array<Dynamic> = null,?playerNote:Bool = false)
		{try{
		// if(!mainstuffisset)
		// {
			switch(PlayState.SONG.mania)
			{
				default:
				{
					noteScale = 0.7;
					longnoteScale = 1.5;
					mania = 0;
					noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT'];
				}
				case 1:
				{
					noteScale = 0.6;
					longnoteScale = 1.75;
					mania = 1;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singRIGHT','singLEFT2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT'];
				}
				case 2:
				{
					noteScale = 0.58;
					longnoteScale = 2;
					mania = 2;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT'];
				}
				case 3:
				{
					noteScale = 0.5;
					longnoteScale = 2.25;
					mania = 3;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT'];
				}
				case 4:
				{
					noteScale = 0.65;
					longnoteScale = 1.625;
					mania = 4;
					noteAnims = ['singLEFT','singDOWN','singSPACE','singUP','singRIGHT'];
				}
				case 5:
				{
					noteScale = 0.55;
					longnoteScale = 2.125;
					mania = 5;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				}
				case 6:
				{
					noteScale = 0.7;
					longnoteScale = 1.5;
					mania = 6;
					noteAnims = ['singSPACE'];
				}
				case 7:
				{
					noteScale = 0.7;
					longnoteScale = 1.5;
					mania = 7;
					noteAnims = ['singLEFT','singRIGHT'];
				}
				case 8:
				{
					noteScale = 0.7;
					longnoteScale = 1.5;
					mania = 8;
					noteAnims = ['singLEFT','singSPACE','singRIGHT'];
				}
				case 9:
				{
					noteScale = 0.35;
					longnoteScale = 2.9;
					mania = 9;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN2','singUP','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
				}
				case 10:
				{
					noteScale = 0.35;
					longnoteScale = 2.9;
					mania = 10;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN2','singSPACE','singUP','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singSPACE','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
				}
				case 11:
				{
					noteScale = 0.35;
					longnoteScale = 2.9;
					mania = 11;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT2','singDOWN2','singUP','singRIGHT','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				}
				case 12:
				{
					noteScale = 0.35;
					longnoteScale = 2.9;
					mania = 12;
					if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT2','singDOWN2','singUP','singRIGHT','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
					else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				}
			}
			if (PlayState.instance.ADOFAIMode)
			{
				switch(PlayState.SongOGmania)
				{
					default: noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT'];
					case 1:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singRIGHT','singLEFT2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT'];
					}
					case 2:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT'];
					}
					case 3:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT'];
					}
					case 4:
					{
						noteAnims = ['singLEFT','singDOWN','singSPACE','singUP','singRIGHT'];
					}
					case 5:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					}
					case 6:
					{
						noteAnims = ['singSPACE'];
					}
					case 7:
					{
						noteAnims = ['singLEFT','singRIGHT'];
					}
					case 8:
					{
						noteAnims = ['singLEFT','singSPACE','singRIGHT'];
					}
					case 9:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN2','singUP','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
					}
					case 10:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN2','singSPACE','singUP','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singSPACE','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
					}
					case 11:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT2','singDOWN2','singUP','singRIGHT','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					}
					case 12:
					{
						if(FlxG.save.data.altsingformultikey) noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT2','singDOWN2','singUP','singRIGHT','singLEFT2','singDOWN2','singUP2','singRIGHT2'];
						else noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					}
				}
			}
			noteAnimsAlt = noteAnims;
		// }
		super();
		
		if (prevNote == null)
			prevNote = this;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		mustPress = playerNote; 
		type = _type;
		this.inCharter = inCharter;
		if(_rawNote == null){
			this.rawNote = [strumTime,_noteData,0];
		}else{
			this.rawNote = _rawNote;

		}

		if(Std.isOfType(_type,String)) _type = _type.toLowerCase();


		this.noteData = _noteData % noteAnims.length;
		showNote = !(!playerNote && !FlxG.save.data.oppStrumLine);
		shouldntBeHit = (isSustainNote && prevNote.shouldntBeHit || (_type == 1 || _type == "hurt note" || _type == "hurt" || _type == true));
		if(!inCharter && rawNote[1] == -1){ // Psych event notes, These should not be shown, and should not appear on the player's side
			shouldntBeHit = false; // Make sure it doesn't become a hurt note
			showNote = false; // Don't show the note
			this.noteData = 1; // Set it to 0, to prevent issues
			mustPress = false; // The player CANNOT recieve this note
			eventNote = true; // Just an identifier
			type = rawNote[2];
			// _update = function(elapsed:Float){if (strumTime <= Conductor.songPosition) wasGoodHit = true;};
			frames = new flixel.graphics.frames.FlxFramesCollection(FlxGraphic.fromRectangle(1,1,0x00000000,false,"blank.mp4"));
			if((rawNote[1] == -1 || rawNote[2] == "eventNote")){ // Psych event notes, These should not be shown, and should not appear on the player's side
				if(rawNote[2] == "eventNote")rawNote.remove(2);
				shouldntBeHit = false; // Make sure it doesn't become a hurt note
				showNote = false; // Don't show the note
				this.noteData = 1; // Set it to 0, to prevent issues
				mustPress = false; // The player CANNOT recieve this note
				eventNote = true; // Just an identifier
				aiShouldPress = true;
				type = rawNote[2];
				// _update = function(elapsed:Float){if (strumTime <= Conductor.songPosition) wasGoodHit = true;};
				frames = new flixel.graphics.frames.FlxFramesCollection(FlxGraphic.fromRectangle(1,1,0x01000000,false,"blank.mp4"));
				switch (Std.string(rawNote[2]).toLowerCase()) {
					case "play animation" | "playanimation": {
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
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false){trace('Playing ${info[0]} for ${info[1]}');PlayState.charAnim(info[1],info[0],true);}; 
						trace('Animation note processed');
					}
					case "changebpm", "bgm change": {
						try{
							// Info can be set to anything, it's being used for storing the BPM

							info = [(if(rawNote[4] != "" && !Math.isNaN(Std.parseFloat(rawNote[4])))Std.parseFloat(rawNote[4]) else Std.parseFloat(rawNote[3]))]; 
						}catch(e){info = [120,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false){Conductor.changeBPM(info[0]);}; 
						trace('BPM note processed');
					}
					case "changescrollspeed": {
						try{
							// Info can be set to anything, it's being used for storing the BPM
							info = [Std.parseFloat(rawNote[4])]; 
						}catch(e){info = [2,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false){PlayState.SONG.speed = info[0];}; 
						trace('BPM note processed');
					}
					default:{ // Don't trigger hit animation
						trace('Note with "${rawNote[2]}" info "${rawNote[3]} / ${rawNote[4]}" hidden');
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false){trace('hit a ${rawNote[2]} note');return;};
					}
				}
			}else if(rawNote[3] != null && Std.isOfType(rawNote[3],String)){
				switch (Std.string(rawNote[3]).toLowerCase()) {
					case "play animation" | "playanimation": {
						try{
							// Info can be set to anything, it's being used for storing the Animation and character
							info = [rawNote[4]
							]; 
						}catch(e){info = [rawNote[4],0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false){PlayState.charAnim(charID,info[0],true);}; 
						trace('Animation note processed');
					}
					case "changebpm", "bgm change": {
						try{
							// Info can be set to anything, it's being used for storing the BPM

							info = [Std.parseFloat(rawNote[4])]; 
						}catch(e){info = [120,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false){Conductor.changeBPM(info[0]);}; 
						trace('BPM note processed');
					}
					case "changescrollspeed": {
						try{
							// Info can be set to anything, it's being used for storing the BPM
							info = [Std.parseFloat(rawNote[4])]; 
						}catch(e){info = [2,0];}
						// Replaces hit func
						hit = function(?charID:Int = 0,note,?useAlt:Bool = false){PlayState.SONG.speed = info[0];}; 
						trace('BPM note processed');
					}
				}
			}
		}

		x += 50;
		if (PlayState.SONG.mania == 3)
				x -= 30;
		if (PlayState.SONG.mania == 9)
				x -= 60;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0 )
			this.strumTime = 0;
		if(PlayState.SONG != null && shouldntBeHit && PlayState.SONG.inverthurtnotes) mustPress=!mustPress;

		if(!inCharter && rawNote != null && PlayState.instance != null) PlayState.instance.callInterp("noteCreate",[this,rawNote]);
		if(!eventNote){
			lastNoteID++;
			noteID = lastNoteID;
		}
		else
		noteID = -40;

		//defaults if no noteStyle was found in chart
		loadFrames();

		setGraphicSize(Std.int(width * noteScale));
		updateHitbox();
		antialiasing = true;

		switch (mania)
		{
			case 0:
				noteNames = ['purple','aqua','green','red'];
			case 1: 
				noteNames = ['purple','aqua','red','yellow','green','orange'];
			case 2: 
				noteNames = ['purple','aqua','red','white','yellow','green','orange'];
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
				noteNames = ['purple','aqua','green','red','lime','cyan','white','magenta','tango','yellow','pink','blue','orange'];
		}

		var noteName = noteNames[noteData];
		if(eventNote) noteName = noteNames[0];
		x+= swagWidth[mania] * noteData;
		animation.play(noteName + "Scroll");

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS 
		flipY = (FlxG.save.data.downscroll && sustainNote);

		if (isSustainNote && prevNote != null)
			{
				noteScore * 0.2;
				alpha = 0.6;
				// Funni downscroll flip when sussy note
				flipY = (FlxG.save.data.downscroll);
				

				// x += width / 2;

				animation.play(noteName + "holdend");
				isSustainNoteEnd = true;
				updateHitbox();

				// x -= width / 2;


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
					prevNote.isSustainNoteEnd = false;
					prevNote.scale.y *= Conductor.stepCrochet / 100 * longnoteScale * (if(FlxG.save.data.scrollSpeed != 1) FlxG.save.data.scrollSpeed else PlayState.SONG.speed);
					prevNote.updateHitbox();

					prevNote.offset.x = prevNote.frameWidth * 0.5;
					// prevNote.setGraphicSize();
				}
			}
		if(rawNote != null && PlayState.instance != null) PlayState.instance.callInterp("noteAdd",[this,rawNote]);
		visible = false;
		offset.x = frameWidth * 0.5;
	}catch(e){MainMenuState.handleError('Caught "Note create" crash: ${e.message}');}}

	var missedNote:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch(inCharter){
			case true:{
				wasGoodHit = (strumTime <= Conductor.songPosition);
				alpha = (wasGoodHit ? 0.7 : 1);
				visible = true;
				skipNote = false;
			}
			case false: if (!skipNote || isOnScreen()){ // doesn't calculate anything until they're on screen
				skipNote = false;
				visible = (!eventNote && showNote);
				callInterp("noteUpdate",[this]);

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
				// else if(eventNote){
				// 	if (strumTime <= Conductor.songPosition){

				// 		this.hit(1,this);
				// 		this.destroy();
				// 	}
				// }
				else if (aiShouldPress && PlayState.dadShow && !PlayState.p2canplay && strumTime <= Conductor.songPosition)
				{
					hit(1,this);
					callInterp("noteHitDad",[PlayState.dad,this]);
					

					PlayState.dad.holdTimer = 0;

					if (PlayState.dad.useVoices){PlayState.dad.voiceSounds[noteData].play(1);PlayState.dad.voiceSounds[noteData].time = 0;PlayState.instance.vocals.volume = 0;}else if (PlayState.SONG.needsVoices) PlayState.instance.vocals.volume = FlxG.save.data.voicesVol;

					PlayState.instance.notes.remove(this, true);
					destroy();
				}
				callInterp("noteUpdateAfter",[this]);

			}
		}
	}
}