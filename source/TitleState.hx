package;

import haxe.macro.Expr.Catch;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import sys.io.File;
import sys.FileSystem;
import flixel.math.FlxMath;
import tjson.Json;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import SickMenuState;
import flash.media.Sound;
import flixel.FlxCamera;
import sys.thread.Thread;
import Alphabet;

import Shaders;
import Discord.DiscordClient;

using StringTools;

typedef Scorekillme = {
	var scores:Array<Float>;
	var songs:Array<String>;
	var funniNumber:Float;
}
@:structInit class StageInfo{
	public var id:String = "";
	public var path(get,default):String = null;
	public function get_path(){
		if(path == "" || path == null) return "mods/stages/";
		return path;
	}
	public var folderName:String = "";
	public var nameSpace:String = null;
	public var nameSpaceType:Int = 0; // 0: mods/stages, 1: mods/weeks, 2: mods/packs 

	public function toString(){
		return 'Stage $nameSpace/$id, Raw folder name:$folderName, path:$path';
	}
	public function getNamespacedName(){
		return (if (nameSpace != null) '$nameSpace|$id' else id);
	}
}

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxTypedGroup<FlxSprite>;
	var ngSpr:FlxSprite;
	public static var p2canplay = true;
	public static var choosableCharacters:Array<String> = [];
	public static var stages:Array<StageInfo> = [];
	public static var choosableCharactersLower:Map<String,String> = [];
	public static var weekChars:Map<String,Array<String>> = [];
	public static var characterDescriptions:Map<String,String> = [];
	public static var characterPaths:Map<String,String> = [];
	public static var invalidCharacters:Array<String> = [];
	// Var's I have because I'm to stupid to get them to properly transfer between certain functions
	public static var returnStateID:Int = 0;
	public static var supported:Bool = false;
	public static var outdated:Bool = false;
	public static var checkedUpdate:Bool = false;
	public static var updatedVer:String = "";
	public static var errorMessage:String = "";
	public static var osuBeatmapLoc:String = "";
	public static var songScores:Scorekillme;
	public static var pauseMenuMusic:Sound;



	var curWacky:Array<String> = [];

	public static function loadNoteAssets(?forced:Bool = false){
		if (NoteAssets == null || NoteAssets.name[0] != FlxG.save.data.noteAsset[0] || forced){
			if (!SELoader.exists('mods/noteassets/${FlxG.save.data.noteAsset[0]}.png') || !SELoader.exists('mods/noteassets/${FlxG.save.data.noteAsset[0]}.xml')){
				FlxG.save.data.noteAsset[0] = "default";
			} // Hey, requiring an entire reset of the game's settings when noteasset goes missing is not a good idea
			new NoteAssets(FlxG.save.data.noteAsset);
		}
	}
	public static function retChar(char:String):String{
		if (choosableCharactersLower[char.toLowerCase()] != null){
			return choosableCharactersLower[char.toLowerCase()];
		}else{
			return "";
		}
	}
	public static function retCharPath(char:String):String{
		if (characterPaths[retChar(char)] != null){
			if(characterPaths[retChar(char)].substring(-1) == "/"){
				return characterPaths[retChar(char)].substring(0,-1);
			}
			return characterPaths[retChar(char)];
		}else{
			return "mods/characters";
		}
	}
	public static function checkCharacters(){
		choosableCharacters = ["bf","gf","lonely","hidden","nothing","blank"];
		choosableCharactersLower = ["bf" => "bf","gf" => "gf","lonely" => "lonely","hidden" => "hidden","nothing" => "nothing","blank" => "blank"];
		characterDescriptions = ["automatic" => "Automatically uses character from song json", "bf" => "Boyfriend, the main protagonist. Provided by the base game.","gf" => "Girlfriend, boyfriend's partner. Provided by the base game.","lonely" => "pick for nothing","hidden" => "pick for nothing","nothing" => "pick for nothing","blank" => "pick for nothing"];
		characterPaths = [];
		weekChars = [];
		invalidCharacters = [];
		#if sys
		// Loading like this is probably not a good idea
		var dataDir:String = "mods/characters/";
		var customCharacters:Array<String> = [];

		if (FileSystem.exists("assets/characters/"))
		{
			var dir = "assets/characters";
			trace('Checking ${dir} for characters');
			for (char in FileSystem.readDirectory(dir))
			{
				if (!FileSystem.isDirectory(dir+"/"+char)){continue;}
				if (FileSystem.exists(dir+"/"+char+"/config.json"))
				{
					customCharacters.push(char);
					var desc = 'Assets character';
					if (FileSystem.exists('${dir}/${char}/description.txt'))
						desc += ";" +File.getContent('${dir}/${char}/description.txt');
					characterDescriptions[char] = desc;
					choosableCharactersLower[char.toLowerCase()] = char;
					characterPaths[char] = dir;

				}else if (FileSystem.exists(dir+"/"+char+"/character.png") && (FileSystem.exists(dir+"/"+char+"/character.xml") || FileSystem.exists(dir+"/"+char+"/character.json"))){
					invalidCharacters.push(char);
					characterPaths[char] = dir;
					// customCharacters.push(directory);
				}
			}
		}

		if (FileSystem.exists(dataDir))
		{
		  for (directory in FileSystem.readDirectory(dataDir))
		  {
			if (!FileSystem.isDirectory(dataDir+"/"+directory)){continue;}
			if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/config.json"))
			{
				customCharacters.push(directory);
				if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/description.txt"))
					characterDescriptions[directory] = File.getContent('${dataDir}/${directory}/description.txt');
				choosableCharactersLower[directory.toLowerCase()] = directory;
			}else if (FileSystem.exists(Sys.getCwd() + dataDir+"/"+directory+"/character.png") && (FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.xml") || FileSystem.exists(Sys.getCwd() + "mods/characters/"+directory+"/character.json"))){
				invalidCharacters.push(directory);
				// customCharacters.push(directory);
			}
		  }
		}

		

		for (_ => dataDir in ['mods/weeks/','mods/packs/']) {
			
			if (FileSystem.exists(dataDir))
			{
			  for (_dir in FileSystem.readDirectory(dataDir))
			  {
				if (!FileSystem.isDirectory(dataDir + _dir)){continue;}
				// trace(_dir);
				if (FileSystem.exists(dataDir + _dir + "/characters/"))
				{
					var dir = dataDir + _dir + "/characters/";
					trace('Checking ${dir} for characters');
					for (char in FileSystem.readDirectory(dir))
					{
						if (!FileSystem.isDirectory(dir+"/"+char)){continue;}
						if (FileSystem.exists(dir+"/"+char+"/config.json"))
						{
							var charPack = "";
							if(choosableCharactersLower[char.toLowerCase()] != null){
								var e = charPack;
								charPack = _dir+"|"+char;
								char = e;
							}
							customCharacters.push(char);
							var desc = 'Provided by ' + _dir;
							if (FileSystem.exists('${dir}/${char}/description.txt'))
								desc += ";" +File.getContent('${dir}/${char}/description.txt');
							characterDescriptions[char] = desc;
							if(choosableCharactersLower[char.toLowerCase()] != null){

								choosableCharactersLower[charPack.toLowerCase()] = char;
								if(weekChars[char] == null){
									weekChars[char] = [];
								}
								weekChars[char].push(charPack);
								characterPaths[charPack] = dir;
							}else{
								choosableCharactersLower[char.toLowerCase()] = char;
								characterPaths[char] = dir;
							}

						}else if (FileSystem.exists(dir+"/"+char+"/character.png") && (FileSystem.exists(dir+"/"+char+"/character.xml") || FileSystem.exists(dir+"/"+char+"/character.json"))){
							invalidCharacters.push(char);
							characterPaths[char] = dir;
							// customCharacters.push(directory);
						}
					}
				}		
			  }
			}
		}

		haxe.ds.ArraySort.sort(customCharacters, function(a, b) {
		   if(a < b) return -1;
		   else if(b > a) return 1;
		   else return 0;
		});
		for (char in customCharacters){
			if(char.length > 0){
				choosableCharacters.push(char);
			}
			// choosableCharactersLower[char.toLowerCase()] = char;
		}
		// try{

		// 	var rawJson = File.getContent('assets/data/characterMetadata.json');
		// 	// trace('Char Json: \n${rawJson}');
		// 	TitleState.defCharJson = haxe.Json.parse(CoolUtil.cleanJSON(rawJson));
		// 	if (defCharJson == null || TitleState.defCharJson.characters == null || TitleState.defCharJson.aliases == null) {defCharJson = {
		// 		characters:[],
		// 		aliases:[]
		// 	};trace("Character characterMetadata is null!");}
		// }catch(e){
		// 	MainMenuState.errorMessage = 'An error occurred when trying to parse Character Metadata:\n ${e.message}.\n You can reload this using Reload Char/Stage List';
		// 	if (defCharJson == null || TitleState.defCharJson.characters == null || TitleState.defCharJson.aliases == null) {defCharJson = {
		// 		characters:[],
		// 		aliases:[]
		// 	};
		// 	}
		// }
		#end
		checkStages();


		if(FlxG.save.data.scripts != null){
			trace('Currently enabled scripts: ${FlxG.save.data.scripts}');
			for (i in 0 ... FlxG.save.data.scripts.length) {
				var v = FlxG.save.data.scripts[i];
				if(!FileSystem.exists('mods/scripts/${v}/')){
					FlxG.save.data.scripts.remove(v);
					trace('Script $v doesn\'t exist! Disabling');
				}
			}
		}
	}
	public static function retStage(char:String):String{
		return findStageByNamespace(char,true).getNamespacedName();
	}

	public static function findStage(char:String,?retStage:Bool = true,?ignoreNSCheck:Bool = false):Null<StageInfo>{
		if(char == ""){
			trace('Empty stage search, returning Stage');
			if(retStage) return stages[1];
			return null;
		}
		if(char.startsWith('NULL|')) char = char.replace('NULL|','');
		if(char.contains('|') && !ignoreNSCheck){
			return inline findStageByNamespace(char,retStage);
		}
		if(char == ""){
			trace('Tried to get a blank stage!');
			if(retStage) return stages[1];
			return null;
		}
		if(Std.parseInt(char) != null && !Math.isNaN(Std.parseInt(char))){
			var e = Std.parseInt(char);
			if(stages[e] != null){

				// trace('Found char with ID of $e');
				return stages[e];
			}else{
				trace('Invalid ID $e, out of range 0-${stages.length}');
				if(retStage) return stages[1];
				return null;
			}
		}
		char = char.replace(' ',"-").replace('_',"-").toLowerCase();
		for (i in stages){
			if(i.id == char.toLowerCase()){
				return i;
			}
		}
		trace('Unable to find $char!');
		if(retStage) return stages[1];
		return null;
	}
	// This prioritises stages from a specific namespace, if it finds one outside of the namespace and the namespace doesn't have one, then they'll be used instead
	public static function findStageByNamespace(stage:String = "",?namespace:String = "",?nameSpaceType:Int = -1,?retStage:Bool = true):Null<StageInfo>{ 
		if(stage == ""){
			trace('Empty stage search, returning stage');
			if(retStage) return stages[1];
			return null;
		}
		if(stage.contains('|')){
			var _e = stage.split('|');
			namespace = _e[0];
			stage = _e[1];
		}
		if(namespace == "") return findStage(stage,retStage,true);
		if(stage == ""){
			trace('Tried to get a blank stageacter!');
			if(retStage) return stages[1];
			return null;
		}
		var currentstage:StageInfo = null;
		stage = stage.replace(' ',"-").replace('_',"-");
		for (i in stages){
			if(i.id == stage.toLowerCase()){
				if(i.nameSpace == namespace && (nameSpaceType == -1 || i.nameSpaceType == nameSpaceType)){
					return i;
				}
				currentstage = i;
			}
		}
		if(currentstage == null){
			trace('Unable to find $stage!');
			if(retStage) return stages[1];
			return null;
		}
		return currentstage;
	}
	public static function checkStages(){

		LoadingScreen.loadingText = 'Updating stage list';
		stages = [
			{id:"nothing",folderName:"nothing",path:"assets/",},
			{id:"stage",folderName:"stage",path:"assets/",},
		];
		#if sys
		// Loading like this is probably not a good idea
		var dataDir:String = "mods/stages/";

		if (SELoader.exists(dataDir))
		{
		  for (directory in SELoader.readDirectory(dataDir))
		  {
			if (!SELoader.isDirectory(dataDir+"/"+directory)){continue;}
			if (SELoader.exists(dataDir+"/"+directory+"/"))
			{
				stages.push({
					id:directory.replace(' ','-').replace('_','-').toLowerCase(),
					folderName:directory,
				});
			}
		  }
		}

		

		for (ID => dataDir in ['mods/weeks/','mods/packs/']) {
			
			if (SELoader.exists(dataDir))
			{
			  for (_dir in SELoader.readDirectory(dataDir))
			  {
				if (!SELoader.isDirectory(dataDir + _dir)){continue;}
				// trace(_dir);
				if (SELoader.exists(dataDir + _dir + "/stages/"))
				{
					var dir = dataDir + _dir + "/stages/";
					// trace('Checking ${dir} for characters');
					for (char in SELoader.readDirectory(dir))
					{
						if (!SELoader.isDirectory(dir+"/"+char)){continue;}
						stages.push({
							id:char.replace(' ',"-").replace('_',"-").toLowerCase(),
							folderName:char,
							path:dir,
							nameSpaceType:ID,
							nameSpace:_dir
						});
					}
				}		
			  }
			}
		}
		trace('Found ${stages.length} stages');
		#end

	}
	public static function findosuBeatmaps(){
		var loc = "";
		#if windows
			if (Sys.getEnv("LOCALAPPDATA") != null && FileSystem.exists('${Sys.getEnv("LOCALAPPDATA")}/osu!/Songs/')) loc = '${Sys.getEnv("LOCALAPPDATA")}/osu!/Songs/';
			if (Sys.getEnv("LOCALAPPDATA") != null && FileSystem.exists('${Sys.getEnv("LOCALAPPDATA")}/osu-stable/Songs/')) loc = '${Sys.getEnv("LOCALAPPDATA")}/osu-stable/Songs/';
		#else
			if (Sys.getEnv("HOME") != null && FileSystem.exists('${Sys.getEnv("HOME")}/.local/share/osu-stable/Songs/')) loc = '${Sys.getEnv("HOME")}/.local/share/osu-stable/Songs/';
			if (loc == "") trace('${Sys.getEnv("HOME")}/.local/share/osu-stable/songs/ doesnt exist!');
		#end

		osuBeatmapLoc = loc;
	}
	var halloweenEffect:VHSEffect = new VHSEffect();
	var halloween:Bool = false;
	override public function create():Void
	{
		Assets.loadLibrary("shared");
		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}

		PlayerSettings.init();

		DiscordClient.initialize();

		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		});

		halloween = (Date.now().getHours() == 3 || Date.now().getMonth() == 9);

		curWacky = getIntroTextShit();

		// DEBUG BULLSHIT

		super.create();

		if(CoolUtil.font != Paths.font("vcr.ttf")) flixel.system.FlxAssets.FONT_DEFAULT = CoolUtil.font;
		KadeEngineData.initSave();

		Highscore.load();
		checkCharacters();			

		// loadScores();
		pauseMenuMusic = Sound.fromFile((if (FileSystem.exists('mods/pauseMenu.ogg')) 'mods/pauseMenu.ogg' else if (FileSystem.exists('assets/music/breakfast.ogg')) 'assets/music/breakfast.ogg' else "assets/shared/music/breakfast.ogg"));

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			startIntro();
		});
	}

	var logoBl:FlxSprite;
	var gf:Character;
	var gf2:Character;
	var titleText:Alphabet;
	override function tranOut(){return;}
	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(-1, 0), {asset: diamond, width: 32, height: 32},
				new FlxRect(-FlxG.width * 0.5, -FlxG.height * 0.5, FlxG.width * 2, FlxG.height * 2));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(1, 0),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-FlxG.width * 0.5, -FlxG.height * 0.5, FlxG.width * 2, FlxG.height * 2));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			lime.app.Application.current.window.onDropFile.add(AnimationDebug.fileDrop);
			// FlxTween.tween(Main.fpsCounter,{alpha:1},0.2);


			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('StartItchBuild'), 0.1);
			FlxG.sound.music.pause();
			// LoadingState.loadingText = new FlxText(FlxG.width * 0.8,FlxG.height * 0.8,"Loading...");
			// LoadingState.loadingText.setFormat();
			findosuBeatmaps();
			MainMenuState.firstStart = true;
			Conductor.changeBPM(140);
			persistentUpdate = true;
			FlxG.fixedTimestep = false; // Makes the game not be based on FPS for things, thank you Forever Engine for doing this
			// make this toggleable cause fucking windows 11 fullscreen bug
			FlxG.mouse.useSystemCursor = FlxG.save.data.UsingSystemMouse; // Uses system cursor, did not know this was a thing until Forever Engine
			if(!FileSystem.exists("mods/menuTimes.json")){ // Causes crashes if done while game is running, unknown why
				File.saveContent("mods/menuTimes.json",Json.stringify(SickMenuState.musicList));
			}else{
				try{
					var musicList:Array<MusicTime> = Json.parse(File.getContent("mods/menuTimes.json"));
					SickMenuState.musicList = musicList;
				}catch(e){
					MusicBeatState.instance.showTempmessage("Unable to load Music Timing: " + e.message,FlxColor.RED);
				}
			}
		}
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		try{
			if(FlxG.save.data.gfTitleShow){
				gf = new Character(FlxG.width, FlxG.height * 0.07, FlxG.save.data.gfChar,false,2,true,null,null,false);
				gf2 = new Character(FlxG.width, FlxG.height * 0.07, FlxG.save.data.gfChar,false,2,true,null,null,false);
				var shader:ChromAbEffect = new ChromAbEffect();
				gf2.shader = shader.shader;
				shader.strength = -0.0015;
				shader.update(0);
				add(gf2);
				add(gf);
			}
		}catch(e){
			trace("There a problem try to load GF for title screen. Disable to pervert more problem");
			FlxG.save.data.gfTitleShow = false;
		}
		add(logoBl);

		titleText = new Alphabet(0, 0,"PRESS ENTER TO BEGIN",true,false);
		titleText.x = 100;
		titleText.y = FlxG.height * 0.8;
		titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxTypedGroup<FlxSprite>();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true, false, false, 70, true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;


		shiftSkip = new FlxText(0,0,0,"Hold shift to go to the options menu after title screen",16);
		shiftSkip.y = FlxG.height - shiftSkip.height - 12;
		shiftSkip.x = 6;
		add(shiftSkip);
		if (initialized)
			skipIntro();
		else{
			Assets.loadLibrary("shared").onComplete(function (_) {
				
				showHaxe();
				LoadingScreen.hide();
			});

		}
			// initialized = true;
		// credGroup.add(credTextShit);
	}
	var shiftSkip:FlxText;
	var isShift = false;
	static var technoAnni = [
			["Technoblade","never dies"],
			['SAY IT WITH ME','Not even close'],
			["thank you hypixel",'very cool'],
			["if you wish to defeat me",'train for another 100 years'],
			["all part of",'my master plan'],
			['subscribe to','technoblade'],
			['This is the second-worst thing','that has happened to these orphans']
		];
	public static var hardcodedDays(default,never):Map<Int,Map<Int,Array<Array<String>>>> = [
		0=>[
			1 => [["New Year","More Pain :)"],["Good bye",'${Date.now().getFullYear() - 1}'],["Hey look","New year"]],
			4 => [["Happy Birthday","PhantomArcade"]],
		],
		4 => [
			12 => [["Hey look","an idiot was born"],['its supers birthday?','whos that?']],
		],
		5 =>[
			-1 => [
				['trans rights','are human rights'],
				['yeah I\'m straight','straight up gay'],
				['be gay','do crime'],
				['Respect my trans homies','or im going to identify','as a fuckin problem'],
				['pride month','less goo'],
				['garlic bread','garlic bread'],
				['omg','blahaj'],
				['I put the l','in lesbian'],
				["you're talkin mad valid",'for someone in','cuddling distance'],
				['women','based'],
				['men','based'],
				['embies','based'],
				['person','based'],
				['skirt go speeen','still cis though'],
				['i want to wear a dress and makeup','still cis though'],
			],
			27 => [["Hey look","a furry was born"],['its naytoon birthday?','whos that?']],
		],
		6 => [
			1 => technoAnni,
			30 => technoAnni
		],
		7 => [
			1 => technoAnni
		],
		8 => [
			12 => [["Happy Birthday","ninjamuffin"]]
		],
		10 => [
			4 => [['funkin on a','friday night']],
			28 => technoAnni,
			30 => [["Spooky time","very spoopy"],["pumpkin pog","wait what"],["Spooky scary skeletons","send shivers down your spine"]]
		],
		11 => [
			30 => [["New Year","More Pain :)"],["Just one more day",'of ${Date.now().getFullYear()}'],["Hey look","New year"]],
		],
	];
	var forcedText:Bool = false;
	function getIntroTextShit():Array<String>
	{
		var now = Date.now();
		if(hardcodedDays[now.getMonth()] != null && hardcodedDays[now.getMonth()][now.getDate()] != null){
			forcedText = true;
			return FlxG.random.getObject(hardcodedDays[now.getMonth()][now.getDate()]);
		}else if(hardcodedDays[now.getMonth()] != null && hardcodedDays[now.getMonth()][-1] != null){
			forcedText = true;
			return FlxG.random.getObject(hardcodedDays[now.getMonth()][-1]);
		}
		if(FlxG.save.data.seenForcedText) FlxG.save.data.seenForcedText = false;
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');

		return FlxG.random.getObject(firstArray).split('--');
	}

	var transitioning:Bool = false;
	var updateCheck:Bool = false;
	var skipMM:Bool = false;

	override function update(elapsed:Float)
	{
		halloweenEffect.update(elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || skipBoth;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if(shiftSkip != null && isShift != FlxG.keys.pressed.SHIFT){
			isShift = FlxG.keys.pressed.SHIFT;
			shiftSkip.color = (if(FlxG.keys.pressed.SHIFT) 0x00aa00 else 0xFFFFFF);
		}
		#if !(debug)
		// This is useless in debug mode since updates aren't checked for
		if(pressedEnter && updateCheck && !skipMM){
			updateCheck = false;
			skipMM = true;
			MainMenu();
		}
		#end
		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.save.data.flashing)
				FlxTween.tween(titleText,{alpha:0},0.1,{type:PINGPONG,ease:FlxEase.cubeInOut});

			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			if(FlxG.save.data.gfTitleShow){
				var Anim:Array<String> = (halloween ? ["scared","cheer","hey","singUP"] : ["cheer","hey","singUP"]);
				gf.playAnimAvailable(Anim,true);
				gf2.playAnimAvailable(Anim,true);
			}

			transitioning = true;

			#if !debug
			if (FlxG.keys.pressed.SHIFT || FileSystem.exists(Sys.getCwd() + "/noUpdates") || checkedUpdate || !FlxG.save.data.updateCheck)
				FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState());
			else
			{
				new FlxTimer().start(0.5,function(_){try{updateCheck = true;}catch(e){}});

				showTempmessage("Checking for updates..",FlxColor.WHITE);
				#if (target.threaded)
				Thread.create(function(){
				#end
					// Get current version of FNFBR, Uses kade's update checker

					var http = new haxe.Http("https://raw.githubusercontent.com/cartoon032/Super-Engine-T-Mod/master/version.downloadMe");
					var returnedData:Array<String> = [];

					http.onData = function (data:String)
					{
						updateCheck = false;
						checkedUpdate = true;
						returnedData[0] = data.substring(0, data.indexOf(';'));
						returnedData[1] = data.substring(data.indexOf('-'), data.length);
						updatedVer = returnedData[0];
						OutdatedSubState.needVer = updatedVer;
						OutdatedSubState.currChanges = returnedData[1];
						if (!MainMenuState.modver.contains(updatedVer.trim()) || (MainMenuState.nightly != ""))
						{
							// trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.ver);
							outdated = true;
						}
						if(skipMM) return;
						skipMM = true;
						MainMenu();
					}
					http.onError = function (error) {
						trace('error: $error');
						if(skipMM) return;
						skipMM = true;
						MainMenu();
					}
					http.request();
				#if (target.threaded)
				});
				#end
			}
			#else
				MainMenu();
			#end
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro  && (!forcedText || FlxG.save.data.seenForcedText))
			skipIntro();

		super.update(elapsed);
	}
	inline function MainMenu(){
		ngSpr.graphic.destroy();
		FlxTween.tween(FlxG.camera.scroll,{y:-300},4,{ease:FlxEase.cubeOut});
		FlxG.switchState(if(FlxG.keys.pressed.SHIFT) new OptionsMenu() else new MainMenuState());
	}

	function createCoolText(textArray:Array<String>,yOffset:Int = 200)
	{
		for (i in 0...textArray.length) addMoreText(textArray[i],yOffset);
			// var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			// money.screenCenter(X);
			// money.y += (i * 70) + 100;
			// money.scale.x = money.scale.y = 1.1;
			// FlxTween.tween(money.scale,{x:1,y:1},0.2,{ease:FlxEase.expoOut});
			// credGroup.add(money);
			// textGroup.add(money);
	
	}

	function addMoreText(text:String,yOffset:Int = 200):Alphabet
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (70 * textGroup.length) + yOffset;
		coolText.bounce();
		credGroup.add(coolText);
		textGroup.add(coolText);
		return coolText;
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}
	var cachingText:Alphabet;
	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null) logoBl.animation.play('bump');
		if(FlxG.save.data.gfTitleShow && !transitioning){
			gf.dance(curBeat % 2 == 0);
			gf2.dance(curBeat % 2 == 0);
		}

		switch (curBeat)
		{
			case 0:
				deleteCoolText();
				destHaxe();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er'], 0);
				credTextShit.x -= 130;
			case 2:
				addMoreText('do not present');
			case 7:
				deleteCoolText();
			case 10:
				deleteCoolText();
				addMoreText('not partnered with').startTyping(0,Conductor.crochetSecs * 2);
			case 11:
			case 12:
				addMoreText('Newgrounds');
				ngSpr.scale.x = ngSpr.scale.y = 1.1;
				FlxTween.tween(ngSpr.scale,{x:1,y:1},0.2);
				ngSpr.visible = true;
			case 16:
				deleteCoolText();
				credTextShit.y += 130;
				ngSpr.visible = false;
			case 18:
				if(curWacky.length % 2 == 1){curWacky.push('');}// Hacky but fuck you
				var max = Std.int(Math.floor(curWacky.length * 0.5));
				createCoolText(curWacky.slice(0,max));
			case 20:
				var max = Std.int(Math.floor(curWacky.length * 0.5));
				createCoolText(curWacky.slice(max));
			case 24:
				deleteCoolText();
				if(forcedText) FlxG.save.data.seenForcedText = true;
			case 26:
				addMoreText('Friday Night Funkin\'');
			case 28:
				addMoreText('Super Engine');
			case 30:
				addMoreText('T mod');
			case 32:
				skipIntro();
			default:
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if(!FlxG.sound.music.playing){
				FlxG.sound.music.play();
				FlxG.sound.music.fadeIn(0.1,FlxG.save.data.instVol);
			}
			remove(ngSpr);
			destHaxe();
			FlxG.camera.flash(FlxColor.WHITE, 2);
			remove(credGroup);
			skippedIntro = true;

			if(halloween){ // lmao
				logoBl.angle = FlxG.random.int(-360,360);
				logoBl.x = FlxG.random.int(-250,250);
				logoBl.y = FlxG.random.int(-250,250);
				FlxG.camera.setFilters([new openfl.filters.ShaderFilter(halloweenEffect.shader)]);
				titleText.color=0xffff8b0f;
			}
			if(Date.now().getHours() == 3)
				titleText.color=0xffff0000;

			if(FlxG.save.data.gfTitleShow){
				var _x = logoBl.x;
				logoBl.x = -100;
				FlxTween.tween(gf,{x: FlxG.width * 0.4},0.4);
				FlxTween.tween(gf2,{x: FlxG.width * 0.4},0.4);
				FlxTween.tween(logoBl,{x: _x},0.5);
			}else{
				FlxG.camera.scroll.x += 100;
				FlxG.camera.scroll.y += 100;
				logoBl.screenCenter(X);
				FlxTween.tween(FlxG.camera.scroll,{x: 0,y:0},1,{ease:FlxEase.cubeOut});
			}
		}
	}
	override function stepHit(){
		super.stepHit();
		if(Date.now().getHours() == 3 && FlxG.random.int(0,100) > 80){
			titleText.members[FlxG.random.int(0,titleText.length)].x = FlxG.random.int(-40,1280);
			titleText.members[FlxG.random.int(0,titleText.length)].y = FlxG.random.int(-40,770);
		}
	}

	// HaxeFlixel thing

	var _sprite:Sprite;
	var _gfx:Graphics;

	var _times:Array<Float>;
	var _colors:Array<Int>;
	var _functions:Array<Void->Void>;
	var _curPart:Int = 0;
	var _cachedBgColor:FlxColor;
	var _cachedTimestep:Bool;
	var _cachedAutoPause:Bool;
	var _timers:Array<FlxTimer>;
	var _sound:FlxSound;
	function showHaxe(){
		_times = [0.041, 0.184, 0.334, 0.495, 0.636,1];
		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb,0xFFFFFF,0xFFFFFF];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue,function(){return;}];
		_sprite = new Sprite();
		FlxG.stage.addChild(_sprite);
		_gfx = _sprite.graphics;
		_sprite.filters = [new flash.filters.GlowFilter(0xFFFFFF,1,6,6,1,1)];

		// This is shit, but it caches unloaded sprites for FlxText
		var coolText:Alphabet = new Alphabet(0, 0, "_", true, false);
		coolText.screenCenter(X);
		coolText.forceFlxText = true;
		coolText.text = 'PRECACHING TEXT: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890~#$%&()*+:;<=>@[|]^.,\'!?/';
		coolText.bounce();
		add(cachingText = coolText);

		_sound = FlxG.sound.load(Assets.getSound("flixel/sounds/flixel." + flixel.system.FlxAssets.defaultSoundExtension,false),FlxG.save.data.instVol - 0.2); // Put the volume down by 0.2 for safety of eardrums
		_sound.play();
		for (time in _times) new FlxTimer().start(time, _timerCallback);
	}
	function destHaxe(){
		flixel.util.FlxTimer.globalManager.clear();
		if(_sprite == null) return;
		if(_sound != null){
			_sound.pause();
			_sound.destroy();
		}
		FlxG.stage.removeChild(_sprite);
		_sprite = null;
		_gfx = null;
		_times = null;
		_colors = null;
		_functions = null;

	}
	function _timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_curPart++;
		
		if(textGroup.members[1] == null) textGroup.members[0].color = _colors[_curPart]; else {textGroup.members[1].color = _colors[_curPart];textGroup.members[0].color = 0xFFFFFF;}
		
		if(_sprite.filters[0] != null) cast(_sprite.filters[0],flash.filters.GlowFilter).color = _colors[_curPart];
		if(_sprite != null){
			_sprite.x = (FlxG.width * 0.5);
			_sprite.y = (FlxG.height * 0.60) - 20 * FlxG.game.scaleY;
			_sprite.scaleX = FlxG.game.scaleX;
			_sprite.scaleY = FlxG.game.scaleY;
		}
		if (_curPart == 6){
			// Make the logo a tad bit longer, so our users fully appreciate our hard work :D
			FlxTween.tween(_sprite.filters[0],{blurX:0,blurY:0,strength:1},1.5,{ease:FlxEase.quadOut});
			FlxTween.tween(_sprite, {alpha: 0}, 3.0, {ease: FlxEase.quadOut, onComplete: __onComplete});
			FlxTween.tween(textGroup.members[0], {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
			FlxTween.tween(textGroup.members[1], {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
		}
	}
	function bounceText(?beatLength:Float = 0.3){
		var i = textGroup.members.length - 1;
		while (i > -1){
			textGroup.members[i].scale.x = textGroup.members[i].scale.y = 1.2;
			FlxTween.cancelTweensOf(textGroup.members[i]);
			FlxTween.tween(textGroup.members[i].scale, {x: 1,y: 1}, beatLength, {ease: FlxEase.cubeOut});
			i--;
		}
		

	}
	var skipBoth:Bool = false;
	function  __onComplete(tmr:FlxTween){
		if(_sound != null){
			_sound.pause();
			_sound.destroy();
		} 
		initialized = true;
		destHaxe();
		FlxG.sound.music.play();
		FlxG.sound.music.fadeIn(0.1,FlxG.save.data.instVol);

		if(!isShift){
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}
		if(isShift || FlxG.keys.pressed.ENTER || (Sys.args()[0] != null && FileSystem.exists(Sys.args()[0]))){
			skipBoth = true;
		}
		new FlxTimer().start(2, function(_){
			if(MusicBeatState.instance.curStep == 0){
				FuckState.FUCK("curStep seems to have not progressed at all.\nThis usually indicates that the game cannot play audio for whatever reason.\nRestarting should fix this.\nif you hear audio perfectly fine, you can safely ignore this and press enter","TitleState.audioCheck",false,true);
			}
		});
	}
	function drawGreen():Void
	{
		cachingText.destroy();
		_gfx.beginFill(0x00b922);
		_gfx.moveTo(0, -37);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(0, -37);
		_gfx.endFill();
		createCoolText(['']);

	}

	function drawYellow():Void
	{
		_gfx.beginFill(0xffc132);
		_gfx.moveTo(-50, -50);
		_gfx.lineTo(-25, -50);
		_gfx.lineTo(0, -37);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(-50, -25);
		_gfx.lineTo(-50, -50);
		_gfx.endFill();
		createCoolText(['Powered by']);
		bounceText();

		// textGroup.members[1].color = 0x00b922;
		
	}

	function drawRed():Void
	{
		_gfx.beginFill(0xf5274e);
		_gfx.moveTo(50, -50);
		_gfx.lineTo(25, -50);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(50, -25);
		_gfx.lineTo(50, -50);
		_gfx.endFill();
		
	}

	function drawBlue():Void
	{
		_gfx.beginFill(0x3641ff);
		_gfx.moveTo(-50, 50);
		_gfx.lineTo(-25, 50);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-50, 25);
		_gfx.lineTo(-50, 50);
		_gfx.endFill();
		deleteCoolText();
		createCoolText(['Powered by',(FlxG.random.bool(0.1) ? 'the bane of my existance' : 'HaxeFlixel')]);
	}

	function drawLightBlue():Void
	{
		_gfx.beginFill(0x04cdfb);
		_gfx.moveTo(50, 50);
		_gfx.lineTo(25, 50);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(50, 25);
		_gfx.lineTo(50, 50);
		_gfx.endFill();
		FlxTween.tween(_sprite.filters[0],{blurX:50,blurY:50,strength:2},0.2,{ease:FlxEase.quadOut});
		bounceText();

		// addMoreText('HaxeFlixel');
	}


}

class FuckinNoDestCam extends FlxCamera{
	public override function destroy(){
		return;
	}
}