package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.ui.FlxBar;
import flixel.FlxCamera;
import sys.FileSystem;
import sys.io.File;
import PlayState.OutNote;
import flash.media.Sound;

import Discord.DiscordClient;
using StringTools;


typedef ActionsFile = {
	var info:String;
	var notes:Array<OutNote>;
	var bf:String;
	var gf:String;
	var opp:String;
	var ver:String;

}
class FinishSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;

	var music:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;
	var win:Bool = true;
	var ready = false;
	var readyTimer:Float = 0;
	var week:Bool = false;
	var errorMsg:String = "";
	var isError:Bool = false;
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	var iconP1Array:Array<HealthIcon>; 
	var iconP2Array:Array<HealthIcon>;
	var scoretype:Array<String> = ["","FNF Score","OSU! Score","Osu!Mania Score","Bal Score","Invert Bal Score","Stupid Score"];
	var randommode:Array<String> = ["","Full Random","Full Random With Jack Prevent","Random Per Section"];
	var extrainfo:Bool = false;
	var noteratingscore:Array<Float> = [350,300,200,-300];
	var settingsText:FlxText;
	var chartdifficult:Float = NoteStuffExtra.CalculateDifficult(0.93,0);
	var Opponentchartdifficult:Float = NoteStuffExtra.CalculateDifficult(0.93,1);
	public static var pauseGame:Bool = true;
	public static var autoEnd:Bool = true;
	public function new(x:Float, y:Float,?won = true,?error:String = "",force:Bool = false)
	{
		if (error != ""){
			isError = true;
			errorMsg = error;
			won = false;
			
		}
		FlxG.camera.alpha = PlayState.instance.camGame.alpha = PlayState.instance.camHUD.alpha = 1;
		PlayState.instance.followChar(0);
		if(!isError){
			var inName = if(won)"winSong" else "loseSong";
			PlayState.instance.callInterp(inName,[]);
			PlayState.dad.callInterp(inName,[]);
			PlayState.boyfriend.callInterp(inName,[]);
		}

		if(!isError) FlxG.state.persistentUpdate = true; else FlxG.state.persistentUpdate = false;
		win = won;
		FlxG.sound.pause();
		PlayState.instance.generatedMusic = false;
		var dadArray = PlayState.dadArray;
		var boyfriendArray = PlayState.boyfriendArray;
		var dad = dadArray[0];
		var boyfriend = boyfriendArray[0];

		// For healthbar shit
		healthBar = PlayState.instance.healthBar;
		healthBarBG = PlayState.instance.healthBarBG;
		iconP1Array = PlayState.instance.iconP1Array;
		iconP2Array = PlayState.instance.iconP2Array;


		if(win){
			for (g in [PlayState.instance.cpuStrums,PlayState.instance.playerStrums]) {
				g.forEach(function(i){
					FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
				});
			}
			if (FlxG.save.data.songPosition)
			{
				for (i in [PlayState.songPosBar,PlayState.songPosBG,PlayState.instance.songName,PlayState.instance.songTimeTxt]) {
					FlxTween.tween(i, {y:if(FlxG.save.data.downscroll)FlxG.height + 200 else -200},1,{ease: FlxEase.expoIn});
				}
			}

			FlxTween.tween(healthBar, {y:Std.int(FlxG.height * 0.10)},1,{ease: FlxEase.expoIn});
			FlxTween.tween(healthBarBG, {y:Std.int(FlxG.height * 0.10 - 4)},1,{ease: FlxEase.expoIn});
			for(icon in iconP1Array){FlxTween.tween(icon, {y:Std.int(FlxG.height * 0.10 - (icon.height * 0.5)),angle:0},1,{ease: FlxEase.expoIn});}
			for(icon in iconP2Array){FlxTween.tween(icon, {y:Std.int(FlxG.height * 0.10 - (icon.height * 0.5)),angle:0},1,{ease: FlxEase.expoIn});}

			FlxTween.tween(PlayState.instance.kadeEngineWatermark, {y:FlxG.height + 200},1,{ease: FlxEase.expoIn});
			FlxTween.tween(PlayState.instance.scoreTxt, {y:if(FlxG.save.data.downscroll) -200 else FlxG.height + 200},1,{ease: FlxEase.expoIn});
			FlxTween.tween(PlayState.instance.judgementCounter, {x: -200},1,{ease: FlxEase.expoIn});
		}
		var bfAnims:Array<String> = [];
		if(!isError){
			if(win){
				bfAnims = ['win','hey','singSPACE','singUP'];
				for(i in boyfriendArray){i.playAnimAvailable(bfAnims);}
				if(PlayState.instance.BothSide)
					{if (dad == PlayState.gf) dad.playAnim('cheer'); else for(i in dadArray){i.playAnimAvailable(bfAnims);}}
				else
					{if (dad == PlayState.gf) dad.playAnim('cheer'); else for(i in dadArray){i.playAnimAvailable(['lose','singDOWNmiss']);}}
				PlayState.gf.playAnim('cheer',true);
			}else{
				for(i in boyfriendArray){i.playAnimAvailable(['lose','singDOWNmiss']);}
				bfAnims = ['lose','singDOWNmiss'];
				if(PlayState.instance.BothSide)
					{for(i in dadArray){i.playAnimAvailable(['lose','singDOWNmiss']);}}
				else
					{for(i in dadArray){i.playAnimAvailable(['win','hey','singSPACE','singUP']);}}
				if (dad == PlayState.gf) dad.playAnim('sad');
				PlayState.gf.playAnim('sad',true);
			}
		}
		super();
		if(autoEnd){
			if(!isError){
				boyfriend.playAnimAvailable(bfAnims,true);
				boyfriend.animation.finishCallback = this.finishNew;
			}
			else finishNew();
			PlayState.instance.followChar(0);
		}
	}


	var cam:FlxCamera;
	var shownResults:Bool = false;
	public var contText:FlxText;
	public function saveScore(forced:Bool = false):Bool{
		if(win && !PlayState.instance.hasDied && !ChartingState.charting && PlayState.instance.canSaveScore)
			return (Highscore.setScore('${PlayState.nameSpace}-${PlayState.actualSongName}${(if(PlayState.invertedChart) "-inverted" else "")}${(if(FlxG.save.data.scoresystem == 0) "" else "-" + FlxG.save.data.scoresystem)}',PlayState.songScore,[PlayState.songScore,'${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%',Ratings.GenerateLetterRank(PlayState.accuracy),(PlayState.songspeed != 1 ? "(" + PlayState.songspeed + "x)" : "")],forced));
		return false;
	}
	public function finishNew(?name:String){
			FlxG.camera.alpha = PlayState.instance.camGame.alpha = PlayState.instance.camHUD.alpha = 1;
			cam = new FlxCamera();
			FlxG.cameras.add(cam);
			FlxG.cameras.setDefaultDrawTarget(cam,true);
			if (win) PlayState.boyfriend.animation.finishCallback = null; else PlayState.dad.animation.finishCallback = null;
			// ready = true;
			FlxG.state.persistentUpdate = !isError && !pauseGame;
			pauseGame = true;
			autoEnd = true;
			FlxG.sound.pause();

			music = new FlxSound().loadEmbedded(Paths.music(if(win) 'StartItchBuild' else 'gameOver'), true, true);
			music.play(false);
			if(win){
				music.looped = false;
				music.onComplete = function(){music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);music.play(false);} 

			}

			shownResults = true;
			FlxG.sound.list.add(music);

			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			if(isError){
				var finishedText:FlxText = new FlxText(20,-55,0, "Error caught!" );
				finishedText.size = 34;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.RED;
				finishedText.scrollFactor.set();
				var comboText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-75,0,'Error Message:\n${errorMsg}\n\nIf you\'re not the creator of the character or chart,\nit is recommended that you report this to the chart/character\'s developer');
				comboText.size = 28;
				comboText.wordWrap = true;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
				comboText.fieldWidth = FlxG.width - comboText.x;
				contText = new FlxText(0,FlxG.height + 100,FlxG.width,'Press ENTER to exit\nor R to reload.');
				contText.size = 28;
				contText.alignment = "right";
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.scrollFactor.set();
				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				add(bg);
				add(finishedText);
				add(comboText);
				add(contText);
			}else{
				var finishedText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-55,0, (if(week) "Week" else "Song") + " " + (if(win) "Won!" else "failed...") );
				finishedText.size = 34;
				finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				finishedText.color = FlxColor.WHITE;
				finishedText.scrollFactor.set();
				var comboText:FlxText = new FlxText(20 + FlxG.save.data.guiGap,-75,0,
				'Song/Chart:'
				+ '\n\nMarvelous - ${PlayState.marvelous}'
				+ '\nSicks - ${PlayState.sicks}'
				+ '\nGoods - ${PlayState.goods}'
				+ '\nBads - ${PlayState.bads}'
				+ '\nShits - ${PlayState.shits}'
				+ '\nGhost Taps - ${PlayState.ghostTaps}'
				+ '\n\nLast combo: ${PlayState.combo} (Max: ${PlayState.maxCombo})'
				+ '\nMisses: ${PlayState.misses}'
				+ (PlayState.badNote > 0 ? '\nBad Note: ${PlayState.badNote}' : '')
				+ '\n\n${scoretype[FlxG.save.data.scoresystem + 1]}: ${PlayState.songScore}'
				+ (FlxG.save.data.altscoresystem > 0 ? '\n${scoretype[FlxG.save.data.altscoresystem]}: ${Math.round(PlayState.altsongScore)}' : '')
				+ '\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%'
				+ '\n\n${Ratings.GenerateLetterRank(PlayState.accuracy)}'
				+ '\n');
				comboText.size = 28;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
				new FlxTimer().start(0.1, function(tmr) // ass
				{
					if(!win){
						DiscordClient.changePresence("GAME OVER -- "
						+ PlayState.detailsText
						+ (QuickOptionsSubState.getSetting("BotPlay") ? "BotPlay" : Ratings.GenerateLetterRank(PlayState.accuracy)),
						"\nAcc: " + HelperFunctions.truncateFloat(PlayState.accuracy, 2)
						+ "% | Score: " + PlayState.songScore
						+ " | Misses: " + PlayState.misses, PlayState.iconRPC,false,null,"dead");
					}
					else{
						DiscordClient.changePresence("Finish --"
						+ PlayState.detailsText
						+ (QuickOptionsSubState.getSetting("BotPlay") ? "BotPlay" : Ratings.GenerateLetterRank(PlayState.accuracy)),
						"\nAcc: " + HelperFunctions.truncateFloat(PlayState.accuracy, 2)
						+ "% | Score: " + PlayState.songScore
						+ " | Misses: " + PlayState.misses, PlayState.iconRPC,false,null,"finish-playstate");
					}
				});
				if (FlxG.save.data.scoresystem == 1 || FlxG.save.data.scoresystem == 2)
					noteratingscore = [350,300,200,100,50];
				for(i in 0...noteratingscore.length){
					switch(FlxG.save.data.scoresystem)
					{
						case 0: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.songspeed,2); //FNF
						case 1: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] + (noteratingscore[i] * ((PlayState.combo * PlayState.songspeed) / 25)),2); //Osu!
						case 2: noteratingscore[i] = HelperFunctions.truncateFloat((1000000 / PlayState.bfnoteamount) * (noteratingscore[i] / 350),2); //Osu!mania
						case 3: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.ScoreMultiplier * PlayState.songspeed,2); //Bal
						case 4: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.ScoreDivider * PlayState.songspeed,2); //Bal invert
						case 5: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.combo * PlayState.songspeed,2); //Stupid
					}
				}

				settingsText = new FlxText(comboText.width * 1.10 + FlxG.save.data.guiGap,-30,0,'');
				settingsText.text =
					(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
					+ (FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : "")
					+'\n\nSettings:'
					+'\n\n Downscroll: ${FlxG.save.data.downscroll}'
					+'\n Ghost Tapping: ${FlxG.save.data.ghost}'
					+'\n Practice: ${FlxG.save.data.practiceMode}'
					+'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}' + (QuickOptionsSubState.getSetting("Song hscripts") ? '\n  Script Count:${PlayState.instance.interpCount}' : "")
					+'\n Safe Frames: ${FlxG.save.data.frames}'
					+'\n Input Engine: ${PlayState.inputEngineName}, V${MainMenuState.ver},T${MainMenuState.modver}'
					+'\n Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms'
					+(FlxG.save.data.scoresystem == 3 || FlxG.save.data.altscoresystem == 4 ? '\n Bal ScoreMultiplier : ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 3)}' : '')
					+(FlxG.save.data.scoresystem == 4 || FlxG.save.data.altscoresystem == 5 ? '\n Bal ScoreDivider : ${HelperFunctions.truncateFloat(PlayState.ScoreDivider, 3)}' : '')
					+'\n Key count: ' + (PlayState.instance.BothSide ? '4k + 4k' : '${PlayState.keyAmmo[PlayState.mania]}K') + (QuickOptionsSubState.getSetting("Force Mania") > -1 ? '*' : '')
					+ (PlayState.instance.ADOFAIMode ? '\n ADOFAI Mode : true' : '')
					+ (PlayState.instance.randomnote != 0 ? '\n Random Mode: ${randommode[PlayState.instance.randomnote]}' : '')
					+'\n'
					;
				settingsText.size = 28;
				settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				settingsText.color = FlxColor.WHITE;
				settingsText.scrollFactor.set();

				contText = new FlxText(0,FlxG.height + 100,FlxG.width,'Press ENTER to continue Press R to restart\nor Tab for extra info.');
				contText.size = 28;
				contText.alignment = "right";
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.scrollFactor.set();
				// var chartInfoText:FlxText = new FlxText(20,FlxG.height + 50,0,'Offset: ${FlxG.save.data.offset + PlayState.songOffset}ms | Played on ${songName}');
				// chartInfoText.size = 16;
				// chartInfoText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
				// chartInfoText.color = FlxColor.WHITE;
				// chartInfoText.scrollFactor.set();
				

				if(saveScore()){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					finishedText.text+=" | New Personal Best!";
				}else if(win){
					finishedText.text+= ' | Old PB ' + (Highscore.songScores.getArr('${PlayState.nameSpace}-${PlayState.actualSongName}${(if(PlayState.invertedChart) "-inverted" else "")}${(if(FlxG.save.data.scoresystem == 0) "" else "-" + FlxG.save.data.scoresystem)}')).join(", ");
				}
				add(bg);
				add(finishedText);
				add(comboText);
				add(contText);
				add(settingsText);
				// add(chartInfoText);
				healthBar.cameras = healthBarBG.cameras = [cam];
				for(icon in iconP2Array){icon.cameras = [cam];}
				for(icon in iconP1Array){icon.cameras = [cam];}

				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:105},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				// FlxTween.tween(chartInfoText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(settingsText, {y:105},0.5,{ease: FlxEase.expoInOut});
				if(PlayState.logGameplay){

					try{
						var info = '--- Game Info:\n${comboText.text}\n\n${settingsText.text}\n\nCharacters(Dad,GF,BF): ${PlayState.dad.curCharacter},${PlayState.gf.curCharacter},${PlayState.boyfriend.curCharacter}\n\nScripts:';
						for (i => v in PlayState.instance.interps) {
							info += '\n- $i';
						}
						var eventLog:ActionsFile = {
							info:info,
							notes:PlayState.instance.eventLog,
							bf:PlayState.boyfriend.curCharacter,
							opp:PlayState.dad.curCharacter,
							gf:PlayState.gf.curCharacter,
							ver:MainMenuState.ver + ' - ' + MainMenuState.modver
						};
						var events:String = info + '\n\n--- Hits and Misses:\n
/ Example Note
|- TIME
|- DIRECTION
|- RATING
|- IS SUSTAIN
|- NOTE STRUM TIME
\\


';
						var noteCount = 0;
						for (_ => v in PlayState.instance.eventLog ) {
							events += '
/
|- ${v.time}
|- ${StrumArrow.arrowIDs[v.direction]}
|- ${v.rating}
|- ${v.isSustain}
|- ${v.strumTime}
\\';
							if(!v.isSustain && v.rating != "Missed without note")noteCount++;
						}
						var eventsjson:String = haxe.Json.stringify(eventLog);
						events += '\n---\nLog generated at ${Date.now()}, Assumed Note Count: ${noteCount}. USE THE JSON FOR AUTOMATION';
						if(!FileSystem.exists("songLogs/"))
							FileSystem.createDirectory("songLogs/");
						var curDate = Date.now();
						var songName = if(PlayState.isStoryMode) StoryMenuState.weekNames[StoryMenuState.curWeek] else if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}';
						songName.replace(".json","");
						if(PlayState.invertedChart) songName = songName + "-inverted";
						if(!FileSystem.exists('songLogs/${songName}/'))
							FileSystem.createDirectory('songLogs/${songName}/');
						File.saveContent('songLogs/${songName}/${curDate.getDate()}-${curDate.getMonth()}-${curDate.getFullYear()}_AT_${curDate.getHours()}-${curDate.getMinutes()}-${curDate.getSeconds()}.log',events);
						File.saveContent('songLogs/${songName}/${curDate.getTime()}.json',eventsjson);
					}catch(e){trace("Something went wrong when trying to output event log! " + e.message);}
				}
			}

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; 
	}
	var shouldveLeft = false;
	function retMenu(){
		if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		PlayState.actualSongName = ""; // Reset to prevent issues
		PlayState.instance.persistentUpdate = true;
		if (shouldveLeft){
			Main.game.forceStateSwitch(new MainMenuState());

		}else{
			switch (PlayState.stateType)
			{
				case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
				case 4:FlxG.switchState(new multi.MultiMenuState());
				case 5:FlxG.switchState(new osu.OsuMenuState());
				default:FlxG.switchState(new FreeplayState());
			}
		}
		shouldveLeft = true;
		return;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready){
			var accepted = controls.ACCEPT;
			var oldOffset:Float = 0;

			if (accepted)
				retMenu();
			if (FlxG.keys.justPressed.R)
				{
					if(win)FlxG.resetState();
					else restart();
				}
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S){
				if(saveScore(true))
					FlxG.sound.play(Paths.sound('confirmMenu'));
			}
			if (FlxG.keys.justPressed.TAB)
				{
					extrainfo = !extrainfo;
					if(!extrainfo)
						settingsText.text =
							(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
							+ (FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : "")
							+'\n\nSettings:'
							+'\n\n Downscroll: ${FlxG.save.data.downscroll}'
							+'\n Ghost Tapping: ${FlxG.save.data.ghost}'
							+'\n Practice: ${FlxG.save.data.practiceMode}'
							+'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}' + (QuickOptionsSubState.getSetting("Song hscripts") ? '\n  Script Count:${PlayState.instance.interpCount}' : "")
							+'\n Safe Frames: ${FlxG.save.data.frames}'
							+'\n Input Engine: ${PlayState.inputEngineName}, V${MainMenuState.ver},T${MainMenuState.modver}'
							+'\n Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms'
							+ (FlxG.save.data.scoresystem == 3 || FlxG.save.data.altscoresystem == 4 ? '\n Bal ScoreMultiplier : ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 3)}' : '')
							+ (FlxG.save.data.scoresystem == 4 || FlxG.save.data.altscoresystem == 5 ? '\n Bal ScoreDivider : ${HelperFunctions.truncateFloat(PlayState.ScoreDivider, 3)}' : '')
							+'\n Key count: ' + (PlayState.instance.BothSide ? '4k + 4k' : '${PlayState.keyAmmo[PlayState.mania]}K') + (QuickOptionsSubState.getSetting("Force Mania") > -1 ? '*' : '')
							+ (PlayState.instance.ADOFAIMode ? '\n ADOFAI Mode : true' : '')
							+ (PlayState.instance.randomnote != 0 ? '\n Random Mode: ${randommode[PlayState.instance.randomnote]}' : '')
							+'\n'
							;
					else
						settingsText.text = 
							(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
							+ (FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : "")
							+ '\n\nScore Mode : ${scoretype[FlxG.save.data.scoresystem + 1]}'
							+ (FlxG.save.data.scoresystem == 1 || FlxG.save.data.scoresystem == 2 ? '\n Marvelous : ${noteratingscore[0]}' + '\n Sick : ${noteratingscore[1]}' : '\n Marvelous/Sick : ${noteratingscore[0]}')
							+ '\n Good : ${noteratingscore[2]}'
							+ '\n Bad : ' + (FlxG.save.data.scoresystem == 1 || FlxG.save.data.scoresystem == 2 ? '${noteratingscore[3]}' : '0')
							+ '\n Shit : ' + (FlxG.save.data.scoresystem == 1 || FlxG.save.data.scoresystem == 2 ? '${noteratingscore[4]}' : '${noteratingscore[3]}')
							+ (FlxG.save.data.scoresystem == 3 ? '\nScoreMultiplier : ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 3)}' : '')
							+ (FlxG.save.data.scoresystem == 4 ? '\nScoreDivider : ${HelperFunctions.truncateFloat(PlayState.ScoreDivider, 3)}' : '')
							+ '\nMax Score : ' + (FlxG.save.data.scoresystem == 1 ? 'OSU! Score is not supported' : FlxG.save.data.scoresystem == 2 ? '1,000,000' : FlxG.save.data.scoresystem == 5 ? '2,147,483,647' : FlxG.save.data.scoresystem == 3 ? Std.string(350 * Math.max(PlayState.bfnoteamount, PlayState.dadnoteamount)) : FlxG.save.data.scoresystem == 4 ? Std.string(350 * Math.min(PlayState.bfnoteamount, PlayState.dadnoteamount)) : PlayState.instance.BothSide ? Std.string(noteratingscore[0] * (PlayState.bfnoteamount + PlayState.dadnoteamount)) : Std.string(noteratingscore[0] * PlayState.bfnoteamount))
							+ '\nYour Note Total : ${PlayState.bfnoteamount}' + (PlayState.bfnoteamount != PlayState.bfnoteamountwithhurt ? ' + ${PlayState.bfnoteamountwithhurt - PlayState.bfnoteamount} Bad Note' : '')
							+ '\nOpponent Note Total : ${PlayState.dadnoteamount}' + (PlayState.dadnoteamount != PlayState.dadnoteamountwithhurt ? ' + ${PlayState.dadnoteamountwithhurt - PlayState.dadnoteamount} Bad Note' : '')
							+ '\nChart difficult : ' + (chartdifficult > 0.1 ? Std.string(chartdifficult) : PlayState.bfnoteamount < 10 ? '0/10 Where gameplay' : 'Error happen :crying:')
							+ '\nOpponent Chart difficult : ' + (Opponentchartdifficult > 0.1 ? Std.string(Opponentchartdifficult) : PlayState.dadnoteamount < 10 ? '0/10 Where gameplay' : 'Error happen :crying:')
							+'\n'
							;
					}
				}else if (!shownResults){
					if(FlxG.keys.justPressed.ANY){
						PlayState.boyfriend.animation.finishCallback = null;
						finishNew();
					}
				}else{
					if(readyTimer > 2)
						ready=true;
					readyTimer += elapsed;
					contText.alpha = readyTimer - 1;
				}

	}
	function restart()
	{
		ready = false;
		if(isError){
			FlxG.resetState();
			if (shouldveLeft){ // Error if the state hasn't changed and the user pressed r already
				MainMenuState.handleError("Caught softlock!");
			}
			shouldveLeft = true;
			return;
		}
		FlxG.resetState();
	}
	override function destroy()
	{
		if (music != null){music.destroy();}

		super.destroy();
	}

}