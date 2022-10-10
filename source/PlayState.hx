package;

import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import flixel.system.macros.FlxMacroUtil;

import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import lime.media.openal.AL;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.system.System;
import flash.media.Sound;

#if windows
import Discord.DiscordClient;
#end
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;


import hscript.Expr;
import hscript.Interp;
import hscript.InterpEx;
import hscript.ParserEx;

import CharacterJson;
import StageJson;

using StringTools;

typedef OutNote = {
	var time:Float;
	var strumTime:Float;
	var direction:Int;
	var rating:String;
	var isSustain:Bool;
}

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var actualSongName:String = ''; // The actual song name, instead of the shit from the JSON
	public static var songDir:String = ''; // The song's directory
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var songDiff:String = "";
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var badNote:Int = 0;
	public static var mania:Int = 0;
	public static var SongOGmania:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 7, 9, 5, 8, 1, 2, 3, 10, 11, 12, 13];
	public static var stateType=0;
	public static var invertedChart:Bool = false;
	public static var bfnoteamount:Int = 0;
	public static var dadnoteamount:Int = 0;
	public static var ScoreMultiplier:Float = 0.0;
	public static var onlinecharacterID:Int = 0;
	public static var MultiPlayerSupport:Bool = false;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;
	public static var underlay:FlxSprite;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static inline var daPixelZoom:Int = 6;

	public static var noteBools:Array<Bool> = [false, false, false, false];
	public static var p2presses:Array<Bool> = [false,false,false,false,false,false,false,false,false,false,false,false]; // 0 = not pressed, 1 = pressed, 2 = hold, 3 = miss
	var p2holds:Array<Bool>;
	public static var p1presses:Array<Bool> = [false,false,false,false,false,false,false,false,false,false,false,false];
	public static var p2canplay = false;//TitleState.p2canplay

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	public var kadeEngineWatermark:FlxText;
	
	#if windows
	// Discord RPC variables
	public static var storyDifficultyText:String = "";
	public static var iconRPC:String = "";
	public static var LargeiconRPC:String = "";
	public static var detailsText:String = "";
	public static var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound;

	public var gfChar:String = "gf";
	public static var dad:Character;
	public static var dad2:Character;
	public static var gf:Character;
	public static var boyfriend:Character;
	public static var boyfriend2:Character;

	public static var girlfriend(get,set):Character;
	public static function get_girlfriend(){return gf;};
	public static function set_girlfriend(vari){return gf = vari;};
	public static var bf(get,set):Character;
	public static function get_bf(){return boyfriend;};
	public static function set_bf(vari){return boyfriend = vari;};
	public static var opponent(get,set):Character;
	public static function get_opponent(){return dad;};
	public static function set_opponent(vari){return dad = vari;};
	public static var player1:String = "bf";
	public static var player2:String = "bf";
	public static var player3:String = "gf";

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumArrow> = null;
	public var playerStrums:FlxTypedGroup<StrumArrow> = null;
	public var cpuStrums:FlxTypedGroup<StrumArrow> = null;
	public static var dadShow = true;
	var canPause:Bool = true;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	public var health:Float = 1; //making public because sethealth doesnt work without it
	public static var combo:Int = 0;
	public static var maxCombo:Int = 0;
	public static var misses:Int = 0;
	public static var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	var rating:FlxSprite;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	var hold:Array<Bool>;
	var press:Array<Bool>;
	var release:Array<Bool>;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var practiceText:FlxText;
	private var songPositionBar:Float = 0;
	public var handleTimes:Bool = true;
	
	public var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;
	public var camGame:FlxCamera;
	public var hasDied:Bool = false;

	public static var offsetTesting:Bool = false;
	var updateTime:Bool = false;


	// Note Splash group
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialogue:Array<String> = [];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	public var songName:FlxText;
	public var songTimeTxt:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	public static var songScore:Int = 0;
	public static var altsongScore:Int = 0;
	var songScoreDef:Int = 0;
	public var scoreTxt:FlxText;
	public var judgementCounter:FlxText;
	var scoreTxtX:Float;
	var replayTxt:FlxText;
	public var downscroll:Bool;
	public var middlescroll:Bool;
	public var scrollspeed:Float;
	public var BothSide:Bool;
	public var randomnote:Int;
	public var ADOFAIMode:Bool;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;


	// public static var theFunne:Bool = true;
	var inCutscene:Bool = false;
	// public static var repPresses:Int = 0;
	// public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	public var moveCamera:Bool = true;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var executeModchart = false;
	private var bruhmode:Bool = false;
	public static var stageTags:Array<String> = [];
	public static var beatAnimEvents:Map<Int,Map<String,IfStatement>>;
	public static var stepAnimEvents:Map<Int,Map<String,IfStatement>>;
	public static var canUseAlts:Bool = false;
	public static var hitSoundEff:Sound;
	public static var hurtSoundEff:Sound;
	static var vanillaHurtSounds:Array<Sound> = [];
	public var inputMode:Int = 0;
	public static var inputEngineName:String = "Unspecified";
	public static var songScript:String = "";
	public static var hsBrTools:HSBrTools;
	public static var nameSpace:String = "";
	public var eventLog:Array<OutNote> = [];
	public var camBeat:Bool = true;
	var practiceMode = false;
	var errorMsg:String = "";

	var hitSound:Bool = false;
	
	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;


	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }

	public function resetScore(){
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;
		badNote = 0;
		combo = 0;
		maxCombo = 0;
		// noteCount = 0;

		// repPresses = 0;
		// repReleases = 0;
		songScore = 0;
		altsongScore = 0;

	}

	var interps:Map<String,Interp> = new Map();

	public function handleError(?error:String = "Unknown error!",?forced:Bool = false){
		try{

			resetInterps();
			if(!songStarted && !forced && playCountdown){
				errorMsg = error;
				return;
			}
			// generatedMusic = false;
			generatedMusic = false;
			persistentUpdate = false;
			#if windows
			DiscordClient.changePresence("Got Script Error",detailsText, iconRPC,false,null,"error-playstate");
			#end
			openSubState(new FinishSubState(0,0,error));
		}catch(e){

			MainMenuState.handleError(error);
		}
	}
	public function revealToInterp(value:Dynamic,name:String,id:String){
		if ((interps[id] == null )) {return;}
		interps[id].variables.set(name,value); 

	}
	public function getFromInterp(name:String,id:String,?remove:Bool = false,?defVal:Dynamic = null):Dynamic{
		if ((interps[id] == null )) {return defVal;}
		var e = interps[id].variables.get(name); 
		if(remove) interps[id].variables.set(name,null);
		return e;
	}

	public function callSingleInterp(func_name:String, args:Array<Dynamic>,id:String){
		try{
			if (interps[id] == null) {trace('No Interp ${id}!');return;}
			if (!interps[id].variables.exists(func_name)) {return;}
			// trace('$func_name:$id $args');
			
			var method = interps[id].variables.get(func_name);
			Reflect.callMethod(interps[id],method,args);
		}catch(e:hscript.Expr.Error){handleError('${func_name} for ${id}:\n ${e.toString()}');}
	}

	public function callInterp(func_name:String, args:Array<Dynamic>,?id:String = "") { // Modified from Modding Plus, I am too dumb to figure this out myself
		try{
			if(func_name == "noteHitDad"){
				charCall("noteHitSelf",[args[1]],1);
				charCall("noteHitOpponent",[args[1]],0);
			}
			if(func_name == "noteHit"){
				charCall("noteHitSelf",[args[1]],0);
				charCall("noteHitOpponent",[args[1]],1);
			}
			// if(func_name != "update") trace('Called $func_name for ${(if(id != "")id else "Global")}');
			args.insert(0,this);
			if (id == "") {

				for (name in interps.keys()) {
					// var ag:Array<Dynamic> = [];
					// for (i => v in args) { // Recreates the array
					// 	ag[i] = v;
					// }
					callSingleInterp(func_name,args,name);
				}
			}else callSingleInterp(func_name,args,id);
		}catch(e:hscript.Expr.Error){handleError('${func_name} for "${id}":\n ${e.toString()}');}

		}
	public function resetInterps() {interps = new Map();interpCount=0;HSBrTools.shared.clear();}
	public function unloadInterp(?id:String){
		interpCount--;interps.remove(id);
	}
	
	public function parseHScript(?script:String = "",?brTools:HSBrTools = null,?id:String = "song"){
		// Scripts are forced with weeks, otherwise, don't load any scripts if scripts are disabled or during online play
		if (!QuickOptionsSubState.getSetting("Song hscripts") && !isStoryMode) {resetInterps();return;}
		var songScript = songScript;
		// var hsBrTools = hsBrTools;
		if (script != "") songScript = script;
		if (brTools == null && hsBrTools != null) brTools = hsBrTools;
		if (songScript == "") {return;}
		var interp = HscriptUtils.createSimpleInterp();
		var parser = new hscript.Parser();
		try{
			parser.allowTypes = parser.allowJSON = parser.allowMetadata = true;

			var program;
			// parser.parseModule(songScript);
			program = parser.parseString(songScript);

			if (brTools != null) {
				trace('Using hsBrTools');
				interp.variables.set("BRtools",brTools); 
				brTools.reset();
			}else {
				trace('Using assets folder');
				interp.variables.set("BRtools",new HSBrTools("assets/"));
			}
			interp.variables.set("charGet",charGet); 
			interp.variables.set("charSet",charSet);
			interp.variables.set("charAnim",charAnim);
			interp.variables.set("scriptName",id);
			interp.variables.set("close",function(id:String){PlayState.instance.unloadInterp(id);}); // Closes a script
			interp.execute(program);
			interps[id] = interp;
			if(brTools != null)brTools.reset();
			callInterp("initScript",[],id);
			interpCount++;
		}catch(e){
			handleError('Error parsing ${id} hscript, Line:${parser.line};\n Error:${e.message}\n ${e.stack}');
			// interp = null;
		}
		trace('Loaded ${id} script!');
	}
	static function charGet(charId:Int,field:String):Dynamic{
		return Reflect.field(switch(charId){
			default: boyfriend;
			case 1: dad; 
			case 2: gf;
			case 3: boyfriend2;
			case 4: dad2; 
		},field);
	}
	static public function charSet(charId:Int,field:String,value:Dynamic){
		Reflect.setField(switch(charId){default: boyfriend; case 1: dad; case 2: gf; case 3: boyfriend2; case 4: dad2;},field,value);
	}
	static public function charAnim(charId:Dynamic = 0,animation:String = "",?forced:Bool = false){
		if(charId.playAnim == null){
			try{
				charId = Std.string(charId);
			}catch(e){
				return boyfriend.playAnim(animation,forced);
			}
			charId = switch(charId){
				case "0" | "bf" | "player" | "p1": boyfriend;
				case "1" | "dad" | "opponent" | "p2": dad;
				case "2" | "gf" | "girlfriend" | "p3": gf;
				case "3" | "bf2" | "player2" | "p4": boyfriend2;
				case "4" | "dad2" | "opponent2" | "p5": dad2;
				default: return;
			};
		}
		charId.playAnim(animation,forced);
	}
	public function clearVariables(){
		stepAnimEvents = [];
		beatAnimEvents = [];
		if(unspawnNotes != null){
			for (i in unspawnNotes) {
				i.destroy();
			}
		}
		notesHitArray = [];
		unspawnNotes = [];
		strumLineNotes = null;
		playerStrums = null;
		cpuStrums = null;
		practiceMode = (FlxG.save.data.practiceMode || ChartingState.charting);
	}
	public static var hasStarted = false;
	public function requireScript(v:String,?important:Bool = false,?nameSpace:String = "requirement",?script:String = ""):Bool{
		if(QuickOptionsSubState.getSetting("Song hscripts") && onlinemod.OnlinePlayMenuState.socket == null){return false;}
		if(interps['${nameSpace}-${v}'] != null || interps['global-${v}'] != null) return true; // Don't load the same script twice
		trace('Checking for ${v}');
		if (FileSystem.exists('mods/scripts/${v}/script.hscript')){
			parseHScript(File.getContent('mods/scripts/${v}/script.hscript'),new HSBrTools('mods/scripts/${v}',v),'${nameSpace}-${v}');
		// }else if (FileSystem.exists('mods/dependancies/${v}/script.hscript')){
		// 	parseHScript(File.getContent('mods/dependancies/${v}/script.hscript'),new HSBrTools('mods/dependancies/${v}',v),'${nameSpace}-${v}');
		}else{showTempmessage('Script \'${v}\'' + (if(script == "") "" else ' required by \'${script}\'') + ' doesn\'t exist!');}
		if(important && interps['${nameSpace}-${v}'] == null){handleError('$script is missing a script: $v!');}
		return ((interps['${nameSpace}-${v}'] == null));
	}
	public function loadScript(v:String){
		if (FileSystem.exists('mods/scripts/${v}')){
			var brtool = new HSBrTools('mods/scripts/${v}',v);
			for (i in CoolUtil.orderList(FileSystem.readDirectory('mods/scripts/${v}/'))) {
				if(i.endsWith(".hscript")){
					parseHScript(File.getContent('mods/scripts/${v}/$i'),brtool,'global-${v}-${i}');
				}
			}
			// parseHScript(File.getContent('mods/scripts/${v}/script.hscript'),new HSBrTools('mods/scripts/${v}',v),'global-${v}');
		}else{showTempmessage('Global script \'${v}\' doesn\'t exist!');}
	}
	public var oldBF:String = "";
	public var oldOPP:String = "";
	override public function new(){
		super();
		PlayState.player1 = "";
		PlayState.player2 = "";
		PlayState.player3 = "";
	}
	override public function create()
	{
		#if !debug
		try{
		#end
		if (instance != null) instance.destroy();
		if(SONG.mania > 0 || (SONG.mania == 3 && SONG.events != null))
			BothSide = false;
		else
			BothSide = QuickOptionsSubState.getSetting("Play Both Side");
		randomnote = QuickOptionsSubState.getSetting("Random Notes");
		ADOFAIMode = QuickOptionsSubState.getSetting("ADOFAI Chart");
		downscroll = FlxG.save.data.downscroll;
		middlescroll = (FlxG.save.data.middleScroll || BothSide);
		scrollspeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2);
		if(FlxG.save.data.FastSongScrollSpeed > 1 && songspeed > 1 && FlxG.save.data.scrollSpeed != 1)
			scrollspeed = FlxMath.roundDecimal(FlxG.save.data.FastSongScrollSpeed * songspeed, 2);
		else
			scrollspeed = FlxMath.roundDecimal(scrollspeed * songspeed, 2);
		setInputHandlers(); // Sets all of the handlers for input
		instance = this;
		clearVariables();
		hasStarted = true;
		if (PlayState.songScript == "" && SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()] != null) songScript = SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()];
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(1000);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		resetScore();

		if(ChartingState.charting){
			if (TitleState.retChar(PlayState.SONG.player1) != "") player1 = TitleState.retChar(PlayState.SONG.player1);
			else if(FlxG.save.data.playerChar == "automatic") player1 = "bf";
			else player1 = FlxG.save.data.playerChar;
		}else{
			if (FlxG.save.data.playerChar == "automatic"){
				if (TitleState.retChar(PlayState.SONG.player1) != "") player1 = TitleState.retChar(PlayState.SONG.player1);
				else player1 = "bf";
			}else player1 = FlxG.save.data.playerChar;
		}
		TitleState.loadNoteAssets(); // Make sure note assets are actually loaded
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;
		
		SongOGmania = SONG.mania;
		if (SONG.events != null && SONG.mania > 0)
			SONG.keyCount = SONG.mania + 1;

		if (ADOFAIMode) // LMAO
			SONG.mania = mania = 6;
		else if(BothSide)
			SONG.mania = mania = 5;
		else if(SONG.keyCount != null && QuickOptionsSubState.getSetting("Force Mania") == -1)
			{
				switch(SONG.keyCount)
				{
					case 1: mania = SONG.mania = SongOGmania = 6;
					case 2: mania = SONG.mania = SongOGmania = 7;
					case 3: mania = SONG.mania = SongOGmania = 8;
					case 4: mania = SONG.mania = SongOGmania = 0;
					case 5: mania = SONG.mania = SongOGmania = 4;
					case 6: mania = SONG.mania = SongOGmania = 1;
					case 7: mania = SONG.mania = SongOGmania = 2;
					case 8: mania = SONG.mania = SongOGmania = 5;
					case 9: mania = SONG.mania = SongOGmania = 3;
					case 10: mania = SONG.mania = SongOGmania = 9;
					case 11: mania = SONG.mania = SongOGmania = 10;
					case 12: mania = SONG.mania = SongOGmania = 11;
					case 13: mania = SONG.mania = SongOGmania = 12;
					default: mania = SONG.mania = SongOGmania = 0;
				}
			}
		else if(QuickOptionsSubState.getSetting("Force Mania") == -1)
			{
				mania = SONG.mania;
				SONG.keyCount = keyAmmo[mania];
			}
		else
			{
				SONG.mania = mania = QuickOptionsSubState.getSetting("Force Mania");
				SONG.keyCount = keyAmmo[mania];
			}

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = songDiff;

		// iconRPC = SONG.player2;
		if(BothSide)
			iconRPC = "bothside";
		else iconRPC = "mania" + SONG.keyCount;

		switch(stateType)
		{
			case 0:detailsText = "Freeplay " + SONG.song	+ " (" + storyDifficultyText + ") ";
			case 2:detailsText = "Offline " + SONG.song	+ " (" + storyDifficultyText + ") ";
			case 3:detailsText = "Online " + SONG.song	+ " (" + storyDifficultyText + ") ";
			case 4:detailsText = "Multi " + storyDifficultyText;
			case 5:detailsText = "OSU " + storyDifficultyText;
			case 6:detailsText = "Story " + SONG.song	+ " (" + storyDifficultyText + ") ";
		}
		if (songspeed != 1)
			detailsText = detailsText + "(" + songspeed + "x)";
		if (ADOFAIMode)
			detailsText = detailsText + " ADOFAI Mode";
		else if (BothSide)
			detailsText = detailsText + " Both Side";
		if (randomnote != 0 && !ADOFAIMode)
			detailsText = detailsText + " Random Note";

		if(stateType == 3)
			{
				if(onlinemod.OnlineLobbyState.clientCount == 1)
					LargeiconRPC = "empty-online-playstate";
				else
					LargeiconRPC = "online-playstate";
			}
		else
			LargeiconRPC = "playstate";
		
		if (QuickOptionsSubState.getSetting("Inverted chart"))
			detailsText = detailsText + " Inverted chart";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(
			detailsText
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: " + songScore
			+ " | Misses: " + misses, iconRPC,false,0,LargeiconRPC);
		#end

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm * songspeed);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);
	
		
		//dialogue shit
		loadDialog();
		// Stage management
		var bfPos:Array<Float> = [0,0]; 
		var gfPos:Array<Float> = [0,0]; 
		var dadPos:Array<Float> = [0,0]; 
		var noGf:Bool = false;
		 // Oh my god this code hurts my soul, but I really don't want to recreate it
		if (FlxG.save.data.preformance){
			defaultCamZoom = 0.5;
			curStage = 'void';
			stageTags = [];
			bfPos = [100,0];
			dadPos = [-100,0];
			// var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
			// stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			// stageFront.updateHitbox();
			// stageFront.antialiasing = false;
			// stageFront.scrollFactor.set(0.9, 0.9);
			// stageFront.active = false;
			// add(stageFront);
		}else{
			if (FlxG.save.data.selStage != "default"){SONG.stage = FlxG.save.data.selStage;}
			switch(SONG.stage.toLowerCase()){
					case 'halloween': 
					{
						curStage = 'spooky';
						halloweenLevel = true;
						stageTags = ["spooky","inside"];
						var hallowTex = Paths.getSparrowAtlas('halloween_bg','week2');
		
						halloweenBG = new FlxSprite(-200, -100);
						halloweenBG.frames = hallowTex;
						halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
						halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
						halloweenBG.animation.play('idle');
						halloweenBG.antialiasing = true;
						add(halloweenBG);
		
						isHalloween = true;
					}
					case 'philly': 
							{
							curStage = 'philly';
							stageTags = ["outside"];
							var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
							bg.scrollFactor.set(0.1, 0.1);
							add(bg);
		
							var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
							city.scrollFactor.set(0.3, 0.3);
							city.setGraphicSize(Std.int(city.width * 0.85));
							city.updateHitbox();
							add(city);
		
							phillyCityLights = new FlxTypedGroup<FlxSprite>();
							if(FlxG.save.data.distractions){
								add(phillyCityLights);
							}
		
							for (i in 0...5)
							{
									var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
									light.scrollFactor.set(0.3, 0.3);
									light.visible = false;
									light.setGraphicSize(Std.int(light.width * 0.85));
									light.updateHitbox();
									light.antialiasing = true;
									phillyCityLights.add(light);
							}
		
							var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain','week3'));
							add(streetBehind);
		
							phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train','week3'));
							if(FlxG.save.data.distractions){
								add(phillyTrain);
							}
		
							trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes','week3'));
							FlxG.sound.list.add(trainSound);
		
							// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);
		
							var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street','week3'));
							add(street);
					}
					case 'limo':
					{
							curStage = 'limo';
							defaultCamZoom = 0.90;
							stageTags = ["outside","windy"];

		
							var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset','week4'));
							skyBG.scrollFactor.set(0.1, 0.1);
							add(skyBG);
		
							var bgLimo:FlxSprite = new FlxSprite(-200, 480);
							bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo','week4');
							bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
							bgLimo.animation.play('drive');
							bgLimo.scrollFactor.set(0.4, 0.4);
							add(bgLimo);
							if(FlxG.save.data.distractions){
								grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
								add(grpLimoDancers);
			
								for (i in 0...5)
								{
										var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
										dancer.scrollFactor.set(0.4, 0.4);
										grpLimoDancers.add(dancer);
								}
							}
		
							var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay','week4'));
							overlayShit.alpha = 0.5;
							// add(overlayShit);
		
							// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
		
							// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
		
							// overlayShit.shader = shaderBullshit;
		
							var limoTex = Paths.getSparrowAtlas('limo/limoDrive','week4');
		
							limo = new FlxSprite(-120, 550);
							limo.frames = limoTex;
							limo.animation.addByPrefix('drive', "Limo stage", 24);
							limo.animation.play('drive');
							limo.antialiasing = true;
		
							fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol','week4'));
							// add(limo);
					}
					case 'mall':
					{
							curStage = 'mall';
							stageTags = ["inside","christmas"];
							defaultCamZoom = 0.80;
		
							var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls','week5'));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.2, 0.2);
							bg.active = false;
							bg.setGraphicSize(Std.int(bg.width * 0.8));
							bg.updateHitbox();
							add(bg);
		
							upperBoppers = new FlxSprite(-240, -90);
							upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop','week5');
							upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
							upperBoppers.antialiasing = true;
							upperBoppers.scrollFactor.set(0.33, 0.33);
							upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
							upperBoppers.updateHitbox();
							if(FlxG.save.data.distractions){
								add(upperBoppers);
							}
		
		
							var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator','week5'));
							bgEscalator.antialiasing = true;
							bgEscalator.scrollFactor.set(0.3, 0.3);
							bgEscalator.active = false;
							bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
							bgEscalator.updateHitbox();
							add(bgEscalator);
		
							var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree','week5'));
							tree.antialiasing = true;
							tree.scrollFactor.set(0.40, 0.40);
							add(tree);
		
							bottomBoppers = new FlxSprite(-300, 140);
							bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop','week5');
							bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
							bottomBoppers.antialiasing = true;
							bottomBoppers.scrollFactor.set(0.9, 0.9);
							bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
							bottomBoppers.updateHitbox();
							if(FlxG.save.data.distractions){
								add(bottomBoppers);
							}
		
		
							var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow','week5'));
							fgSnow.active = false;
							fgSnow.antialiasing = true;
							add(fgSnow);
		
							santa = new FlxSprite(-840, 150);
							santa.frames = Paths.getSparrowAtlas('christmas/santa','week5');
							santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
							santa.antialiasing = true;
							if(FlxG.save.data.distractions){
								add(santa);
							}
					}
					case 'mallevil':
					{
							curStage = 'mallEvil';
							stageTags = ["inside","christmas","spooky"];
							var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG','week5'));
							bg.antialiasing = true;
							bg.scrollFactor.set(0.2, 0.2);
							bg.active = false;
							bg.setGraphicSize(Std.int(bg.width * 0.8));
							bg.updateHitbox();
							add(bg);
		
							var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree','week5'));
							evilTree.antialiasing = true;
							evilTree.scrollFactor.set(0.2, 0.2);
							add(evilTree);
		
							var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow",'week5'));
								evilSnow.antialiasing = true;
							add(evilSnow);
							}
					case 'school':
					{
							curStage = 'school';
							stageTags = ["outside","pixel"];
		
							// defaultCamZoom = 0.9;
		
							var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky','week6'));
							bgSky.scrollFactor.set(0.1, 0.1);
							add(bgSky);
		
							var repositionShit = -200;
							var y = 0;
							gfPos = [0,5];
		
							var bgSchool:FlxSprite = new FlxSprite(repositionShit, y).loadGraphic(Paths.image('weeb/weebSchool','week6'));
							bgSchool.scrollFactor.set(0.6, 0.90);
							add(bgSchool);
		
							var bgStreet:FlxSprite = new FlxSprite(repositionShit, y).loadGraphic(Paths.image('weeb/weebStreet','week6'));
							bgStreet.scrollFactor.set(0.95, 0.95);
							add(bgStreet);
		
							var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, y + 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
							fgTrees.scrollFactor.set(0.9, 0.9);
							add(fgTrees);
		
							var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, y + -800);
							var treetex = Paths.getPackerAtlas('weeb/weebTrees','week6');
							bgTrees.frames = treetex;
							bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
							bgTrees.animation.play('treeLoop');
							bgTrees.scrollFactor.set(0.85, 0.85);
							add(bgTrees);
		
							var treeLeaves:FlxSprite = new FlxSprite(repositionShit, y + -40);
							treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
							treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
							treeLeaves.animation.play('leaves');
							treeLeaves.scrollFactor.set(0.85, 0.85);
							add(treeLeaves);
		
							var widShit = Std.int(bgSky.width * 6);
		
							bgSky.setGraphicSize(widShit);
							bgSchool.setGraphicSize(widShit);
							bgStreet.setGraphicSize(widShit);
							bgTrees.setGraphicSize(Std.int(widShit * 1.4));
							fgTrees.setGraphicSize(Std.int(widShit * 0.8));
							treeLeaves.setGraphicSize(widShit);
		
							fgTrees.updateHitbox();
							bgSky.updateHitbox();
							bgSchool.updateHitbox();
							bgStreet.updateHitbox();
							bgTrees.updateHitbox();
							treeLeaves.updateHitbox();
		
							bgGirls = new BackgroundGirls(-100, y + 190);
							bgGirls.scrollFactor.set(0.9, 0.9);
		
							if (SONG.song.toLowerCase() == 'roses')
								{
									if(FlxG.save.data.distractions){
										bgGirls.getScared();
									}
								}
		
							bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
							bgGirls.updateHitbox();
							if(FlxG.save.data.distractions){
								add(bgGirls);
						}
					}
					case 'schoolevil':
					{
							curStage = 'schoolEvil';
							stageTags = ["outside","pixel"];
							var y = 200;
		
							var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
							var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
		
							var posX = 400;
							var posY = 200;
		
							var bg:FlxSprite = new FlxSprite(posX, posY);
							bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool','week6');
							bg.animation.addByPrefix('idle', 'background 2', 24);
							bg.animation.play('idle');
							bg.scrollFactor.set(0.8, 0.9);
							bg.scale.set(6, 6);
							add(bg);
					}
					case 'stage','default':
					{
								defaultCamZoom = 0.9;
								curStage = 'stage';
								stageTags = ["inside","stage"];
								var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
								bg.antialiasing = true;
								bg.scrollFactor.set(0.9, 0.9);
								bg.active = false;
								add(bg);
			
								var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
								stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
								stageFront.updateHitbox();
								stageFront.antialiasing = true;
								stageFront.scrollFactor.set(0.9, 0.9);
								stageFront.active = false;
								add(stageFront);
			
								var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
								stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
								stageCurtains.updateHitbox();
								stageCurtains.antialiasing = true;
								stageCurtains.scrollFactor.set(1.3, 1.3);
								stageCurtains.active = false;
			
								add(stageCurtains);
					}
					default:
					{	
						var stage:String = TitleState.retStage(SONG.stage);
						if(stage == ""){
								trace('"${SONG.stage}" not found, using "Stage"!');
								stageTags = ["inside"];
								defaultCamZoom = 0.9;
								curStage = 'stage';
								var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
								bg.antialiasing = true;
								bg.scrollFactor.set(0.9, 0.9);
								bg.active = false;
								add(bg);
			
								var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
								stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
								stageFront.updateHitbox();
								stageFront.antialiasing = true;
								stageFront.scrollFactor.set(0.9, 0.9);
								stageFront.active = false;
								add(stageFront);
			
								var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
								stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
								stageCurtains.updateHitbox();
								stageCurtains.antialiasing = true;
								stageCurtains.scrollFactor.set(1.3, 1.3);
								stageCurtains.active = false;
			
								add(stageCurtains);
						}else{
							curStage = SONG.stage;
							stageTags = [];
							var stagePath:String = 'mods/stages/$stage';
							if (FileSystem.exists('$stagePath/config.json')){
								var stagePropJson:String = File.getContent('$stagePath/config.json');
								var stageProperties:StageJSON = haxe.Json.parse(CoolUtil.cleanJSON(stagePropJson));
								if (stageProperties == null || stageProperties.layers == null || stageProperties.layers[0] == null){MainMenuState.handleError('$stage\'s JSON is invalid!');} // Boot to main menu if character's JSON can't be loaded
								defaultCamZoom = stageProperties.camzoom;
								for (layer in stageProperties.layers) {
									if(layer.song != null && layer.song != "" && layer.song.toLowerCase() != SONG.song.toLowerCase()){continue;}
									var curLayer:FlxSprite = new FlxSprite(0,0);
									if(layer.animated){
										var xml:String = File.getContent('$stagePath/${layer.name}.xml');
										if (xml == null || xml == "")MainMenuState.handleError('$stage\'s XML is invalid!');
										curLayer.frames = FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(BitmapData.fromFile('$stagePath/${layer.name}.png')), xml);
										curLayer.animation.addByPrefix(layer.animation_name,layer.animation_name,layer.fps,false);
										curLayer.animation.play(layer.animation_name);
									}else{
										var png:BitmapData = BitmapData.fromFile('$stagePath/${layer.name}.png');
										if (png == null) MainMenuState.handleError('$stage\'s PNG is invalid!');
										curLayer.loadGraphic(png);
									}

									if (layer.centered) curLayer.screenCenter();
									if (layer.flip_x) curLayer.flipX = true;
									curLayer.setGraphicSize(Std.int(curLayer.width * layer.scale));
									curLayer.updateHitbox();
									curLayer.x += layer.pos[0];
									curLayer.y += layer.pos[1];
									curLayer.antialiasing = layer.antialiasing;
									curLayer.alpha = layer.alpha;
									curLayer.active = false;
									curLayer.scrollFactor.set(layer.scroll_factor[0],layer.scroll_factor[1]);
									add(curLayer);
								}
								if (stageProperties.no_gf) noGf = true; // This doesn't have to be provided, doing it this way
								bfPos = stageProperties.bf_pos;
								dadPos = stageProperties.dad_pos;
								gfPos = stageProperties.gf_pos;
								stageTags = stageProperties.tags;
							}
							var brTool = new HSBrTools(stagePath);
							for (i in CoolUtil.orderList(FileSystem.readDirectory(stagePath))) {
								if(i.endsWith(".hscript")){
									parseHScript(File.getContent('$stagePath/$i'),brTool,"STAGE-" + i);
								}
							}
						}
					}
				}
		}

		if(PlayState.player2 == "")PlayState.player2 = SONG.player2;
		if(PlayState.player3 == "")PlayState.player3 = SONG.gfVersion;
		callInterp("afterStage",[]);

		if (FlxG.save.data.charAuto && TitleState.retChar(PlayState.player2) != ""){ // Check is second player is a valid character
			PlayState.player2 = TitleState.retChar(PlayState.player2);
		}else{
			PlayState.player2 = FlxG.save.data.opponent;
    	}
		var gfVersion:String = 'gf';

		switch (SONG.gfVersion)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
			default:
				gfVersion = 'gf';
		}
		if (FlxG.save.data.gfChar != "gf"){gfVersion=FlxG.save.data.gfChar;}
		gfChar = gfVersion;
		if (FlxG.save.data.gfShow) gf = new Character(400, 100, gfVersion,false,2); else gf = new EmptyCharacter(400, 100);
		gf.scrollFactor.set(0.95, 0.95);
		if (noGf) gf.visible = false;
		if (!ChartingState.charting && SONG.player1.startsWith("gf") && FlxG.save.data.charAuto) player1 = FlxG.save.data.gfChar;
		if (!ChartingState.charting && SONG.player2.startsWith("gf") && FlxG.save.data.charAuto) player2 = FlxG.save.data.gfChar;
		if (dadShow && FlxG.save.data.dadShow && !(player3 == player2 && player1 != player2)) dad = new Character(100, 100, player2,false,1); else dad = new EmptyCharacter(100, 100);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		camPos.set(camPos.x + dad.camX, camPos.y + dad.camY);
		if (FlxG.save.data.bfShow) boyfriend = new Character(770, 100, player1,true,0); else boyfriend = new EmptyCharacter(400,100);
		boyfriend2 = new EmptyCharacter(400,100);
		dad2 = new EmptyCharacter(100,100);
		

		// REPOSITIONING PER STAGE
		switch (curStage.toLowerCase())
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if(FlxG.save.data.distractions){
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
		}
		for (i => v in [bfPos,dadPos,gfPos]) {
			if (v[0] != 0 || v[1] != 0){
				switch(i){
					case 0:boyfriend.x+=v[0];boyfriend.y+=v[1];
					case 1:dad.x+=v[0];dad.y+=v[1];
					case 2:gf.x+=v[0];gf.y+=v[1];
				}
			}
		}
		if (player3 == player2 && player1 != player2){// Don't hide GF if player 1 is GF
				// dad.setPosition(gf.x, gf.y);
				dad.destroy();
				dad = gf;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
		}

		if (player3 == player1){
			if (player1 != player2){	// Don't hide GF if player 1 is GF
				boyfriend.destroy();
				boyfriend = gf;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}
		}
		parseHScript(songScript,null,"song");
		if(QuickOptionsSubState.getSetting("Song hscripts") && FlxG.save.data.scripts != null){
			for (i in 0 ... FlxG.save.data.scripts.length) {
				
				var v = FlxG.save.data.scripts[i];
				trace('Checking for ${v}');
				loadScript(v);
			}
		}
		if(QuickOptionsSubState.getSetting("Song hscripts") && onlinemod.OnlinePlayMenuState.socket != null){

			for (i in 0 ... onlinemod.OnlinePlayMenuState.scripts.length) {
				
				var v = onlinemod.OnlinePlayMenuState.scripts[i];
				trace('Checking for ${v}');
				loadScript(v);
			}
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);


		

		charCall("addGF",[],-1);
		callInterp("addGF",[]);
		add(dad);
		charCall("addDad",[],-1);
		callInterp("addDad",[]);
		add(boyfriend);
		callInterp("addChars",[]);
		charCall("addChars",[],-1);

		// if (loadRep)
		// {
		// 	FlxG.watch.addQuick('rep rpesses',repPresses);
		// 	FlxG.watch.addQuick('rep releases',repReleases);
			
		// 	FlxG.save.data.botplay = true;
		// 	FlxG.save.data.scrollSpeed = rep.replay.noteSpeed;
		// 	downscroll = rep.replay.isDownscroll;
		// 	// FlxG.watch.addQuick('Queued',inputsQueued);
		// }

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;
		if(FlxG.save.data.undlaTrans > 0){
			trace("e");
			underlay = new FlxSprite(-100,-100).makeGraphic((if(FlxG.save.data.undlaSize == 0)Std.int(Note.swagWidth[mania] * keyAmmo[mania] + keyAmmo[mania]) else 1920),1080,0xFF000010);
			underlay.alpha = FlxG.save.data.undlaTrans;
			underlay.cameras = [camHUD];
			add(underlay);
		}
		trace('SwagWidth : ${Note.swagWidth[mania]} KeyAmmo : ${keyAmmo[mania]} KeyCount : ${SONG.keyCount}  mania : ${mania}');
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<StrumArrow>();
		add(strumLineNotes);
		// Note splashes
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash();
		noteSplash0.setupNoteSplash(boyfriend, 0);
		grpNoteSplashes.add(noteSplash0);
		add(grpNoteSplashes);
		if (SONG.difficultyString != null && SONG.difficultyString != "") songDiff = SONG.difficultyString;
		else songDiff = if(stateType == 4) "mods/charts" else if (stateType == 5) "osu! beatmap" else (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy");
		playerStrums = new FlxTypedGroup<StrumArrow>();
		cpuStrums = new FlxTypedGroup<StrumArrow>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		followChar(0,true);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		// FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
				if (downscroll)
					songPosBG.y = FlxG.height * 0.9 + 45 - FlxG.save.data.guiGap; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				// add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				// add(songPosBar);
	
				songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
				if (downscroll)
					songName.y -= 3;
				songName.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				// add(songName);
				songName.cameras = [camHUD];
			}
		
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9 - FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
		if (downscroll)
			healthBarBG.y = 50 + FlxG.save.data.guiGap;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,'health', 0, 2);
		
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.definingColor, boyfriend.definingColor);
		// healthBar
		add(healthBar);
		// Add Kade Engine watermark
		if (stateType != 4 && stateType != 5 ) actualSongName = curSong + " " + songDiff;

		
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50 - FlxG.save.data.guiGap,0,actualSongName + (FlxMath.roundDecimal(songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songspeed, 2) + "x)" : "") + " - " + inputEngineName, 16);
		kadeEngineWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap;

		// scoreTxtX = FlxG.width * ;
		
		if (FlxG.save.data.songInfo == 0 || FlxG.save.data.songInfo == 1 || FlxG.save.data.songInfo == 3) {
			scoreTxt = new FlxText(50, healthBarBG.y + 30 - FlxG.save.data.guiGap, 0, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
			scoreTxt.autoSize = false;
			scoreTxt.wordWrap = false;
			scoreTxt.alignment = "left";
		}else {
			scoreTxt = new FlxText(10 + FlxG.save.data.guiGap, FlxG.height * 0.46 , 600, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', 20); // Long ass text to make sure it's sized correctly
			// scoreTxt.autoSize = true;
			// scoreTxt.width += 300;
			scoreTxt.wordWrap = false;
			scoreTxt.alignment = "center";
		}

		
		// if (!FlxG.save.data.accuracyDisplay)
		// 	scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		
		if(FlxG.save.data.botplay && !loadRep){add(botPlayState);bruhmode = FlxG.save.data.botplay;};

		iconP1 = new HealthIcon(player1, true,boyfriend.clonedChar);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(player2, false,dad.clonedChar);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		// iconP2.offset.set(0,iconP2.width);

		add(iconP2);

		callInterp("addUI",[]);
		charCall("addUI",[],-1);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		if(practiceMode){
			healthBar.visible = healthBarBG.visible = false;
			var iconOffset = 26;
			if(middlescroll){
				iconP2.x = FlxG.width * 0.05;
				iconP1.x = FlxG.width * 0.95 - iconP1.width;
			}else{
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01) - iconOffset);

			}
			var y = (downscroll ? FlxG.height * 0.9 : FlxG.height * 0.1);
			iconP2.y = iconP1.y = y - (iconP1.height * 0.5);
		}
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		iconP1.y = healthBarBG.y - (iconP1.height / 2);
		iconP2.y = healthBarBG.y - (iconP2.height / 2);
		// if (FlxG.save.data.songPosition)
		// {
		// 	songPosBG.cameras = [camHUD];
		// 	songPosBar.cameras = [camHUD];
		// }
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		hitSound = FlxG.save.data.hitSound;
		if(FlxG.save.data.hitSound && hitSoundEff == null) hitSoundEff = Sound.fromFile(( if (FileSystem.exists('mods/hitSound.ogg')) 'mods/hitSound.ogg' else Paths.sound('Normal_Hit')));

		if(hurtSoundEff == null) hurtSoundEff = Sound.fromFile(( if (FileSystem.exists('mods/hurtSound.ogg')) 'mods/hurtSound.ogg' else Paths.sound('ANGRY')));
		if(vanillaHurtSounds[0] == null && FlxG.save.data.playMisses) vanillaHurtSounds = [Sound.fromFile('assets/shared/sounds/missnote1.ogg'),Sound.fromFile('assets/shared/sounds/missnote2.ogg'),Sound.fromFile('assets/shared/sounds/missnote3.ogg')];

		startingSong = true;
		
		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdownFirst();
								}
							});
						});
					});
				case 'senpai','thorns':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				default:
					startCountdownFirst();
			}
		}
		else
		{
			startCountdownFirst();
		}

		if (!loadRep)
			rep = new Replay("na");
		
		add(scoreTxt);
		
		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(CoolUtil.font, 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Combo: ${combo}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}\nBad Note: ${badNote}\n';
		add(judgementCounter);

		// FlxG.sound.cache("missnote1");
		// FlxG.sound.cache("missnote2");
		// FlxG.sound.cache("missnote3");

		super.create();



		openfl.system.System.gc();
	#if !debug 
	}catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}\n ${e.stack}');}
	#end
	}
	function loadDialog(){		
		dialogue = [];
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dad battle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}
	}



	// public static function regAnimEvent(charType:Int,ifState:IfStatement,animName:String){
	// 	PlayState.animEvents[charType][animName] = ifState;
	// }


	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdownFirst();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdownFirst(){ // Skip the 
		callInterp("startCountdownFirst",[]);
		FlxG.camera.zoom = FlxMath.lerp(0.90, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		// camFollow.setPosition(720, 500);

		canPause = true;
		updateCharacterCamPos();
		if (!playCountdown){
			playCountdown = true;
			return;
		}
		startCountdown();
	}
	var keys = [false, false, false, false, false, false, false, false, false, false, false, false, false];
	var playCountdown = true;
	var generatedArrows = false;
	public var swappedChars = false;
	public function startCountdown():Void
	{
		inCutscene = false;
		if (!generatedArrows){
			generatedArrows = true;
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		switch(mania) 
		{
			case 0: 
				keys = [false, false, false, false];
			case 1: 
				keys = [false, false, false, false, false, false];
			case 2: 
				keys = [false, false, false, false, false, false, false];
			case 3: 
				keys = [false, false, false, false, false, false, false, false, false];
			case 4: 
				keys = [false, false, false, false, false];
			case 5:
				keys = [false, false, false, false, false, false, false, false];
			case 6:
				keys = [false];
			case 7:
				keys = [false, false];
			case 8:
				keys = [false, false, false];
			case 9:
				keys = [false, false, false, false,false, false, false, false,false, false];
			case 10:
				keys = [false, false, false, false,false, false, false, false,false, false, false];
			case 11:
				keys = [false, false, false, false,false, false, false, false,false, false, false, false];
			case 12:
				keys = [false, false, false, false,false, false, false, false,false, false, false, false, false];
		}
		NoteStuffExtra.CalculateNoteAmount(SONG);
		bfnoteamount = NoteStuffExtra.bfNotes.length;
		dadnoteamount = NoteStuffExtra.dadNotes.length;
		if (!BothSide)
			ScoreMultiplier = Std.int(Math.max(bfnoteamount, dadnoteamount)) / bfnoteamount;
		else ScoreMultiplier = 1;

		if (invertedChart || (onlinemod.OnlinePlayMenuState.socket == null && QuickOptionsSubState.getSetting("Swap characters"))){
			var bf:Character = boyfriend;
			var opp:Character = dad;
			healthBar.createFilledBar(boyfriend.definingColor, dad.definingColor);
			boyfriend = opp;
			dad = bf;
			boyfriend.isPlayer = true;
			dad.isPlayer = false;
			swappedChars = !swappedChars;
			healthBar.fillDirection = (swappedChars ? LEFT_TO_RIGHT : RIGHT_TO_LEFT);
			if(!middlescroll){ // This is dumb but whatever
				var plStrumX = [];
				var oppStrumX = [];
				for (i in playerStrums.members) {
					plStrumX[i.ID] = i.x;
				}
				for (i in cpuStrums.members) {
					oppStrumX[i.ID] = i.x;
				}
				for (i in 0...keyAmmo[mania]) {
					playerStrums.members[i].x = oppStrumX[i];
				}
				for (i in 0...keyAmmo[mania]) {
					cpuStrums.members[i].x = plStrumX[i];
				}
				if(underlay != null)
					underlay.x = playerStrums.members[0].x;
			}
		}
		FlxG.camera.zoom = FlxMath.lerp(0.90, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;


		if(errorMsg != "") {handleError(errorMsg,true);return;}
		var swagCounter:Int = 0;
		
		callInterp("startCountdown",[]);

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			boyfriend.dance();
			dad.dance();
			gf.dance();
			boyfriend2.dance();
			dad2.dance();


			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			// for (value in introAssets.keys())
			// {
			// 	if (value == curStage)
			// 	{
			// 		introAlts = introAssets.get(value);
			// 	}
			// }
			callInterp("startTimerStep",[swagCounter]);
			if(playCountdown){

				switch (swagCounter)
				{
					case 0:
						if (errorMsg != ""){
							handleError(errorMsg);
							startTimer.cancel();
							return;
						}
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();


						ready.screenCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();



						set.screenCenter();
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();


						go.updateHitbox();

						go.screenCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					case 4:
						
				}
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	function charCall(func:String,args:Array<Dynamic>,?char:Int = -1){
		switch(char){
			case 0: boyfriend.callInterp(func,args);
			case 1: dad.callInterp(func,args);
			case 2: gf.callInterp(func,args);
			case -1:
				boyfriend.callInterp(func,args);
				dad.callInterp(func,args);
				gf.callInterp(func,args);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var songspeed = 1.0;

	public var songStarted(default, null):Bool = false;

	function startSong(?alrLoaded:Bool = false):Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
		}
		trace("pitched inst and vocals to " + songspeed);
		#end
		#if windows
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(
			detailsText
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: " + songScore
			+ " | Misses: " + misses, iconRPC,false,0,LargeiconRPC);
		#end

		if (!alrLoaded)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = FlxG.sound.music.pause;
		vocals.play();
		
		if(sectionStart){
			FlxG.sound.music.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length / songspeed;
		FlxG.sound.music.loopTime = 0;
		songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
		if (FlxG.save.data.songPosition)
		{
			addSongBar();
		}
		
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		if(errorMsg != "") {handleError(errorMsg,true);return;}
		charCall("startSong",[]);
		callInterp("startSong",[]);
		updateTime = FlxG.save.data.songPosition;

	}

	function addSongBar(?minimal:Bool = false){

			if(songPosBG != null) remove(songPosBG);
			if(songPosBar != null) remove(songPosBar);
			if(songName != null) remove(songName);
			if(songTimeTxt != null) remove(songTimeTxt);
			songPosBG = new FlxSprite(0, 10 + FlxG.save.data.guiGap).loadGraphic(Paths.image('healthBar'));
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4 + FlxG.save.data.guiGap, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);

			songName = new FlxText(songPosBG.x + (songPosBG.width * 0.2) - 20,songPosBG.y + 1,0,SONG.song, 16);
			songName.x -= songName.text.length;
			songName.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			songTimeTxt = new FlxText(songPosBG.x + (songPosBG.width * 0.7) - 20,songPosBG.y + 1,0,"00:00 | 0:00", 16);
			if (downscroll)
				songName.y -= 3;
			songTimeTxt.text = "00:00 | " + songLengthTxt;
			songTimeTxt.x -= songTimeTxt.text.length;
			songTimeTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songTimeTxt.scrollFactor.set();

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
			songTimeTxt.cameras = [camHUD];
			add(songPosBG);
			add(songPosBar);
			add(songName);
			add(songTimeTxt);





		

	}

	var debugNum:Int = 0;

	public function generateSong(?dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm * songspeed);

		curSong = songData.song;
		if (vocals == null){
			if (SONG.needsVoices)
				{
					try{
						vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					}catch(e){
						SONG.needsVoices = false;
						showTempmessage("Song needs voices but none found! Automatically disabled");
						vocals = new FlxSound();
					}
			}
			else
				vocals = new FlxSound();
		}

		trace('Inst - ${FlxG.sound.music}');
		trace('Voices - ${vocals}');
		FlxG.sound.list.add(vocals);
		if (notes == null) 
			notes = new FlxTypedGroup<Note>();
		
		notes.clear();
		add(notes);
		Note.lastNoteID = -1;

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;


		// Per song offset check
		
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			if(sectionStart && daBeats < sectionStartPoint){
				daBeats++;
				continue;
			}

			var mn:Int = keyAmmo[mania];
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			var dataForThisSection:Array<Int> = [];
			var randomDataForThisSection:Array<Int> = [];
			var fullrandomlastnotedata:Array<Int> = [];
			var RandomNoteData:Int = FlxG.random.int(0, mn - 1);
			//var maxNoteData:Int = 3;
			switch (mania) //sets up the max data for each section based on mania
			{
				case 0: 
					dataForThisSection = [0,1,2,3];
				case 1: 
					dataForThisSection = [0,1,2,3,4,5];
				case 2: 
					dataForThisSection = [0,1,2,3,4,5,6];
				case 3: 
					dataForThisSection = [0,1,2,3,4,5,6,7,8];
				case 4:
					dataForThisSection = [0,1,2,3,4];
				case 5:
					dataForThisSection = [0,1,2,3,4,5,6,7];
				case 6:
					dataForThisSection = [0];
				case 7:
					dataForThisSection = [0,1];
				case 8:
					dataForThisSection = [0,1,2];
				case 9:
					dataForThisSection = [0,1,2,3,4,5,6,7,8,9];
				case 10:
					dataForThisSection = [0,1,2,3,4,5,6,7,8,9,10];
				case 11:
					dataForThisSection = [0,1,2,3,4,5,6,7,8,9,10,11];
				case 12:
					dataForThisSection = [0,1,2,3,4,5,6,7,8,9,10,11,12];
			}
			if (randomnote == 3)
			{
				for (i in 0...dataForThisSection.length) //point of this is to randomize per section, so each lane of notes will move together, its kinda hard to explain, but it give good charts so idc
				{
					var number:Int = dataForThisSection[FlxG.random.int(0, dataForThisSection.length - 1)];
					dataForThisSection.remove(number);
					randomDataForThisSection.push(number);
				}
			}

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = (songNotes[0] + FlxG.save.data.offset) / songspeed;

				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % mn);

				var gottaHitNote:Bool = section.mustHitSection;

				if ((songNotes[1] >= mn && !ADOFAIMode) || (songNotes[1] >= keyAmmo[SongOGmania] && ADOFAIMode))
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				// if(songNotes[3] != null) trace('Note type: ${songNotes[3]}');

				if (ADOFAIMode)
					daNoteData = 0;

				if (BothSide)
					{
						if (gottaHitNote)
						{
							switch(daNoteData) //did this cuz duets crash game / cause issues
							{
								case 0: 
									daNoteData = 4;
								case 1: 
									daNoteData = 5;
								case 2: 
									daNoteData = 6;
								case 3:
									daNoteData = 7;
								case 4: 
									daNoteData = 0;
								case 5: 
									daNoteData = 1;
								case 6: 
									daNoteData = 2;
								case 7:
									daNoteData = 3;
							}
						}
						else
						{
							switch(daNoteData)
							{
								case 0: 
									daNoteData = 0;
								case 1: 
									daNoteData = 1;
								case 2: 
									daNoteData = 2;
								case 3:
									daNoteData = 3;
								case 4: 
									daNoteData = 4;
								case 5: 
									daNoteData = 5;
								case 6: 
									daNoteData = 6;
								case 7:
									daNoteData = 7;
							}
						}
						if (daNoteData > 7) //failsafe
							daNoteData -= 4;
					}

				switch (randomnote)
				{
					case 1:
						if (daNoteData >= keyAmmo[SongOGmania]) //fixes duets
							gottaHitNote = !gottaHitNote;
						daNoteData = FlxG.random.int(0, mn - 1);
					case 2:
						if (daNoteData >= keyAmmo[SongOGmania]) //fixes duets
							gottaHitNote = !gottaHitNote;

						if(fullrandomlastnotedata.contains(RandomNoteData))// move note somewhere else when jack
							{
								RandomNoteData += 1;
								if(RandomNoteData == mn)
									RandomNoteData = 0;
							}
						if(fullrandomlastnotedata.contains(RandomNoteData))// move only one time wasn't very effective
							{
								RandomNoteData -= 2;
								if(RandomNoteData < 0)
									RandomNoteData += mn;
							}

						daNoteData = RandomNoteData;
						fullrandomlastnotedata.push(RandomNoteData);
						if(fullrandomlastnotedata.length > mn)
						fullrandomlastnotedata.pop();
					case 3:
						if (daNoteData >= keyAmmo[SongOGmania]) //fixes duets
							gottaHitNote = !gottaHitNote;
						daNoteData = randomDataForThisSection[daNoteData]; //per section randomization
				}
				if (BothSide)
					gottaHitNote = true; //both side

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,null,null,songNotes[3],songNotes,gottaHitNote);
				swagNote.sustainLength = songNotes[2] / songspeed;
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var lastSusNote = false; // If the last note is a sus note
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,null,songNotes[3],songNotes,gottaHitNote);
					sustainNote.scrollFactor.set();
					sustainNote.sustainLength = susLength;
					unspawnNotes.push(sustainNote);
					lastSusNote = true;

					// sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				if (onlinemod.OnlinePlayMenuState.socket == null && lastSusNote){ // Moves last sustain note so it looks right, hopefully
					unspawnNotes[Std.int(unspawnNotes.length - 1)].strumTime -= (Conductor.stepCrochet * 0.4);
				}

				// swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}

			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
		callInterp("generateSong",[]);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{

		for (i in 0...keyAmmo[mania])
		{
			// FlxG.log.add(i);
			trace('Create note ${i}');
			var babyArrow:StrumArrow = new StrumArrow(i,0, strumLine.y);

			charCall("strumNoteLoad",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteLoad",[babyArrow,player == 1]);
			babyArrow.x += Note.swagWidth[mania] * i + i;
			babyArrow.init();

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				switch(FlxG.save.data.notefade){
					case 0:FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: if (player == 0) 0.7 else 1}, 1, {ease: FlxEase.circOut});
					case 1:FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: if (player == 0) 0.7 else 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
					case 2:FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: if (player == 0) 0.7 else 1}, 1, {ease: FlxEase.circOut, startDelay: 0.25 + (0.1 * i)});
					default:FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: if (player == 0) 0.7 else 1}, 1, {ease: FlxEase.circOut, startDelay: 0.125 + (0.05 * i)});
				}
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0: 
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}
			babyArrow.animation.play('static'); 
			if(middlescroll){
				switch(player){
					case 1:{
						babyArrow.screenCenter(X);
						babyArrow.x += (Note.swagWidth[mania] * i) + i - (Note.swagWidth[mania] + (Note.swagWidth[mania] * ((keyAmmo[mania] * 0.5) - 1.5)));
					}
					case 0:
						if(mania != 3 && mania != 12)
						{
							if(i < Math.floor(keyAmmo[mania] / 2))
								babyArrow.x = (Note.swagWidth[mania] * i + i) + 25;
							else
								babyArrow.x = FlxG.width - (Note.swagWidth[mania] * (keyAmmo[mania] - i) + i) - 25;
						}
						else
						{
							if(i < Math.floor(keyAmmo[mania] / 2))
								babyArrow.x = (Note.swagWidth[mania] * i + i);
							else
								babyArrow.x = FlxG.width - (Note.swagWidth[mania] * (keyAmmo[mania] - i) + i);
						}
				}

			}
			else{
				if(mania != 3 && mania != 12)
				{
					if(player == 0)
						babyArrow.x = (Note.swagWidth[mania] * i + i) + 25;
					else
						babyArrow.x = FlxG.width - (Note.swagWidth[mania] * (keyAmmo[mania] - i) + i) - 25;
				}
				else
				{
					if(player == 0)
						babyArrow.x = (Note.swagWidth[mania] * i + i);
					else
						babyArrow.x = FlxG.width - (Note.swagWidth[mania] * (keyAmmo[mania] - i) + i);
				}
			}
			babyArrow.visible = (player == 1 || FlxG.save.data.oppStrumLine);
			if (BothSide && player == 0) babyArrow.visible = false;

			
			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			if(underlay != null && FlxG.save.data.undlaSize == 0 && i == 0 && player == 1){
				underlay.x = babyArrow.x;
			}

			strumLineNotes.add(babyArrow);
			charCall("strumNoteAdd",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteAdd",[babyArrow,player == 1]);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			canPause = false;

			if (!startTimer.finished)
				startTimer.active = false;
			#if windows
			// Updating Discord Rich Presence.
			if(!finished)
			{
				DiscordClient.changePresence(
				detailsPausedText
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: " + songScore
				+ " | Misses: " + misses, iconRPC,false,null,'pause-' + LargeiconRPC);
			}
			#end
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			canPause = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(
					detailsText
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: " + songScore
					+ " | Misses: " + misses, iconRPC, true,
					songLength - Conductor.songPosition,LargeiconRPC);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC,false,0,LargeiconRPC);
			}
			#end
		}

		super.closeSubState();
	}
	

	var resyncCount:Int = 0;
	function resyncVocals():Void
	{
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time / songspeed;
		if(SONG.needsVoices){
			vocals.pause();
			vocals.time = FlxG.sound.music.time;
			vocals.play();
		}

		@:privateAccess
		{
			#if desktop
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			#end
		}
		resyncCount++;
		#if windows
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(
			detailsText
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: " + songScore
			+ " | Misses: " + misses, iconRPC, true,
			songLength - Conductor.songPosition,LargeiconRPC);
		#end
	}
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;
	var finished = false;

	function finishSong(?win=true):Void{
		
		updateTime = false;
		FlxG.camera.zoom = defaultCamZoom;
		camHUD.zoom = 1;
		if (finished) return;
		finished = true;
		PlayState.dadShow = true; // Reenable this to prevent issues later
		canPause = false;
		this.paused = true;
		FlxG.sound.music.pause();
		this.vocals.pause();
		FlxG.sound.music.volume = 0;
		this.vocals.volume = 0;
		openSubState(new FinishSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,win));
	}

	var songLengthTxt = "N/A";

	public var interpCount:Int = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		try{
		perfectMode = false;
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
			if (combo > maxCombo)
				maxCombo = combo;
		}
		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		PlayState.canUseAlts = (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim);

		super.update(elapsed);
		callInterp("update",[elapsed]);

		scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.text = "Score: " + songScore;
		// if(FlxG.save.data.songInfo == 0) scoreTxt.x = scoreTxtX - scoreTxt.text.length;
		if (updateTime) songTimeTxt.text = FlxStringUtil.formatTime(Math.floor(Conductor.songPosition / 1000), false) + "/" + songLengthTxt;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if(!practiceMode){
			var iconOffset:Int = 26;
			if(!QuickOptionsSubState.getSetting("Swap characters"))
			{
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - (iconOffset));
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - (iconP2.width - iconOffset));
				iconP1.updateAnim(healthBar.percent);
				iconP2.updateAnim(100 - healthBar.percent);
			}
			else
			{
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01) - (iconOffset));
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01) - (iconP2.width - iconOffset));
				iconP1.updateAnim(100 - healthBar.percent);
				iconP2.updateAnim(healthBar.percent);
			}
		}
		// else{
		// 	iconP1.y = playerStrums.members[0].y - (iconP1.height / 2);
		// 	iconP2.y = playerStrums.members[0].y - (iconP2.height / 2);
		// }

		if (health > 2)
			health = 2;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */
		testanimdebug();

		if (startingSong && handleTimes)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else if (handleTimes)
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.game.ticks - previousFrameTime;
			Conductor.rawPosition = FlxG.sound.music.time;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			curSection = Std.int(curStep / 16);
			if(moveCamera){

				var locked = (!FlxG.save.data.camMovement || camLocked || PlayState.SONG.notes[curSection].sectionNotes[0] == null);
				if (PlayState.SONG.notes[curSection] != null) followChar((PlayState.SONG.notes[curSection].mustHitSection ? 0 : 1),locked);
			}
		}
		if(FlxG.save.data.animDebug){
			Overlay.debugVar += '\nResync count:${resyncCount}'
				+'\nSong Time thing:${FlxG.sound.music.time / songspeed + " / " + songLength}'
				+'\nAssumed Section:${curSection}'
				+'\nHealth:${health}'
				+'\nScript Count:${interpCount}';
		}
		if ((FlxG.save.data.camMovement || !camLocked ) && camBeat){
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			
		}else if (camBeat){
			FlxG.camera.zoom = defaultCamZoom;
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			// FlxG.camera.zoom = 0.95;
			// camHUD.zoom = 1;
		}
		switch(curSong){
			case 'Fresh':
				switch (curBeat)
				{
					case 16:
						camZooming = true;
						gfSpeed = 2;
					case 48:
						gfSpeed = 1;
					case 80:
						gfSpeed = 2;
					case 112:
						gfSpeed = 1;
					case 163:
						// FlxG.sound.music.stop();
						// FlxG.switchState(new TitleState());
				}
			case 'Bopeebo':
				switch (curBeat)
				{
					case 128, 129, 130:
						vocals.volume = 0;
						// FlxG.sound.music.stop();
						// FlxG.switchState(new PlayState());
				}
		}

		if (health <= 0 && !hasDied && !ChartingState.charting){
			if(practiceMode) {
					hasDied = true;
					// practiceText.text = "Practice Mode; Score won't be saved";
					// practiceText.screenCenter(X);
					FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
				} else finishSong(false);
		}
 		if (FlxG.save.data.resetButton)
		{
			if(FlxG.keys.justPressed.R)
				finishSong(false);
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500 * songspeed)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
		}
		#end

		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (FlxG.sound.music.time / songspeed >= songLength - 250)
				{
					if(unspawnNotes.length == 0 && notes.length == 0)
						trace("we're fuckin ending the song");
					else
						trace("there still note left but we're fuckin ending the song anyway");
					endingSong = true;
					new FlxTimer().start(0.25, function(timer)
					{
						endSong();
					});
				}
			}
		}
		// if (addNotes && FlxG.random.int(0,1000) > 700){
		// 	var note:Array<Dynamic> = [Conductor.songPosition + FlxG.random.int(400,1000),FlxG.random.int(0,3),0];
		// 	var swagNote:Note = new Note(note[0], note[1], null,null,null,0,note,true);
		// 	swagNote.scrollFactor.set(0, 0);				

		// 	unspawnNotes.push(swagNote);
		// 	notes.add(swagNote);


		// 	swagNote.mustPress = true;

		// 	if (swagNote.mustPress)
		// 	{
		// 		swagNote.x += FlxG.width / 2; // general offset
		// 	}
		// }


		handleInput();
		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene)
			keyShit();
	#if !debug
	}catch(e){MainMenuState.handleError('Caught "update" crash: ${e.message}\n ${e.stack}');}
	#end
}

	public function followChar(?char:Int = 0,?locked:Bool = true){
		if(swappedChars) char = (char == 1 ? 0 : 1);
		focusedCharacter = char;
		if(locked || cameraPositions[char] == null){
			camIsLocked = true;
			camFollow.x = lockedCamPos[0] + additionCamPos[0];
			camFollow.y = lockedCamPos[1] + additionCamPos[1];
			return; 
		}
		camFollow.x = cameraPositions[char][0] + additionCamPos[0];
		camFollow.y = cameraPositions[char][1] + additionCamPos[1];


	}
	public function getDefaultCamPos():Array<Float>{
		if(camIsLocked){
			return lockedCamPos; 
		}
		return cameraPositions[focusedCharacter];
	}
	public var cameraPositions:Array<Array<Float>> = [];
	public var camLocked:Bool = false;
	public var camIsLocked:Bool = false;
	public var defLockedCamPos:Array<Float> = [720, 500];
	public var lockedCamPos:Array<Float> = [720, 500];
	public var additionCamPos:Array<Float> = [0,0];
	public var focusedCharacter:Int = 0;
	public function updateCharacterCamPos(){ // Resets all camera positions
		var offsetX = boyfriend.getMidpoint().x - 100 + boyfriend.camX;
		var offsetY = boyfriend.getMidpoint().y - 100 + boyfriend.camY;


		switch (curStage)
		{
			case 'limo':
				offsetX -= 300;
			case 'mall':
				offsetY -= 200;
		}
		cameraPositions = [[offsetX,offsetY]];
		var offsetX = dad.getMidpoint().x + 150 + dad.camX;
		var offsetY = dad.getMidpoint().y - 100 + dad.camY;
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		switch (dad.curCharacter)
		{
			case 'mom':
				offsetY = dad.getMidpoint().y;
			case 'senpai':
				offsetY = dad.getMidpoint().y - 430;
				offsetX = dad.getMidpoint().x - 100;
			case 'senpai-angry':
				offsetY = dad.getMidpoint().y - 430;
				offsetX = dad.getMidpoint().x - 100;
		}
		cameraPositions.push([offsetX,offsetY]);
		cameraPositions.push([gf.getMidpoint().x,gf.getMidpoint().y - 100]);
		lockedCamPos = defLockedCamPos;
	}


	function endSong():Void
	{
		// if (!loadRep)
		// 	rep.SaveReplay(saveNotes);
		// else
		// {
		// 	FlxG.save.data.botplay = false;
		// 	FlxG.save.data.scrollSpeed = 1;
		// 	downscroll = false;
		// }

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		#if !switch
		if (SONG.validScore && stateType != 2 && stateType != 4)
		{
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
		}
		#end

		charCall("endSong",[]);
		callInterp("endSong",[]);
		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());
					sectionStart = false;


					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					// difficulty = if (songDiff != "normal") '-${songDiff}';
					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					if (SONG.song.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				// trace('WENT BACK TO FREEPLAY??');
				// Switches to the win state
				// openSubState(new FinishSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,true));
				finishSong(true);
			}
		}
	}
	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var lastNoteSplash:NoteSplash;
	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			vocals.volume = FlxG.save.data.voicesVol;
			var placement:String = Std.string(combo);
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			var daRating = daNote.rating;
			if(daRating == "miss") daRating = "shit";
			if(daNote.isSustainNote && FlxG.save.data.scoresystem == 4)
				daRating = "sick";

			switch(daRating.toLowerCase())
			{
				case 'shit':
					score = -300;
					// combo = 0;
					// misses++; A shit should not equal a miss
					health -= 0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
					if (FlxG.save.data.noteSplash){
						var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
						a.setupNoteSplash(playerStrums.members[daNote.noteData], daNote.noteData);
						lastNoteSplash = a;
						grpNoteSplashes.add(a);
					}
			}
			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			var rating:FlxSprite = new FlxSprite(); // Todo, load sprites before song
			
			// if (daRating != 'shit' || daRating != 'bad')
			// {
			switch(FlxG.save.data.scoresystem)
			{
				case 0: songScore += Math.round(score * songspeed); //FNF
				case 1: songScore += Math.round(score + (score * ((combo * songspeed) / 25))); //Osu!
				case 2: songScore += Math.round((1000000 / bfnoteamount) * (score / 350)); //Osu!mania
				case 3: songScore += Math.round(score * ScoreMultiplier * songspeed); //FF
				case 4: songScore += Math.round(score * combo * songspeed); //Stupid
			}
			switch(FlxG.save.data.altscoresystem)
			{
				case 0: altsongScore += 1; //:shrug:
				case 1: altsongScore += Math.round(score * songspeed); //FNF
				case 2: altsongScore += Math.round(score + (score * ((combo * songspeed) / 25))); //Osu!
				case 3: altsongScore += Math.round((1000000 / bfnoteamount) * (score / 350)); //Osu!mania
				case 4: altsongScore += Math.round(score * ScoreMultiplier * songspeed); //FF
				case 5: altsongScore += Math.round(score * combo * songspeed); //Stupid
			}
			songScoreDef += ConvertScore.convertScore(noteDiff);
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
			if(!FlxG.save.data.noterating) return;
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			rating.loadGraphic(Paths.image(daRating));
			if(middlescroll)
				rating.x = playerStrums.members[0].x - (playerStrums.members[0].width);
			else if(!swappedChars)
				rating.x = playerStrums.members[0].x - 100;
			else
				rating.x = playerStrums.members[playerStrums.members.length - 1].x + (playerStrums.members[playerStrums.members.length - 1].width);
			rating.y = playerStrums.members[0].y + (playerStrums.members[0].height * 0.5);
			if(!middlescroll) rating.y -= 50;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff / songspeed, 3);
			if(FlxG.save.data.botplay) msTiming = 0;							   

			// if (currentTimingShown != null)
			// 	remove(currentTimingShown);

			var currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit':
					currentTimingShown.color = FlxColor.RED;
				case 'bad':
					currentTimingShown.color = FlxColor.ORANGE;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms " + (if((Conductor.songPosition - daNote.strumTime) > 0) "A" else "B");
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			add(currentTimingShown);
			// var comboSpr:FlxSprite = null;
			// comboSpr = new FlxSprite().loadGraphic(Paths.image('combo'));
			// comboSpr.screenCenter();
			// comboSpr.x = rating.x;
			// comboSpr.y = rating.y + 100;
			// comboSpr.acceleration.y = 600;
			// comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = (playerStrums.members[daNote.noteData].x + (playerStrums.members[daNote.noteData].width * 0.5)) - (currentTimingShown.width * 0.5);
			currentTimingShown.y = daNote.y + (daNote.height * 0.5);
			currentTimingShown.acceleration.y = -200;
			currentTimingShown.velocity.y = 140;
	
			// comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += FlxG.random.int(-20, 20);
			currentTimingShown.updateHitbox();
			add(rating);
	

			rating.setGraphicSize(Std.int(rating.width * 0.3));
			rating.antialiasing = true;
			// comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			// comboSpr.antialiasing = true;
			// comboSpr.updateHitbox();
			rating.updateHitbox();
			currentTimingShown.cameras = rating.cameras = [camHUD];
			// comboSpr.cameras = [camHUD];
			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			// if (comboSplit.length <= 2)
			// 	seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol! // nah

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			var comboSize = 1.20 - (seperatedScore.length * 0.1);

			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				// numScore.screenCenter();
				if(middlescroll)
					numScore.x = playerStrums.members[playerStrums.members.length - 1].x + (playerStrums.members[playerStrums.members.length - 1].width) + ((43 * comboSize) * daLoop);
				else
					numScore.x = rating.x + ((43 * comboSize) * daLoop);

				if(!middlescroll && !swappedChars && comboSplit.length >= 4) numScore.x -= numScore.width / 2;
				numScore.y = rating.y;
				if(!middlescroll) numScore.y += 50;
				numScore.cameras = rating.cameras;

				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int((numScore.width * comboSize) * 0.5));

				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				// if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}

			FlxTween.tween(rating, {alpha: 0}, 0.3, {
				startDelay: Conductor.crochet * 0.001,
				onComplete: function(tween:FlxTween)
				{
					rating.destroy();
				}
			});
			FlxTween.tween(currentTimingShown, {alpha: 0,y:currentTimingShown.y - 60}, 0.8, {
				onComplete: function(tween:FlxTween)
				{
					currentTimingShown.destroy();
				},
				startDelay: Conductor.crochet * 0.001,
			});

			/* FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			}); */
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	
		private function fromBool(input:Bool):Int{
			if (input) return 1;
			return 0; 
		}
		private function fromInt(?input:Int = 0):Bool{
			return (input == 1);
		}


	// Custom input handling

	function setInputHandlers(){
		inputMode = FlxG.save.data.inputHandler;
		var inputEngines = ["KE " + MainMenuState.kadeEngineVer,"SE"];
		// if (onlinemod.OnlinePlayMenuState.socket != null && inputMode != 0) {inputMode = 0;trace("Loading with non-kade in online. Forcing kade!");} // This is to prevent input differences between clients
		trace('Using ${inputMode}');
		switch(inputMode){
			case 0:
				handleInput = kadeInput; // I believe this is for Dad
				doKeyShit = kadeKeyShit; // I believe this is for Boyfriend
				goodNoteHit = kadeGoodNote;
			case 1:
				handleInput = kadeBRInput; // I believe this is for Dad
				doKeyShit = kadeBRKeyShit; // I believe this is for Boyfriend
				goodNoteHit = kadeBRGoodNote;
			default:
				MainMenuState.handleError('${inputMode} is not a valid input! Please change your input mode!');

		}
		inputEngineName = if(inputEngines[inputMode] != null) inputEngines[inputMode] else "Unspecified";
		// }
		// handleInput = kadeInput;
		// doKeyShit = kadeKeyShit; // Todo, add multiple input options

	}
	dynamic function handleInput(){MainMenuState.handleError("I can't handle input for some reason, Please report this!");}
	public function DadStrumPlayAnim(id:Int) {
		var spr:FlxSprite= strumLineNotes.members[id];
		if(spr != null) {
			spr.animation.play('confirm', true);
			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				switch(mania)
				{
					case 0: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 1: 
						spr.offset.x -= 16;
						spr.offset.y -= 16;
					case 2: 
						spr.offset.x -= 15;
						spr.offset.y -= 15;
					case 3: 
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 4: 
						spr.offset.x -= 18;
						spr.offset.y -= 18;
					case 5: 
						spr.offset.x -= 20;
						spr.offset.y -= 20;
					case 6: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 7: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 8:
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 9:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 10:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 11:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 12:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
				}
			}
			else
				spr.centerOffsets();
		}
	}
	public function BFStrumPlayAnim(id:Int) {
		var spr:FlxSprite= playerStrums.members[id];
		if(spr != null) {
			spr.animation.play('confirm', true);
			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				switch(mania)
				{
					case 0: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 1: 
						spr.offset.x -= 16;
						spr.offset.y -= 16;
					case 2: 
						spr.offset.x -= 15;
						spr.offset.y -= 15;
					case 3: 
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 4: 
						spr.offset.x -= 18;
						spr.offset.y -= 18;
					case 5: 
						spr.offset.x -= 20;
						spr.offset.y -= 20;
					case 6: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 7: 
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 8:
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					case 9:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 10:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 11:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
					case 12:
						spr.offset.x -= 22;
						spr.offset.y -= 22;
				}
			}
			else
				spr.centerOffsets();
		}
	}


	private function keyShit():Void
		{doKeyShit();}
	private dynamic function doKeyShit():Void
		{MainMenuState.handleError("I can't handle key inputs? Please report this!");}



	function badNoteHit():Void {
		var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		for (i in 0...controlArray.length) {
			if(controlArray[i]) noteMiss(i,null);
		}
	}

