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
import flixel.system.FlxSound;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import Discord.DiscordClient;

using StringTools;

class MultiMenuState extends onlinemod.OfflineMenuState
{
	var modes:Map<Int,Array<String>> = [];
	static var CATEGORYNAME:String = "-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-CATEGORY";
	var diffText:FlxText;
	var scoreText:FlxText;
	var selMode:Int = 0;
	var blockedFiles:Array<String> = ['picospeaker.json','dialogue-end.json','dialogue.json','_meta.json','meta.json','config.json'];
	static var lastSel:Int = 1;
	static var lastSearch:String = "";
	public static var lastSong:String = "";
	var beetHit:Bool = false;

	var songNames:Array<String> = [];
	var nameSpaces:Array<String> = [];
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
			if(zoomtween != null)zoomtween.cancel();
			grpSongs.members[curplay].scale.set(1.25,1.25);
			zoomtween = FlxTween.tween(grpSongs.members[curplay].scale,{x:1,y:1},(Conductor.crochet / 2000),{ease: FlxEase.quadInOut});
		}
		if (voices != null && shouldVoicesPlay && (!voices.playing || (voices.time > FlxG.sound.music.time + 20 || voices.time < FlxG.sound.music.time - 20))){
			voices.time = FlxG.sound.music.time;
			voices.play();
		}
		if(Conductor.bpmChangeMap.length > 0){
			for(event in Conductor.bpmChangeMap){
                if(event.stepTime == curStep){
                    Conductor.changeBPM(event.bpm);
                    break;
                }
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
		updateInfoText('Use Shift to scroll faster; Press Control to listen to instrumental/voices of song. Press again to toggle the voices. Found ${songs.length} songs. Press Control + Shift to turn on Music mode. Press again to toggle Shuffle Mode');

	}
	override function onFocus() {
		shouldDraw = true;
		super.onFocus();
	}
	override function onFocusLost(){
		shouldDraw = false;
		super.onFocusLost();
	}
	function addListing(name:String,i:Int):Alphabet{
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);
		controlLabel.yOffset = 20;
		controlLabel.cutOff = 25;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0) controlLabel.alpha = 0.6;
		grpSongs.add(controlLabel);
		return controlLabel;
	}
	function addCategory(name:String,i:Int):Alphabet{
		songs[i] = name;
		modes[i] = [CATEGORYNAME];
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false,true);
		controlLabel.adjustAlpha = false;
		controlLabel.screenCenter(X);
		// blackBorder.alpha = 0.35;
		// blackBorder.screenCenter(X);
		controlLabel.border.alpha = 0.35;
		controlLabel.yOffset = 20;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		controlLabel.alpha = 1;
		// controlLabel.screenCentX = true;
		grpSongs.add(controlLabel);
		return controlLabel;
	}
	inline function isValidFile(file) {return (!blockedFiles.contains(file.toLowerCase()) && (StringTools.endsWith(file, '.json')));}
	override function reloadList(?reload=false,?search = ""){
		curSelected = 0;
		var _goToSong = 0;
		if(reload){grpSongs.clear();}

		songs = ["No Songs!"];
		songNames = ["Nothing"];
		modes = [0 => ["None"]];
		var i:Int = 0;


		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
		// if(!cancelCurrentFunction){
			if (SELoader.exists(dataDir))
			{
				var dirs = orderList(SELoader.readDirectory(dataDir));
				addCategory("charts folder",i);
				i++;

				LoadingScreen.loadingText = 'Scanning mods/charts';
				for (directory in dirs)
				{
					if (search == "" || query.match(directory.toLowerCase())) // Handles searching
					{
						if (SELoader.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in orderList(SELoader.readDirectory(dataDir + directory)))
							{
									if (isValidFile(file)){
										modes[i].push(file);
									}
							}
							if (modes[i][0] == null){ // No charts to load!
								modes[i][0] = "No charts for this song!";
							}
							songs[i] = dataDir + directory;
							songNames[i] =directory;

							addListing(directory,i);
							if(_goToSong == 0)_goToSong = i;
							i++;

						}
					}
				}
			}
			var _packCount:Int = 0;
			if (SELoader.exists("mods/weeks"))
			{
				for (name in orderList(SELoader.readDirectory("mods/weeks")))
				{

					var dataDir = "mods/weeks/" + name + "/charts/";
					if(!SELoader.exists(dataDir)){continue;}
					var catMatch = query.match(name.toLowerCase());
					var dirs = orderList(SELoader.readDirectory(dataDir));
					addCategory(name + "(Week)",i);
					i++;
					_packCount++;
					var containsSong = false;
					LoadingScreen.loadingText = 'Scanning mods/weeks/$name';
					for (directory in dirs)
					{
						if ((search == "" || catMatch || query.match(directory.toLowerCase())) && SELoader.isDirectory('${dataDir}${directory}')) // Handles searching
						{
							if (SELoader.exists('${dataDir}${directory}/Inst.ogg') ){
								modes[i] = [];
								for (file in orderList(SELoader.readDirectory(dataDir + directory)))
								{
										if (isValidFile(file)){
											modes[i].push(file);
										}
								}
								if (modes[i][0] == null){ // No charts to load!
									modes[i][0] = "No charts for this song!";
								}
								songs[i] = dataDir + directory;
								songNames[i] = directory;

								
								addListing(directory,i);
								nameSpaces[i] = dataDir;
								if(_goToSong == 0)_goToSong = i;
								containsSong = true;
								i++;
							}
						}
					}
					if(!containsSong){
						grpSongs.members[i - 1].color = FlxColor.RED;
					}
				}
			}
			var emptyCats:Array<String> = [];
			if (SELoader.exists("mods/packs"))
			{
				for (name in orderList(SELoader.readDirectory("mods/packs")))
				{
					// dataDir = "mods/packs/" + dataDir + "/charts/";
					var catMatch = query.match(name.toLowerCase());
					var dataDir = "mods/packs/" + name + "/charts/";
					if(!SELoader.exists(dataDir)){continue;}
					var containsSong = false;
					var dirs = orderList(SELoader.readDirectory(dataDir));
					LoadingScreen.loadingText = 'Scanning mods/packs/$name/charts/';
					for (directory in dirs)
					{
						if ((search == "" || catMatch || query.match(directory.toLowerCase())) && SELoader.isDirectory('${dataDir}${directory}')) // Handles searching
						{
							if (SELoader.exists('${dataDir}${directory}/Inst.ogg') ){
								if(!containsSong){
									containsSong = true;
									addCategory(name,i);
									i++;
								}
								modes[i] = [];
								for (file in orderList(SELoader.readDirectory(dataDir + directory)))
								{
										if (isValidFile(file)){
											modes[i].push(file);
										}
								}
								if (modes[i][0] == null){ // No charts to load!
									modes[i][0] = "No charts for this song!";
								}

								songs[i] = dataDir + directory;
								songNames[i] =directory;

								
								addListing(directory,i);
								if(_goToSong == 0)_goToSong = i;
								nameSpaces[i] = dataDir;
								i++;
							}
						}
					}
					if(!containsSong){
						// grpSongs.members[i - 1].color = FlxColor.RED;
						emptyCats.push(name);
					}
				}
			}
			while(emptyCats.length > 0){
				var e = emptyCats.shift();
				addCategory(e,i).color = FlxColor.RED;
				i++;
			}
		// }
		// if(_packCount == 0){
		// 	addCategory("No packs or weeks to show",i);
		// 	grpSongs.members[i - 1].color = FlxColor.RED;
		// }
		if(reload && lastSel == 1) changeSelection(_goToSong);
		updateInfoText('Use shift to scroll faster; Shift+F7 to erase the score of the current chart. Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while listening to a song in this menu. Found ${songs.length} songs');
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
	public static function gotoSong(?selSong:String = "",?songJSON:String = "",?songName:String = "",charting:Bool = false,blankFile:Bool = false){
			try{
				if(selSong == "" || songJSON == ""){
					throw("No song name provided!");
				}
				onlinemod.OfflinePlayState.chartFile = '${selSong}/${songJSON}';
				PlayState.isStoryMode = false;
				// Set difficulty
				PlayState.songspeed = onlinemod.OfflineMenuState.rate;
				PlayState.songDiff = songJSON;
				PlayState.storyDifficulty = (if(songJSON == '${songName}-easy.json') 0 else if(songJSON == '${songName}-easy.json') 2 else 1);
				PlayState.actualSongName = songJSON;
				onlinemod.OfflinePlayState.voicesFile = '';
				PlayState.hsBrToolsPath = selSong;
				PlayState.scripts = [];

				if (FileSystem.exists('${selSong}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${selSong}/Voices.ogg';}
				loadScriptsFromSongPath(selSong);
				// if (FileSystem.exists('${selSong}/script.hscript')) {
				// 	trace("Song has script!");
				// 	MultiPlayState.scriptLoc = '${selSong}/script.hscript';
				// }else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
				onlinemod.OfflinePlayState.instFile = '${selSong}/Inst.ogg';
				if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg")){
					trace("Inst For Chart Exist!");
					onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
				}
				if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg")){
					trace("Voices For Chart Exist!");
					onlinemod.OfflinePlayState.voicesFile = onlinemod.OfflinePlayState.chartFile + "-Voices.ogg";
				}
				PlayState.nameSpace = selSong;
				PlayState.stateType = 4;
				FlxG.sound.music.fadeOut(0.4);
				LoadingState.loadAndSwitchState(new MultiPlayState());
			}catch(e){
				MainMenuState.handleError('Error while loading chart ${e.message}');
			}
	}

	function selSong(sel:Int = 0,charting:Bool = false){
		if (songs[sel] == "No Songs!" || modes[sel][selMode] == CATEGORYNAME){ // Actually check if the song is a song, if not then error
			FlxG.sound.play(Paths.sound("cancelMenu"));
			showTempmessage("Invalid song!",FlxColor.RED);
			return;
		}
		var songLoc = songs[sel];
		if(charting){
			var chart = modes[sel][selMode];
			var songName = songNames[sel];
			if(modes[curSelected][selMode] == "No charts for this song!"){
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${songName}.json';
				var song = cast Song.getEmptySong();
				song.song = songName;
				SELoader.saveContent(onlinemod.OfflinePlayState.chartFile,Json.stringify({song:song}));
				reloadList(true,searchField.text);
				curSelected = sel;
				changeSelection();
				selSong(sel,true);
				return;
			}else{
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${chart}';
				PlayState.SONG = Song.parseJSONshit(SELoader.loadText(onlinemod.OfflinePlayState.chartFile),true);
			}
			loadScriptsFromSongPath(songLoc);
			if (SELoader.exists('${songLoc}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${songLoc}/Voices.ogg';}
			PlayState.hsBrTools = new HSBrTools('${songLoc}');
			onlinemod.OfflinePlayState.instFile = '${songLoc}/Inst.ogg';
			if(SELoader.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg"))
				onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
			if(SELoader.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg"))
				onlinemod.OfflinePlayState.voicesFile = onlinemod.OfflinePlayState.chartFile + "-Voices.ogg";
			PlayState.stateType = 4;
			PlayState.SONG.needsVoices =  onlinemod.OfflinePlayState.voicesFile != "";
			LoadingState.loadAndSwitchState(new ChartingState());
			return;
		}
		if (modes[sel][selMode] == "No charts for this song!"){ // Actually check if the song has no charts when loading, if so then error
			FlxG.sound.play(Paths.sound("cancelMenu"));
			showTempmessage("Invalid song!",FlxColor.RED);
			return;
		}
		onlinemod.OfflinePlayState.nameSpace = "";
		if(nameSpaces[sel] != null){
			onlinemod.OfflinePlayState.nameSpace = nameSpaces[sel];
			trace('Using namespace ${onlinemod.OfflinePlayState.nameSpace}');
		}
		loadScriptsFromSongPath(songLoc);
		lastSel = sel;
		lastSearch = searchField.text;
		lastSong = songs[sel] + modes[sel][selMode] + songNames[sel];
		{
			var diffList:Array<String> = PlayState.songDifficulties = [];
			for(i => v in modes[sel]){
				diffList.push(songs[sel] + "/" + v);
			}
		}
		gotoSong(songs[sel],modes[sel][selMode],songNames[sel]);
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
			if (controls.BACK || FlxG.keys.justPressed.ESCAPE)
				ret();
			if(songs.length == 0) return;
			if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} 
			else if (controls.UP_P || (controls.UP && grpSongs.members[curSelected].y > FlxG.height * 0.46 && grpSongs.members[curSelected].y < FlxG.height * 0.50) ){changeSelection(-1);}
			if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} 
			else if (controls.DOWN_P || (controls.DOWN && grpSongs.members[curSelected].y > FlxG.height * 0.50 && grpSongs.members[curSelected].y < FlxG.height * 0.56) ){changeSelection(1);}
			handleScroll();
			extraKeys();

			try{
				if (FlxG.keys.justPressed.Q)
					{
						PlayState.SONG = Song.parseJSONshit(File.getContent('${songs[curSelected]}/${modes[curSelected][selMode]}'));
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
						+ '\n' + (FileSystem.exists('${songs[curSelected]}/script.hscript') ? 'Song has script' : '')
						+ '\n';
					}
			}catch(e){showTempmessage("Unable to get info of this chart",0xee0011);}
			if (controls.ACCEPT && songs.length > 0)
			{
				select(curSelected);
			}
	}

	override function extraKeys(){
		if(controls.LEFT_P && !FlxG.keys.pressed.SHIFT){changeDiff(-1);}
		if(controls.RIGHT_P && !FlxG.keys.pressed.SHIFT){changeDiff(1);}
		if (FlxG.keys.justPressed.SEVEN && songs.length > 0 && FlxG.save.data.animDebug)
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
			#if (target.threaded)
			sys.thread.Thread.create(() -> {
			#end
				if(curPlaying != songs[curSelected]){
					if(songProgressParent != null){
						try{
							songProgressParent.remove(songProgress);
							songProgressParent.remove(songProgressText);
						}catch(e){}
					}
					FlxG.sound.music.fadeOut(0.4);
					curPlaying = songs[curSelected];
					curplay = curSelected;
					if(voices != null){
						voices.stop();
						voices.destroy();
					}
					voices = null;
					try{
						if(SELoader.exists('${songs[curSelected]}/${modes[curSelected][selMode]}-Inst.ogg'))
								FlxG.sound.playMusic(SELoader.loadSound('${songs[curSelected]}/${modes[curSelected][selMode]}-Inst.ogg'),FlxG.save.data.instVol,true);
						else FlxG.sound.playMusic(SELoader.loadSound('${songs[curSelected]}/Inst.ogg'),FlxG.save.data.instVol,true);
						songLength = FlxG.sound.music.length;
						songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
						updateTime = true;
					}catch(e){
						showTempmessage('Unable to play instrumental! ${e.message}',FlxColor.RED);
					}
					if (FlxG.sound.music.playing){
						if(modes[curSelected][selMode] != "No charts for this song!" && SELoader.exists(songs[curSelected] + "/" + modes[curSelected][selMode])){
							try{
								var e:SwagSong = cast Json.parse(File.getContent(songs[curSelected] + "/" + modes[curSelected][selMode])).song;
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
						DiscordClient.changePresence('Listening to',songNames[curSelected],null,true,FlxG.sound.music.length,"https://i.imgur.com/HXQiPxD.gif");
					}else{
						curPlaying = "";
						SickMenuState.musicHandle();
					}
				}
				if(curPlaying == songs[curSelected]){
					try{

						if(voices == null){
							if(SELoader.exists('${songs[curSelected]}/Voices.ogg')){
								voices = new FlxSound();
								if(SELoader.exists('${songs[curSelected]}/${modes[curSelected][selMode]}-Voices.ogg'))
									voices.loadEmbedded(SELoader.loadSound('${songs[curSelected]}/${modes[curSelected][selMode]}-Voices.ogg'),true);
								else voices.loadEmbedded(SELoader.loadSound('${songs[curSelected]}/Voices.ogg'),true);
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
				if(playCount > 2){
					playCount = 0;
					SELoader.gc();
				}
				allowInput = true;
			#if (target.threaded)
			});
			#end
		}
	super.extraKeys();
	}
	var twee:FlxTween;
	function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
		if (songs.length == 0 || songs[curSelected] == null || songs[curSelected] == "") {
			diffText.text = 'No song selected';
			return;
		}
		if(twee != null)twee.cancel();
		diffText.scale.set(1.2,1.2);
		twee = FlxTween.tween(diffText.scale,{x:1,y:1},(30 / Conductor.bpm));
		lastSong = modes[curSelected][selMode] + songNames[curSelected];

		if (forcedInt == -100) selMode += change; else selMode = forcedInt;
		if (selMode >= modes[curSelected].length) selMode = 0;
		if (selMode < 0) selMode = modes[curSelected].length - 1;
		diffText.text = (if(modes[curSelected][selMode - 1 ] != null ) '< ' else '|  ') + (if(modes[curSelected][selMode] == CATEGORYNAME) songs[curSelected] else modes[curSelected][selMode]) + (if(modes[curSelected][selMode + 1 ] != null) ' >' else '  |');
		diffText.screenCenter(X);
		var name = '${songs[curSelected]}-${modes[curSelected][selMode]}${(if(QuickOptionsSubState.getSetting("Inverted chart")) "-inverted" else "")}${(if(FlxG.save.data.scoresystem == 0) "" else "-" + FlxG.save.data.scoresystem)}';
		if(modes[curSelected][selMode] == null || modes[curSelected][selMode] == CATEGORYNAME || !Highscore.songScores.exists(name)){
			// score = 0;
			scoreText.text = "N/A";
			SCORETXT = "N/A";
			scoreText.screenCenter(X);
		}else{
			scoreText.text = (Highscore.songScores.getArr(name)).join(", ");
			scoreText.screenCenter(X);
		}
		chartinfotext.text = "Press Q for chart info";
	}

	override function changeSelection(change:Int = 0)
	{
		var looped = 0;
		chartinfotext.text = "Press Q for chart info";
		super.changeSelection(change);
		if (modes[curSelected].indexOf('${songNames[curSelected]}.json') != -1) changeDiff(0,modes[curSelected].indexOf('${songNames[curSelected]}.json')); else changeDiff(0,0);
	}

	function musicmode()
	{

		if(musicshuffle)
		{
			if(curSelected < songs.length / 10)
				shuffleforwand = true;
			else if(songs.length - curSelected < songs.length / 10)
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
			#if (target.threaded)
			sys.thread.Thread.create(() -> {
			#end
				if(curPlaying != songs[curSelected]){
					if(songProgressParent != null){
						try{
							songProgressParent.remove(songProgress);
							songProgressParent.remove(songProgressText);
						}catch(e){}
					}
					FlxG.sound.music.fadeOut(0.4);
					curPlaying = songs[curSelected];
					curplay = curSelected;
					if(voices != null){
						voices.stop();
						voices.destroy();
					}
					voices = null;
					try{
						FlxG.sound.playMusic(SELoader.loadSound('${songs[curSelected]}/Inst.ogg'),FlxG.save.data.instVol,true);
						songLength = FlxG.sound.music.length;
						songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
					}catch(e){
						showTempmessage('Unable to play instrumental! ${e.message}',FlxColor.RED);
					}
					if (FlxG.sound.music.playing){
						if(modes[curSelected][selMode] != "No charts for this song!" && SELoader.exists(songs[curSelected] + "/" + modes[curSelected][selMode])){
							try{
								var e:SwagSong = cast Json.parse(File.getContent(songs[curSelected] + "/" + modes[curSelected][selMode])).song;
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

						DiscordClient.changePresence('Listening to',songNames[curSelected],null,true,FlxG.sound.music.length,"https://i.imgur.com/HXQiPxD.gif");
					}else{
						curPlaying = "";
						SickMenuState.musicHandle();
					}
				}
				if(curPlaying == songs[curSelected]){
					try{

						if(voices == null){
							if(SELoader.exists('${songs[curSelected]}/Voices.ogg')){
								voices = new FlxSound();
								voices.loadEmbedded(SELoader.loadSound('${songs[curSelected]}/Voices.ogg'),true);
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
				if(playCount > 2){
					playCount = 0;
					SELoader.gc();
				}
				allowInput = true;
			#if (target.threaded)
			});
			#end
		FlxG.sound.music.onComplete = musicmode;
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