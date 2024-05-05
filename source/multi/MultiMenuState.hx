package multi;

import haxe.macro.Expr.Catch;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import openfl.media.Sound;
import Song;
import sys.io.File;
import sys.FileSystem;
import tjson.Json;
import flixel.sound.FlxSound;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import se.formats.SongInfo;
import Discord.DiscordClient;

using StringTools;

class MultiMenuState extends onlinemod.OfflineMenuState
{
	var modes:Map<Int,Array<String>> = [];
	static var CATEGORYNAME:String = "-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-CATEGORY";
	var diffText:FlxText;
	var scoreText:FlxText;
	var selMode:Int = 0;
	public static var blockedFiles:Array<String> = ['events.json','picospeaker.json','dialogue-end.json','dialogue.json','_meta.json','meta.json','se-overrides.json','config.json'];
	static var lastSel:Int = 1;
	static var lastSearch:String = "";
	public static var lastSong:String = "";
	var beetHit:Bool = false;

	var songNames:Array<String> = [];
	var nameSpaces:Array<String> = [];
	static var songInfoArray:Array<SongInfo> = [];
	static var categories:Array<String> = [];
	var shouldDraw:Bool = true;
	var shouldVoicesPlay:Bool = false;

	var chartinfotext:FlxText;

	var musicmodetext:FlxText;
	var musicshuffle:Bool = true; //it will get invert when you turn on music mode
	var shuffleforwand:Bool = true;
	var zoom:Bool = false;
	var zoomtween:FlxTween;