// Vanilla Kade
	public var acceptInput = true;
	function kadeInput(){
		if (generatedMusic)
			{
				var _scrollSpeed = scrollspeed; // Probably better to calculate this beforehand
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						daNote.active = true;
					}
					// if (!daNote.modifiedByLua) Modcharts don't work, this check is useless
					// 	{
						if(daNote.updateY)
						{
							if (downscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * ((Conductor.songPosition - daNote.strumTime) / songspeed) * _scrollSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * ((Conductor.songPosition - daNote.strumTime) / songspeed) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height * 0.5;
	
									// Only clip sustain notes when properly hit
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth[mania] / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth[mania] / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								}
							}else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * ((Conductor.songPosition - daNote.strumTime) / songspeed) * _scrollSpeed);
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * ((Conductor.songPosition - daNote.strumTime) / songspeed) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height * 0.5;
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth[mania] / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth[mania] / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								}
							}
						}
		
					if (daNote.skipNote) return;
					if (dadShow && !daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;
						if (!p2canplay){
							PlayState.canUseAlts = (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim);
							// switch (Math.abs(daNote.noteData))
							// {
							// 	case 2:
							// 		dad.playAnim('singUP', true);
							// 	case 3:
							// 		dad.playAnim('singRIGHT', true);
							// 	case 1:
							// 		dad.playAnim('singDOWN', true);
							// 	case 0:
							// 		dad.playAnim('singLEFT', true);
							// }
							
							// if (FlxG.save.data.cpuStrums)
							// {
							// 	DadStrumPlayAnim(daNote.noteData);
							// }
							daNote.hit(1,daNote);
							callInterp("noteHitDad",[dad,daNote]);
						}

						dad.holdTimer = 0;
						if (dad.useVoices){dad.voiceSounds[daNote.noteData].play(1);dad.voiceSounds[daNote.noteData].time = 0;vocals.volume = 0;}else if (SONG.needsVoices) vocals.volume = 1;

	
						daNote.active = false;


						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					} else if (!daNote.mustPress && daNote.wasGoodHit && !dadShow && SONG.needsVoices){
						daNote.active = false;
						vocals.volume = 0;
						daNote.kill();
						notes.remove(daNote, true);
					}

					if (daNote.mustPress)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					
					

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if (daNote.mustPress && daNote.tooLate )
					{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							else if (!daNote.shouldntBeHit)
							{
								health += SONG.noteMetadata.tooLateHealth;
								vocals.volume = 0;
								noteMiss(daNote.noteData, daNote);
							}
		
							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
						}
					
				});
			}
	}
 	private function kadeKeyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				switch(mania)
				{
					case 0: 
						hold = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
						press = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];
						release = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
					case 1: 
						hold = [controls.L1, controls.D1, controls.R1, controls.L2, controls.U1, controls.R2];
						press = [
							controls.L1_P,
							controls.D1_P,
							controls.R1_P,
							controls.L2_P,
							controls.U1_P,
							controls.R2_P
						];
						release = [
							controls.L1_R,
							controls.D1_R,
							controls.R1_R,
							controls.L2_R,
							controls.U1_R,
							controls.R2_R
						];
					case 2: 
						hold = [controls.L1, controls.D1, controls.R1, controls.N4, controls.L2, controls.U1, controls.R2];
						press = [
							controls.L1_P,
							controls.D1_P,
							controls.R1_P,
							controls.N4_P,
							controls.L2_P,
							controls.U1_P,
							controls.R2_P
						];
						release = [
							controls.L1_R,
							controls.D1_R,
							controls.R1_R,
							controls.N4_R,
							controls.L2_R,
							controls.U1_R,
							controls.R2_R
						];
					case 3: 
						hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N4, controls.N5, controls.N6, controls.N7, controls.N8];
						press = [
							controls.N0_P,
							controls.N1_P,
							controls.N2_P,
							controls.N3_P,
							controls.N4_P,
							controls.N5_P,
							controls.N6_P,
							controls.N7_P,
							controls.N8_P
						];
						release = [
							controls.N0_R,
							controls.N1_R,
							controls.N2_R,
							controls.N3_R,
							controls.N4_R,
							controls.N5_R,
							controls.N6_R,
							controls.N7_R,
							controls.N8_R
						];
					case 4:
						hold = [
							controls.LEFT,
							controls.DOWN,
							controls.N4,
							controls.UP,
							controls.RIGHT
						];
						press = [
							controls.LEFT_P,
							controls.DOWN_P,
							controls.N4_P,
							controls.UP_P,
							controls.RIGHT_P
						];
						release = [
							controls.LEFT_R,
							controls.DOWN_R,
							controls.N4_R,
							controls.UP_R,
							controls.RIGHT_R
						];
					case 5:
						hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N5, controls.N6, controls.N7, controls.N8];
						press = [
							controls.N0_P,
							controls.N1_P,
							controls.N2_P,
							controls.N3_P,
							controls.N5_P,
							controls.N6_P,
							controls.N7_P,
							controls.N8_P
						];
						release = [
							controls.N0_R,
							controls.N1_R,
							controls.N2_R,
							controls.N3_R,
							controls.N5_R,
							controls.N6_R,
							controls.N7_R,
							controls.N8_R
						];
					case 6:
						hold = [FlxG.keys.pressed.ANY];
						press = [FlxG.keys.justPressed.ANY];
						release = [FlxG.keys.justReleased.ANY];
					case 7:
						hold = [controls.LEFT,controls.RIGHT];
						press = [controls.LEFT_P,controls.RIGHT_P];
						release = [controls.LEFT_R,controls.RIGHT_R];
					case 8:
						hold = [controls.LEFT,controls.N4,controls.RIGHT];
						press = [controls.LEFT_P,controls.N4_P,controls.RIGHT_P];
						release = [controls.LEFT_R,controls.N4_R,controls.RIGHT_R];
					case 9:
						hold = [
							controls.EX0,
							controls.EX1,
							controls.EX2,
							controls.EX3,
							controls.EX5,
							controls.EX6,
							controls.EX8,
							controls.EX9,
							controls.EX10,
							controls.EX11
						];
						press = [
							controls.EX0_P,
							controls.EX1_P,
							controls.EX2_P,
							controls.EX3_P,
							controls.EX5_P,
							controls.EX6_P,
							controls.EX8_P,
							controls.EX9_P,
							controls.EX10_P,
							controls.EX11_P
						];
						release = [
							controls.EX0_R,
							controls.EX1_R,
							controls.EX2_R,
							controls.EX3_R,
							controls.EX5_R,
							controls.EX6_R,
							controls.EX8_R,
							controls.EX9_R,
							controls.EX10_R,
							controls.EX11_R
						];
					case 10:
						hold = [
							controls.EX0,
							controls.EX1,
							controls.EX2,
							controls.EX3,
							controls.EX5,
							controls.N4,
							controls.EX6,
							controls.EX8,
							controls.EX9,
							controls.EX10,
							controls.EX11
						];
						press = [
							controls.EX0_P,
							controls.EX1_P,
							controls.EX2_P,
							controls.EX3_P,
							controls.EX5_P,
							controls.N4_P,
							controls.EX6_P,
							controls.EX8_P,
							controls.EX9_P,
							controls.EX10_P,
							controls.EX11_P
						];
						release = [
							controls.EX0_R,
							controls.EX1_R,
							controls.EX2_R,
							controls.EX3_R,
							controls.EX4_R,
							controls.EX5_R,
							controls.N4_R,
							controls.EX6_R,
							controls.EX7_R,
							controls.EX8_R,
							controls.EX9_R,
							controls.EX10_R,
							controls.EX11_R
						];
					case 11:
						hold = [
							controls.EX0,
							controls.EX1,
							controls.EX2,
							controls.EX3,
							controls.EX4,
							controls.EX5,
							controls.EX6,
							controls.EX7,
							controls.EX8,
							controls.EX9,
							controls.EX10,
							controls.EX11
						];
						press = [
							controls.EX0_P,
							controls.EX1_P,
							controls.EX2_P,
							controls.EX3_P,
							controls.EX4_P,
							controls.EX5_P,
							controls.EX6_P,
							controls.EX7_P,
							controls.EX8_P,
							controls.EX9_P,
							controls.EX10_P,
							controls.EX11_P
						];
						release = [
							controls.EX0_R,
							controls.EX1_R,
							controls.EX2_R,
							controls.EX3_R,
							controls.EX4_R,
							controls.EX5_R,
							controls.EX6_R,
							controls.EX7_R,
							controls.EX8_R,
							controls.EX9_R,
							controls.EX10_R,
							controls.EX11_R
						];
					case 12:
						hold = [
							controls.EX0,
							controls.EX1,
							controls.EX2,
							controls.EX3,
							controls.EX4,
							controls.EX5,
							controls.N4,
							controls.EX6,
							controls.EX7,
							controls.EX8,
							controls.EX9,
							controls.EX10,
							controls.EX11
						];
						press = [
							controls.EX0_P,
							controls.EX1_P,
							controls.EX2_P,
							controls.EX3_P,
							controls.EX4_P,
							controls.EX5_P,
							controls.N4_P,
							controls.EX6_P,
							controls.EX7_P,
							controls.EX8_P,
							controls.EX9_P,
							controls.EX10_P,
							controls.EX11_P
						];
						release = [
							controls.EX0_R,
							controls.EX1_R,
							controls.EX2_R,
							controls.EX3_R,
							controls.EX4_R,
							controls.EX5_R,
							controls.N4_R,
							controls.EX6_R,
							controls.EX7_R,
							controls.EX8_R,
							controls.EX9_R,
							controls.EX10_R,
							controls.EX11_R
						];
				}
				var holdArray:Array<Bool> = hold;
				var pressArray:Array<Bool> = press;
				var releaseArray:Array<Bool> = release;
				
		 		callInterp("keyShit",[pressArray,holdArray]);
		 		charCall("keyShit",[pressArray,holdArray]);
		 		if (!acceptInput) {holdArray = pressArray = releaseArray = [false,false,false,false];}
				// HOLDS, check for sustain notes
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
				var hitArray = [false,false,false,false,false,false,false,false,false,false,false,false,false];
				switch(mania)
				{
					case 0: 
						hitArray = [false, false, false, false];
					case 1: 
						hitArray = [false, false, false, false, false, false];
					case 2: 
						hitArray = [false, false, false, false, false, false, false];
					case 3: 
						hitArray = [false, false, false, false, false, false, false, false, false];
					case 4:
						hitArray = [false, false, false, false, false];
					case 5:
						hitArray = [false, false, false, false, false, false, false, false];
					case 6:
						hitArray = [false];
					case 7:
						hitArray = [false, false];
					case 8:
						hitArray = [false, false, false];
					case 9:
						hitArray = [false, false, false, false, false, false, false, false, false, false];
					case 10:
						hitArray = [false, false, false, false, false, false, false, false, false, false, false];
					case 11:
						hitArray = [false, false, false, false, false, false, false, false, false, false, false, false];
					case 12:
						hitArray = [false, false, false, false, false, false, false, false, false, false, false, false, false];
				}
				// PRESSES, check for note hits
				if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.skipNote) return;
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (directionList.contains(daNote.noteData))
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					});
		 
					for (note in dumbNotes)
					{
						FlxG.log.add("killing dumb ass note at " + note.strumTime);
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
		 
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		 
					var dontCheck = false;

					for (i in 0...pressArray.length)
					{
						if (pressArray[i] && !directionList.contains(i))
							dontCheck = true;
					}

					if (perfectMode)
						goodNoteHit(possibleNotes[0]);
					else if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList.contains(shit))
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								hitArray[coolNote.noteData] = true;
								if (mashViolations != 0)
									mashViolations--;
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
						}

					if(dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost)
					{
						if (mashViolations > keyAmmo[mania] * 2.5)
						{
							trace('mash violations ' + mashViolations);
							scoreTxt.color = FlxColor.RED;
							noteMiss(0,null);
						}
						else
							mashViolations++;
					}

				}
		 		callInterp("keyShitAfter",[pressArray,holdArray,hitArray]);
		 		charCall("keyShitAfter",[pressArray,holdArray,hitArray]);
				

				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true)))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idle');
				}
		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						{
							spr.animation.play('pressed');
							if(BothSide && spr.ID < 4)
								dad.playAnim(Note.noteAnimsAlt[spr.ID],true);
							else
								boyfriend.playAnim(Note.noteAnimsAlt[spr.ID],true);
						}
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 
					if (spr.animation.curAnim.name == 'confirm')
					{
						spr.centerOffsets();
						switch(mania)
						{
							case 0: 
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 1: 
								spr.offset.x -= 16;
								spr.offset.y -= 16;
							case 2: 
								spr.offset.x -= 15;
								spr.offset.y -= 15;
							case 3: 
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 4: 
								spr.offset.x -= 18;
								spr.offset.y -= 18;
							case 5: 
								spr.offset.x -= 20;
								spr.offset.y -= 20;
							case 6: 
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 7: 
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 8:
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 9:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 10:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 11:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 12:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
						}
					}
					else
						spr.centerOffsets();
				});
			}

	function kadeGoodNote(note:Note, ?resetMashViolation = true):Void
					{

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if(note.shouldntBeHit){if(note.rating != "miss" && note.rating != "shit" && note.rating != "bad") {noteMiss(note.noteData,note,true);} return;}

				// if (note.canMiss){ Disabled for now, It seemed to add to the lag and isn't even properly implemented
					
				// 	if (note.rating == "shit") return;// Lets not be a shit and count shit hits for hurt notes
				// 	noteMiss(note.noteData, note,1);
				// }


				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;


				if (mashViolations < 0)
					mashViolations = 0;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote || FlxG.save.data.scoresystem == 4)
					{
						combo++;
						popUpScore(note);
					}
					else
						totalNotesHit += 1;
					

					if(hitSound && !note.isSustainNote) FlxG.sound.play(hitSoundEff,0.75);






					// if(!loadRep && note.mustPress)
					// 	saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));
					
					if (note.noteData <= 3 && BothSide)
						{
							note.hit(1,note);
							callInterp("noteHitDad",[dad,note]);
							onlineNoteHit(note.noteID,0);
						}
					else
						{
							note.hit(0,note);
							callInterp("noteHit",[boyfriend,note]);
							onlineNoteHit(note.noteID,0);
						}
					
					note.wasGoodHit = true;
					if (boyfriend.useVoices){boyfriend.voiceSounds[note.noteData].play(1);boyfriend.voiceSounds[note.noteData].time = 0;vocals.volume = 0;}else vocals.volume = 1;
		

					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}

