package multi;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
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
#if windows
import Discord.DiscordClient;
#end

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
	var inTween:FlxTween;

	var chartinfo:Array<Float> = [];
	var chartinfotext:FlxText;

	var musicmodetext:FlxText;
	var musicshuffle:Bool = true; //it will get invert on first play
	var zoom:Bool = false;
	var zoomtween:FlxTween;

	var curplay:Int = 0;
	var songLength:Float = 0;
	var songLengthTxt = "N/A";
	var songTimeTxt:FlxText;
	var updateTime:Bool = false;
	override function draw(){
		if(shouldDraw){
			super.draw();
		}else{
			grpSongs.members[curSelected].draw();
			grpSongs.members[curplay].draw();
			musicmodetext.draw();
			songTimeTxt.draw();
		}
	}
	override function beatHit(){
		if(zoom /* && curBeat % 2 == 0 */){
			if(zoomtween != null)zoomtween.cancel();
			grpSongs.members[curplay].scale.set(1.1,1.1);
			zoomtween = FlxTween.tween(grpSongs.members[curplay].scale,{x:1,y:1},(Conductor.crochet / 2000),{ease: FlxEase.quadInOut});
		}
		if (voices != null && voices.playing && (voices.time > FlxG.sound.music.time + 20 || voices.time < FlxG.sound.music.time - 20))
		{
			voices.time = FlxG.sound.music.time;
			voices.play();
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
		#if windows
		new FlxTimer().start(0.1, function(tmr)
		{
			DiscordClient.changePresence('Browsing Multi Menu',null);
		});
		#end
		FlxG.sound.music.onComplete = null;
		retAfter = false;
		SearchMenuState.doReset = true;
		dataDir = "mods/charts/";
		bgColor = 0x00661E;
		super.create();
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
		chartinfotext = new FlxText(0, 140, FlxG.width, "Press Q for chart info", 24);
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
		songTimeTxt = new FlxText(0, FlxG.height / 2 , FlxG.width , '',24);
		songTimeTxt.alignment = RIGHT;
		songTimeTxt.font = CoolUtil.font;
		songTimeTxt.borderSize = 2;
		add(songTimeTxt);

		searchField.text = lastSearch;
		if(lastSearch != "") reloadList(true,lastSearch);

		lastSearch = "";
		changeSelection(lastSel);
		lastSel = 1;
		changeDiff();
		updateInfoText('Use shift to scroll faster; Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while listening to a song in this menu. Found ${songs.length} songs. Press Control + Shift to turn on Music mode. Press again to toggle Shuffle Mode');

	}
	override function onFocus() {
		shouldDraw = true;
		super.onFocus();
		bg.alpha = 0;
		inTween = FlxTween.tween(bg,{alpha:1},0.7);
	}
	override function onFocusLost(){
		shouldDraw = false;
		super.onFocusLost();
		if(inTween != null){
			inTween.cancel();
			inTween.destroy();
		}
	}
	function addListing(name:String,i:Int){
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false);
		controlLabel.yOffset = 20;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0)
			controlLabel.alpha = 0.6;
		grpSongs.add(controlLabel);
	}
	function addCategory(name:String,i:Int){
		songs[i] = name;
		modes[i] = [CATEGORYNAME];
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, name, true, false,true);
		controlLabel.adjustAlpha = false;
		controlLabel.screenCenter(X);
		var blackBorder = new FlxSprite(-500,-10).makeGraphic((Std.int(FlxG.width * 2)),Std.int(controlLabel.height) + 20,FlxColor.BLACK);
		blackBorder.alpha = 0.35;
		// blackBorder.screenCenter(X);
		controlLabel.insert(0,blackBorder);
		controlLabel.yOffset = 20;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		controlLabel.alpha = 1;
		grpSongs.add(controlLabel);
	}
	override function reloadList(?reload=false,?search = ""){
		curSelected = 0;
		var _goToSong = 0;
		if(reload){grpSongs.clear();}

		songs = ["No Songs!"];
		songNames = ["Nothing"];
		modes = [0 => ["None"]];
		var i:Int = 0;

		var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
		if (FileSystem.exists(dataDir))
		{
			var dirs = orderList(FileSystem.readDirectory(dataDir));
			addCategory("charts folder",i);
			i++;
			for (directory in dirs)
			{
				if (search == "" || query.match(directory.toLowerCase())) // Handles searching
				{
					if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
						modes[i] = [];
						for (file in FileSystem.readDirectory(dataDir + directory))
						{
								if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
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
		if (FileSystem.exists("mods/weeks"))
		{
			for (name in FileSystem.readDirectory("mods/weeks"))
			{

				var dataDir = "mods/weeks/" + name + "/charts/";
				if(!FileSystem.exists(dataDir)){continue;}
				var catMatch = query.match(name.toLowerCase());
				var dirs = orderList(FileSystem.readDirectory(dataDir));
				addCategory(name + "(Week)",i);
				i++;
				var containsSong = false;
				for (directory in dirs)
				{
					if ((search == "" || catMatch || query.match(directory.toLowerCase())) && FileSystem.isDirectory('${dataDir}${directory}')) // Handles searching
					{
						if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in FileSystem.readDirectory(dataDir + directory))
							{
									if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
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
		if (FileSystem.exists("mods/packs"))
		{
			for (name in FileSystem.readDirectory("mods/packs"))
			{
				// dataDir = "mods/packs/" + dataDir + "/charts/";
				var catMatch = query.match(name.toLowerCase());
				var dataDir = "mods/packs/" + name + "/charts/";
				if(!FileSystem.exists(dataDir)){continue;}
				
				addCategory(name,i);
				
				i++;
				var containsSong = false;
				var dirs = orderList(FileSystem.readDirectory(dataDir));
				for (directory in dirs)
				{
					if ((search == "" || catMatch || query.match(directory.toLowerCase())) && FileSystem.isDirectory('${dataDir}${directory}')) // Handles searching
					{
						if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
							modes[i] = [];
							for (file in FileSystem.readDirectory(dataDir + directory))
							{
									if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
										modes[i].push(file);
									}
							}
							if (modes[i][0] == null){ // No charts to load!
								modes[i][0] = "No charts for this song!";
							}

							songs[i] = dataDir + directory;
							songNames[i] =directory;

							
							addListing(directory,i);
							containsSong = true;
							if(_goToSong == 0)_goToSong = i;
							nameSpaces[i] = dataDir;
							i++;
						}
					}
				}
				if(!containsSong){
					grpSongs.members[i - 1].color = FlxColor.RED;
				}
			}
		}
		if(reload && lastSel == 1)changeSelection(_goToSong);
		updateInfoText('Use shift to scroll faster; Press CTRL/Control to listen to instrumental/voices of song. Press again to toggle the voices. *Disables autopause while listening to a song in this menu. Found ${songs.length} songs. Press Control + Shift to turn on Music mode. Press again to toggle Shuffle Mode');
	}
	// function checkSong(dataDir:String,directory:String){

	// }

	// public static function grabSongInfo(songName:String):Array<String>{ // Returns empty array if song is not found or invalid
	// 	var ret:Array<Dynamic> = [];
	// 	var query = new EReg((~/[-_ ]/g).replace(songName.toLowerCase(),'[-_ ]'),'i');
	// 	var modes = [];
	// 	var dataDir = "mods/charts/";
	// 	// This is pretty messy, but I don't believe regex's are possible without a for loop
	// 	if (FileSystem.exists(dataDir))
	// 	{
	// 		var dirs = orderList(FileSystem.readDirectory(dataDir));
	// 		for (directory in dirs)
	// 			{
	// 				if (query.match(directory.toLowerCase())) // Handles searching
	// 				{
	// 					if (FileSystem.exists('${dataDir}${directory}/Inst.ogg') ){
	// 						modes = [];
	// 						for (file in FileSystem.readDirectory(dataDir + directory))
	// 						{
	// 								if (!blockedFiles.contains(file.toLowerCase()) && StringTools.endsWith(file, '.json')){
	// 									modes.push(file);
	// 								}
	// 						}
	// 						if (modes[0] == null){return [];}
	// 						ret[0] = dataDir + directory;
	// 						ret[1] = directory;
	// 						ret[2] = modes;
	// 						break; // Who the hell in their right mind would continue to loop
	// 					}
	// 				}
	// 			}
	// 	}
	// 	return ret;
	// }

	public static function gotoSong(?selSong:String = "",?songJSON:String = "",?songName:String = "",charting:Bool = false,blankFile:Bool = false){
			try{
				if(selSong == "" || songJSON == "" || songName == ""){
					throw("No song name provided!");
				}
				onlinemod.OfflinePlayState.chartFile = '${selSong}/${songJSON}';
				PlayState.isStoryMode = false;
				// Set difficulty
				PlayState.songDiff = songJSON;
				PlayState.storyDifficulty = switch(songJSON){case '${songName}-easy.json': 0; case '${songName}-hard.json': 2; default: 1;};
				PlayState.actualSongName = songJSON;
				onlinemod.OfflinePlayState.voicesFile = '';

				if (FileSystem.exists('${selSong}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${selSong}/Voices.ogg';}
				PlayState.hsBrTools = new HSBrTools('${selSong}');
				if (FileSystem.exists('${selSong}/script.hscript')) {
					trace("Song has script!");
					MultiPlayState.scriptLoc = '${selSong}/script.hscript';
					
				}else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
				onlinemod.OfflinePlayState.instFile = '${selSong}/Inst.ogg';
				if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg")){
					onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
				}
				if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg")){
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
		PlayState.songspeed = onlinemod.OfflineMenuState.rate;
		if(charting && (songs[curSelected] != "No Songs!" && modes[curSelected][selMode] != CATEGORYNAME)){
			var songLoc = songs[curSelected];
			var chart = modes[curSelected][selMode];
			var songName = songNames[curSelected];
			if(modes[curSelected][selMode] == "No charts for this song!"){
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${songName}.json';
				PlayState.SONG = {
					song: songName,
					notes: [],
					bpm: 150,
					needsVoices: true,
					player1: 'bf',
					player2: 'bf',
					gfVersion: 'gf',
					noteStyle: 'normal',
					stage: 'stage',
					speed: 1,
					validScore: false,
					mania: 0
				};


			}else{
				onlinemod.OfflinePlayState.chartFile = '${songLoc}/${chart}';
				PlayState.SONG = Song.parseJSONshit(File.getContent(onlinemod.OfflinePlayState.chartFile));
			}
			if (FileSystem.exists('${songLoc}/Voices.ogg')) {onlinemod.OfflinePlayState.voicesFile = '${songLoc}/Voices.ogg';}
			PlayState.hsBrTools = new HSBrTools('${selSong}');
			if (FileSystem.exists('${songLoc}/script.hscript')) {
				trace("Song has script!");
				MultiPlayState.scriptLoc = '${songLoc}/script.hscript';
				
			}else {MultiPlayState.scriptLoc = "";PlayState.songScript = "";}
			onlinemod.OfflinePlayState.instFile = '${songLoc}/Inst.ogg';
			if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Inst.ogg")){
				onlinemod.OfflinePlayState.instFile = onlinemod.OfflinePlayState.chartFile + "-Inst.ogg";
			}
			if(FileSystem.exists(onlinemod.OfflinePlayState.chartFile + "-Voices.ogg")){
				onlinemod.OfflinePlayState.voicesFile = onlinemod.OfflinePlayState.chartFile + "-Voices.ogg";
			}
			PlayState.stateType = 4;
			LoadingState.loadAndSwitchState(new ChartingState());
			return;
		}
		if (songs[curSelected] == "No Songs!" || modes[curSelected][selMode] == CATEGORYNAME || modes[curSelected][selMode] == "No charts for this song!"){ // Actually check if the song has no charts when loading, if so then error
			FlxG.sound.play(Paths.sound("cancelMenu"));
			showTempmessage("Invalid song!",FlxColor.RED);
			return;
		}
		onlinemod.OfflinePlayState.nameSpace = "";
		if(nameSpaces[sel] != null){
			onlinemod.OfflinePlayState.nameSpace = nameSpaces[sel];
		}
		lastSel = curSelected;
		lastSearch = searchField.text;
		lastSong = songs[curSelected] + modes[curSelected][selMode] + songNames[curSelected];
		gotoSong(songs[curSelected],modes[curSelected][selMode],songNames[curSelected]);
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
		if (updateTime) songTimeTxt.text = FlxStringUtil.formatTime(Math.floor(Conductor.songPosition / 1000), false) + "/" + songLengthTxt;
		if (musicmodetext.text != "" && musicmodetext.text != null && FlxG.sound.music.onComplete == null)
			FlxG.sound.music.onComplete = musicmode;
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, onlinemod.OfflineMenuState.rate);
		try{
			if (voices != null)
				lime.media.openal.AL.sourcef(voices._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, onlinemod.OfflineMenuState.rate);
		}catch(e){return;}
		}
	}
	override function handleInput(){
			if (controls.BACK || FlxG.keys.justPressed.ESCAPE)
			{
				ret();
			}
			if(songs.length == 0) return;
			if (controls.UP_P && FlxG.keys.pressed.SHIFT){changeSelection(-5);} 
			else if (controls.UP_P || (controls.UP && grpSongs.members[curSelected].y > FlxG.height * 0.46 && grpSongs.members[curSelected].y < FlxG.height * 0.50) ){changeSelection(-1);}
			if (controls.DOWN_P && FlxG.keys.pressed.SHIFT){changeSelection(5);} 
			else if (controls.DOWN_P || (controls.DOWN  && grpSongs.members[curSelected].y > FlxG.height * 0.50 && grpSongs.members[curSelected].y < FlxG.height * 0.56) ){changeSelection(1);}
			extraKeys();
			if (FlxG.keys.justPressed.Q)
				{
					onlinemod.OfflinePlayState.chartFile = '${songs[curSelected]}/${modes[curSelected][selMode]}';
					PlayState.SONG = Song.parseJSONshit(File.getContent(onlinemod.OfflinePlayState.chartFile));
					NoteStuffExtra.CalculateNoteAmount(PlayState.SONG);
					chartinfo[0] = NoteStuffExtra.bfNotes.length;
					chartinfo[1] = NoteStuffExtra.dadNotes.length;
					if (PlayState.SONG.mania > 0)
						chartinfo[2] = chartinfo[3] = 0;
					else
					{
						chartinfo[2] = NoteStuffExtra.CalculateDifficult(0.93,0);
						chartinfo[3] = NoteStuffExtra.CalculateDifficult(0.93,1);
					}
					chartinfotext.text = 'BF Note : ${chartinfo[0]}\nDad Note : ${chartinfo[1]}\nBF Diff : ${chartinfo[2]}\nDad Diff : ${chartinfo[3]}\n';
				}
			if (controls.ACCEPT && songs.length > 0)
			{
				select(curSelected);
			}
	}

	override function extraKeys(){
		if(controls.LEFT_P && !FlxG.keys.pressed.SHIFT){changeDiff(-1);}
		if(controls.RIGHT_P && !FlxG.keys.pressed.SHIFT){changeDiff(1);}
		if(FlxG.keys.justPressed.CONTROL && FlxG.keys.pressed.SHIFT)
			{
				FlxG.sound.music.onComplete = musicmode;
				musicshuffle = !musicshuffle;
				if(musicshuffle)
					musicmodetext.text = "Music Mode activate\nShuffle Mode";
				else
					musicmodetext.text = "Music Mode activate";
			}
			if(FlxG.keys.justPressed.CONTROL && !FlxG.keys.pressed.SHIFT){
				musicmodetext.text = "";
				FlxG.autoPause = false;
				zoom = true;
				playCount++;
				if(curPlaying != songs[curSelected]){
					curPlaying = songs[curSelected];
					curplay = curSelected;
					if(voices != null){
						voices.stop();
					}
					voices = null;
					FlxG.sound.music.stop();
					FlxG.sound.playMusic(Sound.fromFile('${songs[curSelected]}/Inst.ogg'),FlxG.save.data.instVol,true);
					songLength = FlxG.sound.music.length;
					songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
					updateTime = true;
					if (FlxG.sound.music.playing){
						if(modes[curSelected][selMode] != "No charts for this song!" && FileSystem.exists(songs[curSelected] + "/" + modes[curSelected][selMode])){
							try{

								var e:SwagSong = cast Json.parse(File.getContent(songs[curSelected] + "/" + modes[curSelected][selMode])).song;
								if(e.bpm > 0){
									Conductor.changeBPM(e.bpm);
								}
							}catch(e){
								showTempmessage("Unable to get BPM from chart automatically. BPM will be out of sync",0xee0011);
							}
						}

					}else{
						curPlaying = "";
						SickMenuState.musicHandle();
					}
				#if windows
				DiscordClient.changePresence('listening to',songNames[curSelected],null,true,FlxG.sound.music.length,"https://i.imgur.com/HXQiPxD.gif");
				#end
				}
				if(curPlaying == songs[curSelected]){
					try{

						if(voices == null){
							voices = new FlxSound();
							voices.loadEmbedded(Sound.fromFile('${songs[curSelected]}/Voices.ogg'),true);
							voices.play(FlxG.sound.music.time);
							FlxG.sound.list.add(voices);
						}else{
							if(!voices.playing){
								voices.play(FlxG.sound.music.time);
							}else
								voices.stop();
						}
					}catch(e){
						showTempmessage('Unable to play voices! ${e.message}',FlxColor.RED);
					}
				}
				if(playCount > 2){
					playCount = 0;
					openfl.system.System.gc();
				}
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
		// var e:Dynamic = TitleState.getScore(4);
		// if(e != null && e != 0) diffText.text = '< ' + e + '%(' + Ratings.getLetterRankFromAcc(e) + ') - ' + modes[curSelected][selMode] + ' >';
		// else 
		diffText.text = (if(modes[curSelected][selMode - 1 ] != null ) '< ' else '|  ') + (if(modes[curSelected][selMode] == CATEGORYNAME) songs[curSelected] else modes[curSelected][selMode]) + (if(modes[curSelected][selMode + 1 ] != null) ' >' else '  |');
		// diffText.centerOffsets();
		diffText.screenCenter(X);
		var name = '${songs[curSelected]}-${modes[curSelected][selMode]}${(if(QuickOptionsSubState.getSetting("Inverted chart")) "-inverted" else "")}';
		if(modes[curSelected][selMode] == null || modes[curSelected][selMode] == CATEGORYNAME || !Highscore.songScores.exists(name)){
			// score = 0;
			scoreText.text = "N/A";
			SCORETXT = "N/A";
			scoreText.screenCenter(X);
		}else{
			// var _Arr:Array<Dynamic> = Highscore.songScores.getArr(name);
			// if(Std.isOfType(_Arr[0],Int)){
			// 	score = _Arr.shift();
			// }else{
			// 	score = -1;
			// }
			// SCORETXT = ', ${_Arr.join(", ")}';
			scoreText.text = (Highscore.songScores.getArr(name)).join(", ");
			scoreText.screenCenter(X);
			// score = Highscore.getScoreUnformatted();
		}
		// diffText.x = (FlxG.width) - 20 - diffText.width;
		chartinfotext.text = "Press Q for chart info";
	}

	override function changeSelection(change:Int = 0)
	{
		var looped = 0;
		// while(modes[curSelected + change] != null && modes[curSelected + change][0] == CATEGORYNAME && looped < 200){ // If this loops more than 200 times, break to prevent crashes
		// 	if(change > 0) change+=1;
		// 	if(change < 0) change-=1;
		// 	if(curSelected + change > songs.length){
		// 		curSelected = 0;
		// 		change = 0;
		// 	}
		// 	looped++;
		// }
		// if(looped > 199){
		// 	grpSongs.clear();
		// 	change = 0;
		// 	curSelected = 0;
		// 	songs = ["No Songs!"];
		// 	songNames = ["Nothing"];
		// 	modes = [0 => ["None"]];
		// }

		chartinfotext.text = "Press Q for chart info";
		super.changeSelection(change);
		if (modes[curSelected].indexOf('${songNames[curSelected]}.json') != -1) changeDiff(0,modes[curSelected].indexOf('${songNames[curSelected]}.json')); else changeDiff(0,0);

	}

	function musicmode()
	{

		if(musicshuffle)
		{
			if(curSelected > songs.length / 10)
				changeSelection(FlxG.random.int(Std.int(-(songs.length / 10)),Std.int((songs.length / 10))));
			else
				changeSelection(FlxG.random.int(1,Std.int(songs.length / 10)));
		}
		else
			changeSelection(1);
		playCount++;
		if(curPlaying != songs[curSelected]){
			curPlaying = songs[curSelected];
			curplay = curSelected;
			if(voices != null){
				voices.stop();
			}
			voices = null;
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Sound.fromFile('${songs[curSelected]}/Inst.ogg'),FlxG.save.data.instVol,true);
			songLength = FlxG.sound.music.length;
			songLengthTxt = FlxStringUtil.formatTime(Math.floor((songLength) / 1000), false);
			if (FlxG.sound.music.playing){
				if(modes[curSelected][selMode] != "No charts for this song!" && FileSystem.exists(songs[curSelected] + "/" + modes[curSelected][selMode])){
					try{
						var e:SwagSong = cast Json.parse(File.getContent(songs[curSelected] + "/" + modes[curSelected][selMode])).song;
						if(e.bpm > 0){
							Conductor.changeBPM(e.bpm);
						}
					}catch(e){
						showTempmessage("Current Song don't have chart. BPM will be out of sync",0xee0011);
					}
				}
			}else{
				curPlaying = "";
				SickMenuState.musicHandle();
			}
		#if windows
		DiscordClient.changePresence('listening to',songNames[curSelected],null,true,FlxG.sound.music.length,"https://i.imgur.com/HXQiPxD.gif");
		#end
		}
		if(curPlaying == songs[curSelected]){
			try{
				if(voices == null){
					voices = new FlxSound();
					voices.loadEmbedded(Sound.fromFile('${songs[curSelected]}/Voices.ogg'),true);
					voices.play(FlxG.sound.music.time);
					FlxG.sound.list.add(voices);
				}else{
					if(!voices.playing){
						voices.play(FlxG.sound.music.time);
					}else
						voices.stop();
				}
			}catch(e){
				showTempmessage('Unable to play voices! ${e.message}',FlxColor.RED);
			}
		}
		if(playCount > 2){
			playCount = 0;
			openfl.system.System.gc();
		}
		FlxG.sound.music.onComplete = musicmode;
	}

	override function goOptions(){
			lastSel = curSelected;
			lastSearch = searchField.text;
			FlxG.mouse.visible = false;
			OptionsMenu.lastState = 4;
			FlxG.switchState(new OptionsMenu());
	}
}