	var curplay:Int = 0;
	var songLength:Float = 0;
	var songLengthTxt = "N/A";
	var songProgress:FlxBar = new FlxBar();
	var songProgressParent:Alphabet;
	var songProgressText:FlxText = new FlxText(0,0,"00:00/00:00. Playing voices",12);
	var updateTime:Bool = false;
	override function draw(){
		if(shouldDraw)
			super.draw();
		else{
			bg.draw();
			grpSongs.members[curSelected].draw();
			grpSongs.members[curplay].draw();
			musicmodetext.draw();
		}
	}
	override function beatHit(){
		if(zoom && grpSongs.members[curplay] != null){
			if(zoomtween != null){
				zoomtween.cancel();
				zoomtween.destroy();
			}
			zoomtween = FlxTween.tween(grpSongs.members[curplay].scale.set(1.25,1.25),{x:1,y:1},(Conductor.crochet / 2000),{ease: FlxEase.quadInOut});
		}
		if (voices != null && shouldVoicesPlay && (!voices.playing || (voices.time > FlxG.sound.music.time + 20 || voices.time < FlxG.sound.music.time - 20))){
			voices.pause();
			voices.time = FlxG.sound.music.time;
			voices.play();
		}
		if(Conductor.bpmChangeMap.length > 0){
			for(event in Conductor.bpmChangeMap){
                if(event.stepTime == curStep){
                    Conductor.changeBPM(event.bpm);
					break;
                }
				if(event.stepTime > curStep)
					break;
			}
		}
		super.beatHit();
	}
	override function findButton(){
		super.findButton();
		changeDiff();
	}
	override function switchTo(nextState:FlxState):Bool{
		FlxG.autoPause = true;
		if(voices != null){
			voices.destroy();
			voices = null;
		}
		return super.switchTo(nextState);
	}
	override function create()
	{
		FlxG.sound.music.onComplete = null;
		retAfter = false;
		SearchMenuState.doReset = true;
		scriptSubDirectory = "/multilist/";
		useNormalCallbacks = true;
		loadScripts(true);
		dataDir = "mods/charts/";
		PlayState.scripts = [];
		bgColor = 0x00661E;
		super.create();
		DiscordClient.changePresence('Browsing Multi Menu',null);
		diffText = new FlxText(FlxG.width * 0.7, 5, 0, "", 24);
		diffText.font = CoolUtil.font;
		diffText.borderSize = 2;
		diffText.x = (FlxG.width) - 20;
		diffText.alignment = RIGHT;
		add(diffText);
		scoreText = new FlxText(FlxG.width * 0.7, 35, 0, "N/A", 24);
		scoreText.font = CoolUtil.font;
		scoreText.borderSize = 2;
		add(scoreText);
		SpeedText.y = 65;
		chartinfotext = new FlxText(-19, 140, FlxG.width, "Press Q for chart info", 24);
		chartinfotext.font = CoolUtil.font;
		chartinfotext.alignment = RIGHT;
		chartinfotext.borderSize = 2;
		add(chartinfotext);
		musicmodetext = new FlxText(0, FlxG.height*(5/6), FlxG.width, "", 24);
		musicmodetext.color = 0x9BD2F5;
		musicmodetext.alignment = CENTER;
		musicmodetext.font = CoolUtil.font;
		musicmodetext.borderSize = 2;
		add(musicmodetext);
		songProgress.height = 18;
		songProgress.width = 180;
		songProgress.createFilledBar(0xff000000,0xFF9BD2F5,true,0xff000000);

		searchField.text = lastSearch;
		if(lastSearch != "") reloadList(true,lastSearch);

		lastSearch = "";
		changeSelection(lastSel);
		lastSel = 1;
		changeDiff();
		updateInfoText('Use Shift to scroll faster; Press Control to listen to instrumental/voices of song. Press again to toggle the voices. Found ${songInfoArray.length} songs. Press Control + Shift to turn on Music mode. Press again to toggle Shuffle Mode');

	}
	override function onFocus() {
		shouldDraw = true;
		super.onFocus();
	}
	override function onFocusLost(){
		shouldDraw = false;
		super.onFocusLost();
	}
	function addListing(name:String,i:Int,child:Dynamic):Alphabet{
		callInterp('addListing',[name,i]);
		if(cancelCurrentFunction) return null;
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);
		controlLabel.yOffset = 20;
		controlLabel.cutOff = 25;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		controlLabel.menuValue = child;
		if (i != 0) controlLabel.alpha = 0.6;
		grpSongs.add(controlLabel);
		callInterp('addListingAfter',[controlLabel,name,i]);
		return controlLabel;
	}
	function addCategory(name:String,i:Int,addToCats:Bool = true):Alphabet{
		callInterp('addCategory',[name,i]);
		if(cancelCurrentFunction) return null;
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false,true);
		controlLabel.adjustAlpha = false;
		controlLabel.x = 20;
		if(controlLabel.border != null) {
			controlLabel.border.alpha = 0.35;
			controlLabel.border.lockGraphicSize((Std.int(FlxG.width) + 20),Std.int(controlLabel.border.height));
			controlLabel.border.x -= 20;
		}
		controlLabel.yOffset = 20;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		controlLabel.alpha = 1;
		grpSongs.add(controlLabel);
		if(addToCats) categories.push(name);
		callInterp('addCategoryAfter',[controlLabel,name,i]);
		return controlLabel;
	}
	@:keep inline static public function isValidFile(file) {return ((StringTools.endsWith(file, '.json') || StringTools.endsWith(file, '.sm')) && !blockedFiles.contains(file.toLowerCase()));}
	@:keep inline function addSong(path:String,name:String,catID:Int = 0):SongInfo{
		if(!SELoader.exists(path) || !SELoader.isDirectory(path)){
			trace('$path doesnt exist!');
			return null;
		}
		var songInfo:SongInfo = {
			name:name,
			charts:[],
			namespace:null,
			path:path + '/',
			categoryID:catID
		};
		for (file in orderList(SELoader.readDirectory(path))) {
			if (!isValidFile(file)) continue;
			songInfo.charts.push(file);
		}

		return songInfo;
	}
	inline function reloadListFromMemory(search:String = "",query){
		var _goToSong = 0;
		var i:Int = 0;
		var emptyCats:Array<String> = [];
		var currentCat = "";
		var currentCatID:Int = -1;
		var hadSong = false;
		var matchedCat = false;
		for(song in songInfoArray){
			if(currentCatID != song.categoryID){
				if(!hadSong) emptyCats.push(currentCat);
				hadSong = false;
				currentCatID = song.categoryID;
				currentCat = categories[currentCatID] ?? "Unknown";
				matchedCat = search == "" || (currentCat != "Unknown" && query.match(currentCat.toLowerCase()));
			}
			if(!matchedCat && !query.match(song.name.toLowerCase())) continue;
			if(!hadSong) {
				hadSong = true;
				addCategory(currentCat,i,false);
				i++;
			}
			if(_goToSong == 0) _goToSong = i;
			addListing(song.name,i,song);
			i++;


		}
		if(!hadSong) emptyCats.push(currentCat);
		while(emptyCats.length > 0){
			var e = emptyCats.shift();
			addCategory(e,i).color = FlxColor.RED;
			i++;
		}
		changeSelection(_goToSong);
	}
	override function reloadList(?reload=false,?search = ""){
		if(!allowInput) return;
		curSelected = 0;

		if(reload) {
			CoolUtil.clearFlxGroup(grpSongs);
		}

		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
		callInterp('reloadList',[reload,search,query]);

		if(!cancelCurrentFunction && songInfoArray[0] != null && (reload || FlxG.save.data.cacheMultiList)){
			if(selMode == -1) {
				reloadListFromMemory(search,query);
				return;
			}
			#if (false && target.threaded)
			var loadingText = new FlxText(0,0,'Loading...',32);
			replace(grpSongs,loadingText);
			loadingText.screenCenter(XY);
			sys.thread.Thread.create(() -> {
				allowInput = false;
			#end
				reloadListFromMemory(search,query);
			#if (false && target.threaded)
				allowInput = true;
				replace(loadingText,grpSongs);
				loadingText.destroy();
			});
			#end
			return;
		}
		var i:Int = 0;
		categories = [];
		songInfoArray=[];
		callInterp('generateList',[reload,search,query]);
		if(!cancelCurrentFunction){
			var emptyCats:Array<String> = [];
			if (SELoader.exists(dataDir)){
				var dirs = orderList(SELoader.readDirectory(dataDir));
				var catID = 0;
				var containsSong = false;
				LoadingScreen.loadingText = 'Scanning mods/charts';
				for (directory in dirs){
					if (!SELoader.isDirectory('${dataDir}${directory}') || (search != "" && !query.match(directory.toLowerCase()))) continue; // Handles searching
					var song = addSong('${dataDir}${directory}',directory,catID);
					if(song == null) continue;
					if(!containsSong){
						containsSong = true;
						addCategory('Charts Folder',i);
						i++;
					}
					addListing(directory,i,song);
					songInfoArray.push(song);
					i++;
				}
				if(!containsSong){
					emptyCats.push('Charts Folder');
				}
			}
			var _packCount:Int = 0;
			if (SELoader.exists("mods/weeks")){
				for (name in orderList(SELoader.readDirectory("mods/weeks"))){
					var catID = categories.length;

					var dataDir = "mods/weeks/" + name + "/charts/";
					if(!SELoader.exists(dataDir)){continue;}
					var catMatch = query.match(name.toLowerCase());
					var dirs = orderList(SELoader.readDirectory(dataDir));
					// addCategory(name + "(Week)",i);
					_packCount++;
					var containsSong = false;
					LoadingScreen.loadingText = 'Scanning mods/weeks/$name';
					for (directory in dirs){
						if (!SELoader.isDirectory('${dataDir}${directory}') && (!catMatch && search != "" && !query.match(directory.toLowerCase()))) continue; // Handles searching
						if (SELoader.exists('${dataDir}${directory}/Inst.ogg')){
							var song = addSong('${dataDir}${directory}',directory,catID);
							if(song == null) continue;
							song.namespace = name;
							if(!containsSong){
								containsSong = true;
								addCategory(name,i);
								i++;
							}
							addListing(directory,i,song);
							songInfoArray.push(song);
							
							i++;
						}
					}
					if(!containsSong){
						emptyCats.push(name + "(Week)");
					}
				}
			}
			if (SELoader.exists("mods/packs")){
				for (name in orderList(SELoader.readDirectory("mods/packs"))){
					var catID = categories.length;
					// dataDir = "mods/packs/" + dataDir + "/charts/";
					var catMatch = query.match(name.toLowerCase());
					var baseDir = 'mods/packs/$name/';
					// var dataDir = SELoader.anyExists(['${baseDir}charts/','${baseDir}data/']);
					// !SELoader.exists(dataDir) && !SELoader.exists(dataDir = "mods/packs/" + name + "/data/")
					// if(dataDir == null) continue;
					_packCount++;
					// var containsSong = false;
					var dirs = orderList(SELoader.readDirectory(dataDir));
					
					var folderSongs:Array<SongInfo> = SELoader.getSongsFromFolder(baseDir);
					if(folderSongs.length == 0){
						emptyCats.push(name);
						continue;
					}
					addCategory(name,i);
					i++;
					for (song in folderSongs){
						song.categoryID=catID;
						song.namespace=name;
						addListing(song.name,i,song);
						songInfoArray.push(song);
					}
					
					i++;

					// if(!containsSong) emptyCats.push(name);
					
				}
			}
			while(emptyCats.length > 0){
				var e = emptyCats.shift();
				if(e != null && e != "") addCategory(e,i).color = FlxColor.RED;
				i++;
			}
		}
		if(reload && lastSel == 1){
			for(value in grpSongs){
				if(value.menuValue is SongInfo){
					changeSelection(i);
					break;
				}
			}
		}
		// if(_packCount == 0){
		// 	addCategory("No packs or weeks to show",i);
		// 	grpSongs.members[i - 1].color = FlxColor.RED;
		// }
		// if(reload && lastSel == 1) changeSelection(_goToSong);
		SELoader.gc();
		updateInfoText('Use shift to scroll faster; Shift+F7 to erase the score of the current chart. Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while listening to a song in this menu. Found ${songInfoArray.length} songs');
	}

	public static function loadScriptsFromSongPath(selSong:String){
		LoadingScreen.loadingText = "Finding scripts";
		if(selSong.contains("mods/packs") || selSong.contains("mods/weeks")){
			var packDirL = selSong.split("/"); // Holy shit this is shit but using substr won't work for some reason :<

			if(packDirL[packDirL.length] == "")packDirL.pop(); // There might be an extra slash at the end, remove it
			packDirL.pop();
			if(packDirL.contains('packs')) 
				while(packDirL[packDirL.length - 2] != null && packDirL[packDirL.length - 2] != 'packs' )packDirL.pop(); 

			// Packs have a sub charts folder, weeks do not
			
			var packDir = packDirL.join("/");
			if(SELoader.isDirectory('${packDir}/scripts')){
				for (file in SELoader.readDirectory('${packDir}/scripts')) {
					if((file.endsWith(".hscript") || file.endsWith(".hx") #if(linc_luajit) || file.endsWith(".lua") #end ) && !SELoader.isDirectory('${packDir}/scripts/$file')){
						PlayState.scripts.push('${packDir}/scripts/$file');
					}
				}
			}
		}
	}
	public static function gotoSong(?selSong:String = "",?songJSON:String = "",?songName:String = "",?charting:Bool = false,?blankFile:Bool = false,?voicesFile:String="",?instFile:String=""){
		try{
			if(selSong == "" || songJSON == ""){
				throw("No song name provided!");
			}
			#if windows
			selSong = selSong.replace("\\","/"); // Who decided this was a good idea?
			#end
			LoadingScreen.loadingText = "Setting up variables";
			var chartFile = onlinemod.OfflinePlayState.chartFile = '${selSong}/${songJSON}';
			PlayState.isStoryMode = false;
			// Set difficulty
			PlayState.songspeed = onlinemod.OfflineMenuState.rate;
			PlayState.songDiff = songJSON;
			PlayState.storyDifficulty = (songJSON.endsWith('-easy.json') ? 0 : (songJSON.endsWith('easy.json') ? 2 : 1));
			PlayState.actualSongName = songJSON;
			onlinemod.OfflinePlayState.voicesFile = '';
			PlayState.hsBrToolsPath = selSong;
			PlayState.scripts = [];

			onlinemod.OfflinePlayState.instFile = (
				FileSystem.exists('${chartFile}-Inst.ogg') ? '${chartFile}-Inst.ogg'
				: instFile != "" ? instFile
				: '${selSong}/Inst.ogg');
			onlinemod.OfflinePlayState.voicesFile = (
				FileSystem.exists('${chartFile}-Voices.ogg') ? '${chartFile}-Voices.ogg' 
				: voicesFile != "" ? voicesFile
				: (FileSystem.exists('${selSong}/Voices.ogg') ? '${selSong}/Voices.ogg'
				: ''));
			loadScriptsFromSongPath(selSong);
			// if (FileSystem.exists('${selSong}/script.hscript')) {
			// 	trace("Song has script!");
			// 	MultiPlayState.scriptLoc = '${selSong}/script.hscript';
				
			// }else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
			LoadingScreen.loadingText = "Creating PlayState";

			PlayState.nameSpace = selSong;
			PlayState.stateType = 4;
			FlxG.sound.music.fadeOut(0.4);
			LoadingScreen.loadAndSwitchState(new MultiPlayState(charting));
		}catch(e){MainMenuState.handleError(e,'Error while loading chart ${e.message}');}
	}

	function selSong(sel:Int = 0,charting:Bool = false){
		if (grpSongs.members[sel].menuValue == null){ // Actually check if the song is a song, if not then error
			FlxG.sound.play(Paths.sound("cancelMenu"));
			showTempmessage("Invalid song!",FlxColor.RED);
			return;
		}
		var songInfo:SongInfo = cast grpSongs.members[sel].menuValue;
		onlinemod.OfflinePlayState.nameSpace = "";
		if(songInfo.namespace != null){
			onlinemod.OfflinePlayState.nameSpace = songInfo.namespace;
			trace('Using namespace ${onlinemod.OfflinePlayState.nameSpace}');
		}
		var songLoc = songInfo.path;
		if(charting){

			
			var chart = songInfo.charts[selMode];
			var songName = songInfo.name;
			if(chart == null){
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${chart = '$songName.json'}';
				trace('New chart! ${onlinemod.OfflinePlayState.chartFile}  $chart');
				var song = (PlayState.SONG = Song.parseJSONshit("",true));
				song.song = songName;
				try{
					SELoader.saveContent(onlinemod.OfflinePlayState.chartFile,Json.stringify({song:song}));
				}catch(e){trace('Unable to save chart:$e');} // The player will be manually saving this later, this doesn't need to succeed
			}else{
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${chart}';
				PlayState.SONG = Song.parseJSONshit(SELoader.loadText(onlinemod.OfflinePlayState.chartFile),true);
			}
			trace('Loading $songName  $chart');
			loadScriptsFromSongPath(songLoc);
			onlinemod.OfflinePlayState.voicesFile = (songInfo.voices ?? (SELoader.exists('${songLoc}/Voices.ogg') ? '${songLoc}/Voices.ogg' : ""));
			PlayState.hsBrTools = new HSBrTools('${songLoc}');
			onlinemod.OfflinePlayState.instFile = (songInfo.inst ?? '${songLoc}/Inst.ogg');
			if(SELoader.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg"))
				onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
			if(SELoader.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg"))
				onlinemod.OfflinePlayState.voicesFile = onlinemod.OfflinePlayState.chartFile + "-Voices.ogg";
			PlayState.stateType = 4;
			PlayState.SONG.needsVoices = onlinemod.OfflinePlayState.voicesFile != "";
			LoadingState.loadAndSwitchState(new ChartingState());
			return;
		}
		if (songInfo.charts[selMode] == "No charts for this song!"){ // Actually check if the song has no charts when loading, if so then error
			FlxG.sound.play(Paths.sound("cancelMenu"));
			showTempmessage("Invalid song!",FlxColor.RED);
			return;
		}
		loadScriptsFromSongPath(songLoc);

		lastSel = sel;
		lastSearch = searchField.text;
		lastSong = songInfo.path + songInfo.charts[selMode] + songInfo.name;
		{
			var diffList:Array<String> = PlayState.songDifficulties = [];
			for(i => v in songInfo.charts){
				diffList.push(songInfo.path + "/" + v);
			}
		}
		gotoSong(SELoader.getPath(songInfo.path),songInfo.charts[selMode],songInfo.name,songInfo.voices,songInfo.inst);
	}

	override function select(sel:Int = 0){
			selSong(sel,false);
	}

	var curPlaying = "";
	var playCount:Int = 0;
	var voices:FlxSound;
	var curVol:Float = 1;
	var SCORETXT:String = "";
	override function update(e){
		super.update(e);
		bg.alpha += e * (shouldDraw ? 2 : -2);
		if (updateTime) songProgressText.text = FlxStringUtil.formatTime(Math.floor(Conductor.songPosition / 1000), false) + "/" + songLengthTxt
			+ (voices != null ? voices.playing ? " Playing Inst and Voices" : " Playing Inst" : " Playing Inst. No Voices available");
		if (musicmodetext.text != "" && musicmodetext.text != null && FlxG.sound.music.onComplete == null)
			FlxG.sound.music.onComplete = musicmode;
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, onlinemod.OfflineMenuState.rate);
		try{
			if (voices != null)
				lime.media.openal.AL.sourcef(voices._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, onlinemod.OfflineMenuState.rate);
		}catch(e){return;}
		}
	}
	override function handleInput(){
		if (controls.BACK || FlxG.keys.justPressed.ESCAPE) {ret();return;}
		if(songInfoArray.length == 0 || !allowInput) return;
		if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} 
		else if (controls.UP_P || (controls.UP && grpSongs.members[curSelected].y > FlxG.height * 0.46 && grpSongs.members[curSelected].y < FlxG.height * 0.50) ){changeSelection(-1);}
		if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} 
		else if (controls.DOWN_P || (controls.DOWN && grpSongs.members[curSelected].y > FlxG.height * 0.50 && grpSongs.members[curSelected].y < FlxG.height * 0.56) ){changeSelection(1);}
		handleScroll();
		extraKeys();

		try{
			if (FlxG.keys.justPressed.Q)
				{
					var songInfo:SongInfo = cast grpSongs.members[curSelected].menuValue;
					PlayState.SONG = Song.parseJSONshit(File.getContent(songInfo.path + songInfo.charts[selMode]));
					if (PlayState.SONG.events != null && PlayState.SONG.mania > 0 && PlayState.SONG.keyCount == null)
						PlayState.SONG.keyCount = PlayState.SONG.mania + 1;
					if(PlayState.SONG.keyCount != null){
						switch(PlayState.SONG.keyCount)
						{
							case 1: PlayState.mania = 6;
							case 2: PlayState.mania = 7;
							case 3: PlayState.mania = 8;
							case 4: PlayState.mania = 0;
							case 5: PlayState.mania = 4;
							case 6: PlayState.mania = 1;
							case 7: PlayState.mania = 2;
							case 8: PlayState.mania = 5;
							case 9: PlayState.mania = 3;
							case 10: PlayState.mania = 9;
							case 11: PlayState.mania = 10;
							case 12: PlayState.mania = 11;
							case 13: PlayState.mania = 12;
							case 14: PlayState.mania = 13;
							case 15: PlayState.mania = 14;
							case 16: PlayState.mania = 15;
							case 17: PlayState.mania = 16;
							case 18: PlayState.mania = 17;
							case 21: PlayState.mania = 18;
							default: PlayState.mania = 0;
						}
					}else PlayState.mania = PlayState.SONG.mania;
					if(PlayState.SONG.playerKeyCount != null){
						switch(PlayState.SONG.playerKeyCount)
						{
							case 1: PlayState.playermania = 6;
							case 2: PlayState.playermania = 7;
							case 3: PlayState.playermania = 8;
							case 4: PlayState.playermania = 0;
							case 5: PlayState.playermania = 4;
							case 6: PlayState.playermania = 1;
							case 7: PlayState.playermania = 2;
							case 8: PlayState.playermania = 5;
							case 9: PlayState.playermania = 3;
							case 10: PlayState.playermania = 9;
							case 11: PlayState.playermania = 10;
							case 12: PlayState.playermania = 11;
							case 13: PlayState.playermania = 12;
							case 14: PlayState.playermania = 13;
							case 15: PlayState.playermania = 14;
							case 16: PlayState.playermania = 15;
							case 17: PlayState.playermania = 16;
							case 18: PlayState.playermania = 17;
							case 21: PlayState.playermania = 18;
							default: PlayState.playermania = 0;
						}
					}else PlayState.playermania = PlayState.SONG.mania;
					NoteStuffExtra.CalculateNoteAmount(PlayState.SONG,Math.POSITIVE_INFINITY);
					chartinfotext.text =
					'Chart Mania: ' + PlayState.SONG.mania + (PlayState.SONG.keyCount != PlayState.keyAmmo[PlayState.SONG.mania] ? '*' : '')
					+ '\n' + (PlayState.SONG.keyCount != PlayState.SONG.playerKeyCount ? 'Chart Player Keycount: ${PlayState.SONG.playerKeyCount}\nChart Opp Keycount: ${PlayState.SONG.keyCount}' : 'Chart Keycount: ${PlayState.SONG.keyCount}')
					+ '\nBF Note: ${CoolUtil.FormatNumber(NoteStuffExtra.bfNotes.length)}'
					+ '\nOpp Note: ${CoolUtil.FormatNumber(NoteStuffExtra.dadNotes.length)}'
					+ '\nShit Note: ${CoolUtil.FormatNumber(NoteStuffExtra.shitNotes)}'
					+ '\nBF Diff: ${NoteStuffExtra.CalculateDifficult(0.93,0)}'
					+ '\nOpp Diff: ${NoteStuffExtra.CalculateDifficult(0.93,1)}'
					+ '\n' + (FileSystem.exists('${songInfo.path}/script.hscript') ? 'Song has script' : '')
					+ '\n';
				}
		}catch(e){showTempmessage("Unable to get info of this chart",0xee0011);}
		if (controls.ACCEPT) select(curSelected);
	}

	override function extraKeys(){
		if(controls.LEFT_P && !FlxG.keys.pressed.SHIFT){changeDiff(-1);}
		if(controls.RIGHT_P && !FlxG.keys.pressed.SHIFT){changeDiff(1);}
		if (FlxG.keys.justPressed.SEVEN && FlxG.save.data.animDebug)
			selSong(curSelected,true);
		if((FlxG.mouse.justPressed)){
			if(FlxG.mouse.screenY < 35 && FlxG.mouse.screenX < 1115){
				changeDiff(if(FlxG.mouse.screenX > 640) 1 else -1);
			}
			else if(!FlxG.mouse.overlaps(blackBorder)){
				var curSel = grpSongs.members[curSelected];
				for (i in -2 ... 2) {
					var member = grpSongs.members[curSelected + i];
					if(member != null && FlxG.mouse.overlaps(member)){
						if(curSel == member){
							selSong(curSelected,false);
						}else{
							changeSelection(i);
						}
					}
				}
			}
		}
		if(FlxG.mouse.justPressedMiddle){
			changeDiff(1);
		}
		if(FlxG.mouse.wheel != 0){
			var move = -FlxG.mouse.wheel;
			changeSelection(Std.int(move));
		}
		if(FlxG.keys.justPressed.CONTROL && FlxG.keys.pressed.SHIFT)
			{
				FlxG.sound.music.onComplete = musicmode;
				musicmodetext.visible = true;
				musicshuffle = !musicshuffle;
				if(musicshuffle)
					musicmodetext.text = "Music Mode activate\nShuffle Mode";
				else
					musicmodetext.text = "Music Mode activate";
			}
		if(FlxG.keys.justPressed.CONTROL && !FlxG.keys.pressed.SHIFT){
			musicmodetext.visible = (FlxG.sound.music.onComplete != null);
			FlxG.autoPause = false;
			zoom = true;
			playCount++;
			allowInput = false;
			var songInfo:SongInfo = grpSongs.members[curSelected]?.menuValue;
			var songchart:Bool = false;
			if(songInfo == null) {
				curPlaying = "";
				SickMenuState.musicHandle();
				curPlaying = "SEMENUMUSIC";
				if(voices != null){
					voices.stop();
					voices.destroy();
				}
				allowInput = true;
			}else{
				#if (target.threaded)
				sys.thread.Thread.create(() -> {
				#end
					if(curPlaying != songInfo.name){
						if(songProgressParent != null){
							try{
								songProgressParent.remove(songProgress);
								songProgressParent.remove(songProgressText);
							}catch(e){}
						}
						FlxG.sound.music.fadeOut(0.4);
						curPlaying = songInfo.name;
						curplay = curSelected;
						if(voices != null){
							voices.stop();
							voices.destroy();
						}
						voices = null;
						try{
							if(SELoader.exists('${songInfo.path}${songInfo.charts[selMode]}-Inst.ogg')){
								FlxG.sound.playMusic(SELoader.loadSound('${songInfo.path}${songInfo.charts[selMode]}-Inst.ogg'),FlxG.save.data.instVol,true);
								songchart = true;
							}
							else FlxG.sound.playMusic(SELoader.loadSound(songInfo.inst),FlxG.save.data.instVol,true);
							songLength = FlxG.sound.music.length;
							songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
							updateTime = true;
						}catch(e){
							showTempmessage('Unable to play instrumental! ${e.message}',FlxColor.RED);
						}
						if (FlxG.sound.music.playing){
							if(songInfo.charts[selMode] != null && SELoader.exists(songInfo.path + "/" + songInfo.charts[selMode])){
								try{
									var e:SwagSong = cast Json.parse(SELoader.getContent(songInfo.path + "/" + songInfo.charts[selMode])).song;
									if(e.bpm > 0){
										PlayState.songspeed = 1;
										Conductor.changeBPM(e.bpm);
										Conductor.mapBPMChanges(e);
									}
								}catch(e){
									showTempmessage("Unable to get BPM from chart automatically. BPM will be out of sync",0xee0011);
								}
								FlxG.sound.music.pause();
							}
							try{
								songProgressParent = grpSongs.members[curSelected];
								songProgressParent.add(songProgress);
								songProgressParent.add(songProgressText);
								songProgress.revive();
								songProgressText.revive();
								songProgress.setParent(FlxG.sound.music,'time');
								songProgress.setRange(0,FlxG.sound.music.length);
								try{FlxTween.cancelTweensOf(songProgress);}catch(e){}
								try{FlxTween.cancelTweensOf(songProgressText);}catch(e){}
								songProgressText.alpha = songProgress.alpha = 0;
								songProgressText.y = songProgress.y = 0;
								songProgressText.x = (songProgress.x = songProgressParent.x + 20) ;
								songProgressText.y = (songProgress.y = songProgressParent.y + 60) - 5;
								FlxTween.tween(songProgress,{alpha:1,y:songProgress.y + 20},0.4,{ease:FlxEase.expoOut});
								FlxTween.tween(songProgressText,{alpha:1,y:songProgress.y + 20},0.4,{ease:FlxEase.expoOut});
								FlxTween.tween(songProgressText,{x:songProgress.x + songProgress.width + 10},0.7,{ease:FlxEase.expoOut});
								songProgressText.text = "Playing Inst";
							}catch(e){}
						}else{
							curPlaying = "";
							SickMenuState.musicHandle();
						}
					}
					if(curPlaying == songInfo.name){
						try{
							if(voices == null){
								if(SELoader.exists(songInfo.voices)){
									voices = new FlxSound();
									if(SELoader.exists('${songInfo.path}/${songInfo.charts[selMode]}-Voices.ogg')){
										voices.loadEmbedded(SELoader.loadSound('${songInfo.path}/${songInfo.charts[selMode]}-Voices.ogg'),true);
										songchart = true;
									}
									else voices.loadEmbedded(SELoader.loadSound(songInfo.voices),true);
									voices.volume = FlxG.save.data.voicesVol;
									voices.looped = true;
									voices.play(FlxG.sound.music.time);
									FlxG.sound.list.add(voices);
								}
							}else{
								if(!voices.playing){
									voices.play(FlxG.sound.music.time);
									voices.volume = FlxG.save.data.voicesVol;
									voices.looped = true;
								}else{
									voices.stop();
								}
							}
							shouldVoicesPlay = (voices != null && voices.playing);
						}catch(e){
							showTempmessage('Unable to play voices! ${e.message}',FlxColor.RED);
						}
						if(FlxG.sound.music.fadeTween != null) FlxG.sound.music.fadeTween.destroy(); // Prevents the song from muting itself
						FlxG.sound.music.volume = FlxG.save.data.instVol;
						FlxG.sound.music.play();
					}
					DiscordClient.changePresence('Listening to',(songchart ? songInfo.charts[selMode] : songInfo.name),null,true,FlxG.sound.music.length,"https://i.imgur.com/HXQiPxD.gif");
					if(playCount > 2)
						playCount = 0;
					allowInput = true;
				#if (target.threaded)
				});
				#end
			}
		}
	super.extraKeys();
	}
	var twee:FlxTween;
	var curScoreName:String = "";
	function updateScore(?songInfo:SongInfo,?chart:String){
		if(songInfo == null || chart == null){
			scoreText.text = "N/A";
			SCORETXT = "N/A";
			scoreText.screenCenter(X);
			return;
		}
		var name = '${songInfo.path}-${chart}${(QuickOptionsSubState.getSetting("Inverted chart") ? "-inverted" : "")}${(if(FlxG.save.data.scoresystem == 0) "" else "-" + FlxG.save.data.scoresystem)}';
		curScoreName = "";
		if(!Highscore.songScores.exists(name)){
			scoreText.text = "N/A";
			SCORETXT = "N/A";
			scoreText.screenCenter(X);
			return;
		}
		curScoreName = name;
		scoreText.text = (Highscore.songScores.getArr(curScoreName)).join(", ");
		scoreText.screenCenter(X);
		
	}
	function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
		var songInfo = grpSongs.members[curSelected]?.menuValue;
		if (songInfo == null) {
			diffText.text = 'No song selected';
			diffText.screenCenter(X);
			updateScore();
			return;
		}
		if(twee != null)twee.cancel();
		diffText.scale.set(1.2,1.2);
		twee = FlxTween.tween(diffText.scale,{x:1,y:1},(30 / Conductor.bpm));
		var charts = songInfo.charts;
		lastSong = charts[selMode] + songInfo.name;

		if (forcedInt == -100) selMode += change; else selMode = forcedInt;
		if (selMode >= charts.length) selMode = 0;
		if (selMode < 0) selMode = charts.length - 1;
		// var e:Dynamic = TitleState.getScore(4);
		// if(e != null && e != 0) diffText.text = '< ' + e + '%(' + Ratings.getLetterRankFromAcc(e) + ') - ' + modes[curSelected][selMode] + ' >';
		// else 
		// "No charts for this song!"
		// diffText.text = (if(modes[curSelected][selMode - 1 ] != null ) '< ' else '|  ') + (if(modes[curSelected][selMode] == CATEGORYNAME) songs[curSelected] else modes[curSelected][selMode]) + (if(modes[curSelected][selMode + 1 ] != null) ' >' else '  |');
		diffText.text = (charts[selMode - 1] == null ? "|  " : "< ") + (charts[selMode] ?? "No charts for this song!") + (charts[selMode + 1] == null ? "  |" : " >");
		// diffText.centerOffsets();
		diffText.screenCenter(X);
		updateScore(songInfo,charts[selMode]);
		chartinfotext.text = "Press Q for chart info";

		// diffText.x = (FlxG.width) - 20 - diffText.width;

	}

	override function changeSelection(change:Int = 0){
		var looped = 0;
		chartinfotext.text = "Press Q for chart info";
		super.changeSelection(change);
		var songInfo = grpSongs.members[curSelected]?.menuValue;
		if(songInfo == null || !songInfo.charts.contains('${songInfo.name}.json')){
			changeDiff(0,0);
			return;
		}
		changeDiff(0,songInfo.charts.indexOf('${songInfo.name}.json'));
		// if (modes[curSelected].indexOf('${songNames[curSelected]}.json') != -1) changeDiff(0,modes[curSelected].indexOf('${songNames[curSelected]}.json')); else changeDiff(0,0);
	}

	function musicmode()
	{

		if(musicshuffle)
		{
			if(curSelected < songInfoArray.length / 10)
				shuffleforwand = true;
			else if(songInfoArray.length - curSelected < songInfoArray.length / 10)
				shuffleforwand = false;
			if(shuffleforwand)
				changeSelection(FlxG.random.int(1,10));
			else
				changeSelection(FlxG.random.int(-10,-1));
		}
		else
			changeSelection(1);
		FlxG.autoPause = false;
		playCount++;
		allowInput = false;
		var songInfo:SongInfo = grpSongs.members[curSelected]?.menuValue;
		var songchart:Bool = false;
		if(songInfo == null) {
			curPlaying = "";
			SickMenuState.musicHandle();
			curPlaying = "SEMENUMUSIC";
			if(voices != null){
				voices.stop();
				voices.destroy();
			}
			allowInput = true;
		}else{
			#if (target.threaded)
			sys.thread.Thread.create(() -> {
			#end
				if(curPlaying != songInfo.name){
					if(songProgressParent != null){
						try{
							songProgressParent.remove(songProgress);
							songProgressParent.remove(songProgressText);
						}catch(e){}
					}
					FlxG.sound.music.fadeOut(0.4);
					curPlaying = songInfo.name;
					curplay = curSelected;
					if(voices != null){
						voices.stop();
						voices.destroy();
					}
					voices = null;
					try{
						if(SELoader.exists('${songInfo.path}${songInfo.charts[selMode]}-Inst.ogg')){
								FlxG.sound.playMusic(SELoader.loadSound('${songInfo.path}${songInfo.charts[selMode]}-Inst.ogg'),FlxG.save.data.instVol,true);
								songchart = true;
							}
						else FlxG.sound.playMusic(SELoader.loadSound(songInfo.inst),FlxG.save.data.instVol,true);
						songLength = FlxG.sound.music.length;
						songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
						updateTime = true;
					}catch(e){
						showTempmessage('Unable to play instrumental! ${e.message}',FlxColor.RED);
					}
					if (FlxG.sound.music.playing){
						if(songInfo.charts[selMode] != null && SELoader.exists(songInfo.path + "/" + songInfo.charts[selMode])){
							try{
								var e:SwagSong = cast Json.parse(SELoader.getContent(songInfo.path + "/" + songInfo.charts[selMode])).song;
								if(e.bpm > 0){
									PlayState.songspeed = 1;
									Conductor.changeBPM(e.bpm);
									Conductor.mapBPMChanges(e);
								}
							}catch(e){
								showTempmessage("Unable to get BPM from chart automatically. BPM will be out of sync",0xee0011);
							}
							FlxG.sound.music.pause();
						}
						try{
							songProgressParent = grpSongs.members[curSelected];
							songProgressParent.add(songProgress);
							songProgressParent.add(songProgressText);
							songProgress.revive();
							songProgressText.revive();
							songProgress.setParent(FlxG.sound.music,'time');
							songProgress.setRange(0,FlxG.sound.music.length);
							try{FlxTween.cancelTweensOf(songProgress);}catch(e){}
							try{FlxTween.cancelTweensOf(songProgressText);}catch(e){}
							songProgressText.alpha = songProgress.alpha = 0;
							songProgressText.y = songProgress.y = 0;
							songProgressText.x = (songProgress.x = songProgressParent.x + 20) ;
							songProgressText.y = (songProgress.y = songProgressParent.y + 60) - 5;
							FlxTween.tween(songProgress,{alpha:1,y:songProgress.y + 20},0.4,{ease:FlxEase.expoOut});
							FlxTween.tween(songProgressText,{alpha:1,y:songProgress.y + 20},0.4,{ease:FlxEase.expoOut});
							FlxTween.tween(songProgressText,{x:songProgress.x + songProgress.width + 10},0.7,{ease:FlxEase.expoOut});
							songProgressText.text = "Playing Inst";
						}catch(e){}
						#if discord_rpc
						#end
					}else{
						curPlaying = "";
						SickMenuState.musicHandle();
					}
				}
				if(curPlaying == songInfo.name){
					try{
						if(voices == null){
							if(SELoader.exists(songInfo.voices)){
								voices = new FlxSound();
								if(SELoader.exists('${songInfo.path}${songInfo.charts[selMode]}-Voices.ogg')){
										voices.loadEmbedded(SELoader.loadSound('${songInfo.path}/${songInfo.charts[selMode]}-Voices.ogg'),true);
										songchart = true;
									}
								else voices.loadEmbedded(SELoader.loadSound(songInfo.voices),true);
								voices.volume = FlxG.save.data.voicesVol;
								voices.looped = true;
								voices.play(FlxG.sound.music.time);
								FlxG.sound.list.add(voices);
							}
						}else{
							if(!voices.playing){
								voices.play(FlxG.sound.music.time);
								voices.volume = FlxG.save.data.voicesVol;
								voices.looped = true;
							}else{
								voices.stop();
							}
						}
						shouldVoicesPlay = (voices != null && voices.playing);
					}catch(e){
						showTempmessage('Unable to play voices! ${e.message}',FlxColor.RED);
					}
					if(FlxG.sound.music.fadeTween != null)FlxG.sound.music.fadeTween.destroy(); // Prevents the song from muting itself
					FlxG.sound.music.volume = FlxG.save.data.instVol;
					FlxG.sound.music.play();
				}
				DiscordClient.changePresence('Listening to',(songchart ? songInfo.charts[selMode] : songInfo.name),null,true,FlxG.sound.music.length,"https://i.imgur.com/HXQiPxD.gif");
				if(playCount > 2)
					playCount = 0;
				allowInput = true;
			#if (target.threaded)
			});
			#end
		FlxG.sound.music.onComplete = musicmode;
		}
	}

	override function goOptions(){
		lastSel = curSelected;
		lastSearch = searchField.text;
		FlxG.mouse.visible = false;
		OptionsMenu.lastState = 4;
		FlxG.switchState(new OptionsMenu());
	}
	public static function findSongByName(songName:String = "",?namespace:String = ""):String{
		if(songName == "") return null;
		if(namespace == "" && songName.contains('|')){
			namespace = songName.substring(0,songName.indexOf('|'));
			songName = songName.substring(songName.indexOf('|') + 1);

		}
		var probablyHasDifficulty = songName.contains("-");
		var songNameWithoutDifficulty = (probablyHasDifficulty ? songName.substring(0,songName.lastIndexOf("-")) : "");
		var difficulty = (probablyHasDifficulty ? songName.substring(songName.lastIndexOf("-") + 1) : "");
		if(namespace != ""){
			if(SELoader.exists('mods/packs/$namespace')){
				var packDir = 'mods/packs/$namespace/charts';
				var dir = SELoader.anyExists(['$packDir/$songName/$songName.json','$packDir/$songNameWithoutDifficulty/$songName.json']);
				if(dir != null) return dir;
			}
			if(SELoader.exists('mods/weeks/$namespace')){
				var packDir = 'mods/weeks/$namespace/charts';
				var dir = SELoader.anyExists(['$packDir/$songName/$songName.json','$packDir/$songNameWithoutDifficulty/$songName.json']);
				if(dir != null) return dir;
			}
		}
		var dir = SELoader.anyExists(['mods/charts/$songName/$songName.json',
									'mods/packs/$songNameWithoutDifficulty/charts/$songName/$songName.json',
									'mods/packs/$songNameWithoutDifficulty/charts/$songNameWithoutDifficulty/$songName.json',
									'mods/packs/$songName/charts/$songName/$songName.json',
									'mods/charts/$songNameWithoutDifficulty/$songName.json']);
		if(dir != null) return dir;
		for(i in SELoader.readDirectory('mods/packs')){
			var dir = SELoader.anyExists(['mods/packs/$i/charts/$songName/$songName.json','mods/packs/$i/charts/$songNameWithoutDifficulty/$songName.json']);
			if(dir != null) return dir;
		}
		return null;
	}
	public static function playSongByName(songName:String = "",?namespace:String = ""):Bool{
		var song = findSongByName(songName,namespace);
		if(song == null)return false;
		if(!SELoader.exists(song)){
			trace('"$song" does not exist!');
			return false;
		}
		gotoSong(song.substr(0,song.lastIndexOf('/')),song.substr(song.lastIndexOf('/') + 1));
		return true;
	}
}