// "improved" kade

	function kadeBRInput(){
		if (generatedMusic)
			{
				var _scrollSpeed = scrollspeed; // Probably better to calculate this beforehand
				var strumNote:StrumArrow;
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					strumNote = (if (daNote.mustPress) playerStrums.members[Math.floor(Math.abs(daNote.noteData))] else strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))]);
					if(daNote.updateY){

						switch (downscroll){

							case true:{
								daNote.y = (strumNote.y + 0.45 * ((Conductor.songPosition - daNote.strumTime) / songspeed) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height * 0.5;
	
									// Only clip sustain notes when properly hit
									if((daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || dadShow) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth[mania] / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumNote.y + Note.swagWidth[mania] / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
										if(daNote.mustPress || !(!daNote.mustPress && !p2canplay)){

											daNote.susHit(if(daNote.mustPress)0 else 1,daNote);
											callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
										}
									}
								}
						
							}
							case false:{
								daNote.y = (strumNote.y - 0.45 * ((Conductor.songPosition - daNote.strumTime) / songspeed) * _scrollSpeed);
								if(daNote.isSustainNote)
								{
									daNote.y -= daNote.height / 2;
									// (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) &&
									if((daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || dadShow) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth[mania] / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumNote.y + Note.swagWidth[mania] / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
										if(daNote.mustPress || !(!daNote.mustPress && !p2canplay)){
											daNote.susHit(if(daNote.mustPress)0 else 1,daNote);
											callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
										}
									}
								}
							}
						}
					}
					if (daNote.skipNote) return;
		
	
					if ((daNote.mustPress || !daNote.wasGoodHit) && daNote.lockToStrum){
						daNote.visible = strumNote.visible;
						if(daNote.updateX) daNote.x = strumNote.x + (strumNote.width * 0.5);
						if(!daNote.isSustainNote && daNote.updateAngle) daNote.angle = strumNote.angle;
						if(daNote.updateAlpha) daNote.alpha = strumNote.alpha;

					}
					if(daNote.mustPress && daNote.tooLate){
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
						else if (!daNote.shouldntBeHit)
						{
							health += SONG.noteMetadata.tooLateHealth;
							noteMiss(daNote.noteData, daNote);
						}
	
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}


					// if (daNote.mustPress)
					// {
					// 	daNote.visible = playerStrums.members[Std.int(daNote.noteData)].visible;
					// 	if(!daNote.skipXAdjust){
					// 		daNote.x = playerStrums.members[Std.int(daNote.noteData)].x;
					// 		if (daNote.isSustainNote)
					// 			daNote.x += daNote.width / 2 + 17;
					// 	}
					// 	if (!daNote.isSustainNote)
					// 		daNote.angle = playerStrums.members[Std.int(daNote.noteData)].angle;
					// 	daNote.alpha = playerStrums.members[Std.int(daNote.noteData)].alpha;



					// }
					// else if (!daNote.wasGoodHit)
					// {
					// 	daNote.visible = strumLineNotes.members[Std.int(daNote.noteData)].visible;
					// 	if(!daNote.skipXAdjust){
					// 		daNote.x = strumLineNotes.members[Std.int(daNote.noteData)].x;
					// 		if (daNote.isSustainNote)
					// 			daNote.x += daNote.width / 2 + 17;
					// 	}
						
					// 	if (!daNote.isSustainNote)
					// 		daNote.angle = strumLineNotes.members[Std.int(daNote.noteData)].angle;
					// 	daNote.alpha = strumLineNotes.members[Std.int(daNote.noteData)].alpha;
					// }



					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

					
				});
			}
	}
 	private function kadeBRKeyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				switch(mania)
				{
					case 0: 
						hold = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
						press = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
					];
						release = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
					];
					case 1: 
						hold = [controls.L1, controls.D1, controls.R1, controls.L2, controls.U1, controls.R2];
						press = [
							controls.L1_P,
							controls.D1_P,
							controls.R1_P,
							controls.L2_P,
							controls.U1_P,
							controls.R2_P
						];
						release = [
							controls.L1_R,
							controls.D1_R,
							controls.R1_R,
							controls.L2_R,
							controls.U1_R,
							controls.R2_R
						];
					case 2: 
						hold = [controls.L1, controls.D1, controls.R1, controls.N4, controls.L2, controls.U1, controls.R2];
						press = [
							controls.L1_P,
							controls.D1_P,
							controls.R1_P,
							controls.N4_P,
							controls.L2_P,
							controls.U1_P,
							controls.R2_P
						];
						release = [
							controls.L1_R,
							controls.D1_R,
							controls.R1_R,
							controls.N4_R,
							controls.L2_R,
							controls.U1_R,
							controls.R2_R
						];
					case 3: 
						hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N4, controls.N5, controls.N6, controls.N7, controls.N8];
						press = [
							controls.N0_P,
							controls.N1_P,
							controls.N2_P,
							controls.N3_P,
							controls.N4_P,
							controls.N5_P,
							controls.N6_P,
							controls.N7_P,
							controls.N8_P
						];
						release = [
							controls.N0_R,
							controls.N1_R,
							controls.N2_R,
							controls.N3_R,
							controls.N4_R,
							controls.N5_R,
							controls.N6_R,
							controls.N7_R,
							controls.N8_R
						];
					case 4:
						hold = [controls.LEFT, controls.DOWN, controls.N4, controls.UP, controls.RIGHT];
						press = [
							controls.LEFT_P,
							controls.DOWN_P,
							controls.N4_P,
							controls.UP_P,
							controls.RIGHT_P
						];
						release = [
							controls.LEFT_R,
							controls.DOWN_R,
							controls.N4_R,
							controls.UP_R,
							controls.RIGHT_R
						];
					case 5:
						hold = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N5, controls.N6, controls.N7, controls.N8];
						press = [
							controls.N0_P,
							controls.N1_P,
							controls.N2_P,
							controls.N3_P,
							controls.N5_P,
							controls.N6_P,
							controls.N7_P,
							controls.N8_P
						];
						release = [
							controls.N0_R,
							controls.N1_R,
							controls.N2_R,
							controls.N3_R,
							controls.N5_R,
							controls.N6_R,
							controls.N7_R,
							controls.N8_R
						];
					case 6:
						hold = [FlxG.keys.pressed.ANY];
						press = [FlxG.keys.justPressed.ANY];
						release = [FlxG.keys.justReleased.ANY];
					case 7:
						hold = [controls.LEFT,controls.RIGHT];
						press = [controls.LEFT_P,controls.RIGHT_P];
						release = [controls.LEFT_R,controls.RIGHT_R];
					case 8:
						hold = [controls.LEFT,controls.N4,controls.RIGHT];
						press = [controls.LEFT_P,controls.N4_P,controls.RIGHT_P];
						release = [controls.LEFT_R,controls.N4_R,controls.RIGHT_R];
						case 9:
							hold = [
								controls.EX0,
								controls.EX1,
								controls.EX2,
								controls.EX3,
								controls.EX5,
								controls.EX6,
								controls.EX8,
								controls.EX9,
								controls.EX10,
								controls.EX11
							];
							press = [
								controls.EX0_P,
								controls.EX1_P,
								controls.EX2_P,
								controls.EX3_P,
								controls.EX5_P,
								controls.EX6_P,
								controls.EX8_P,
								controls.EX9_P,
								controls.EX10_P,
								controls.EX11_P
							];
							release = [
								controls.EX0_R,
								controls.EX1_R,
								controls.EX2_R,
								controls.EX3_R,
								controls.EX5_R,
								controls.EX6_R,
								controls.EX8_R,
								controls.EX9_R,
								controls.EX10_R,
								controls.EX11_R
							];
						case 10:
							hold = [
								controls.EX0,
								controls.EX1,
								controls.EX2,
								controls.EX3,
								controls.EX5,
								controls.N4,
								controls.EX6,
								controls.EX8,
								controls.EX9,
								controls.EX10,
								controls.EX11
							];
							press = [
								controls.EX0_P,
								controls.EX1_P,
								controls.EX2_P,
								controls.EX3_P,
								controls.EX5_P,
								controls.N4_P,
								controls.EX6_P,
								controls.EX8_P,
								controls.EX9_P,
								controls.EX10_P,
								controls.EX11_P
							];
							release = [
								controls.EX0_R,
								controls.EX1_R,
								controls.EX2_R,
								controls.EX3_R,
								controls.EX4_R,
								controls.EX5_R,
								controls.N4_R,
								controls.EX6_R,
								controls.EX7_R,
								controls.EX8_R,
								controls.EX9_R,
								controls.EX10_R,
								controls.EX11_R
							];
						case 11:
							hold = [
								controls.EX0,
								controls.EX1,
								controls.EX2,
								controls.EX3,
								controls.EX4,
								controls.EX5,
								controls.EX6,
								controls.EX7,
								controls.EX8,
								controls.EX9,
								controls.EX10,
								controls.EX11
							];
							press = [
								controls.EX0_P,
								controls.EX1_P,
								controls.EX2_P,
								controls.EX3_P,
								controls.EX4_P,
								controls.EX5_P,
								controls.EX6_P,
								controls.EX7_P,
								controls.EX8_P,
								controls.EX9_P,
								controls.EX10_P,
								controls.EX11_P
							];
							release = [
								controls.EX0_R,
								controls.EX1_R,
								controls.EX2_R,
								controls.EX3_R,
								controls.EX4_R,
								controls.EX5_R,
								controls.EX6_R,
								controls.EX7_R,
								controls.EX8_R,
								controls.EX9_R,
								controls.EX10_R,
								controls.EX11_R
							];
						case 12:
							hold = [
								controls.EX0,
								controls.EX1,
								controls.EX2,
								controls.EX3,
								controls.EX4,
								controls.EX5,
								controls.N4,
								controls.EX6,
								controls.EX7,
								controls.EX8,
								controls.EX9,
								controls.EX10,
								controls.EX11
							];
							press = [
								controls.EX0_P,
								controls.EX1_P,
								controls.EX2_P,
								controls.EX3_P,
								controls.EX4_P,
								controls.EX5_P,
								controls.N4_P,
								controls.EX6_P,
								controls.EX7_P,
								controls.EX8_P,
								controls.EX9_P,
								controls.EX10_P,
								controls.EX11_P
							];
							release = [
								controls.EX0_R,
								controls.EX1_R,
								controls.EX2_R,
								controls.EX3_R,
								controls.EX4_R,
								controls.EX5_R,
								controls.N4_R,
								controls.EX6_R,
								controls.EX7_R,
								controls.EX8_R,
								controls.EX9_R,
								controls.EX10_R,
								controls.EX11_R
							];
				}
				var holdArray:Array<Bool> = hold;
				var pressArray:Array<Bool> = press;
				var releaseArray:Array<Bool> = release;
				
				var hitArray = [false,false,false,false,false,false,false,false,false,false,false,false,false];
				switch(mania)
				{
					case 0: 
						hitArray = [false, false, false, false];
					case 1: 
						hitArray = [false, false, false, false, false, false];
					case 2: 
						hitArray = [false, false, false, false, false, false, false];
					case 3: 
						hitArray = [false, false, false, false, false, false, false, false, false];
					case 4:
						hitArray = [false, false, false, false, false];
					case 5:
						hitArray = [false, false, false, false, false, false, false, false];
					case 6:
						hitArray = [false];
					case 7:
						hitArray = [false, false];
					case 8:
						hitArray = [false, false, false];
					case 9:
						hitArray = [false, false, false, false, false, false, false, false, false, false];
					case 10:
						hitArray = [false, false, false, false, false, false, false, false, false, false, false];
					case 11:
						hitArray = [false, false, false, false, false, false, false, false, false, false, false, false];
					case 12:
						hitArray = [false, false, false, false, false, false, false, false, false, false, false, false, false];
				}
		 		callInterp("keyShit",[pressArray,holdArray]);
		 		charCall("keyShit",[pressArray,holdArray]);
		


		 		if (!acceptInput) {holdArray = pressArray = releaseArray = [false,false,false,false];}
				// HOLDS, check for sustain notes
				if (generatedMusic && (holdArray.contains(true) || releaseArray.contains(true)))
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.mustPress && daNote.isSustainNote && daNote.canBeHit && holdArray[daNote.noteData]){ // Clip note to strumline
							if(daNote.strumTime <= Conductor.songPosition || daNote.sustainLength < 2 || !FlxG.save.data.accurateNoteSustain) // Only destroy the note when properly hit
								{goodNoteHit(daNote);return;}
							// if(Std.isOfType(daNote,HoldNote)){
							// 	var e:HoldNote = cast daNote;
							// 	daNote.clip = true;
							// }else{
								daNote.isPressed = true;
							// }
							
							daNote.susHit(0,daNote);
							callInterp("susHit",[daNote]);
						}
					});
				}
		 
				// PRESSES, check for note hits
				
				if (generatedMusic && pressArray.contains(true) /*!boyfriend.stunned && */ )
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Bool> = [false,false,false,false]; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 			var onScreenNote:Bool = false;
		 			var i = 0;
		 			var daNote:Note;
		 			while (i < notes.members.length)
					{
						daNote = notes.members[i];
						i++;
						if (daNote == null || !daNote.alive || daNote.skipNote || !daNote.mustPress) continue;

						if (!onScreenNote) onScreenNote = true;
						if (daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit && pressArray[daNote.noteData])
						{
							if (directionList[daNote.noteData])
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData){

										if (Math.abs(daNote.strumTime - coolNote.strumTime) < 5)
										{ // if it's the same note twice at < 5ms distance, just delete it
											// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
											// weell now I'm using a while instead of a forEachAlive, so fuck you

											daNote.kill();
											notes.remove(daNote, true);
											daNote.destroy();
											i--;
											break;
										}
										if (daNote.strumTime < coolNote.strumTime)
										{ // if daNote is earlier than existing note (coolNote), replace
											// This shouldn't happen due to all of the notes being arranged by strumtime, if it does, run
											possibleNotes.remove(coolNote);
											// trace('${daNote.strumTime} < ${coolNote.strumTime} 💀');
											possibleNotes.push(daNote);
											break;
										}
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList[daNote.noteData] = true;
							}
						}
						
					};
					// for (note in dumbNotes)
					// {
					// }
		 			if(onScreenNote){

						for (i in 0...possibleNotes.length) {
							hitArray[possibleNotes[i].noteData] = true;
							goodNoteHit(possibleNotes[i]);
						}
						if(!FlxG.save.data.ghost && onScreenNote){

							for (i in 0 ... pressArray.length) {
								if(pressArray[i] && !directionList[i]){
									noteMiss(i, null);
								}
							}
						}

		 			}

				}
		 		callInterp("keyShitAfter",[pressArray,holdArray,hitArray]);
		 		charCall("keyShitAfter",[pressArray,holdArray,hitArray]);
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.dadVar * 0.001 && (!holdArray.contains(true)))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idle');
				}

		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						{
							spr.animation.play('pressed');
							if(BothSide && spr.ID < 4)
								dad.playAnim(Note.noteAnimsAlt[spr.ID],true);
							else
								boyfriend.playAnim(Note.noteAnimsAlt[spr.ID],true);
						}
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 			

					if (spr.animation.curAnim.name == 'confirm')
					{
						spr.centerOffsets();
						switch(mania)
						{
							case 0: 
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 1: 
								spr.offset.x -= 16;
								spr.offset.y -= 16;
							case 2: 
								spr.offset.x -= 15;
								spr.offset.y -= 15;
							case 3: 
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 4: 
								spr.offset.x -= 18;
								spr.offset.y -= 18;
							case 5: 
								spr.offset.x -= 20;
								spr.offset.y -= 20;
							case 6: 
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 7: 
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 8:
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							case 9:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 10:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 11:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							case 12:
								spr.offset.x -= 22;
								spr.offset.y -= 22;
						}
					}
					else
						spr.centerOffsets();
				});
			}

	function kadeBRGoodNote(note:Note, ?resetMashViolation = true):Void
		{

		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);


		if(note.shouldntBeHit){noteMiss(note.noteData,note,true);return;}

		if (FlxG.save.data.npsDisplay && !note.isSustainNote)
			notesHitArray.unshift(Date.now());



		// if(logGameplay) eventLog.push({
		// 	rating:note.rating,
		// 	direction:note.noteData,
		// 	strumTime:note.strumTime,
		// 	isSustain:note.isSustainNote,
		// 	time:Conductor.songPosition
		// });
		// if (!note.wasGoodHit)
		// {
			if (!note.isSustainNote|| FlxG.save.data.scoresystem == 4)
			{
				combo++;
				popUpScore(note);
			}
			else
				totalNotesHit += 1;
			

			if(hitSound && !note.isSustainNote) FlxG.sound.play(hitSoundEff,FlxG.save.data.hitVol).x = (FlxG.camera.x) + (FlxG.width * (0.25 * note.noteData + 1));
			if (note.noteData <= 3 && BothSide)
				{
					note.hit(1,note);
					callInterp("noteHitDad",[dad,note]);
					onlineNoteHit(note.noteID,0);
				}
			else
				{
					note.hit(0,note);
					callInterp("noteHit",[boyfriend,note]);
					onlineNoteHit(note.noteID,0);
				}
			
			note.wasGoodHit = true;
			if (boyfriend.useVoices){boyfriend.voiceSounds[note.noteData].play(1);boyfriend.voiceSounds[note.noteData].time = 0;vocals.volume = 0;}else vocals.volume = 1;
			note.skipNote = true;
			note.kill();
			notes.remove(note, true);
			note.destroy();
			
			updateAccuracy();
		// }
	}
		
	inline function onlineNoteHit(noteID:Int = -1,miss:Int = 0){
		if(p2canplay)
			onlinemod.Sender.SendPacket(onlinemod.Packets.KEYPRESS, [noteID,miss,onlinecharacterID], onlinemod.OnlinePlayMenuState.socket);
	}

	public function noteMiss(direction:Int = 1, daNote:Note,?forced:Bool = false):Void
	{
		noteMissdyn(direction,daNote,forced);
	}
	dynamic function noteMissdyn(direction:Int = 1, daNote:Note,?forced:Bool = false):Void
	{
		if(daNote != null && daNote.shouldntBeHit && !forced) return;
		
		if(daNote != null && forced && daNote.shouldntBeHit){ // Only true on hurt arrows
			FlxG.sound.play(hurtSoundEff, 1);
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();

		}
		if (!boyfriend.stunned)
		{
			if(FlxG.save.data.playMisses) if (boyfriend.useMisses){FlxG.sound.play(boyfriend.missSounds[direction], 1);}else{FlxG.sound.play(vanillaHurtSounds[Math.round(Math.random() * 2)], FlxG.random.float(0.1, 0.2));}
			// FlxG.sound.play(hurtSoundEff, 1);
			health += SONG.noteMetadata.missHealth;
			// switch (direction)
			// {
			// 	case 0:
			// 		boyfriend.playAnim('singLEFTmiss', true);
			// 	case 1:
			// 		boyfriend.playAnim('singDOWNmiss', true);
			// 	case 2:
			// 		boyfriend.playAnim('singUPmiss', true);
			// 	case 3:
			// 		boyfriend.playAnim('singRIGHTmiss', true);
			// }
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if(FlxG.save.data.scoresystem != 4)combo = 0; else combo++;
			misses++;
			if(daNote != null)
				{
					if (daNote.noteData <= 3 && BothSide)
						daNote.miss(1,daNote);
					else
						daNote.miss(0,daNote);
				}
			else
				charAnim(0,"singDOWNmiss");


			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;
			altsongScore -= 10;
			if (daNote != null && daNote.shouldntBeHit) {songScore += SONG.noteMetadata.badnoteScore; health += SONG.noteMetadata.badnoteHealth; altsongScore += SONG.noteMetadata.badnoteScore; badNote += 1;} // Having it insta kill, not a good idea 
			if(daNote != null)
				callInterp("noteMiss",[boyfriend,daNote]);
			else
				callInterp("miss",[boyfriend,direction]);
			onlineNoteHit(if(daNote == null) -1 else daNote.noteID,direction + 1);




			updateAccuracy();
		}
	}













	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
			judgementCounter.text = 'Combo: ${combo}' + ${(combo < maxCombo ? ' (Max: ' + maxCombo + ')' : '')} +'\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}\nBad Note: ${badNote}\n';
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;



	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			note.rating = Ratings.CalculateRating(noteDiff);
			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note, (mashing > getKeyPresses(note)));

			}
		}


	dynamic function goodNoteHit(note:Note, ?resetMashViolation = true):Void
		{MainMenuState.handleError('I cant register any note hits!');}




	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if(FlxG.save.data.distractions){
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if(FlxG.save.data.distractions){
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if(FlxG.save.data.distractions){
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if(FlxG.save.data.distractions){
			if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
		}

	}

	function trainReset():Void
	{
		if(FlxG.save.data.distractions){
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;




	override function stepHit()
	{
		super.stepHit();
		if (handleTimes && FlxG.sound.music.time > (Conductor.songPosition * songspeed) + 20 || FlxG.sound.music.time < (Conductor.songPosition * songspeed) - 20 && generatedMusic)
		{
			resyncVocals();
		}
		try{
			callInterp("stepHit",[]);
			charCall("stepHit",[curStep]);
			for (i => v in stepAnimEvents) {
				for (anim => ifState in v) {
					var variable:Dynamic = Reflect.field(this,ifState.variable);
					var play:Bool = false;
					if (ifState.type == "contains"){
						if (ifState.value.contains(variable)){play = true;}
					}else{
						var ret:Int = Reflect.compare(variable,ifState.value);
						if (ifState.type == "equals" && ret == 0) play = true; else if (ifState.type == "more" && ret == 1) play = true; else if (ifState.type == "less" && ret == 0) play = true;
					}
					if (play){
						trace("Custom animation, Playing anim");
						switch(i){
							case 0: boyfriend.playAnim(anim);
							case 1: dad.playAnim(anim);
							case 2: gf.playAnim(anim);
						}
					}
				}
			}
			
		}catch(e){MainMenuState.handleError('A animation event caused an error ${e.message}\n ${e.stack}');}

	}
	
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();
		callInterp("beatHit",[]);
		charCall("beatHit",[curBeat]);

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}
		if (FlxG.save.data.songInfo == 0 || FlxG.save.data.songInfo == 1 || FlxG.save.data.songInfo == 3) {
			scoreTxt.screenCenter(X);
		}



		if (dad.dance_idle) {
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
				dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
				dad.playAnim('danceRight');
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm * songspeed);
			}
			// if (SONG.notes[Math.floor(curStep / 16)].scrollSpeed != null)
			// {
			// 	curScrollSpeed = SONG.notes[Math.floor(curStep / 16)].scrollSpeed;
			// }
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && dad.curCharacter != 'gf')
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (FlxG.save.data.camMovement && camBeat){
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		// if (curBeat % gfSpeed == 0)
		// {
		// 	gf.dance();
		// }
		try{
			for (i => v in beatAnimEvents) {
				for (anim => ifState in v) {
					var variable:Dynamic = Reflect.field(this,ifState.variable);
					var play:Bool = false;
					if (ifState.type == "contains"){
						if (ifState.value.contains(variable)){play = true;}
					}else{
						var ret:Int = Reflect.compare(variable,ifState.value);
						if (ifState.type == "equals" && ret == 0) play = true; else if (ifState.type == "more" && ret == 1) play = true; else if (ifState.type == "less" && ret == 0) play = true;
					}
					if (play){
						trace("Custom animation, Playing anim");
						switch(i){
							case 0: boyfriend.playAnim(anim);
							case 1: dad.playAnim(anim);
							case 2: gf.playAnim(anim);
						}
					}
				}
			}
		}catch(e){MainMenuState.handleError('A animation event caused an error ${e.message}\n ${e.stack}');}

		// if (gf.animation.curAnim.name.startsWith("dance") || gf.animation.curAnim.finished){
		// 	if (curBeat % 2 == 1){gf.playAnim('danceLeft');}
		// 	if (curBeat % 2 == 0){gf.playAnim('danceRight');}
		// } // Honestly surprised this fixed it

		// if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.dance_idle)
		// {
		// 	boyfriend.playAnim('idle');
		// }
		// if (boyfriend.dance_idle && (boyfriend.animation.curAnim.name.startsWith("dance") || boyfriend.animation.curAnim.finished)){
		// 	if (curBeat % 2 == 1){boyfriend.playAnim('danceLeft');}
		// 	if (curBeat % 2 == 0){boyfriend.playAnim('danceRight');}
		// }
		for (i => v in [boyfriend,gf,dad]) {
			if (v.dance_idle && (v.animation.curAnim.name.startsWith("dance") || v.animation.curAnim.finished)){
				if (curBeat % 2 == 1){v.playAnim('danceLeft');}
				if (curBeat % 2 == 0){v.playAnim('danceRight');}
			}else if (!v.dance_idle && !v.animation.curAnim.name.startsWith("sing"))
			{
			 v.playAnim('idle');
			}
		}




		stageShit();

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if(FlxG.save.data.distractions){
				lightningStrikeShit();
			}
		}
	}

	inline function stageShit(){
		switch (curStage)
		{
			case 'school':
				if(FlxG.save.data.distractions){
					bgGirls.dance();
				}

			case 'mall':
				if(FlxG.save.data.distractions){
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if(FlxG.save.data.distractions){
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});
		
						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
				}
			case "philly":
				if(FlxG.save.data.distractions){
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
	
						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
				}

				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if(FlxG.save.data.distractions){
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}
	}
	public function testanimdebug(){
		if (FlxG.save.data.animDebug && onlinemod.OnlinePlayMenuState.socket == null) {
			if (FlxG.keys.justPressed.ONE && boyfriend != null)
			{
				FlxG.switchState(new AnimationDebug(boyfriend.curCharacter,true,0));
			}
			if (FlxG.keys.justPressed.TWO && dad != null)
			{
				FlxG.switchState(new AnimationDebug(dad.curCharacter,false,1));
			}
			if (FlxG.keys.justPressed.THREE && gf != null)
			{
				FlxG.switchState(new AnimationDebug(gfChar,false,2));
			}
			if (FlxG.keys.justPressed.SEVEN)
			{
				songspeed = 1;
				FlxG.switchState(new ChartingState());
				sectionStart = false;
			}
		}
	}
	var curLight:Int = 0;
}