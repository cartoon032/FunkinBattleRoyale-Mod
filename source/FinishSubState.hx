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
import flixel.sound.FlxSound;
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
import tjson.Json;
import haxe.crypto.Md5;

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
	var scoretype:Array<String> = ["","FNF Score","OSU! Score","Osu!Mania Score","Bal Score","Invert Bal Score","Voiid Score","Voiid Uncap Score","Stupid Score"];
	var randommode:Array<String> = ["","Full Random","Full Random With Jack Prevent","Random Per Section"];
	var extrainfo:Bool = false;
	var noteratingscore:Array<Float> = [350,350,200,0,-300];
	var MaxScore:Float = 0;
	var settingsText:FlxText;
	var chartdifficult:Float = NoteStuffExtra.CalculateDifficult(0.93,0);
	var Opponentchartdifficult:Float = NoteStuffExtra.CalculateDifficult(0.93,1);
	public static var instance:FinishSubState;
	public static var pauseGame:Bool = true;
	public static var autoEnd:Bool = true;
	public function new(x:Float, y:Float,?won = true,?error:String = "",force:Bool = false)
	{
		instance = this;
		super();
		if (error != ""){
			isError = true;
			errorMsg = error;
			won = false;
			// PlayState.instance.paused = true;
		}
		if(force){
			FlxG.state.persistentUpdate = false;
			FlxG.sound.pause();
			PlayState.instance.generatedMusic = PlayState.instance.handleTimes = PlayState.instance.acceptInput = false;
			super();
			finishNew("FORCEDMOMENT.MP4efdhseuifghbehu");
			return;
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
	var KeyCount:String = "";
	public function saveScore(forced:Bool = false):Bool{
		if(win && !PlayState.instance.hasDied && !ChartingState.charting && PlayState.instance.canSaveScore)
			return (Highscore.setScore('${PlayState.nameSpace}-${PlayState.actualSongName}${(if(PlayState.invertedChart || QuickOptionsSubState.getSetting("Inverted chart") || QuickOptionsSubState.getSetting("Mirror Mode") == 2) "-inverted" else "")}${(if(FlxG.save.data.scoresystem == 0) "" else "-" + FlxG.save.data.scoresystem)}',PlayState.songScore,[PlayState.songScore,'${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%',Ratings.GenerateLetterRank(PlayState.accuracy),(PlayState.songspeed != 1 ? "(" + PlayState.songspeed + "x)" : "")],forced));
		return false;
	}
	public function finishNew(?name:String){
			Conductor.changeBPM(70);
			if(isError) win = false;
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
				FlxTween.tween(contText, {y:FlxG.height - contText.height},0.5,{ease: FlxEase.expoInOut});
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
				(if(PlayState.instance.botPlay) "Botplay " else "") + (!PlayState.isStoryMode ? 'Song performance' : "Week performance")
				+ '\n\nMarvelous - ${CoolUtil.FormatNumber(PlayState.marvelous)}'
				+ '\nSicks - ${CoolUtil.FormatNumber(PlayState.sicks)}'
				+ '\nGoods - ${CoolUtil.FormatNumber(PlayState.goods)}'
				+ '\nBads - ${CoolUtil.FormatNumber(PlayState.bads)}'
				+ '\nShits - ${CoolUtil.FormatNumber(PlayState.shits)}'
				+ '\nGhost Taps - ${CoolUtil.FormatNumber(PlayState.ghostTaps)}'
				+ '\nMA: ${PlayState.MA}'
				+ (PlayState.goods > 0 ||
					PlayState.bads > 0 ||
					PlayState.shits > 0 ||
					PlayState.misses > 0
					? '\nSA: ${PlayState.SA}' : '')
				+ '\n\nLast combo: ${CoolUtil.FormatNumber(PlayState.combo)}x (Max: ${CoolUtil.FormatNumber(PlayState.maxCombo)})'
				+ '\nMisses: ${PlayState.misses}'
				+ (PlayState.badNote > 0 ? '\nBad Note: ${PlayState.badNote}' : '')
				+ '\n\n${scoretype[FlxG.save.data.scoresystem + 1]}: ${CoolUtil.FormatNumber(PlayState.songScore)}'
				+ (FlxG.save.data.altscoresystem > 0 && Math.round(PlayState.songScoreInFloat) != Math.round(PlayState.altsongScore) ? '\n${scoretype[FlxG.save.data.altscoresystem]}: ${CoolUtil.FormatNumber(Math.round(PlayState.altsongScore))}' : '')
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
				if (FlxG.save.data.scoresystem == 5 || FlxG.save.data.scoresystem == 6)
					noteratingscore = [400,350,200,50,-150];
				for(combo in 1...PlayState.bfnoteamount + 1){
					switch(FlxG.save.data.scoresystem)
					{
						case 0: MaxScore = noteratingscore[0] * PlayState.songspeed * PlayState.bfnoteamount; break; //FNF
						case 1: MaxScore += noteratingscore[0] + (noteratingscore[0] * ((combo * PlayState.songspeed) / 25)); //Osu!
						case 2: MaxScore = 1000000; break; //Osu!mania
						case 3: MaxScore = noteratingscore[0] * PlayState.ScoreMultiplier * PlayState.songspeed * PlayState.bfnoteamount; break; //Bal
						case 4: MaxScore = noteratingscore[0] * PlayState.ScoreDivider * PlayState.songspeed * PlayState.bfnoteamount; break; //Bal invert
						case 5: MaxScore += Math.floor(noteratingscore[0] * Math.min(5,Math.ceil(combo / 10))); //Voiid
						case 6: MaxScore += Math.floor(noteratingscore[0] * Math.ceil(combo / 10) * PlayState.songspeed); //Voiid Uncap
						case 7: MaxScore = 0; break; //Stupid
					}
				}
				for(i in 0...noteratingscore.length){
					switch(FlxG.save.data.scoresystem)
					{
						case 0: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.songspeed,2); //FNF
						case 1: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] + (noteratingscore[i] * ((PlayState.combo * PlayState.songspeed) / 25)),2); //Osu!
						case 2: noteratingscore[i] = HelperFunctions.truncateFloat((1000000 / PlayState.bfnoteamount) * (noteratingscore[i] / 350),2); //Osu!mania
						case 3: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.ScoreMultiplier * PlayState.songspeed,2); //Bal
						case 4: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.ScoreDivider * PlayState.songspeed,2); //Bal invert
						case 5: noteratingscore[i] = HelperFunctions.truncateFloat(Math.floor(noteratingscore[i] * Math.min(5,Math.ceil(PlayState.combo / 10))),2); //Voiid
						case 6: noteratingscore[i] = HelperFunctions.truncateFloat(Math.floor(noteratingscore[i] * Math.ceil(PlayState.combo / 10) * PlayState.songspeed),2); //Voiid Uncap
						case 7: noteratingscore[i] = HelperFunctions.truncateFloat(noteratingscore[i] * PlayState.combo * PlayState.songspeed,2); //Stupid
					}
				}

				settingsText = new FlxText(comboText.width * 1.10 + FlxG.save.data.guiGap,-30,0,'');
				if(Conductor.ManiaChangeMap.length > 0)
					{
						for(ManiaMap in Conductor.ManiaChangeMap)
							{
							if(ManiaMap.Section != -100 && KeyCount == "") KeyCount += PlayState.keyAmmo[PlayState.SONG.mania] + 'K ';
							if(KeyCount != "") KeyCount += ">";
							KeyCount += " " + PlayState.keyAmmo[ManiaMap.Mania] + "K ";
						}
					}
				else
					KeyCount = (PlayState.instance.BothSide ? '4k + 4k' : '${PlayState.keyAmmo[PlayState.playermania]}K') + (QuickOptionsSubState.getSetting("Force Mania") > -1 ? '*' : '');
				settingsText.text =
					(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
					+ (FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : "")
					+'\n\nSettings:'
					+'\n\n Ghost Tapping: ${FlxG.save.data.ghost}'
					+(FlxG.save.data.practiceMode ? '\n Practice: true' : '')
					+'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}' + (QuickOptionsSubState.getSetting("Song hscripts") ? '\n  Script Count: ${PlayState.instance.interpCount}' : "")
					+'\n Safe Frames: ${FlxG.save.data.frames}'
					+'\n Input Engine: ${PlayState.inputEngineName}, T${MainMenuState.modver}'
					+'\n Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms'
					+(FlxG.save.data.scoresystem == 3 || FlxG.save.data.altscoresystem == 4 ? '\n Bal ScoreMultiplier: ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 3)}' : '')
					+(FlxG.save.data.scoresystem == 4 || FlxG.save.data.altscoresystem == 5 ? '\n Bal ScoreDivider: ${HelperFunctions.truncateFloat(PlayState.ScoreDivider, 3)}' : '')
					+'\n Key count: ' + KeyCount
					+ (PlayState.instance.ADOFAIMode ? '\n ADOFAI Mode: true' : '')
					+ (PlayState.instance.randomnote != 0 ? '\n Random Mode: ${randommode[PlayState.instance.randomnote]}' : '')
					+'\n'
					;
				settingsText.size = 28;
				settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				settingsText.color = FlxColor.WHITE;
				settingsText.scrollFactor.set();

				contText = new FlxText(0,FlxG.height + 100,FlxG.width,'ENTER: to continue\nR: to restart\nTab: for extra info\nS: to Post Score to discord\nCtrl + S: to overwrite your PB');
				contText.size = 20;
				contText.alignment = "right";
				contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				contText.color = FlxColor.WHITE;
				contText.scrollFactor.set();
				

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
				healthBar.cameras = healthBarBG.cameras = [cam];
				for(icon in iconP2Array){icon.cameras = [cam];}
				for(icon in iconP1Array){icon.cameras = [cam];}

				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:75},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - contText.height},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(settingsText, {y:75},0.5,{ease: FlxEase.expoInOut});
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
						var eventsjson:String = Json.encode(eventLog,"fancy",true);
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
		if (shouldveLeft)
			Main.game.forceStateSwitch(new MainMenuState());
		else{
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
	var canSendEmbed = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready){
			if (controls.ACCEPT)
				retMenu();
			if (FlxG.keys.justPressed.R)
				{
					if(win)FlxG.resetState();
					else restart();
				}
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S){
				if(saveScore(true)){
					FlxG.sound.play(Paths.sound('confirmMenu'));
					showTempmessage('Your PB have been overwrite!');
				}
			}
			if (!FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S && !isError){
				if(!canSendEmbed){
					showTempmessage('You already post the score.',FlxColor.RED);
					return;
				}
				canSendEmbed = false;
				var _Rank:String = Ratings.GenerateLetterRank(PlayState.accuracy);
				var Rank:String = _Rank.substring(_Rank.indexOf(')') + 1, _Rank.length);
				var RankImage:String = (Rank == "Bro Hacking" || Rank == "actual bot moment" || Rank == "N/A" ? "skull" : Rank);

				var Player:String = "";
				if(FlxG.save.data.nickname == null){
					if(FlxG.save.data.randomNumber == null) FlxG.save.data.randomNumber = Std.int(Math.random() * 100000);
					Player = 'anonymous#' + FlxG.save.data.randomNumber;
				}else Player = FlxG.save.data.nickname;

				var _Performance:String = 'Marvelous - ${CoolUtil.FormatNumber(PlayState.marvelous)}[newline]Sicks - ${CoolUtil.FormatNumber(PlayState.sicks)}[newline]Goods - ${CoolUtil.FormatNumber(PlayState.goods)}[newline]Bads - ${CoolUtil.FormatNumber(PlayState.bads)}[newline]Shits - ${CoolUtil.FormatNumber(PlayState.shits)}[newline]Ghost Taps - ${CoolUtil.FormatNumber(PlayState.ghostTaps)}[newline]MA: ${PlayState.MA}[newline]SA: ${PlayState.SA}[newline][newline]Last combo: ${CoolUtil.FormatNumber(PlayState.combo)}x (Max: ${CoolUtil.FormatNumber(PlayState.maxCombo)})[newline]Misses: ${PlayState.misses}';
				var _Settings:String = 'Ghost Tapping: ${FlxG.save.data.ghost}[newline]HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}[newline] Script Count: ${(QuickOptionsSubState.getSetting("Song hscripts") ? '${PlayState.instance.interpCount}' : 'off')}[newline]Safe Frames: ${FlxG.save.data.frames}[newline]Input Engine: ${PlayState.inputEngineName}, T${MainMenuState.modver}[newline]Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms[newline]Key count: ${KeyCount}${(FlxG.save.data.scoresystem == 3 ? "[newline] Bal ScoreMultiplier: " + HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 3) : '')}${(FlxG.save.data.scoresystem == 4 ? "[newline] Bal ScoreDivider: " + HelperFunctions.truncateFloat(PlayState.ScoreDivider, 3) : '')}${(PlayState.instance.ADOFAIMode ? "[newline]ADOFAI Mode: true" : '')}${(PlayState.instance.randomnote != 0 ? "[newline]Random Mode: " + randommode[PlayState.instance.randomnote] : '')}';
				var Performance:String = _Performance.replace('[newline]','\\n'); // fuck you haxe
				var Settings:String = _Settings.replace('[newline]','\\n'); // fuck you haxe

				var http = new haxe.Http("https://canary.discord.com/api/webhooks/1194182726790676511/tiuC_k_k44wJVxcXA9Jk2l96QEEjj2QMcfYnZ9Fnetw7udNfygfgVD0yk3GG6PXdEmrG"); // please don't do anything stupid.
				var data = '{
					"content": null,
					"embeds": [
					  {
						"title": "${(if(week) "Week" else "Song") + " " + (if(win) "Won!" else "failed...")}",
						"description": "${(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')}${FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : ""}${PlayState.invertedChart || QuickOptionsSubState.getSetting("Inverted chart") ? " Left Side" : ""}\\n${scoretype[FlxG.save.data.scoresystem + 1]}: ${CoolUtil.FormatNumber(PlayState.songScore)} ${HelperFunctions.truncateFloat(PlayState.accuracy,2)}% ${Ratings.GenerateLetterRank(PlayState.accuracy)}",
						"color": ${(win ? 10212085 : 15835313)},
						"fields": [
						  {
							"name": "${(if(PlayState.instance.botPlay) "Botplay " else "")}Song Performance",
							"value": "$Performance",
							"inline": true
						  },
						  {
							"name": "Settings",
							"value": "$Settings",
							"inline": true
						  }
						],
						"author": {
						  "name": "Played By $Player"
						},
						"footer": {
						  "text": "Evil Text: ${Md5.encode(PlayState.SONG.notes.toString())}"
						},
						"thumbnail": {
						  "url": "https://github.com/cartoon032/Super-Engine-T-Mod/blob/master/art/Extra/Rank/${RankImage}.png?raw=true"
						}
					  }
					]
				  }';
				http.setHeader("Content-Type", "application/json");
				http.setPostData(data);
				http.onError = function (error:String) {
					canSendEmbed = true;
					showTempmessage('Something went wrong. error: $error',FlxColor.RED);
					FlxG.sound.play(Paths.sound('cancelMenu'));
					trace(data);
					trace('error: $error');
				}
				http.onData = function (data:String) {
					showTempmessage('Score have been post by the name ${Player}!');
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				http.request(true);
			}
			if (FlxG.keys.justPressed.TAB)
				{
					extrainfo = !extrainfo;
					if(!extrainfo)
						settingsText.text =
							(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
							+ (FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : "")
							+'\n\nSettings:'
							+'\n\n Ghost Tapping: ${FlxG.save.data.ghost}'
							+(FlxG.save.data.practiceMode ? '\n Practice: true' : '')
							+'\n HScripts: ${QuickOptionsSubState.getSetting("Song hscripts")}' + (QuickOptionsSubState.getSetting("Song hscripts") ? '\n  Script Count: ${PlayState.instance.interpCount}' : "")
							+(FlxG.save.data.frames != 10 ? '\n Safe Frames: ${FlxG.save.data.frames}' : '')
							+'\n Input Engine: ${PlayState.inputEngineName}, T${MainMenuState.modver}'
							+'\n Song Offset: ${HelperFunctions.truncateFloat(FlxG.save.data.offset + PlayState.songOffset,2)}ms'
							+(FlxG.save.data.scoresystem == 3 || FlxG.save.data.altscoresystem == 4 ? '\n Bal ScoreMultiplier: ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 3)}' : '')
							+(FlxG.save.data.scoresystem == 4 || FlxG.save.data.altscoresystem == 5 ? '\n Bal ScoreDivider: ${HelperFunctions.truncateFloat(PlayState.ScoreDivider, 3)}' : '')
							+'\n Key count: ' + KeyCount
							+ (PlayState.instance.ADOFAIMode ? '\n ADOFAI Mode: true' : '')
							+ (PlayState.instance.randomnote != 0 ? '\n Random Mode: ${randommode[PlayState.instance.randomnote]}' : '')
							+'\n'
							;
					else
						settingsText.text =
							(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
							+ (FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : "")
							+ '\n\nScore Mode: ${scoretype[FlxG.save.data.scoresystem + 1]} ' + (FlxG.save.data.scoresystem == 1 || FlxG.save.data.scoresystem == 5  || FlxG.save.data.scoresystem == 6 || FlxG.save.data.scoresystem == 7 ? "Calculate using last combo" : "")
							+ (FlxG.save.data.scoresystem == 1 || FlxG.save.data.scoresystem == 2 || FlxG.save.data.scoresystem == 5 || FlxG.save.data.scoresystem == 6 ? '\n Marvelous: ${CoolUtil.FormatNumber(noteratingscore[0])}' + '\n Sick: ${CoolUtil.FormatNumber(noteratingscore[1])}' : '\n Marvelous/Sick: ${CoolUtil.FormatNumber(noteratingscore[0])}')
							+ '\n Good: ${CoolUtil.FormatNumber(noteratingscore[2])}'
							+ '\n Bad: ${CoolUtil.FormatNumber(noteratingscore[3])}'
							+ '\n Shit: ${CoolUtil.FormatNumber(noteratingscore[4])}'
							+ (FlxG.save.data.scoresystem == 3 ? '\nScoreMultiplier: ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 3)}' : '')
							+ (FlxG.save.data.scoresystem == 4 ? '\nScoreDivider: ${HelperFunctions.truncateFloat(PlayState.ScoreDivider, 3)}' : '')
							+ '\nMax Score: ' + (FlxG.save.data.scoresystem == 7 ? 'A very high number source: trust me bro' : CoolUtil.FormatNumber(Math.round(MaxScore)))
							+ '\nYour Note Total: ${CoolUtil.FormatNumber(PlayState.bfnoteamount)}' + (PlayState.bfnoteamount != PlayState.bfnoteamountwithhurt ? ' + ${CoolUtil.FormatNumber(PlayState.bfnoteamountwithhurt - PlayState.bfnoteamount)} Bad Note' : '')
							+ '\nOpponent Note Total: ${CoolUtil.FormatNumber(PlayState.dadnoteamount)}' + (PlayState.dadnoteamount != PlayState.dadnoteamountwithhurt ? ' + ${CoolUtil.FormatNumber(PlayState.dadnoteamountwithhurt - PlayState.dadnoteamount)} Bad Note' : '')
							+ '\nNote Outside of chart: ${CoolUtil.FormatNumber(NoteStuffExtra.shitNotes)}'
							+ '\nChart difficult: ' + (chartdifficult > 0.1 ? Std.string(chartdifficult) : PlayState.bfnoteamount < 10 ? '0/10 Where gameplay' : 'Error happen :crying:')
							+ '\nOpponent Chart difficult: ' + (Opponentchartdifficult > 0.1 ? Std.string(Opponentchartdifficult) : PlayState.dadnoteamount < 10 ? '0/10 Where gameplay' : 'Error happen :crying:')
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

				if(tempMessages[0] != null && (tempMessages[0][0] -= elapsed) < 0){
					try{
						var msg = tempMessages.shift();
						remove(msg[1]);
						remove(msg[2]);
						msg[1].destroy();
						msg[2].destroy();
						if(tempMessages[0] != null){
							for (_ => msg in tempMessages){
								msg[1].y -= Std.int(msg[2].height);
								msg[2].y -= Std.int(msg[2].height);
							}
						}
					}catch(e){}
				}
	}
	var tempMessages:Array<Array<Dynamic>> = [];
	function showTempmessage(str:String,?color:FlxColor = FlxColor.LIME){ // stole from the MusicBeatState lol
		var moveDown = false;
		var lastBacking = null;
		if (tempMessages.length > 0){
			moveDown = true;
			lastBacking = tempMessages[tempMessages.length - 1][2];
		}

		var tempMessage = new FlxText(0,60,FlxG.width,str,24);
		tempMessage.setFormat(CoolUtil.font, 24, color, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		tempMessage.scrollFactor.set();
		var tempMessBacking = new FlxSprite(tempMessage.x - 2,tempMessage.y - 2).makeGraphic(Std.int(tempMessage.width + 4),Std.int(tempMessage.height + 4),0xaa000000);
		tempMessBacking.scrollFactor.set();
		add(tempMessBacking);
		add(tempMessage);

		if(moveDown){
			tempMessBacking.y = lastBacking.y + lastBacking.height;
			tempMessage.y = tempMessBacking.y + 2;
		};
		tempMessages.push([5.0,tempMessage,tempMessBacking]);
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