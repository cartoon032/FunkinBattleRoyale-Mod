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
import Song.MoreChar;
import WiggleEffect.WiggleEffectType;
import Shaders;
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
import flixel.sound.FlxSound;
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

#if linc_luajit
import se.handlers.SELua;
#end
import Discord.DiscordClient;
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import Xml;
import openfl.events.KeyboardEvent;
import Overlay.Console;

import hscript.Expr;
import hscript.Interp;

import TitleState.StageInfo;
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

class PlayState extends ScriptMusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var actualSongName:String = ''; // The actual song name, instead of the shit from the JSON
	public static var songDir:String = ''; // The song's directory
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Dynamic = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var songDiff:String = "";
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var marvelous:Int = 0;
	public static var MA:Float = 0;
	public static var SA:Float = 0;
	public static var badNote:Int = 0;
	public static var ghostTaps:Int = 0;
	public static var mania:Int = 0;
	public static var playermania:Int = 0;
	public static var SongOGmania:Int = 0;
	public static var Changemania:Int = -1;
	public static var keyAmmo:Array<Int> = [4, 6, 7, 9, 5, 8, 1, 2, 3, 10, 11, 12, 13, 14, 15, 16 ,17, 18, 21];
	public static var stateType = 0;
	public static var invertedChart:Bool = false;
	public static var bfnoteamountwithhurt:Int = 0;
	public static var dadnoteamountwithhurt:Int = 0;
	public static var bfnoteamount:Int = 0;
	public static var dadnoteamount:Int = 0;
	public static var ScoreMultiplier:Float = 1.0;
	public static var ScoreDivider:Float = 1.0;
	public static var RatingScore:Array<Int> = [350,350,200,0,-300];
	public static var AltRatingScore:Array<Int> = [350,350,200,0,-300];
	public static var scoretype:Array<String> = ["FNF Score","OSU! Score","Osu!Mania Score","Bal Score","Invert Bal Score","Voiid Score","Voiid Uncap Score","Stupid Score"];
	public static var onlinecharacterID:Int = 0;
	public static var dialogue:Array<String> = [];
	public static var endDialogue:Array<String> = [];

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;
	public static var underlay:FlxSprite;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var p2canplay = false;//TitleState.p2canplay

	var songLength:Float = 0;
	public var kadeEngineWatermark:FlxText;
	
	// Discord RPC variables
	public static var storyDifficultyText:String = "";
	public static var iconRPC:String = "";
	public static var iconRPCText:String = "";
	public static var LargeiconRPC:String = "";
	public static var PauseLargeiconRPC:String = "";
	public static var detailsText:String = "";
	public static var detailsPausedText:String = "";

	public var vocals:FlxSound;

	public var gfChar:String = "gf";
	public static var dad:Character;
	public static var dadArray:Array<Character> = [];
	public static var gf:Character;
	public static var boyfriend:Character;
	public static var boyfriendArray:Array<Character> = [];
	public static var ExtraChar:Array<MoreChar>;
	public static var ShouldAIPress:Array<Array<Bool>> = [[true],[true]];
	public var COOPMode:Bool = false;

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
	public var gfShow:Bool = true;
	public static var dadShow = true;
	public var _dadShow = dadShow && FlxG.save.data.dadShow;
	public static var bfShow = true;
	public var forceChartChars:Bool = false;
	public var loadChars:Bool = true;
	public static var canUseAlts:Bool = false;

	public var notes:FlxTypedGroup<Note>;
	public var eventNotes:FlxTypedGroup<Note>; // The above but doesn't need to update anything beyond the strumtime
	private var unspawnNotes:Array<Note> = [];
	public var eventLog:Array<OutNote> = [];
	public static var logGameplay:Bool = false;

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumArrow> = null;
	public var playerStrums:FlxTypedGroup<StrumArrow> = null;
	public var cpuStrums:FlxTypedGroup<StrumArrow> = null;
	public var BabyArrowCenterX:Float = 0.00;
	var canPause:Bool = true;

	private var camZooming:Bool = false;
	private var curSong:String = "";
	public static var songDifficulties:Array<String> = [];
	public var timeSinceOnscreenNote:Float = 0;

    private var lastStartTime:Float = FlxMath.MAX_VALUE_FLOAT;
	public var timerText:FlxText;
	public var timerBar:FlxSprite;

	public var health:Float = 1; //making public because sethealth doesnt work without it
	public static var combo:Int = 0;
	public static var maxCombo:Int = 0;
	public static var misses:Int = 0;
	public static var accuracy:Float = 0.00;
	var rating:FlxSprite;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

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
	public var iconP1Array:Array<HealthIcon> = [];
	public var iconP2Array:Array<HealthIcon> = [];
	public var camHUD:FlxCamera;
	public var camTOP:FlxCamera;
	public var camGame:FlxCamera;
	public var hasDied:Bool = false;
	public var canSaveScore(default,set):Bool = true; // Controls the ability for the game to save your score. Can be disabled but not re-enabled to prevent cheating
	public function set_canSaveScore(val){ // Prevents being able to enable this if it's already been disabled.
		if(!val){
			canSaveScore = false;
		}
		return canSaveScore;
	}
	public var botPlay(default,set):Bool = false;
	public function set_botPlay(val){ // Prevents botplay from being disabled to cheat
		if(val) canSaveScore = false;
		
		return botPlay = val;
	}
	var updateTime:Bool = false;


	// Note Splash group
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var songName:FlxText;
	public var songTimeTxt:FlxText;

	var talking:Bool = true;
	public static var songScore:Int = 0;
	public static var songScoreInFloat:Float = 0;
	public static var altsongScore:Float = 0;
	var songScoreDef:Int = 0;
	public var scoreTxt:FlxText;
	public var judgementCounter:FlxText;
	public var downscroll:Bool;
	public var middlescroll:Bool;
	public var scrollspeed:Float;
	public var BothSide:Bool;
	public var randomnote:Int;
	public var ADOFAIMode:Bool;
	public var MirrorMode:Int; // 1 is player 2 is Opponent

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// public static var theFunne:Bool = true;
	var inCutscene:Bool = false;
	// public static var repPresses:Int = 0;
	// public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	public var realtimeCharCam:Bool = true;
	public var moveCamera(default,set):Bool = true;
	public function set_moveCamera(v):Bool{
		if(v){
			FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		}else{
			FlxG.camera.follow(null);
		}
		return moveCamera = v;
	}
	
	public static var stage:String = "nothing";
	public static var stageInfo:StageInfo = null;
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;

	private var executeModchart = false;
	public static var stageTags:Array<String> = [];
	public static var beatAnimEvents:Map<Int,Map<String,IfStatement>>;
	public static var stepAnimEvents:Map<Int,Map<String,IfStatement>>;
	public static var hitSoundEff:Sound;
	public static var holdSoundEff:Sound;
	public static var hurtSoundEff:Sound;
	static var vanillaHurtSounds:Array<Sound> = [];
	public var inputMode:Int = 0;
	public static var inputEngineName:String = "Unspecified";
	public static var songScript:String = "";
	public static var scripts:Array<String> = [];
	public static var hsBrTools:HSBrTools;
	public static var hsBrToolsPath:String = 'assets/';
	public static var nameSpace:String = "";
	public var camBeat:Bool = true;
	var practiceMode = false;
	var errorMsg:String = "";
	public static var customDiff = "";

	public var hitSound:Bool = false;
	public var dadhitSound:Bool = false;
	
	public var holdArray:Array<Bool> = [];
	public var pressArray:Array<Bool> = [];
	public var releaseArray:Array<Bool> = [];
	public var lastPressArray:Array<Bool> = [];
	public var FalseBoolArray:Array<Bool> = [];

	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;

	public static function resetScore(){
		marvelous = 0;
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;
		badNote = 0;
		ghostTaps = 0;
		combo = 0;
		maxCombo = 0;
		accuracy = 0.00;
		// noteCount = 0;

		// repPresses = 0;
		// repReleases = 0;
		songScore = 0;
		songScoreInFloat = 0;
		altsongScore = 0;
	}
	/*Interpeter shit*/
		public override function addVariablesToHScript(interp:Interp){
			interp.variables.set("state",cast (this));
			interp.variables.set("game",cast (this));
			interp.variables.set("require",require);
			interp.variables.set("charGet",charGet);
			interp.variables.set("charSet",charSet);
			interp.variables.set("charAnim",charAnim);
		}
		#if linc_luajit
		public override function addVariablesToLua(interp:SELua){
			interp.variables.set("state",cast (this));
			interp.variables.set("game",cast (this));
			interp.variables.set("charGet",charGet);
			interp.variables.set("charSet",charSet);
			interp.variables.set("charAnim",charAnim);
			interp.variables.set("require",require);
		}
		#end

		public function require(v:String,nameSpace:String):Bool{
			// if(QuickOptionsSubState.getSetting("Song hscripts") && onlinemod.OnlinePlayMenuState.socket == null){return false;}
			trace('Checking for ${v}');
			if(interps[nameSpace] == null) {
				trace('Unable to load $v: $nameSpace doesn\'t exist!');
				return false;
			}
			if (SELoader.exists('mods/${v}') || SELoader.exists('mods/scripts/${v}/script.hscript')){
				var parser = new hscript.Parser();
				try{
					parser.allowTypes = parser.allowJSON = parser.allowMetadata = true;

					var program;
					// parser.parseModule(songScript);
					program = parser.parseString(SELoader.loadText('mods/scripts/${v}/script.hscript'));
					interps[nameSpace].execute(program);
				}catch(e){
					errorHandle('Unable to load $v for $nameSpace:${e.message}');
					return false;
				}
				// parseHScript(,new HSBrTools('mods/scripts/${v}',v),'${nameSpace}-${v}');
			}else{showTempmessage('Unable to load $v for $nameSpace: Script doesn\'t exist');}
			return ((interps['${nameSpace}-${v}'] == null));
		}
		public override function callInterp(func_name:String, args:Array<Dynamic>,?id:String = "") { // Modified from Modding Plus, I am too dumb to figure this out myself
				try{
					switch(func_name){
						case ("noteHitDad"):{
							charCall("noteHitSelf",[args[1]],1);
							charCall("noteHitOpponent",[args[1]],0);
						}
						case ("noteHit"):{
							charCall("noteHitSelf",[args[1]],0);
							charCall("noteHitOpponent",[args[1]],1);
						}
						case ("susHitDad"):{
							charCall("susHitSelf",[args[1]],1);
							charCall("susHitOpponent",[args[1]],0);
						}
						case ("susHit"):{
							charCall("susHitSelf",[args[1]],0);
							charCall("susHitOpponent",[args[1]],1);
						}

					}
					args.insert(0,this);
					if (id == "") {
						for (name => interp in interps) {
							callSingleInterp(func_name,args,name,interp);
						}
						if(Console.instance != null && Console.instance.commandBox != null){
							if(Console.instance.commandBox.interp != null) callSingleInterp(func_name,args,'console-hx',Console.instance.commandBox.interp);
							#if linc_luajit
								if(Console.instance.commandBox.selua != null) callSingleInterp(func_name,args,'console-lua',Console.instance.commandBox.selua);
							#end
						}
					}else callSingleInterp(func_name,args,id);
				}catch(e:hscript.Expr.Error){handleError('${func_name} for "${id}":\n ${e.toString()}');}

			}


	public override function errorHandle(?error:String = "",?forced:Bool = false) handleError(error,forced);
	public function handleError(?error:String = "",?forced:Bool = false){
		SHUTUP();
		DiscordClient.changePresence("Script Error -- "
		+ PlayState.detailsText
		, PlayState.iconRPC,false,null,"Error-PlayState");
		generatedMusic = persistentUpdate = false;
		canPause=true;
		try{
			if(currentInterp.args[0] == this) currentInterp.args.shift();

			if(error == "") error = 'No error passed!';
			// else if(error == "Null Object Reference") error = 'Null Object Reference;\nInterp info: ${currentInterp}';
			if(currentInterp.isActive) error += '\nInterp info: ${currentInterp}';
			trace('Error!\n ${error}');
			if(currentInterp.isActive) trace('Current Interpeter: ${currentInterp}');
			resetInterps();
			parseMoreInterps = false;
			if(!songStarted && !forced && playCountdown){
				if(errorMsg == "") errorMsg = error;
				startedCountdown = true;
				LoadingScreen.loadingText = 'ERROR!';
				return;
			}
			errorMsg = "";
			FlxTimer.globalManager.clear();
			FlxTween.globalManager.clear();
			try { camGame.visible = false; } catch(e){}
			try { camHUD.visible = false; } catch(e){}
			try { playerNoteCamera.visible=false; } catch(e){}
			try { opponentNoteCamera.visible=false; } catch(e){}

			var _forced = (!songStarted && !forced && playCountdown);
			generatedMusic = persistentUpdate = false;
			persistentDraw = true;
			if(FinishSubState.instance != null){
				FinishSubState.instance.destroy();
				openSubState(new ErrorSubState(0,0,error,true));
				canPause = true;
				return;
			}
			// _forced
			Main.game.blockUpdate = Main.game.blockDraw = false;
			openSubState(new FinishSubState(0,0,error,true));
		}catch(e){
			trace('${e.message}\n${e.stack}');MainMenuState.handleError(error);
		}
	}
	static function charGet(charId:Dynamic,field:String):Dynamic{
		return Reflect.field(getCharFromID(charId),field);
	}
	static public function charSet(charId:Dynamic,field:String,value:Dynamic){
		Reflect.setField(getCharFromID(charId),field,value);
	}
	public static function getCharVariName(charID:Dynamic):String{
		return switch('$charID'){case "1" | "dad" | "opponent" | "p2": "dad"; case "2" | "gf" | "girlfriend" | "p3": "gf"; default: "boyfriend";};
	}
	public static function getCharFromID(charID:Dynamic):Character{
		return switch('$charID'){case "1" | "dad" | "opponent" | "p2": dad; case "2" | "gf" | "girlfriend" | "p3": gf; default: boyfriend;};
	}
	public static function getCharID(charID:Dynamic):Int{
		return switch('$charID'){case "1" | "dad" | "opponent" | "p2": 1; case "2" | "gf" | "girlfriend" | "p3": 2; default: 0;};
	}
	static public function charAnim(charId:Dynamic = 0,animation:String = "",?forced:Bool = false,?CharNote:Int = 0){
		if(charId.playAnim == null){
			try{
				charId = Std.string(charId);
			}catch(e){
				return boyfriendArray[0].playAnim(animation,forced);
			}
			switch(charId){
				case "0" | "bf" | "player" | "p1":
					if(boyfriendArray.length > CharNote)
						charId = boyfriendArray[CharNote]; else charId = boyfriendArray[0];
				case "1" | "dad" | "opponent" | "p2":
					if(dadArray.length > CharNote)
						charId = dadArray[CharNote]; else charId = dadArray[0];
				case "2" | "gf" | "girlfriend" | "p3":
					charId = gf;
				default: return;
			}
		}
		charId.playAnim(animation,forced);
	}
	public function clearVariables(){

		resetInterps();
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
		botPlay = QuickOptionsSubState.getSetting("BotPlay") && (onlinemod.OnlinePlayMenuState.socket == null);
		practiceMode = (FlxG.save.data.practiceMode || ChartingState.charting || onlinemod.OnlinePlayMenuState.socket != null || botPlay || FlxG.save.data.aprilfools > 0);

		introAudio = [
			Paths.sound('intro3'),
			Paths.sound('intro2'),
			Paths.sound('intro1'),
			Paths.sound('introGo'),
		];
		introGraphics = [
			"",
			Paths.image('ready'),
			Paths.image("set"),
			Paths.image("go"),
		];
		songStarted = false;
	}
/* 
	override public function softReloadState(?showWarning:Bool = true){
		if(!parseMoreInterps){
			showTempmessage('You are currently unable to reload interpeters!',FlxColor.RED);
			return;
		}
		FlxG.sound.music.pause();
		if(vocals != null) vocals.pause();
		var time = Conductor.songPosition;
		callInterp('reload',[false]);
		callInterp('unload',[]);
		FlxTimer.globalManager.clear();
		FlxTween.globalManager.clear();
		resetInterps();
		loadScripts();
		generateSong();
		addNotes();
		var oldBf:Character = bf;
		bf = new Character(oldBf.x, oldBf.y,oldBf.isPlayer,oldBf.charType, oldBf.charInfo);
		this.replace(oldBf,bf);
		oldBf.destroy();
		oldBf = dad;
		dad = new Character(oldBf.x, oldBf.y,oldBf.isPlayer,oldBf.charType, oldBf.charInfo);
		this.replace(oldBf,dad);
		oldBf.destroy();
		FlxG.sound.music.play();
		if(vocals != null) vocals.play();


		callInterp('reloadDone',[]);
		if(showWarning) showTempmessage('Soft reloaded state. This is unconventional, Hold shift and press F5 for a proper state reload');
		Conductor.songPosition = time;
	} */

	override public function loadScripts(?enableScripts:Bool = false,?enableCallbacks:Bool = false,?force:Bool = false){
		if((!enableScripts && !parseMoreInterps && !force)) return;
		parseMoreInterps = true;
		super.loadScripts(enableScripts,enableCallbacks,force);
		for (i in 0 ... scripts.length) {
			var v = scripts[i];
			LoadingScreen.loadingText = 'Loading scripts: $v';
			loadSingleScript(v);
		}

	}
	public static var hasStarted = false;
	public var oldBF:String = "";
	public var oldOPP:String = "";
	override public function new(){
		LoadingScreen.loadingText = "Starting Playstate";
		super();
		PlayState.player1 = "";
		PlayState.player2 = "";
		PlayState.player3 = "";
		PlayState.ExtraChar = [];
		PlayState.boyfriendArray = [];
		PlayState.dadArray = [];
		PlayState.ShouldAIPress = [[true],[true]];
		PlayState.dadShow = true;
		PlayState.bfShow = true;
		PlayState.onlinecharacterID = 0;
	}
	override public function create()
	{
		#if !debug
		try{
		#end
		scriptSubDirectory = "";
		SELoader.gc();
		LoadingScreen.loadingText = 'Loading playstate variables';
		parseMoreInterps = (QuickOptionsSubState.getSetting("Song hscripts") || isStoryMode);
		instance?.destroy();
		ScriptMusicBeatState.instance=cast(instance=this);
		if(SONG.keyCount != 4)
			BothSide = false;
		else
			BothSide = QuickOptionsSubState.getSetting("Play Both Side");
		MirrorMode = QuickOptionsSubState.getSetting("Mirror Mode");
		randomnote = QuickOptionsSubState.getSetting("Random Notes");
		ADOFAIMode = QuickOptionsSubState.getSetting("ADOFAI Chart");
		COOPMode = QuickOptionsSubState.getSetting("CO OP Mode");
		downscroll = FlxG.save.data.downscroll;
		middlescroll = (FlxG.save.data.middleScroll || BothSide);
		scrollspeed = FlxMath.roundDecimal(QuickOptionsSubState.getSetting("Scroll speed") > 1 ? QuickOptionsSubState.getSetting("Scroll speed") : QuickOptionsSubState.getSetting("Scroll speed") == 1 || FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2);
		if(FlxG.save.data.MKScrollSpeed > 1 && SONG.playerKeyCount > 4 && FlxG.save.data.scrollSpeed != 1)
			scrollspeed = FlxMath.roundDecimal(QuickOptionsSubState.getSetting("Scroll speed") > 1 ? QuickOptionsSubState.getSetting("Scroll speed") : FlxG.save.data.MKScrollSpeed, 2);
		scrollspeed = FlxMath.roundDecimal(scrollspeed * songspeed, 2);
		instance = this;
		clearVariables();
		hasStarted = true;
		logGameplay = FlxG.save.data.logGameplay;
		// if (PlayState.songScript == "" && SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()] != null) songScript = SongHScripts.scriptList[PlayState.SONG.song.toLowerCase()];
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(1000);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		resetScore();

		TitleState.loadNoteAssets(); // Make sure note assets are actually loaded
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camTOP = new FlxCamera();
		camGame.bgColor = 0xFF000000;
		camHUD.bgColor = camTOP.bgColor = 0x00000000;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camTOP);

		FlxG.cameras.setDefaultDrawTarget(camGame,true);

		persistentUpdate = true;
		persistentDraw = true;
		
		SongOGmania = SONG.mania;
		if (SONG.events != null && SONG.mania > 0 && SONG.keyCount == null)
			SONG.keyCount = SONG.playerKeyCount = SONG.mania + 1;

		if (ADOFAIMode) // LMAO
			{
				SONG.mania = mania = 6;
				SONG.keyCount = SONG.playerKeyCount = 1;
			}
		else if(BothSide)
			{
				SONG.mania = mania = 5;
				SONG.keyCount = SONG.playerKeyCount = 8;
			}
		else if(SONG.keyCount != null)
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
					case 14: mania = SONG.mania = SongOGmania = 13;
					case 15: mania = SONG.mania = SongOGmania = 14;
					case 16: mania = SONG.mania = SongOGmania = 15;
					case 17: mania = SONG.mania = SongOGmania = 16;
					case 18: mania = SONG.mania = SongOGmania = 17;
					case 21: mania = SONG.mania = SongOGmania = 18;
					default: mania = SONG.mania = SongOGmania = 0;
				}
			}
		else if(QuickOptionsSubState.getSetting("Force Mania") == -1)
			{
				mania = SONG.mania;
				SONG.keyCount = SONG.playerKeyCount = keyAmmo[mania];
			}
		if(QuickOptionsSubState.getSetting("Force Mania") > -1)
			{
				SONG.mania = mania = QuickOptionsSubState.getSetting("Force Mania");
				SONG.keyCount = SONG.playerKeyCount = keyAmmo[mania];
			}
		if (SONG.Smania != null && SONG.Smania > 0)
			{
				mania = SONG.mania = SONG.Smania;
				SONG.keyCount = SONG.playerKeyCount = keyAmmo[mania];
			}
		Changemania = mania;
		switch(SONG.playerKeyCount)
		{
			case 1: playermania = 6;
			case 2: playermania = 7;
			case 3: playermania = 8;
			case 4: playermania = 0;
			case 5: playermania = 4;
			case 6: playermania = 1;
			case 7: playermania = 2;
			case 8: playermania = 5;
			case 9: playermania = 3;
			case 10: playermania = 9;
			case 11: playermania = 10;
			case 12: playermania = 11;
			case 13: playermania = 12;
			case 14: playermania = 13;
			case 15: playermania = 14;
			case 16: playermania = 15;
			case 17: playermania = 16;
			case 18: playermania = 17;
			case 21: playermania = 18;
			default: playermania = 0;
		}
		if(FlxG.save.data.aprilfools > 0){
			mania = playermania = 18;
			SONG.keyCount = SONG.playerKeyCount = keyAmmo[mania];
			randomnote = 1;
		}
		setInputHandlers(); // Sets all of the handlers for input

		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = songDiff;

		// iconRPC = SONG.player2;
		if(BothSide)
			iconRPC = "bothside";
		else if(keyAmmo.contains(SONG.keyCount))iconRPC = "mania" + SONG.keyCount;
		else iconRPC = "wdym";
		iconRPCText = 'Song Mania: ${SONG.mania}';

		switch(stateType)
		{
			case 0:detailsText = "Freeplay ";
			case 2:detailsText = "Offline ";
			case 3:detailsText = "Online ";
			case 4:detailsText = "Multi ";
			case 5:detailsText = "OSU ";
			case 6:detailsText = "Story ";
		}
		detailsText += CoolUtil.formatChartName(SONG.song) + " (" + storyDifficultyText + ") ";
		if (songspeed != 1)
			detailsText += "(" + songspeed + "x)";
		if (ADOFAIMode)
			detailsText += " ADOFAI Mode";
		else if (BothSide)
			detailsText += " Both Side";
		if (randomnote != 0 && !ADOFAIMode)
			detailsText += " Random Note";

		if(stateType == 3)
			{
				if(onlinemod.OnlineLobbyState.clientCount == 1)
					LargeiconRPC = "empty-online-playstate";
				else
					LargeiconRPC = "online-playstate";
			}
		else
			LargeiconRPC = "playstate";
		PauseLargeiconRPC = 'pause-' + LargeiconRPC;

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(
			detailsText
			+ (botPlay ? " BotPlay" : Ratings.GenerateLetterRank(accuracy)),
			"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: " + songScore
			+ " | Misses: " + misses, iconRPC,false,0,LargeiconRPC,iconRPCText);

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.mapManiaChanges(SONG);
		Conductor.changeBPM(SONG.bpm * songspeed);
		if(hsBrToolsPath == "" || !SELoader.exists(hsBrToolsPath)) hsBrToolsPath = 'assets/';
		hsBrTools = getBRTools(hsBrToolsPath,'SONG');
		if(QuickOptionsSubState.getSetting("Song hscripts") && SELoader.exists(hsBrTools.path)){
			LoadingScreen.loadingText = 'Loading song scripts';
			loadScript(hsBrTools.path,'','SONG',hsBrTools);
		}

		trace('INFORMATION ABOUT WHAT U PLAYIN WITH:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + QuickOptionsSubState.getSetting("BotPlay"));
	
		
		//dialogue shit
		loadDialog();
		LoadingScreen.loadingText = "Loading stage";
		// Stage management
		var bfPos:Array<Float> = [0,0]; 
		var gfPos:Array<Float> = [0,0]; 
		var dadPos:Array<Float> = [0,0]; 
		stageInfo =TitleState.findStageByNamespace(FlxG.save.data.selStage,onlinemod.OfflinePlayState.nameSpace);
		if(FlxG.save.data.stageAuto || PlayState.isStoryMode || ChartingState.charting || SONG.forceCharacters || isStoryMode || FlxG.save.data.selStage == "default")
			stageInfo = TitleState.findStageByNamespace(SONG.stage,onlinemod.OfflinePlayState.nameSpace,null,false);
		if(stageInfo == null){
			stageInfo = TitleState.findStageByNamespace(FlxG.save.data.selStage);
		}
		stage = stageInfo.folderName;
		var noGf:Bool = false;
		 // Oh my god this code hurts my soul, but I really don't want to recreate it
		if (FlxG.save.data.preformance){
			defaultCamZoom = 0.5;
			curStage = 'void';
			stageTags = [];
			bfPos = [100,0];
			dadPos = [-100,0];
		}else{
			if (FlxG.save.data.selStage != "default"){SONG.stage = FlxG.save.data.selStage;}
			switch(SONG.stage.toLowerCase()){
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
						if(stage == "" || !SELoader.exists('${stageInfo.path}/${stageInfo.folderName}')){
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
							curStage = stage;
							stageTags = [];
							var stagePath:String = '${stageInfo.path}/${stageInfo.folderName}';
							if (SELoader.exists('$stagePath/config.json')){
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
								// if(gfShow) gfShow = stageProperties.showGF;
							}
							var brTool = new HSBrTools(stagePath);
							for (i in CoolUtil.orderList(FileSystem.readDirectory(stagePath))) {
								if(i.endsWith(".hscript")){
									parseHScript(SELoader.getContent('$stagePath/$i'),brTool,"STAGE-" + i);
								}
								#if linc_luajit
								else if(i.endsWith(".lua")){
									parseLua(SELoader.getContent('$stagePath/$i'),brTool,"STAGE/" + i,'$stagePath/$i');
								}
								#end
							}
						}
					}
				}
		}

		if(PlayState.player1 == "" && TitleState.retChar(SONG.player1) != "")PlayState.player1 = SONG.player1; else PlayState.player1 = FlxG.save.data.playerChar;
		if(PlayState.player2 == "" && TitleState.retChar(SONG.player2) != "")PlayState.player2 = SONG.player2; else PlayState.player2 = FlxG.save.data.opponent;
		if(PlayState.player3 == "" && TitleState.retChar(SONG.gfVersion) != "")PlayState.player3 = SONG.gfVersion; else PlayState.player3 = FlxG.save.data.gfChar;
		if(SONG.player1 == "" || SONG.player1.toLowerCase() == "lonely" || SONG.player1.toLowerCase() == "hidden" || SONG.player1.toLowerCase() == "nothing" || SONG.player1.toLowerCase() == "blank") bfShow = false;
		if(SONG.player2 == "" || SONG.player2.toLowerCase() == "lonely" || SONG.player2.toLowerCase() == "hidden" || SONG.player2.toLowerCase() == "nothing" || SONG.player2.toLowerCase() == "blank"){
			if(FlxG.save.data.ReplaceDadWithGF)
				PlayState.player2 = (PlayState.player3 == "gf" ? FlxG.save.data.gfChar : PlayState.player3);
			else dadShow = false;
		}
		if(SONG.gfVersion == "" || SONG.gfVersion.toLowerCase() == "lonely" || SONG.gfVersion.toLowerCase() == "hidden" || SONG.gfVersion.toLowerCase() == "nothing" || SONG.gfVersion.toLowerCase() == "blank") gfShow = false;
		if(onlinemod.OnlineLobbyState.ExChar != []) PlayState.ExtraChar = onlinemod.OnlineLobbyState.ExChar;
		if(SONG.multichar != null && SONG.multichar != []) PlayState.ExtraChar = SONG.multichar;
		callInterp("afterStage",[]);

		if(!(SONG.forceCharacters || PlayState.isStoryMode || ChartingState.charting || isStoryMode)){

			if (PlayState.player2 == "bf" || !FlxG.save.data.charAuto){
				PlayState.player2 = FlxG.save.data.opponent;
	    	}
	    	
			if((PlayState.player1 == "bf" && FlxG.save.data.playerChar != "automatic") || !FlxG.save.data.charAutoBF ){
				PlayState.player1 = FlxG.save.data.playerChar;
			}
		}
		var gfVersion:String = 'gf';

		if(loadChars){
			LoadingScreen.loadingText = 'Loading GF: ${FlxG.save.data.gfChar}';
			switch (SONG.gfVersion)
			{
				case 'gf-car':
					player3 = 'gf-car';
				case 'gf-christmas':
					player3 = 'gf-christmas';
				case 'gf-pixel':
					player3 = 'gf-pixel';
				default:
					player3 = 'gf';
			}
			if (FlxG.save.data.gfChar != "gf"){player3=FlxG.save.data.gfChar;}
			gfChar = player3;
			gf = (if (FlxG.save.data.gfShow && loadChars && gfShow)	new Character(400, 100, player3,false,2) else new EmptyCharacter(400, 100));
			gf.scrollFactor.set(0.95, 0.95);

			LoadingScreen.loadingText = 'Loading Opponent: $player2';
			if (!ChartingState.charting && SONG.player1.startsWith("gf") && FlxG.save.data.charAuto) player1 = FlxG.save.data.gfChar;
			if (!ChartingState.charting && SONG.player2.startsWith("gf") && FlxG.save.data.charAuto) player2 = FlxG.save.data.gfChar;

			dad = (if (dadShow && FlxG.save.data.dadShow && loadChars && !(player3 == player2 && player1 != player2)) new Character(100, 100, player2,false,1) else new EmptyCharacter(100, 100));
			dadArray.push(dad);

			LoadingScreen.loadingText = 'Loading BF: $player1';
			boyfriend = (if (bfShow && FlxG.save.data.bfShow && loadChars) new Character(770, 100, player1,true,0) else new EmptyCharacter(770,100));
			boyfriendArray.push(boyfriend);
			addExtraCharacter();
		}else{
			dad = new EmptyCharacter(100, 100);
			boyfriend = new EmptyCharacter(400,100);
			gf = new EmptyCharacter(400, 100);
			dadArray.push(dad);
			boyfriendArray.push(boyfriend);
			if(ExtraChar != []){
				for(i in ExtraChar){
					var Char = new EmptyCharacter(0,100);
					if(i.side == 1)	dadArray.push(Char); else boyfriendArray.push(Char);
					ShouldAIPress[i.side].push(true);
				}
			}
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		camPos.set(camPos.x + dad.camX, camPos.y + dad.camY);

		LoadingScreen.loadingText = "Adding characters";
		for (i => v in [bfPos,dadPos,gfPos]) {
			if (v[0] != 0 || v[1] != 0){
				switch(i){
					case 0:for(bf in boyfriendArray){bf.x+=v[0];bf.y+=v[1];}
					case 1:for(dad in dadArray){dad.x+=v[0];dad.y+=v[1];}
					case 2:gf.x+=v[0];gf.y+=v[1];
				}
			}
		}
		if (player3 == player2 && player1 != player2){// Don't hide GF if player 1 is GF
				// dad.setPosition(gf.x, gf.y);
				dad.destroy();
				dad = dadArray[0] = gf;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
		}

		if (player3 == player1){
			if (player1 != player2){	// Don't hide GF if player 1 is GF
				boyfriend.destroy();
				boyfriend = boyfriendArray[0] = gf;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			}
		}
		LoadingScreen.loadingText = "Loading scripts";
		if(QuickOptionsSubState.getSetting("Song hscripts")){
			loadScripts(null,null);
		}
		if(onlinemod.OnlinePlayMenuState.socket != null){
			for (i in 0 ... onlinemod.OnlinePlayMenuState.scripts.length) {
				var v = onlinemod.OnlinePlayMenuState.scripts[i];
				LoadingScreen.loadingText = 'loading script: $v';
				var _v = v.substr(v.lastIndexOf('/') - 1);
				if(v.lastIndexOf('/') > v.length - 2){
					_v = v.substr(0,v.lastIndexOf('/') - 1).substr(v.lastIndexOf('/'));
				}
				loadScript(v,null,'ONLINE/' + _v);
			}
			for (i in 0 ... onlinemod.OnlinePlayMenuState.rawScripts.length) {
				if(onlinemod.OnlinePlayMenuState.rawScripts[i][0].endsWith(".hscript"))
					parseHScript(onlinemod.OnlinePlayMenuState.rawScripts[i][1],hsBrTools,onlinemod.OnlinePlayMenuState.rawScripts[i][0],'onlineScript:$i');
				else if(onlinemod.OnlinePlayMenuState.rawScripts[i][0].endsWith(".lua"))
					parseLua(onlinemod.OnlinePlayMenuState.rawScripts[i][1],hsBrTools,onlinemod.OnlinePlayMenuState.rawScripts[i][0],'onlineScript:$i');
			}
		}

		add(gf);
		charCall("addGF",[],-1);
		callInterp("addGF",[]);

		for(Char in dadArray){add(Char);}
		charCall("addDad",[],-1);
		callInterp("addDad",[]);

		for(Char in boyfriendArray){add(Char);}
		callInterp("addChars",[]);
		charCall("addChars",[],-1);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;
		if(FlxG.save.data.undlaTrans > 0){
			underlay = new FlxSprite(0,0).makeGraphic((if(FlxG.save.data.undlaSize == 0)Std.int(Note.swagWidth[playermania] * keyAmmo[playermania]) else 1920),1080,0xFF000010);
			underlay.alpha = FlxG.save.data.undlaTrans;
			underlay.cameras = [camHUD];
			add(underlay);
		}
		timerBar = new FlxSprite(0,0).makeGraphic((Std.int(Note.swagWidth[playermania] * keyAmmo[playermania])),10,0xFFFFFFFF);
		timerBar.screenCenter();
		timerBar.alpha = 0;
		timerBar.scale.x = 0;
		timerBar.y += 32;
		add(timerBar);
        timerText = new FlxText(0,0,0,"");
        timerText.setFormat(CoolUtil.font, 36, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timerText.screenCenter();
		timerText.alpha = 0;
        add(timerText);
		trace('SwagWidth: ${Note.swagWidth[mania]} KeyAmmo: ${keyAmmo[mania]} KeyCount: ${SONG.keyCount}  PlayerKeyCount: ${SONG.playerKeyCount} mania: ${mania}');
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


		if (SONG.difficultyString != null && SONG.difficultyString != "") songDiff = SONG.difficultyString;
		else songDiff = if(customDiff != "") customDiff else if(stateType == 4) "mods/charts" else if (stateType == 5) "osu! beatmap" else (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy");
		playerStrums = new FlxTypedGroup<StrumArrow>();
		cpuStrums = new FlxTypedGroup<StrumArrow>();

		// startCountdown();

		LoadingScreen.loadingText = "Loading chart";
		generateSong(SONG.song);

		LoadingScreen.loadingText = "Loading UI";
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

		moveCamera = moveCamera;
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
		healthBar.createFilledBar(dadArray[0].definingColor, boyfriendArray[0].definingColor);
		// healthBar
		add(healthBar);
		// Add Kade Engine watermark
		if(actualSongName == "" || (stateType != 4 && stateType != 5)) actualSongName = (if(ChartingState.charting) "Charting" else curSong + " " + songDiff);

		
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50 - FlxG.save.data.guiGap,0,actualSongName + (FlxMath.roundDecimal(songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songspeed, 2) + "x)" : "") + " - " + inputEngineName, 16);
		kadeEngineWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45 + FlxG.save.data.guiGap;
		
		if (FlxG.save.data.songInfo == 0 || FlxG.save.data.songInfo == 1 || FlxG.save.data.songInfo == 3) {
			scoreTxt = new FlxText(0, healthBarBG.y + 30 - FlxG.save.data.guiGap, FlxG.width, '');
			scoreTxt.autoSize = false;
			scoreTxt.wordWrap = false;
			scoreTxt.alignment = "left";
		}else {
			scoreTxt = new FlxText(10 + FlxG.save.data.guiGap, FlxG.height * 0.46 , 600, '', 20); // Long ass text to make sure it's sized correctly
			scoreTxt.wordWrap = false;
			scoreTxt.alignment = "center";
		}

		
		// if (!FlxG.save.data.accuracyDisplay)
		// 	scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(CoolUtil.font, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(player1, true,boyfriendArray[0].clonedChar);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.trackedSprite = healthBar;
		iconP1Array.push(iconP1);
		add(iconP1);
		
		iconP2 = new HealthIcon(player2, BothSide && !practiceMode,dadArray[0].clonedChar);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.trackedSprite = healthBar;
		iconP2Array.push(iconP2);
		add(iconP2);

		if(ExtraChar != [] && FlxG.save.data.ExtraIcon){
			for(i in ExtraChar){
				var CharName = (if(TitleState.retChar(i.char) != "") i.char else "boyfriend");
				var icon = new HealthIcon(CharName,i.side == 1 ? BothSide && !practiceMode : true,"bf");
				icon.trackedSprite = healthBar;
				if(i.side == 1) iconP2Array.push(icon); else iconP1Array.push(icon);
				// icon.scale.set(0.75,0.75);
				add(icon);
			}
		}

		callInterp("addUI",[]);
		charCall("addUI",[],-1);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		for(array in [iconP1Array,iconP2Array]){for(icon in array){icon.isTracked = !practiceMode;}}
		if(practiceMode){
			practiceText = new FlxText(0,healthBar.y - 64,(if(FlxG.save.data.aprilfools > 0) "Get Pranked LMAO" else if(botPlay) "Botplay" else if(ChartingState.charting) "Testing Chart" else "Practice mode"),16);
			if(FlxG.save.data.aprilfools > 0)FlxG.save.data.aprilfools--;
			if(onlinemod.OnlinePlayMenuState.socket == null){
				practiceText.setFormat(CoolUtil.font, 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				practiceText.cameras = [camTOP];
				practiceText.screenCenter(X);
				if(downscroll) practiceText.y += 20;
				insert(members.indexOf(healthBar),practiceText);
				FlxTween.tween(practiceText,{alpha:0},1,{type:PINGPONG});
			}
			healthBar.visible = healthBarBG.visible = false;
			for(icon in 0...iconP2Array.length){iconP2Array[icon].x = FlxG.width * 0.05 - (75 * icon);}
			for(icon in 0...iconP1Array.length){iconP1Array[icon].x = FlxG.width * 0.95 - iconP1Array[icon].width + (75 * icon);}
			var y = (downscroll ? FlxG.height * 0.9 : FlxG.height * 0.1);
			for(array in [iconP1Array,iconP2Array]){for(icon in array){icon.y = y - (icon.height * 0.5);}}
			scoreTxt.y = FlxG.save.data.guiGap;
		}
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		scoreTxt.alpha = 0;
		doof.cameras = [camHUD];
		for(icon in iconP2Array){icon.y = healthBarBG.y - (icon.height / 2);icon.cameras = [camHUD];}
		for(icon in iconP1Array){icon.y = healthBarBG.y - (icon.height / 2);icon.cameras = [camHUD];}
		kadeEngineWatermark.cameras = [camHUD];

		hitSound = FlxG.save.data.hitSound;
		dadhitSound = FlxG.save.data.dadhitSound;
		if((hitSound || dadhitSound) && hitSoundEff == null) hitSoundEff = Sound.fromFile(FileSystem.exists('mods/hitSound.ogg') ? 'mods/hitSound.ogg' : Paths.sound('Normal_Hit'));
		if((hitSound || dadhitSound) && holdSoundEff == null) holdSoundEff = Sound.fromFile(FileSystem.exists('mods/holdSound.ogg') ? 'mods/holdSound.ogg': FileSystem.exists('mods/hitSound.ogg') ? 'mods/hitSound.ogg' : Paths.sound('Normal_Hit'));

		if(hurtSoundEff == null) hurtSoundEff = ((SELoader.exists('mods/hurtSound.ogg') ? SELoader.loadSound('mods/hurtSound.ogg') : SELoader.loadSound('assets/shared/sounds/ANGRY.ogg',true)));
		if(vanillaHurtSounds[0] == null && FlxG.save.data.playMisses) vanillaHurtSounds = [Sound.fromFile('assets/shared/sounds/missnote1.ogg'),Sound.fromFile('assets/shared/sounds/missnote2.ogg'),Sound.fromFile('assets/shared/sounds/missnote3.ogg')];

		startingSong = true;
		
		add(scoreTxt);
		
		judgementCounter = new FlxText(20, 0, 0, "", 16);
		judgementCounter.setFormat(CoolUtil.font, 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		judgementCounter.text = 'Combo: 0'
		+ '\nMarvelous: 0'
		+ '\nSicks: 0'
		+ '\nGoods: 0'
		+ '\nBads: 0'
		+ '\nShits: 0'
		+ '\nMisses: 0'
		+ '\nGhost Taps: 0'
		+ '\n'
		;
		if(FlxG.save.data.JudgementCounter)
			add(judgementCounter);

		LoadingScreen.loadingText = "Finishing up";
		super.create();
		openfl.system.System.gc();
		LoadingScreen.loadingText = "Starting countdown/dialog";

		if((dialogue != null && dialogue[0] != null && isStoryMode)){
			var doof:DialogueBox = new DialogueBox(false, dialogue);
			doof.scrollFactor.set();
			doof.finishThing = startCountdownFirst;
			doof.cameras = [camTOP];
			callInterp('openDialogue',[doof]);
			addDialogue(doof);
		}else{
			startCountdownFirst();
		}
	#if !debug
	}catch(e){MainMenuState.handleError(e,'Caught "create" crash: ${e.message}\n ${e.stack}');}
	#end
	}
	function loadDialog(){
		// dialogue = [];
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = CoolUtil.coolFormat("dad:Hey you're pretty cute.
				dad:Use the arrow keys to keep up\\nwith me singing.");
			case 'bopeebo':
				dialogue = CoolUtil.coolFormat(
					'dad:HEY!\n' +
					'bf:Beep?\n' +
					"dad:You think you can just sing\\nwith my daughter like that?\n" +
					'bf:Beep' +
					"dad:If you want to date her...\\n" +
					"dad:You're going to have to go \\nthrough ME first!\n" +
					'bf:Beep bop!'
				);
			case 'fresh':
				dialogue = CoolUtil.coolFormat("dad:Not too shabby $BF.\ndad:But I'd like to see you\\n keep up with this!");
			case 'dad battle':
				dialogue = CoolUtil.coolFormat(
					"dad:Gah, you think you're hot stuff?\n"+
					"dad:If you can beat me here...\n"+
					"dad:Only then I will even CONSIDER letting you\\ndate my daughter!"+
					'bf:Beep!'
				);
		}
	}

	inline function addDialogue(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		FlxTween.tween(black, {alpha: 0}, 1, {
			onComplete: function(twn:FlxTween){
				remove(black);
				if (dialogueBox != null){
					inCutscene = true;
					add(dialogueBox);
					return;
				}
				startCountdownFirst();
			}
		});
	}

	var startTimer:FlxTimer;

	function startCountdownFirst(){ // Skip the
		callInterp("startCountdownFirst",[]);
		FlxG.camera.zoom = FlxMath.lerp(0.90, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		// camFollow.setPosition(720, 500);
		NoteStuffExtra.CalculateNoteAmount(SONG,FlxG.sound.music.length);
		bfnoteamount = bfnoteamountwithhurt = NoteStuffExtra.bfNotes.length;
		dadnoteamount = dadnoteamountwithhurt = NoteStuffExtra.dadNotes.length;
		for(note in unspawnNotes){
			if(note.shouldntBeHit && !note.isSustainNote){
				switch(note.mustPress){
				case true: bfnoteamount--;
				case false: dadnoteamount--;
				}
			}
		}
		if(!BothSide && MirrorMode == 0){
				ScoreMultiplier = Math.max(bfnoteamount, dadnoteamount) / bfnoteamount;
				ScoreDivider = Math.min(bfnoteamount, dadnoteamount) / bfnoteamount;
		}
		else{
			ScoreMultiplier = 1.0;
			ScoreDivider = 1.0;
		}
		if(ScoreDivider <= 0.1) ScoreDivider = 1;
		switch(FlxG.save.data.scoresystem)
		{
			case 0 | 3 | 4 | 7: RatingScore = [350,350,200,0,-300]; //FNF / Bal / Bal Invert / Stupid
			case 1 | 2: RatingScore = [350,300,200,100,50]; //Osu! / Osu!Mania
			case 5 | 6: RatingScore = [400,350,200,50,-150]; //Voiid / Voiid Uncap
		}
		switch(FlxG.save.data.altscoresystem)
		{
			case 0: AltRatingScore = [0]; //:shrug:
			case 1 | 4 | 5 | 8: AltRatingScore = [350,350,200,0,-300]; //FNF / Bal / Bal Invert / Stupid
			case 2 | 3: AltRatingScore = [350,300,200,100,50]; //Osu! / Osu!Mania
			case 6 | 7: AltRatingScore = [400,350,200,50,-150]; //Voiid / Voiid Uncap
		}

		canPause = true;
		updateCharacterCamPos();
		if (!generatedArrows){
			generatedArrows = true;
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		handleManiaChange();
		if (!playCountdown){
			playCountdown = true;
			return;
		}
		startCountdown();
	}
	public static var introAudio:Array<flixel.system.FlxAssets.FlxSoundAsset> = [];
	public static var introGraphics:Array<flixel.system.FlxAssets.FlxGraphicAsset> = [];
	var keys = [false, false, false, false, false, false, false, false, false, false, false, false, false];
	var playCountdown = true;
	var generatedArrows = false;
	public var swappedChars = false;
	public function startCountdown():Void
	{
		inCutscene = false;
		onlinecharacterID = onlinemod.OnlineLobbyState.CharID;
		if  (invertedChart || (onlinemod.OnlinePlayMenuState.socket == null && QuickOptionsSubState.getSetting("Swap characters"))){
			detailsText += " Left Side"; // discord thing move here for online
			detailsPausedText = "Paused - " + detailsText;
			var bfarray:Array<Character> = boyfriendArray;
			var opparray:Array<Character> = dadArray;
			var bf:Character = boyfriend;
			var opp:Character = dad;
			healthBar.createFilledBar(boyfriendArray[0].definingColor, dadArray[0].definingColor);
			boyfriendArray = opparray;
			dadArray = bfarray;
			boyfriend = opp;
			dad = bf;
			boyfriend.isPlayer = true;
			dad.isPlayer = false;
			var AIPressArray = ShouldAIPress;
			ShouldAIPress = [AIPressArray[1],AIPressArray[0]];
			swappedChars = !swappedChars;
			healthBar.fillDirection = (swappedChars ? LEFT_TO_RIGHT : RIGHT_TO_LEFT);
			if(middlescroll)
				opponentNoteCamera.x = Std.int(FlxG.width * 0.33);
			else
			{
				playerNoteCamera.x = Std.int(FlxG.width * -0.25);
				opponentNoteCamera.x = Std.int(FlxG.width * 0.25);
			}
		}
		FlxG.camera.zoom = FlxMath.lerp(0.90, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= (introAudio.length + 1) * 500;

		if(errorMsg != "") {handleError(errorMsg,true);return;}
		var swagCounter:Int = 0;

		callInterp("startCountdown",[]);
		startTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			gf.dance(curBeat % 2 == 0);
			for(array in [boyfriendArray,dadArray]){
				for(char in array){
					if(char != null)
						char.dance(curBeat % 2 == 0);
				}
			}
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
				}
				if(introGraphics[swagCounter] != null && introGraphics[swagCounter] != ""){
					var go:FlxSprite = new FlxSprite().loadGraphic(introGraphics[swagCounter]);
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 500, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
				}
				try{FlxG.sound.play(introAudio[swagCounter],FlxG.save.data.otherVol);}catch(e){}
			}
			callInterp("startTimerStepAfter",[swagCounter]);

			swagCounter += 1;
		}, introAudio.length + 1);
	}

	function charCall(func:String,args:Array<Dynamic>,?char:Int = -1){
		switch(char){
			case 0: for(bf in boyfriendArray){bf.callInterp(func,args);}
			case 1: for(dad in dadArray){dad.callInterp(func,args);}
			case 2: gf.callInterp(func,args);
			case -1:
				for(bf in boyfriendArray){bf.callInterp(func,args);}
				for(dad in dadArray){dad.callInterp(func,args);}
				gf.callInterp(func,args);
		}
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	public static var songspeed = 1.0;

	public var songStarted(default, null):Bool = false;

	function startSong(?alrLoaded:Bool = false):Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		FlxTween.tween(scoreTxt,{alpha:1},Conductor.crochet * 0.001);
		try{if(ShouldAIPress[0][onlinecharacterID])ShouldAIPress[0][onlinecharacterID] = false;}catch(e){trace("why is this still crash omg");}// death

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
		}
		trace("pitched inst and vocals to " + songspeed);
		#end
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(
			detailsText
			+ (botPlay ? " BotPlay" : Ratings.GenerateLetterRank(accuracy)),
			"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: " + songScore
			+ " | Misses: " + misses, iconRPC,false,0,LargeiconRPC,iconRPCText);

		if (!alrLoaded)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		FlxG.sound.music.onComplete = FlxG.sound.music.pause;
		vocals.play();
		
		if(sectionStart)
			FlxG.sound.music.time = Conductor.songPosition = vocals.time = sectionStartTime;

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length / songspeed;
		songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
		if (FlxG.save.data.songPosition)
			addSongBar();
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
			songPosBG.alpha = 0;
			songPosBar.alpha = 0;
			songName.alpha = 0;
			songTimeTxt.alpha = 0;

			FlxTween.tween(songPosBG,{alpha:1},0.5);
			FlxTween.tween(songPosBar,{alpha:1},0.5);
			FlxTween.tween(songName,{alpha:1},0.5);
			FlxTween.tween(songTimeTxt,{alpha:1},0.5);
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
				try{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				}catch(e){
					SONG.needsVoices = false;
					showTempmessage("Song needs voices but none found! Automatically disabled");
					vocals = new FlxSound();
				}
			else{
				SONG.needsVoices = false;
				vocals = new FlxSound();
			}
		}
		vocals.looped = FlxG.sound.music.looped = false;
		FlxG.sound.list.add(vocals);
		if (notes == null)
			notes = new FlxTypedGroup<Note>();
		if (eventNotes == null)
			eventNotes = new FlxTypedGroup<Note>();
		CoolUtil.clearFlxGroup(notes);
		CoolUtil.clearFlxGroup(eventNotes);
		add(notes);
		Note.lastNoteID = -1;
		var opponentNotes = (onlinemod.OnlinePlayMenuState.socket != null || QuickOptionsSubState.getSetting("Opponent arrows") || ChartingState.charting);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;


		callInterp("generateSongBefore",[]);
		// Per song offset check

		var daSection:Int = 0;
		for (section in noteData)
		{
			if(sectionStart && daSection < sectionStartPoint){
				daSection++;
				continue;
			}

			var mn:Int = keyAmmo[if(SONG.Smania != null && SONG.Smania > 0) SongOGmania else mania];
			var dataForThisSection:Array<Int> = [];
			var randomDataForThisSection:Array<Int> = [];
			var fullrandomlastnotedata:Array<Int> = [];
			var RandomNoteData:Int = FlxG.random.int(0, mn - 1);
			if (randomnote == 3)
			{
				for(i in 0...keyAmmo[mania]){ //sets up the max data for each section based on mania
					dataForThisSection.push(i);
				}
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
				var gottaHitNote:Bool = section.mustHitSection;
				var NoteType:Dynamic = songNotes[3];

				if(SONG.keyCount != SONG.playerKeyCount){
					if (songNotes[1] >= (!gottaHitNote ? SONG.keyCount : SONG.playerKeyCount))
						gottaHitNote = !section.mustHitSection;
				}
				else if ((songNotes[1] >= mn && !ADOFAIMode) || (songNotes[1] >= keyAmmo[SongOGmania] && ADOFAIMode))
					gottaHitNote = !section.mustHitSection;

				if(!opponentNotes && !gottaHitNote) continue;
				if(MirrorMode > 0){
					var Mirror:Bool = (MirrorMode == 1);
					if(gottaHitNote != Mirror)
						continue;
				}
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1]);
				if(SONG.keyCount != SONG.playerKeyCount)
					{
						if(daNoteData >= (!section.mustHitSection ? SONG.keyCount : SONG.playerKeyCount))
						daNoteData -= (!section.mustHitSection ? SONG.keyCount : SONG.playerKeyCount);
					}
				else daNoteData = Std.int(songNotes[1] % mn);

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

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
							daNoteData = daNoteData % 8;
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
				if (SONG.Smania != null && SONG.Smania > 0 && NoteType != null) // New shit i put in for that one cry baby that can't play multiplay
				{
					switch (NoteType){
						case "SNote0": daNoteData = 0;
						case "SNote1": daNoteData = 1;
						case "SNote2": daNoteData = 2;
						case "SNote3": daNoteData = 3;
						case "SNote4": daNoteData = 4;
						case "SNote5": daNoteData = 5;
						case "SNote6": daNoteData = 6;
						case "SNote7": daNoteData = 7;
						case "SNote8": daNoteData = 8;
					}
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,null,null,NoteType,songNotes,gottaHitNote,daSection * 4);
				swagNote.sustainLength = songNotes[2] / songspeed;
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var lastSusNote = false; // If the last note is a sus note
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,null,NoteType,songNotes,gottaHitNote,daSection * 4);
					sustainNote.scrollFactor.set();
					sustainNote.sustainLength = susLength;
					unspawnNotes.push(sustainNote);
					lastSusNote = true;

					// sustainNote.mustPress = gottaHitNote;

					// if (sustainNote.mustPress)
					// {
					// 	sustainNote.x += FlxG.width / 2; // general offset
					// }
				}

				if (onlinemod.OnlinePlayMenuState.socket == null && lastSusNote){ // Moves last sustain note so it looks right, hopefully
					unspawnNotes[Std.int(unspawnNotes.length - 1)].strumTime -= (Conductor.stepCrochet * 0.4);
				}
			}

			daSection += 1;
		}

		if(MirrorMode > 0){
			switch(MirrorMode){
				case 1: mania = playermania;
				case 2: playermania = mania;
			}
			SONG.keyCount = SONG.playerKeyCount = keyAmmo[mania];
			var oldNote:Note = null;
			for(i in 0...unspawnNotes.length){
				if(unspawnNotes[i].isSustainNote) continue;
				var dupeNote:Note = new Note(unspawnNotes[i].strumTime, unspawnNotes[i].noteData, oldNote,null,null,unspawnNotes[i].type,unspawnNotes[i].rawNote,!unspawnNotes[i].mustPress);
				dupeNote.sustainLength = unspawnNotes[i].sustainLength;
				oldNote = dupeNote;
				unspawnNotes.push(dupeNote);
				var susLength:Float = unspawnNotes[i].sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					var sustainNote:Note = new Note(unspawnNotes[i].strumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, unspawnNotes[i].noteData, oldNote, true,null,unspawnNotes[i].type,unspawnNotes[i].rawNote,!unspawnNotes[i].mustPress);
					sustainNote.scrollFactor.set();
					sustainNote.sustainLength = susLength;
					unspawnNotes.push(sustainNote);
				}
			}
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
	public var useNoteCameras:Bool = true; // Legacy support because fuck you
	public var playerNoteCamera:FlxCamera;
	public var opponentNoteCamera:FlxCamera;
	inline function readdCam(camera:FlxCamera){
		FlxG.cameras.remove(camera,false);
		FlxG.cameras.add(camera,false);
	}

	private function generateStaticArrows(player:Int):Void
	{
		if(useNoteCameras){
			if(player == 1){
				if(playerNoteCamera != null)playerNoteCamera.destroy();
				playerNoteCamera = new FlxCamera(0,0,
												1280,720
												);
				if(FlxG.save.data.undlaSize == 0 && underlay != null){
					underlay.cameras = [playerNoteCamera];
					// playerNoteCamera.fill(FlxColor.BLACK,true,FlxG.save.data.undlaTrans);
				}
				timerBar.cameras = [playerNoteCamera];
				timerText.cameras = [playerNoteCamera];
				playerNoteCamera.bgColor = 0x00000000;
				playerNoteCamera.color = 0xAAFFFFFF;
				// playerNoteCamera.x = ;
				// playerNoteCamera.width = ;
				// readdCam(camHUD);
				FlxG.cameras.add(playerNoteCamera,false);

				readdCam(camHUD);
				readdCam(camTOP);
			}else{
				if(opponentNoteCamera != null)opponentNoteCamera.destroy();
				opponentNoteCamera = new FlxCamera(0,0,
												1280,(if(middlescroll) 1080 else 720));
				opponentNoteCamera.bgColor = 0x00000000;
				opponentNoteCamera.color = 0xAAFFFFFF;

				if(middlescroll){
					opponentNoteCamera.setScale(0.5,0.5);
				}
				// readdCam(camHUD,false);
				FlxG.cameras.add(opponentNoteCamera,false);
				readdCam(camHUD);
				readdCam(camTOP);

			}
		}

		var  _KeyAmmo:Int =(player == 1 ? SONG.playerKeyCount : SONG.keyCount);
		for (i in 0..._KeyAmmo)
		{
			// FlxG.log.add(i);
			trace('Create note ' + i + ' for ' + if(player == 1) "Boy" else "Not Boy");
			var babyArrow:StrumArrow = new StrumArrow(i,0, strumLine.y);

			charCall("strumNoteLoad",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteLoad",[babyArrow,player == 1]);
			babyArrow.init(player);

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if(Conductor.ManiaChangeMap.length == 0 || Conductor.ManiaChangeMap[0].Beat != -100)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.125 + (0.05 * i)});
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
			babyArrow.screenCenter(X);
			BabyArrowCenterX = babyArrow.x;
			var _mania = (player == 1 ? playermania : mania);
			babyArrow.x = BabyArrowCenterX + (Note.swagWidth[_mania] * i) - (Note.swagWidth[_mania] + (Note.swagWidth[_mania] * ((_KeyAmmo * 0.5) - 1.5)));

				babyArrow.cameras = [switch(player){
					case 1:
						playerNoteCamera;
					default:
						opponentNoteCamera;
				}];
			babyArrow.visible = (player == 1 || (FlxG.save.data.oppStrumLine && dadnoteamount > 10 && !BothSide));

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
			charCall("strumNoteAdd",[babyArrow,player],if (player == 1) 0 else 1);
			callInterp("strumNoteAdd",[babyArrow,player == 1]);
		}

		if(useNoteCameras){
			if(player == 1){
				if(underlay != null && FlxG.save.data.undlaSize == 0){
					underlay.screenCenter(X);
				}
				playerNoteCamera.x = Std.int(FlxG.width * (if(middlescroll) 0 else 0.25));
			}else{
				opponentNoteCamera.x = Std.int(FlxG.width * -0.25);
				if(middlescroll){
					opponentNoteCamera.x -= 100;
				}
			}
		}
		if(player == 1){add(grpNoteSplashes);}
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
			// Updating Discord Rich Presence.
			if(!finished)
			{
				DiscordClient.changePresence(
				detailsPausedText
				+ (botPlay ? " BotPlay" : Ratings.GenerateLetterRank(accuracy)),
				"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: " + songScore
				+ " | Misses: " + misses, iconRPC,false,null,PauseLargeiconRPC,iconRPCText);
			}
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
			if(FlxG.save.data.PauseMode != 2)canPause = true;
			else new FlxTimer().start(Conductor.crochet * 0.004, function(tmr)
				{
					canPause = true;
				});
			paused = false;

			if (startTimer.finished)
			{
				DiscordClient.changePresence(
					detailsText
					+ (botPlay ? " BotPlay" : Ratings.GenerateLetterRank(accuracy)),
					"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: " + songScore
					+ " | Misses: " + misses, iconRPC, true,
					songLength - Conductor.songPosition,LargeiconRPC,iconRPCText);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + (botPlay ? " BotPlay" : Ratings.GenerateLetterRank(accuracy)), iconRPC,false,0,LargeiconRPC,iconRPCText);
			}
		}

		super.closeSubState();
	}

	var resyncCount:Int = 0;
	var Bigresync:Int = 0;
	function resyncVocals():Void
	{
		FlxG.sound.music.play();
		if(songspeed < 1 || Conductor.rawPosition - FlxG.sound.music.time > Conductor.crochet * 8)
			{
				FlxG.sound.music.time = Conductor.rawPosition;
				Bigresync++;
			}
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
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			#end
		}
		resyncCount++;
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(
			detailsText
			+ (botPlay ? " BotPlay" : Ratings.GenerateLetterRank(accuracy)),
			"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: " + songScore
			+ " | Misses: " + misses, iconRPC, true,
			songLength - Conductor.songPosition,LargeiconRPC,iconRPCText);
	}
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var nps:Int = 0;
	var maxNPS:Int = 0;

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
		openSubState(new FinishSubState(boyfriendArray[0].getScreenPosition().x, boyfriendArray[0].getScreenPosition().y,win));
	}

	var songLengthTxt = "N/A";

	override public function update(elapsed:Float)
	{
		#if !debug
		try{
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

		super.update(elapsed);
		callInterp("update",[elapsed]);

		scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy,combo,maxCombo);
		if (updateTime) songTimeTxt.text = FlxStringUtil.formatTime(Math.floor(Conductor.songPosition / 1000), false) + "/" + songLengthTxt;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
			pause();

		if (BothSide){
			var hello:Int = 0;
			for(array in [iconP1Array,iconP2Array]){for(icon in array){
				icon.trackingOffset = hello * 75;
				icon.updateTracking(1 - (health * 0.5));
				hello++;
			}}
		}else{
			for(icon in 0...iconP1Array.length){
				iconP1Array[icon].trackingOffset = -26 + (75 * icon);
				iconP1Array[icon].updateTracking(if(healthBar.fillDirection == LEFT_TO_RIGHT) health * 0.5 else 1 - (health * 0.5));
			}
			for(icon in 0...iconP2Array.length){
				iconP2Array[icon].trackingOffset = -(iconP2Array[icon].width - 26) - (75 * icon);
				iconP2Array[icon].updateTracking(if(healthBar.fillDirection == LEFT_TO_RIGHT) health * 0.5 else 1 - (health * 0.5));
			}
		}

		if (health > 2)
			health = 2;
		if(BothSide){
			for(array in [iconP1Array,iconP2Array]){for(icon in array){icon.updateAnim(healthBar.percent);}}
		}
		else if(!swappedChars){
			for(icon in iconP1Array){icon.updateAnim(healthBar.percent);}
			for(icon in iconP2Array){icon.updateAnim(100 - healthBar.percent);}
		}
		else{
			for(icon in iconP1Array){icon.updateAnim(100 - healthBar.percent);}
			for(icon in iconP2Array){icon.updateAnim(healthBar.percent);}
		}
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
			if (FlxG.sound.music.time > Conductor.rawPosition)
			Conductor.rawPosition = FlxG.sound.music.time;
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
				}
			}
			if(FlxG.save.data.breakTimer > 0)BreakTimer(elapsed);
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}
		if(FlxG.save.data.animDebug){
			var vt = 0;
			if(vocals != null) vt = Std.int(vocals.time);
			var e = getDefaultCamPos();
			Overlay.debugVar += '\nResync/SongReset count:${resyncCount}/${Bigresync}'
				+'\nCondPos/RawPos time:${Std.int(Conductor.songPosition)}/${Std.int(Conductor.rawPosition)}'
				+'\nMusic/Vocals time:${Std.int(FlxG.sound.music.time)}/${vt}'
				+'\nScript Count:${interpCount}'
				+'\nChartType: ${SONG.chartType}'
				;
		}
		if (camBeat){
			if (FlxG.save.data.camMovement || !camLocked){FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);} else FlxG.camera.zoom = defaultCamZoom;
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}
		if(curBeat >= 128 && curSong == "Bopeebo")
			vocals.volume = 0;

		if (health <= 0 && !hasDied && !ChartingState.charting && onlinemod.OnlinePlayMenuState.socket == null){
			if(practiceMode) {
				if(!botPlay){
					hasDied = true;
					practiceText.text = "Practice Mode; Score won't be saved";
					practiceText.screenCenter(X);
					FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
				}
			} else finishSong(false);
		}
 		if (FlxG.save.data.resetButton && onlinemod.OnlinePlayMenuState.socket == null)
		{
			if(controls.RESET)
				finishSong(false);
		}
		try{
			addNotes();
		}catch(e){trace('Error adding notes to pool? ${e.message}');}
		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, songspeed);
		}
		#end

		if (generatedMusic && songStarted && !endingSong && FlxG.sound.music.length - Conductor.rawPosition <= Conductor.stepCrochet)
		{
			charCall("beforeendSong",[]);
			callInterp("beforeendSong",[]);
			if(unspawnNotes.length == 0 && notes.length == 0)
				trace("we're fuckin ending the song");
			else
				trace("there still note left but we're fuckin ending the song anyway");
			endingSong = true;
			handleTimes = generatedMusic = false;
			new FlxTimer().start(0.5, function(timer){endSong();});
		}
		if (generatedMusic && songStarted && !endingSong && Bigresync > 100 && songspeed != 1)
			{
				endingSong = true;
				handleTimes = generatedMusic = false;
				showTempmessage('Too many Song Reset Force End Song',FlxColor.RED);
				endSong();
			}
		if(realtimeCharCam){
			var f = getDefaultCamPos();

			camFollow.x = f[0] + additionCamPos[0];
			camFollow.y = f[1] + additionCamPos[1];
		}

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
		callInterp("updateAfter",[elapsed]);
		if(eventNotes.members.length > 0){
			var i = 0;
			var note:Note;
			while (i < eventNotes.members.length){
				note = eventNotes.members[i];
				i++;
				if(note == null || note.strumTime > Conductor.songPosition) continue;
				note.hit(note);
				eventNotes.remove(note,true);
				note.destroy();
			}
		}

		if (!inCutscene)
			if(timeSinceOnscreenNote > 0) timeSinceOnscreenNote -= elapsed;
			keyShit();
	#if !debug
	}catch(e){MainMenuState.handleError(e,'Caught "update" crash: ${e.message}\n ${e.stack}');}
	#end
}
public function pause(){
	persistentUpdate = false;
	persistentDraw = true;
	paused = true;
	openSubState(new PauseSubState(boyfriend.x, boyfriend.y));
	camFollow.x = defLockedCamPos[0];
	camFollow.y = defLockedCamPos[1];
	camGame.zoom = 1;
}
	@:keep inline function addNotes(){
		if(unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.rawPosition / songspeed < 2000){
			while(unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.rawPosition / songspeed < 2000)
			{
				var dunceNote:Note = unspawnNotes.shift();
				callInterp('noteSpawn',[dunceNote]);
				if(dunceNote.eventNote) // eventNote
					eventNotes.add(dunceNote);
				else{ // we add note lmao
					notes.add(dunceNote);
					var strumNote = (if (dunceNote.parentSprite != null) dunceNote.parentSprite else if (dunceNote.mustPress) playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))] else strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))] );
					updateNotePosition(dunceNote,strumNote);
				}
			}
		}
	}
	override function draw(){
		try{noteShit();}catch(e){handleError('Error during noteShit: ${e.message}\n ${e.stack}}');}
		callInterp("draw",[]);
		try{

			if(!FlxG.save.data.preformance){
				if(downscroll){
					notes.sort(FlxSort.byY,FlxSort.DESCENDING);
				}else{
					notes.sort(FlxSort.byY,FlxSort.ASCENDING);
				}
			}
		}catch(e){}
		super.draw();
		callInterp("drawAfter",[]);
	}

	public function followChar(?char:Int = 0,?locked:Bool = true){
		focusedCharacter = char;

		camIsLocked = (locked || cameraPositions[char] == null);
		var f = getDefaultCamPos();

		camFollow.x = f[0] + additionCamPos[0];
		camFollow.y = f[1] + additionCamPos[1];


	}
	public var cameraPositions:Array<Array<Float>> = [];
	public var camLocked:Bool = false;
	public var camIsLocked:Bool = false;
	public var defLockedCamPos:Array<Float> = [720, 500];
	public var lockedCamPos:Array<Float> = [720, 500];
	public var additionCamPos:Array<Float> = [0,0];
	public var focusedCharacter:Int = 0;
	public var BFCamID:Int = 0;
	public var DADCamID:Int = 0;
	public function updateCharacterCamPos(){ // Resets all camera positions
		cameraPositions = [
			[boyfriendArray[BFCamID].getMidpoint().x - 100 + boyfriendArray[BFCamID].camX,boyfriendArray[BFCamID].getMidpoint().y - 100 + boyfriendArray[BFCamID].camY],
			[dadArray[DADCamID].getMidpoint().x + 150 + dadArray[DADCamID].camX,dadArray[DADCamID].getMidpoint().y - 100 + dadArray[DADCamID].camY],
			[gf.getMidpoint().x + gf.camX,gf.getMidpoint().y - 100 + gf.camY]
		];
		lockedCamPos = defLockedCamPos;
	}
	public function getDefaultCamPos():Array<Float>{
		if(!moveCamera) return [camFollow.x,camFollow.y];
		if(camIsLocked) return lockedCamPos;
		if(realtimeCharCam){
			var char = switch(focusedCharacter){case 1: dadArray[DADCamID];case 2:gf;default: boyfriendArray[BFCamID];};
			var x = switch(focusedCharacter){case 2: 0;case 1: 150;default:-100;};
			cameraPositions[focusedCharacter] = [char.getMidpoint().x + x + char.camX,char.getMidpoint().y - 100 + char.camY];
		}
		return cameraPositions[focusedCharacter];
	}

	var shouldEndSong:Bool = true;
	function endSong():Void
	{
		inCutscene = true;
		paused = true;
		if(endDialogue[0] != null){
			canPause = false;
			var doof:DialogueBox = new DialogueBox(false, endDialogue);
			vocals.stop();
			vocals.volume = 0;
			endDialogue = [];
			doof.scrollFactor.set();
			doof.finishThing = endSong;
			camHUD.alpha = 1;
			doof.cameras = [camHUD];

			// inCutscene = true;
			add(doof);
			return;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		charCall("endSong",[]);
		callInterp("endSong",[]);
		if(!shouldEndSong){shouldEndSong = true;return;}
		if (isStoryMode){
			campaignScore += Math.round(songScore);

			storyPlaylist.remove(storyPlaylist[0]);
			StoryMenuState.weekMarvelous = marvelous;
			StoryMenuState.weekSicks = sicks;
			StoryMenuState.weekBads = bads;
			StoryMenuState.weekShits = shits;
			StoryMenuState.weekGoods = goods;
			StoryMenuState.weekMisses = misses;
			StoryMenuState.weekMaxCombo = maxCombo;
			StoryMenuState.weekScore = songScore;
			StoryMenuState.weekAccuracy = accuracy;
			if (storyPlaylist.length <= 0)
			{
				// FlxG.sound.playMusic(Paths.music('freakyMenu'));
				trace("Song finis");
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				sectionStart = false;
				Highscore.saveWeekScore(storyWeek, songScore, storyDifficulty);
				FlxG.save.flush();
				finishSong(true);
			}
			else if(!StoryMenuState.isVanillaWeek){
				trace('Swapping songs');
				resetInterps();
				FlxG.sound.music.stop();
				prevCamFollow = camFollow;
				StoryMenuState.curSong++;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				StoryMenuState.swapSongs();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'),FlxG.save.data.otherVol);
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else finishSong(!hasDied);
	}
	var endingSong:Bool = false;

	var lastNoteSplash:NoteSplash;
	var lastRating:FlxSprite = null;
	var lastCombo:Array<FlxSprite> = [];
	var lastMS:Array<FlxText> = [null,null,null,null];
	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			vocals.volume = FlxG.save.data.voicesVol;
			var score:Float = RatingScore[0];
			var altscore:Float = AltRatingScore[0];

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			var daRating = daNote.rating;
			if(daNote.isSustainNote && FlxG.save.data.scoresystem == 7)
				daRating = "marvelous";

			switch(daRating)
			{
				case 'shit':
					score = RatingScore[4];
					altscore = AltRatingScore[4];
					if (FlxG.save.data.ShitCombo) combo = 0;
					health -= 0.2;
					shits++;
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.25;
				case 'bad':
					score = RatingScore[3];
					altscore = AltRatingScore[3];
					health -= 0.06;
					bads++;
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.50;
				case 'good':
					score = RatingScore[2];
					altscore = AltRatingScore[2];
					goods++;
					if (health < 2) health += 0.04;
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.75;
				case 'sick':
						score = RatingScore[1];
						altscore = AltRatingScore[1];
					if (health < 2) health += 0.1;
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 1;
					sicks++;
					if (FlxG.save.data.noteSplash && !daNote.isSustainNote){
						var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
						a.setupNoteSplash(playerStrums.members[daNote.noteData], daNote.noteData);
						lastNoteSplash = a;
						grpNoteSplashes.add(a);
					}
				case 'marvelous':
					if (health < 2) health += 0.125;
					if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 1.01;
					marvelous++;
					if (FlxG.save.data.noteSplash && !daNote.isSustainNote){
						var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
						a.setupNoteSplash(playerStrums.members[daNote.noteData], daNote.noteData);
						lastNoteSplash = a;
						grpNoteSplashes.add(a);
					}
			}

			switch(FlxG.save.data.scoresystem)
			{
				case 0: songScoreInFloat += score * songspeed; //FNF
				case 1: songScoreInFloat += score + (score * ((combo * songspeed) / 25)); //Osu!
				case 2: songScoreInFloat += (1000000 / bfnoteamount) * (score / 350); //Osu!mania
				case 3: songScoreInFloat += score * ScoreMultiplier * songspeed; //Bal
				case 4: songScoreInFloat += score * ScoreDivider * songspeed; //Bal Invert
				case 5: songScoreInFloat += Math.floor(score * Math.min(5,Math.ceil(combo / 10))); //Voiid
				case 6: songScoreInFloat += Math.floor(score * Math.ceil(combo / 10) * songspeed); //Voiid Uncap
				case 7: songScoreInFloat += score * combo * songspeed; //Stupid
			}
			switch(FlxG.save.data.altscoresystem)
			{
				case 0: altsongScore += 1; //:shrug:
				case 1: altsongScore += altscore * songspeed; //FNF
				case 2: altsongScore += altscore + (altscore * ((combo * songspeed) / 25)); //Osu!
				case 3: altsongScore += (1000000 / bfnoteamount) * (altscore / 350); //Osu!mania
				case 4: altsongScore += altscore * ScoreMultiplier * songspeed; //Bal
				case 5: altsongScore += altscore * ScoreDivider * songspeed; //Bal Invert
				case 6: altsongScore += Math.floor(altscore * Math.min(5,Math.ceil(combo / 10))); //Voiid
				case 7: altsongScore += Math.floor(altscore * Math.ceil(combo / 10) * songspeed); //Voiid Uncap
				case 8: altsongScore += altscore * combo * songspeed; //Stupid
			}
			songScore = Math.round(songScoreInFloat);
			// songScoreDef += ConvertScore.convertScore(noteDiff);

			if((FlxG.save.data.noterating == 0 && FlxG.save.data.showTimings == 0 && FlxG.save.data.showCombo == 0) || daNote.isSustainNote) return;

			var strum = playerStrums.members[daNote.noteData];
			var firstStrum = playerStrums.members[0];
			var lastStrum = playerStrums.members[playerStrums.members.length - 1];

			var rating:FlxSprite=null;
			if(FlxG.save.data.noterating > 0){
				if(FlxG.save.data.noterating == 2 && lastRating != null) lastRating.kill();
				rating = new FlxSprite().loadGraphic(SELoader.cache.loadGraphic('assets/shared/images/$daRating.png'));
				if(middlescroll || !swappedChars)
					rating.x = firstStrum.x - 100;
				else
					rating.x = lastStrum.x + lastStrum.width;
				rating.y = firstStrum.y + (firstStrum.height * 0.5);
				if(!middlescroll) rating.y -= 33;
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);
				add(rating);

				rating.setGraphicSize(Std.int(rating.width * 0.3));
				rating.antialiasing = true;
				rating.updateHitbox();
				rating.cameras = [playerNoteCamera];
				
				FlxTween.tween(rating, {alpha: 0}, 0.3, {
					startDelay: Conductor.crochet * 0.001,
					onComplete: function(tween:FlxTween){rating.destroy();}
					});
				lastRating = rating;
			}

			var currentTimingShown:FlxText=null;
			var txtColor:FlxColor = FlxColor.CYAN;
			switch(daRating)
			{
				case 'shit': txtColor = FlxColor.RED;
				case 'bad': txtColor = FlxColor.ORANGE;
				case 'good': txtColor = FlxColor.GREEN;
				case 'sick' | 'marvelous': txtColor = FlxColor.CYAN;
			}

			if(FlxG.save.data.showTimings > 0){
				if(FlxG.save.data.showTimings == 2 && lastMS[daNote.noteData] != null) lastMS[daNote.noteData].kill();
				var _dist = (Conductor.songPosition - daNote.strumTime);
				currentTimingShown = new FlxText(0,0,100,Std.string(Math.floor(noteDiff * 1000) * 0.001) + "ms " + ((_dist == 0) ? "=" :((downscroll && _dist < 0 || !downscroll && _dist > 0) ? "^" : "v")));
				currentTimingShown.color = txtColor;
				currentTimingShown.borderStyle = OUTLINE;
				currentTimingShown.borderSize = 1;
				currentTimingShown.borderColor = FlxColor.BLACK;
				currentTimingShown.size = 20;
				currentTimingShown.alignment=CENTER;

				add(currentTimingShown);

				currentTimingShown.x = (strum.x + (strum.width * 0.5)) - (currentTimingShown.width * 0.5);
				currentTimingShown.y = daNote.y + (daNote.height * 0.5);
				currentTimingShown.acceleration.y = -200;
				currentTimingShown.velocity.y = 140;

				currentTimingShown.velocity.x += FlxG.random.int(-20, 20);
				currentTimingShown.updateHitbox();
				currentTimingShown.cameras = [playerNoteCamera];
				lastMS[daNote.noteData] = currentTimingShown;
				FlxTween.tween(currentTimingShown, {alpha: 0,y:currentTimingShown.y - 60}, Conductor.crochet * 0.002, {
					onComplete: function(tween:FlxTween){currentTimingShown.destroy();},
					startDelay: Conductor.crochet * 0.001,
				});
			}

			var scoreObjs:Array<FlxSprite> = [];
			if(FlxG.save.data.showCombo > 0){
				if(FlxG.save.data.showCombo == 2 && lastCombo.length > 0){
					for(thing in lastCombo){thing.kill();}
				}
				var comboSplit:Array<String> = ('$combo').split('');
				var comboSize = 1.20 - (comboSplit.length * 0.1);
				for (i in 0...comboSplit.length) {
					var num:Int = Std.parseInt(comboSplit[i]);
					var numScore:FlxSprite = new FlxSprite().loadGraphic(SELoader.cache.loadGraphic('assets/images/num$num.png'));
					if(middlescroll)
						numScore.x = lastStrum.x + (lastStrum.width) + ((43 * comboSize) * i);
					else{
						if(!swappedChars)
							numScore.x = (firstStrum.x - 100) + ((43 * comboSize) * i);
						else
							numScore.x = (lastStrum.x + lastStrum.width) + ((43 * comboSize) * i);
					}
					if(!middlescroll && !swappedChars){
						if(comboSplit.length >= 4)
							numScore.x -= numScore.width * 0.5;
						else if(comboSplit.length >= 3)
							numScore.x -= numScore.width * 0.25;
					}
					numScore.y = lastStrum.y + (lastStrum.height * 0.5);
					if(!middlescroll) numScore.y += 33;
					numScore.cameras = [playerNoteCamera];
					if(goods == 0 && bads == 0 && shits == 0 && misses == 0)
						numScore.color = 0xFFFFBF00; //#FFBF00 gold
					else numScore.color = txtColor;

					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int((numScore.width * comboSize) * 0.5));
					numScore.updateHitbox();

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);
					add(numScore);
					scoreObjs.push(numScore);
					FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						onComplete: function(tween:FlxTween) {numScore.destroy();},
						startDelay: Conductor.crochet * 0.002
					});
				}
				lastCombo = scoreObjs;
			}
			callInterp('popUpScore',[rating,scoreObjs,currentTimingShown]);
		}

		public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;

		private function fromBool(input:Bool):Int{
			if (input) return 1;
			return 0; 
		}
		private function fromInt(?input:Int = 0):Bool{
			return (input == 1);
		}

	// Custom input handling

	function setInputHandlers(){
		while(FalseBoolArray.length < keyAmmo[mania]){
			FalseBoolArray.push(false);
		}
		if(botPlay){
			inputMode = 0;
			noteShit = SENoteShit;

			doKeyShit = BotplayKeyShit;
			goodNoteHit = kadeBRGoodNote;
			inputEngineName = "SE-botplay";
			return;
		}
		inputMode = FlxG.save.data.inputHandler;
		var inputEngines = ["SE-LEGACY" + (if (FlxG.save.data.accurateNoteSustain) "-ACNS" else "") 
		#if(!mobile), 'SE'+ (if (FlxG.save.data.accurateNoteSustain) "-ACNS" else "")#end
		];
		if(inputMode == 0 && mania > 8){
			inputMode = 1;
			showTempmessage("Old input do not support 10K+",FlxColor.RED);
		}
		trace('Using ${inputMode}');
		switch(inputMode){
			case 0:
				noteShit = SENoteShit;
				doKeyShit = kadeBRKeyShit;
				goodNoteHit = kadeBRGoodNote;
			#if(!mobile)
			case 1:
				noteShit = SENoteShit;
				doKeyShit = SEKeyShit;
				goodNoteHit = kadeBRGoodNote;
				SEIUpdateKeys();
				FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, SEIKeyPress);
				FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, SEIKeyRelease);
			#end
			default:
				MainMenuState.handleError('${inputMode} is not a valid input! Please change your input mode!');
		}
		inputEngineName = if(inputEngines[inputMode] != null) inputEngines[inputMode] else "Unspecified";
	}
	dynamic function noteShit(){MainMenuState.handleError("I can't handle input for some reason, Please report this!");}
	public function DadStrumPlayAnim(id:Int) {
		var spr:StrumArrow= (!BothSide ? cpuStrums.members[id] : playerStrums.members[id]);
		if(spr != null) {
					spr.confirm();
		}
	}
	public function BFStrumPlayAnim(id:Int) {
		var spr:StrumArrow= playerStrums.members[id];
		if(spr != null) {
					spr.confirm();
		}
	}

	private function keyShit():Void
		{doKeyShit();}
	private dynamic function doKeyShit():Void
		{MainMenuState.handleError("I can't handle key inputs? Please report this!");}

	// Super Engine input and handling
	function SENoteShit(){
		if (!generatedMusic) return;
		var _scrollSpeed = scrollspeed; // Probably better to calculate this beforehand
		var strumNote:FlxSprite;
		var i = notes.members.length - 1;
		var daNote:Note;
		while (i > -1){
			daNote = notes.members[i];
			i--;
			if(daNote == null || !daNote.alive) continue;
			// instead of doing stupid y > FlxG.height
			// we be men and actually calculate the time :)
			if (daNote.tooLate)
			{
				notes.remove(daNote, true);
				daNote.destroy();
			}
			else
			{
				daNote.visible = true;
				daNote.active = true;
			}
			strumNote = (if (daNote.parentSprite != null) daNote.parentSprite else if (daNote.mustPress) playerStrums.members[Math.floor(Math.abs(daNote.noteData))] else strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))] );
			daNote.distanceToSprite = 0.45 * ((Conductor.songPosition - daNote.strumTime) / songspeed) * _scrollSpeed;
			if(daNote.updateY){
				switch (downscroll){
					case true:{
						daNote.y = strumNote.y + daNote.distanceToSprite;
						if(daNote.isSustainNote)
						{
							if(daNote.isSustainNoteEnd && daNote.prevNote != null)
								daNote.y = daNote.prevNote.y - (daNote.height * 0.5);
							else
								daNote.y += daNote.height * 0.5;

							// Only clip sustain notes when properly hit
							if(daNote.clipSustain && (daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || _dadShow && daNote.aiShouldPress) && FlxG.overlap(daNote,strumNote))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (strumNote.y + (Note.swagWidth[mania] / 2) - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
								daNote.susHit(if(daNote.mustPress)0 else 1,daNote);
								callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
							}
						}
				
					}
					case false:{
						daNote.y = strumNote.y - daNote.distanceToSprite;
						if(daNote.isSustainNote)
						{
							if(daNote.isSustainNoteEnd && daNote.parentNote != null)
								daNote.y = daNote.prevNote.y + (daNote.height * 2.5);
							else
								daNote.y -= daNote.height * 0.5;
							if(daNote.clipSustain && (daNote.isPressed || !daNote.mustPress) && (daNote.mustPress || _dadShow && daNote.aiShouldPress) && FlxG.overlap(daNote,strumNote))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumNote.y + (Note.swagWidth[mania] / 2) - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								if(daNote.mustPress && swagRect.height < 0 ) {goodNoteHit(daNote);continue;}

								daNote.clipRect = swagRect;
								daNote.susHit(if(daNote.mustPress) 0 else 1,daNote);
								callInterp("susHit" + (if(daNote.mustPress) "" else "Dad"),[daNote]);
							}
						}
					}
				}
			}
			if (daNote.skipNote) continue;

			updateNotePosition(daNote,strumNote);

			if(daNote.mustPress && daNote.tooLate){
				if (!daNote.shouldntBeHit)
				{
					health += SONG.noteMetadata.tooLateHealth;
					vocals.volume = 0;
					noteMiss(daNote.noteData, daNote);
				}

				notes.remove(daNote, true);
				daNote.destroy();
			}
		}
	}

	@:keep inline function updateNotePosition(daNote:Note,strumNote:FlxSprite){
		if ((daNote.mustPress || !daNote.wasGoodHit) && daNote.lockToStrum){
			daNote.visible = strumNote.visible;
			if(daNote.updateX) daNote.x = strumNote.x + (strumNote.width * 0.5);
			if(!daNote.isSustainNote && daNote.updateAngle) daNote.angle = strumNote.angle;
			if(daNote.updateAlpha) daNote.alpha = strumNote.alpha * (daNote.isSustainNote ? 0.6 : 1);
			if(daNote.updateScrollFactor) daNote.scrollFactor.set(strumNote.scrollFactor.x,strumNote.scrollFactor.y);
			if(daNote.updateCam) daNote.cameras = [if(daNote.ourNote || daNote.mustPress) playerNoteCamera else opponentNoteCamera];
		}
	}
	private function SEKeyShit():Void{ // Only used for holds, not pressing
		if (!generatedMusic) return;
		boyfriend.isPressingNote = false;
		callInterp("holdShit",[holdArray]);
		charCall("holdShit",[holdArray]);

		if (generatedMusic && acceptInput && !boyfriend.isStunned && holdArray.contains(true)) {

 			var daNote:Note;
 			var i:Int = 0;
			
 			boyfriend.holdTimer = 0;
			boyfriend.isPressingNote = true;
			while(i < notes.members.length){
				daNote = notes.members[i];
				i++;
				if(daNote == null || !holdArray[daNote.noteData] || !daNote.mustPress || !daNote.isSustainNote || !daNote.canBeHit) continue;
				if(!FlxG.save.data.accurateNoteSustain || daNote.strumTime <= Conductor.songPosition - 50 || daNote.isSustainNoteEnd) // Only destroy the note when properly hit
					{goodNoteHit(daNote);continue;}
				// Tell note to be clipped to strumline
				daNote.isPressed = true;
				
				daNote.susHit(0,daNote);
				callInterp("susHit",[daNote]);
			}
		}
 		callInterp("holdShitAfter",[holdArray]);
 		charCall("holdShitAfter",[holdArray]);
		if (boyfriend.currentAnimationPriority == 10 && (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.dadVar * 0.001 || boyfriend.isDonePlayingAnim()) && !boyfriend.isPressingNote) {
			for(char in boyfriendArray){if(!char.animation.curAnim.name.startsWith("dance") && !char.animation.curAnim.name.startsWith("idle")){char.dance(curBeat % 2 == 0);}}
		}
	}
	var SEIKeyMap:Map<Int,Int> = [];
	var SEIKeyHeld:Map<Int,Bool> = [];
	var SEIBlockInput:Bool = false;
	function SEIUpdateKeys(){
		SEIKeyMap = [];
		callInterp('registerKeys',[SEIKeyMap]);
		switch(playermania){
			case 0:
				SEIKeyMap[FlxKey.fromStringMap['LEFT']] =	0;
				SEIKeyMap[FlxKey.fromStringMap['DOWN']] =	1;
				SEIKeyMap[FlxKey.fromStringMap['UP']] =		2;
				SEIKeyMap[FlxKey.fromStringMap['RIGHT']] =	3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.leftBind]] =		0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltleftBind]] =	0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.downBind]] =		1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltdownBind]] =	1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.upBind]] =		2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltupBind]] =		2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.rightBind]] =		3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltrightBind]] =	3;
			case 1: 
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.L1Bind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.D1Bind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.R1Bind]] = 2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.L2Bind]] = 3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.U1Bind]] = 4;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.R2Bind]] = 5;
			case 2: 
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.L1Bind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.D1Bind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.R1Bind]] = 2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N4Bind]] = 3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.L2Bind]] = 4;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.U1Bind]] = 5;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.R2Bind]] = 6;
			case 3: 
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N0Bind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N1Bind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N2Bind]] = 2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N3Bind]] = 3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N4Bind]] = 4;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N5Bind]] = 5;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N6Bind]] = 6;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N7Bind]] = 7;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N8Bind]] = 8;
			case 4:
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.leftBind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltleftBind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.downBind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltdownBind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N4Bind]] = 2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.upBind]] = 3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltupBind]] = 3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.rightBind]] = 4;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltrightBind]] = 4;
			case 5:
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N0Bind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N1Bind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N2Bind]] = 2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N3Bind]] = 3;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N5Bind]] = 4;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N6Bind]] = 5;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N7Bind]] = 6;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N8Bind]] = 7;
			case 6:
				SEIKeyMap[FlxKey.fromStringMap['ANY']] = 0;
			case 7:
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.leftBind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltleftBind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.rightBind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltrightBind]] = 1;
			case 8:
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.leftBind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltleftBind]] = 0;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.N4Bind]] = 1;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.rightBind]] = 2;
				SEIKeyMap[FlxKey.fromStringMap[FlxG.save.data.AltrightBind]] = 2;
			default:
				var arr:Array<String> = cast FlxG.save.data.keys[mania - 9];
				for(i => v in arr){
					SEIKeyMap[FlxKey.fromStringMap[v]] = i; 
				}
		}
		// callInterp('registerKeysAfter',[SEIKeyMap]);
	}
	function SEIKeyPress(event:KeyboardEvent){
		if(this != FlxG.state){
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, SEIKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, SEIKeyRelease);
			return;
		}
		pressArray = releaseArray = FalseBoolArray.copy();
		// var keyCode:FlxKey = event.keyCode;
		// var data:Null<Int> = SEIKeyMap[keyCode];
		// if(data == null) data = -1;
		SEIBlockInput = false;
		callInterp('keyPress',[event.keyCode]);
		try{if (SEIBlockInput || !acceptInput || boyfriend.isStunned || !generatedMusic || subState != null || paused ) return;}catch(e){return;}
		
		for(key => data in SEIKeyMap){
			if(FlxG.keys.checkStatus(key, JUST_PRESSED) && !SEIKeyHeld[key]){
				pressArray[data] = true;
				holdArray[data] = true;
				var strum = playerStrums.members[data];
				SEIKeyHeld[key] = true;
				if(strum != null) strum.press();
			}else if(FlxG.keys.checkStatus(key, PRESSED)){
				SEIKeyHeld[key] = true;
				holdArray[data] = true;
			}
		}
		callInterp('keyShit',[pressArray,holdArray]);
		charCall("keyShit",[pressArray,holdArray]);
		if(!pressArray.contains(true) || SEIBlockInput || !acceptInput) return;

		boyfriend.holdTimer = 0;
		var hitArray = FalseBoolArray.copy();
		if(holdArray.contains(true)){
			boyfriend.isPressingNote = true;
			var daNote = null;
			var i = notes.members.length;
			while(i < notes.members.length){
				daNote = notes.members[i];
				i++;
				if(daNote == null || !holdArray[daNote.noteData] || !daNote.mustPress || !daNote.isSustainNote || !daNote.canBeHit) continue;
				if(!FlxG.save.data.accurateNoteSustain || daNote.strumTime <= Conductor.songPosition - 50 || daNote.isSustainNoteEnd) // Only destroy the note when properly hit
					{goodNoteHit(daNote);continue;}
				// Tell note to be clipped to strumline
				daNote.isPressed = true;
				hitArray[daNote.noteData] = true;
				daNote.susHit(0,daNote);
				callInterp("susHit",[daNote]);
			}
		}
		var possibleNotes:Array<Note> = []; // notes that can be hit
		var onScreenNote:Bool = false;
		var i = notes.members.length;
		var daNote:Note;
		while (i >= 0) {
			daNote = notes.members[i];
			i--;
			if (daNote == null || !daNote.alive || daNote.skipNote || !daNote.mustPress) continue;
			
			if (!onScreenNote) onScreenNote = true;
			if (!pressArray[daNote.noteData] || !daNote.canBeHit || daNote.tooLate || daNote.wasGoodHit) continue;
			var coolNote = possibleNotes[daNote.noteData];
			if (coolNote != null){
				if((Math.abs(daNote.strumTime - coolNote.strumTime) < 7)){notes.remove(daNote,true);daNote.destroy();continue;}
				if((daNote.strumTime > coolNote.strumTime)) continue;
			}
			possibleNotes[daNote.noteData] = daNote;

		}

		if(onScreenNote) timeSinceOnscreenNote = 0.5;
		i = pressArray.length;
		daNote = null;
		var ghostTapping = FlxG.save.data.ghost;
		while(i > 0) {
			i--;
			daNote = possibleNotes[i];
			if(daNote == null && pressArray[i] && timeSinceOnscreenNote > 0){
				ghostTaps++;
				if(!ghostTapping){
					noteMiss(i, null);
				}
				continue;
			}
			if(daNote == null) continue;
			hitArray[daNote.noteData] = true;
			goodNoteHit(daNote);
		}
		callInterp('keyShitAfter',[pressArray,holdArray,hitArray]);
		charCall("keyShitAfter",[pressArray,holdArray,hitArray]);
		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				{
					if(BothSide && spr.ID < 4 && !boyfriendArray[onlinecharacterID].animation.curAnim.name.endsWith("miss"))
						dadArray[onlinecharacterID].playAnim(Note.noteAnimsAlt[spr.ID],true);
					else if(!boyfriendArray[onlinecharacterID].animation.curAnim.name.endsWith("miss"))
						boyfriendArray[onlinecharacterID].playAnim(Note.playernoteAnims[spr.ID],true);
					onlineNoteHit(-1,spr.ID + 1);
				}
		});

	}
	function SEIKeyRelease(event:KeyboardEvent){
		if(this != FlxG.state){
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, SEIKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, SEIKeyRelease);
			return;
		}
		callInterp('keyRelease',[event.keyCode]);
		holdArray = FalseBoolArray.copy();

		for(key => data in SEIKeyMap){
			if(FlxG.keys.checkStatus(key, PRESSED) && acceptInput && !boyfriend.isStunned){
				holdArray[data] = true;
			}else{
				SEIKeyHeld[key] = false;
			}
		}
		for(id => bool in holdArray){
			if(!bool){
				var strum = playerStrums.members[id];
				if(strum == null) return;
				strum.playStatic();
			}
		}
	}

	function BotplayKeyShit(){
		if(!botPlay)return kadeBRKeyShit();
		holdArray = pressArray = releaseArray = FalseBoolArray.copy();
		var i = 0;
		var daNote:Note = null;
		callInterp('botKeyShit',[]);
		while(i < notes.members.length){
			daNote = notes.members[i];
			i++;
			if(daNote == null || !daNote.mustPress || !daNote.canBeHit || daNote.shouldntBeHit) continue;
			
			if(daNote.strumTime <= Conductor.songPosition){boyfriend.holdTimer = 0;pressArray[daNote.noteData] = true;goodNoteHit(daNote);continue;}
			if(!daNote.isSustainNote) continue;
			boyfriend.holdTimer = 0;
			// hitArray[daNote.noteData] = true;
			// Tell note to be clipped to strumline
			daNote.isPressed = true;
			holdArray[daNote.noteData] = true;
			daNote.susHit(0,daNote);
			callInterp("susHit",[daNote]);
		}

		boyfriend.isPressingNote = holdArray.contains(true);
		playerStrums.forEach(function(spr:StrumArrow){if (spr.animation.finished)spr.playStatic();});
	}

 	private function kadeBRKeyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				switch(mania)
				{
					default:
						hold = [FlxG.keys.pressed.SPACE];
						press = [FlxG.keys.justPressed.SPACE];
						release = [FlxG.keys.justReleased.SPACE];
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
				}
				var holdArray:Array<Bool> = hold;
				var pressArray:Array<Bool> = press;
				var releaseArray:Array<Bool> = release;
				
				var hitArray:Array<Bool> = [false,false,false,false,false,false,false,false,false,false,false,false,false];
				callInterp("keyShit",[pressArray,holdArray]);
				charCall("keyShit",[pressArray,holdArray]);

				if (!acceptInput || boyfriend.isStunned) {holdArray = pressArray = releaseArray = [false,false,false,false];}

				// HOLDS, check for sustain notes
				if (generatedMusic && (holdArray.contains(true) || releaseArray.contains(true))) {
		
					 var daNote:Note;
					 var i:Int = 0;
					
					while(i < notes.members.length){
						daNote = notes.members[i];
						i++;
						if(daNote == null || !holdArray[daNote.noteData] || !daNote.mustPress || !daNote.isSustainNote || !daNote.canBeHit) continue;
						if(!FlxG.save.data.accurateNoteSustain || daNote.strumTime <= Conductor.songPosition - 50 || daNote.isSustainNoteEnd) // Only destroy the note when properly hit
							{goodNoteHit(daNote);continue;}
						hitArray[daNote.noteData] = true;
						// Tell note to be clipped to strumline
						daNote.isPressed = true;
						
						daNote.susHit(0,daNote);
						callInterp("susHit",[daNote]);
					}
				}
		 
				// PRESSES, check for note hits
				
				if (generatedMusic && pressArray.contains(true))
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = [null,null,null,null]; // notes that can be hit
					 var onScreenNote:Bool = false;
					 var i = notes.members.length;
					 var daNote:Note;
					 while (i >= 0) {
						daNote = notes.members[i];
						i--;
						if (daNote == null || !daNote.alive || daNote.skipNote || !daNote.mustPress) continue;
		
						if (!onScreenNote) onScreenNote = true;
						if (!pressArray[daNote.noteData] || !daNote.canBeHit || daNote.tooLate || daNote.wasGoodHit) continue;
						var coolNote = possibleNotes[daNote.noteData];
						if (coolNote != null)
						{
							if((Math.abs(daNote.strumTime - coolNote.strumTime) < 7)){notes.remove(daNote,true);daNote.destroy();continue;}
							if((daNote.strumTime > coolNote.strumTime)) continue;
						}
						possibleNotes[daNote.noteData] = daNote;
					}
					if(onScreenNote) timeSinceOnscreenNote = 0.5;
					 i = pressArray.length;
					 daNote = null;
					while(i > 0) {
						i--;
						daNote = possibleNotes[i];
						if(daNote == null && pressArray[i] && timeSinceOnscreenNote > 0){
							ghostTaps++;
							if(!FlxG.save.data.ghost){
								noteMiss(i, null);
							}
							continue;
						}
						if(daNote == null) continue;
						hitArray[daNote.noteData] = true;
						goodNoteHit(daNote);
					}
				}
				 callInterp("keyShitAfter",[pressArray,holdArray,hitArray]);
				 charCall("keyShitAfter",[pressArray,holdArray,hitArray]);
				boyfriend.isPressingNote = holdArray.contains(true);
				if (boyfriend.currentAnimationPriority == 10 && (boyfriend.holdTimer > Conductor.stepCrochet * boyfriend.dadVar * 0.001 || boyfriend.isDonePlayingAnim()) && !boyfriend.isPressingNote) {
					for(char in boyfriendArray){if(!char.animation.curAnim.name.startsWith("dance") && !char.animation.curAnim.name.startsWith("idle")){char.dance(curBeat % 2 == 0);}}
				}
		
		 
				var i = playerStrums.members.length - 1;
				var spr:StrumArrow;
				while (i >= 0){
					spr = playerStrums.members[i];
					i--;
					if(spr == null) continue;
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm'){
						spr.press();
						if(BothSide && spr.ID < 4 && !boyfriendArray[onlinecharacterID].animation.curAnim.name.endsWith("miss"))
							dadArray[onlinecharacterID].playAnim(Note.noteAnimsAlt[spr.ID],true);
						else if(!boyfriendArray[onlinecharacterID].animation.curAnim.name.endsWith("miss"))
							boyfriendArray[onlinecharacterID].playAnim(Note.noteAnimsAlt[spr.ID],true);
						onlineNoteHit(-1,spr.ID + 1);
					}
					else if (!holdArray[spr.ID]) spr.playStatic();
				}
			}

	function kadeBRGoodNote(note:Note, ?resetMashViolation = true):Void
		{

		if(!botPlay){
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
			note.rating = Ratings.CalculateRating(noteDiff);
		}else
			note.rating = "marvelous";

		if(note.shouldntBeHit){noteMiss(note.noteData,note,true);return;}
		callInterp("beforeNoteHit",[boyfriendArray[onlinecharacterID],note]);

		if (FlxG.save.data.npsDisplay && !note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if(logGameplay) eventLog.push({
			rating:note.rating,
			direction:note.noteData,
			strumTime:note.strumTime,
			isSustain:note.isSustainNote,
			time:Conductor.songPosition
		});
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote|| FlxG.save.data.scoresystem == 7)
			{
				combo++;
				popUpScore(note);
			}

			if(hitSound){
				if(note.isSustainNoteStart) FlxG.sound.play(holdSoundEff,FlxG.save.data.hitVol).x = (FlxG.camera.x) + (FlxG.width * ((note.noteData + 1) / keyAmmo[mania]));
				else if(!note.isSustainNote) FlxG.sound.play(hitSoundEff,FlxG.save.data.hitVol).x = (FlxG.camera.x) + (FlxG.width * ((note.noteData + 1) / keyAmmo[mania]));
			}
			if (note.noteData <= 3 && BothSide)
				{
					note.hit(1,note);
					callInterp("noteHitDad",[dadArray[onlinecharacterID],note]);
					onlineNoteHit(note.noteID,0);
				}
			else
				{
					note.hit(0,note);
					callInterp("noteHit",[boyfriendArray[onlinecharacterID],note]);
					onlineNoteHit(note.noteID,0);
				}
			
			note.wasGoodHit = true;
			if (boyfriendArray[onlinecharacterID].useVoices){boyfriendArray[onlinecharacterID].voiceSounds[note.noteData].play(1);boyfriendArray[onlinecharacterID].voiceSounds[note.noteData].time = 0;vocals.volume = 0;}else vocals.volume = 1;
			note.skipNote = true;
			notes.remove(note, true);
			updateAccuracy(note.isSustainNote);
			note.destroy();
		}
	}
		
	inline function onlineNoteHit(noteID:Int = -1,miss:Int = 0){
		if(stateType == 3)
			{
				if(noteID == -1)
					onlinemod.Sender.SendPacket(onlinemod.Packets.KEYPRESS, [noteID,miss,onlinecharacterID,invertedChart ? 1 : 0], onlinemod.OnlinePlayMenuState.socket);
				else
					onlinemod.Sender.SendPacket(onlinemod.Packets.KEYPRESS, [noteID,miss,onlinecharacterID], onlinemod.OnlinePlayMenuState.socket);
			}
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
			notes.remove(daNote, true);
			daNote.destroy();

		}
		if (!boyfriendArray[0].stunned)
		{
			if(FlxG.save.data.playMisses) if (boyfriendArray[0].useMisses){FlxG.sound.play(boyfriendArray[0].missSounds[direction], 1);}else{FlxG.sound.play(vanillaHurtSounds[Math.round(Math.random() * 2)], FlxG.random.float(0.1, 0.2));}
			// FlxG.sound.play(hurtSoundEff, 1);
			health += SONG.noteMetadata.missHealth;
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');
			if(FlxG.save.data.scoresystem != 7)combo = 0; else combo++;
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

			if(logGameplay) {eventLog.push ({
					rating:if(daNote == null) "Missed without note" else "Missed a note",
					direction:direction,
					strumTime:(if(daNote != null) daNote.strumTime else 0 ),
					isSustain:if(daNote != null) daNote.isSustainNote else false,
					time:Conductor.songPosition
				});
			}

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScoreInFloat -= 10;
			altsongScore -= 10;
			if (daNote != null && daNote.shouldntBeHit) {
				songScoreInFloat += SONG.noteMetadata.badnoteScore;
				altsongScore += SONG.noteMetadata.badnoteScore;
				health += SONG.noteMetadata.badnoteHealth;
				badNote++;
			} // Having it insta kill, not a good idea
			songScore = Math.round(songScoreInFloat);
			if(daNote != null){
					callInterp("noteMiss",[boyfriendArray[onlinecharacterID],daNote]);
					boyfriend.callInterp('noteMiss',[daNote,direction]);
				}else{
					callInterp("miss",[boyfriendArray[onlinecharacterID],direction]);
					boyfriend.callInterp('miss',[direction]);
				}
			onlineNoteHit(if(daNote == null) -1 else daNote.noteID,direction + 1);
			updateAccuracy(false);
		}
	}

	function updateAccuracy(?sus:Bool = false)
		{
			if(!sus)totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			MA = HelperFunctions.truncateFloat(marvelous / (sicks + goods + bads + shits + misses),2);
			SA = HelperFunctions.truncateFloat((sicks + marvelous) / (goods + bads + shits + misses),2);
			if(FlxG.save.data.JudgementCounter)
				judgementCounter.text = 'Combo: ${combo}' + (combo < maxCombo ? ' (Max: ' + maxCombo + ')' : '')
				+ '\nMarvelous: ${marvelous}'
				+ '\nSicks: ${sicks}'
				+ '\nGoods: ${goods}'
				+ '\nBads: ${bads}'
				+ '\nShits: ${shits}'
				+ '\nMisses: ${misses}'
				+ '\nGhost Taps: ${ghostTaps}'
				+ (badNote > 0 ? '\nBad Note: ${badNote}' : '')
				+ '\nMA: ${MA}'
				+ '\nSA: ${SA}'
				+ '\n'
				;
		}

	dynamic function goodNoteHit(note:Note, ?resetMashViolation = true):Void
		{MainMenuState.handleError('I cant register any note hits!');}

	override function stepHit()
	{
		if(lastStep == curStep)return;
		super.stepHit();
		if (handleTimes && generatedMusic && (FlxG.sound.music.time > (Conductor.songPosition * songspeed) + 20 || FlxG.sound.music.time < (Conductor.songPosition * songspeed) - 20))
			resyncVocals();
		try{
			callInterp("stepHit",[]);
			charCall("stepHit",[curStep]);
			if(Note.noteAnims != null && Note.noteAnims == []) Note.playernoteAnims = Note.noteAnims;
			if(boyfriend != null && boyfriend != boyfriendArray[0]) boyfriendArray[0] = boyfriend;
			if(dad != null && dad != dadArray[0]) dadArray[0] = dad;
			for (i => v in stepAnimEvents) {
				for (anim => ifState in v) {
					var variable:Dynamic = Reflect.field(this,ifState.variable);
					var play:Bool = false;
					if (ifState.type == "contains"){
						if (ifState.value.contains(variable)){play = true;}
					}else if(ifState.type == "function"){
						callInterp(ifState.value,[]);
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

	override function beatHit()
	{
		super.beatHit();
		callInterp("beatHit",[]);
		charCall("beatHit",[curBeat]);

		try{
			if(!FlxG.save.data.preformance){
				if(downscroll)
					notes.sort(FlxSort.byY,FlxSort.DESCENDING);
				else
					notes.sort(FlxSort.byY,FlxSort.ASCENDING);
			}
		}catch(e){}
		if (FlxG.save.data.songInfo == 0 || FlxG.save.data.songInfo == 1 || FlxG.save.data.songInfo == 3) {
			scoreTxt.screenCenter(X);
		}
		if(FlxG.save.data.JudgementCounter)
			judgementCounter.text = 'Combo: ${combo}' + (combo < maxCombo ? ' (Max: ' + maxCombo + ')' : '')
			+ '\nMarvelous: ${marvelous}'
			+ '\nSicks: ${sicks}'
			+ '\nGoods: ${goods}'
			+ '\nBads: ${bads}'
			+ '\nShits: ${shits}'
			+ '\nMisses: ${misses}'
			+ '\nGhost Taps: ${ghostTaps}'
			+ (badNote > 0 ? '\nBad Note: ${badNote}' : '')
			+ (totalNotesHit > 0 ? '\nMA: ${MA}' : '')
			+ (totalNotesHit > 0 ? '\nSA: ${SA}' : '')
			+ '\n'
			;

		if (generatedMusic && SONG.notes[Math.floor(curStep / 16)] != null)
		{
			curSection = Math.floor(curStep / 16);
			var sect = SONG.notes[curSection];
			if (sect.changeBPM && !Math.isNaN(sect.bpm))
				Conductor.changeBPM(sect.bpm * songspeed);

			PlayState.canUseAlts = sect.altAnim;
			var locked = (sect.centerCamera || !FlxG.save.data.camMovement || camLocked || (notes.members[0] == null && unspawnNotes[0] == null || (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition > 4000)) );
			followChar((sect.gfSection ? 2 : sect.mustHitSection ? 0 : 1),locked);
			handleManiaChange();
		}

		for(icon in iconP2Array){icon.bounce(60 / Conductor.bpm);}
		for(icon in iconP1Array){icon.bounce(60 / Conductor.bpm);}
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
						if(ifState.isFunc){
							ifState.func(this);
						}else{

							switch(i){
								case 0: boyfriend.playAnim(anim);
								case 1: dad.playAnim(anim);
								case 2: gf.playAnim(anim);
							}
						}
					}
				}
			}
		}catch(e){handleError('A animation event caused an error ${e.message}\n ${e.stack}');}

		gf.dance(curBeat % 2 == 0);
		for(array in [boyfriendArray,dadArray]){
			for(char in array){
				if(char != null)
					char.dance(curBeat % 2 == 0);
			}
		}
	}

	function handleManiaChange() {
		for(ManiaMap in Conductor.ManiaChangeMap){
			if (curBeat >= ManiaMap.Beat && !ManiaMap.Skip){ //change mania mid song lmao // geez the code is ass
				mania = playermania = SONG.mania = Changemania = ManiaMap.Mania;
				ManiaMap.Skip = true;
				resetNote();
				SEIUpdateKeys();
				if(keyAmmo.contains(SONG.keyCount))iconRPC = "mania" + keyAmmo[mania];
				else iconRPC = "wdym";
				iconRPCText = 'Song Mania: ${SONG.mania}';
				for(i in 0...playerStrums.length){
					FlxTween.tween(cpuStrums.members[i],{x: BabyArrowCenterX + (Note.swagWidth[mania] * i) + i - (Note.swagWidth[mania] + (Note.swagWidth[mania] * ((keyAmmo[mania] * 0.5) - 1.5)))},0.25,{ease: FlxEase.quadInOut});
					FlxTween.tween(cpuStrums.members[i].scale,{x: Note.noteScale[mania],y: Note.noteScale[mania]},0.25,{ease: FlxEase.quadInOut});

					FlxTween.tween(playerStrums.members[i],{x: BabyArrowCenterX + (Note.swagWidth[mania] * i) + i - (Note.swagWidth[mania] + (Note.swagWidth[mania] * ((keyAmmo[mania] * 0.5) - 1.5)))},0.25,{ease: FlxEase.quadInOut});
					FlxTween.tween(playerStrums.members[i].scale,{x: Note.noteScale[mania],y: Note.noteScale[mania]},0.25,{ease: FlxEase.quadInOut});
					playerStrums.members[i].ShowKeyReminder();
					if(i < keyAmmo[mania]){
						FlxTween.tween(cpuStrums.members[i],{alpha: 1},0.25,{ease: FlxEase.quadInOut});
						cpuStrums.members[i].RefreshSprite(mania);

						FlxTween.tween(playerStrums.members[i],{alpha: 1},0.25,{ease: FlxEase.quadInOut});
						playerStrums.members[i].RefreshSprite(mania);
					}else{
						FlxTween.tween(cpuStrums.members[i],{alpha: 0},0.25,{ease: FlxEase.quadInOut});
						FlxTween.tween(playerStrums.members[i],{alpha: 0},0.25,{ease: FlxEase.quadInOut});
					}
				}
				if(FlxG.save.data.undlaSize == 0 && underlay != null)FlxTween.tween(underlay.scale,{x: (Note.swagWidth[mania] * keyAmmo[mania]) / (Note.swagWidth[SongOGmania] * keyAmmo[SongOGmania])},0.25,{ease: FlxEase.quadInOut});
			}
		}
	}

	function BreakTimer(elapsed:Float){
        var timeTillNextNote:Float = FlxMath.MAX_VALUE_FLOAT;

        // if (instance != null)
        // {
            var show:Bool = false;
            if (Conductor.rawPosition > 0)
            {
                for (daNote in notes)
                    if (daNote.mustPress && !daNote.shouldntBeHit) //check notes for closest
                    {
                        var timeDiff = daNote.strumTime-Conductor.rawPosition;
                        if (timeDiff < timeTillNextNote)
                            timeTillNextNote = timeDiff;
                    }

                if (timeTillNextNote == FlxMath.MAX_VALUE_FLOAT) //now check unspawnNotes if not found anything
                {
                    for (daNote in unspawnNotes)
                        if (daNote.mustPress && !daNote.shouldntBeHit)
                        {
                            var timeDiff = daNote.strumTime-Conductor.rawPosition;
                            if (timeDiff < timeTillNextNote)
                            {
                                timeTillNextNote = timeDiff;
                                break;
                            }
                        }
                }
                show = timeTillNextNote != FlxMath.MAX_VALUE_FLOAT;
            }

            var targetAlpha:Float = 0.0;
            if (show)
            {
                if (lastStartTime == FlxMath.MAX_VALUE_FLOAT && timeTillNextNote > FlxG.save.data.breakTimer * 1000)
                    lastStartTime = timeTillNextNote;

                if (lastStartTime != FlxMath.MAX_VALUE_FLOAT)
                {
                    var secsLeft:Float = FlxMath.roundDecimal(timeTillNextNote*0.001,1);
                    var percent:Float = timeTillNextNote/lastStartTime;
					// Overlay.debugVar += '\nBreak Timer:$timeTillNextNote / $lastStartTime : $percent';
                    if (secsLeft <= 0.1)
                    {
                        lastStartTime = FlxMath.MAX_VALUE_FLOAT; //reset
                        timerText.text = "";
                    }
                    else
                    {
						timerBar.scale.x = FlxMath.lerp(timerBar.scale.x, (Note.swagWidth[playermania] * keyAmmo[playermania] / timerBar.width) * percent, elapsed*5);
                        timerText.text = ""+secsLeft;
                    }
					timerText.screenCenter(X);
                }
                if (timeTillNextNote > 1000 && timerText.text.length > 0)
                {
                    targetAlpha = 1.0;
                }
            }
            timerBar.alpha = timerText.alpha = FlxMath.lerp(timerText.alpha, targetAlpha, elapsed*7.5);
        // }
    }

	function addExtraCharacter(){
		if(ExtraChar != []){
			var CurEXChar = 1;
			for(i in ExtraChar){
				LoadingScreen.loadingText = 'Loading Extra Character ${CurEXChar}/${ExtraChar.length}: ${i.char} on ${i.side == 1 ? 'Left' : 'Right'}';
				var CharName = (if(TitleState.retChar(i.char) != "") i.char else "boyfriend");
				var Char = (if((bfShow && FlxG.save.data.bfShow && i.side == 0) || (dadShow && FlxG.save.data.dadShow && i.side == 1)) new Character(0, 100, CharName,i.side == 1 ? false : true,i.side) else new EmptyCharacter(0,100));
				if(i.side == 1){
					Char.x = dad.x + i.offset;
					dadArray.push(Char);
				}
				else{
					Char.x = boyfriend.x + i.offset;
					boyfriendArray.push(Char);
				}
				ShouldAIPress[i.side].push(true);
				CurEXChar++;
			}
		}
	}

	function resetNote(){
		var _noteAnims = [];
		var _noteNames = [];
		switch (SONG.mania)
		{
			case 0:
				_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','green','red'];
			case 1:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT'];
					_noteNames = ['purple','green','red','yellow','aqua','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','red','yellow','green','orange'];
				}
			case 2:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singRIGHT'];
					_noteNames = ['purple','green','red','white','yellow','aqua','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','red','white','yellow','green','orange'];
				}
			case 3:
				_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','green','red','white','yellow','pink','blue','orange'];
			case 4:
				_noteAnims = ['singLEFT','singDOWN','singSPACE','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','white','green','red'];
			case 5:
				_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','green','red','yellow','pink','blue','orange'];
			case 6:
				_noteAnims = ['singSPACE'];
				_noteNames = ['white'];
			case 7:
				_noteAnims = ['singLEFT','singRIGHT'];
				_noteNames = ['purple','red'];
			case 8:
				_noteAnims = ['singLEFT','singSPACE','singRIGHT'];
				_noteNames = ['purple','white','red'];
			case 9:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singUP','singDOWN','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','magenta','cyan','yellow','pink','blue','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','cyan','magenta','yellow','pink','blue','orange'];
				}
			case 10:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singUP','singSPACE','singDOWN','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','magenta','wintergreen','cyan','yellow','pink','blue','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singDOWN','singSPACE','singUP','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','cyan','white','magenta','yellow','pink','blue','orange'];
				}
			case 11:
				_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','yellow','pink','blue','orange'];
			case 12:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singRIGHT','singSPACE','singLEFT','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','lime','tango','wintergreen','canary','erin','yellow','pink','blue','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singSPACE','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','lime','cyan','wintergreen','magenta','tango','yellow','pink','blue','orange'];
				}
			case 13:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singRIGHT','singSPACE','singSPACE','singLEFT','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','lime','tango','white','wintergreen','canary','erin','yellow','pink','blue','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT','singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','lime','cyan','tango','canary','magenta','tango','yellow','pink','blue','orange'];
				}
			case 14:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singRIGHT','singUP','singSPACE','singUP','singLEFT','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','lime','tango','magenta','wintergreen','violet','canary','erin','yellow','pink','blue','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singRIGHT','singSPACE','singLEFT','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','lime','cyan','tango','wintergreen','canary','magenta','tango','yellow','pink','blue','orange'];
				}
			case 15:
				_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 16:
				if(FlxG.save.data.AltMK) {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singSPACE','singDOWN','singSPACE','singUP','singSPACE','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','wintergreen','lime','white','cyan','wintergreen','magenta','white','tango','wintergreen','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
				}
				else {
					_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
					_noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','wintergreen','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
				}
			case 17:
				_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singSPACE','singSPACE','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','white','wintergreen','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 18: // 21K
				_noteAnims = ['singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singSPACE','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT','singLEFT','singDOWN','singUP','singRIGHT'];
				_noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','lime','cyan','wintergreen','violet','erin','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
		}
		Note.noteAnimsAlt = Note.noteAnims = Note.playernoteAnims = _noteAnims;
		Note.noteNames = Note.playernoteNames = _noteNames;
	}

	public var acceptInput = true;
	public function testanimdebug(){
		if (FlxG.save.data.animDebug && onlinemod.OnlinePlayMenuState.socket == null) {
			if (FlxG.keys.justPressed.ONE && FlxG.keys.pressed.SHIFT && boyfriend != null)
				FlxG.switchState(new AnimationDebug(boyfriend.curCharacter,true,0));
			if (FlxG.keys.justPressed.TWO && FlxG.keys.pressed.SHIFT && dad != null)
				FlxG.switchState(new AnimationDebug(dad.curCharacter,false,1));
			if (FlxG.keys.justPressed.THREE && FlxG.keys.pressed.SHIFT && gf != null)
				FlxG.switchState(new AnimationDebug(gfChar,false,2));
			if (FlxG.keys.justPressed.SEVEN)
			{
				health = 9999;
				songspeed = 1;
				sectionStart = false;
				LoadingState.loadAndSwitchState(new ChartingState());
			}
			if (FlxG.keys.pressed.SHIFT && (FlxG.keys.justPressed.LBRACKET || FlxG.keys.justPressed.RBRACKET) )
			{
				FlxG.save.data.scrollSpeed += (if(FlxG.keys.justPressed.LBRACKET) -0.05 else 0.05);
				scrollspeed += (if(FlxG.keys.justPressed.LBRACKET) -0.05 else 0.05);
				showTempmessage('Changed scrollspeed to ${FlxG.save.data.scrollSpeed}');
			}
		}
	}
	public static function SHUTUP(){
		try{
			if(PlayState.instance.vocals == null) return;
			PlayState.instance.vocals.stop();
			PlayState.instance.vocals.volume = 0;
			FlxG.sound.list.remove(PlayState.instance.vocals,true);
			PlayState.instance.vocals.destroy();
			PlayState.instance.vocals = new FlxSound();
		}catch(e){}
	}
	override function switchTo(nextState:FlxState):Bool{
		if(!paused)resetInterps();
		return super.switchTo(nextState);
	}
	override function destroy(){
		callInterp("destroy",[]);
		try{
			hsBrTools.reset();
			instance = null;
		}catch(e){}
		super.destroy();
	}
	var curLight:Int = 0;
}