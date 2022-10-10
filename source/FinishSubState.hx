package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.ui.FlxBar;
import flixel.FlxCamera;
import flixel.math.FlxMath;

#if windows
import Discord.DiscordClient;
#end
class FinishSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;

	var music:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;
	var win:Bool = true;
	var ready = false;
	var week:Bool = false;
	var errorMsg:String = "";
	var isError:Bool = false;
	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	var iconP1:HealthIcon; 
	var iconP2:HealthIcon;
	var scoretype:Array<String> = ["","FNF Score","OSU! Score","Osu!Mania Score","Bal Score","Stupid Score"];
	var randommode:Array<String> = ["","Full Random","Full Random With Jack Prevent","Random Per Section"];
	var extrainfo:Bool = false;
	var noteratingscore:Array<Int> = [350,200,-300];
	var settingsText:FlxText;
	var chartdifficult:Float = NoteStuffExtra.CalculateDifficult(0.93,0);
	var Opponentchartdifficult:Float = NoteStuffExtra.CalculateDifficult(0.93,1);
	public static var pauseGame:Bool = true;
	public static var autoEnd:Bool = true;
	public function new(x:Float, y:Float,?won = true,?week:Bool = false,?error:String = "")
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

		this.week = week;
		if(!isError) FlxG.state.persistentUpdate = true; else FlxG.state.persistentUpdate = false;
		win = won;
		FlxG.sound.pause();
		PlayState.instance.generatedMusic = false;
		var dad = PlayState.dad;
		var boyfriend = PlayState.boyfriend;

		// For healthbar shit
		healthBar = PlayState.instance.healthBar;
		healthBarBG = PlayState.instance.healthBarBG;
		iconP1 = PlayState.instance.iconP1;
		iconP2 = PlayState.instance.iconP2;


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
			FlxTween.tween(iconP1, {y:Std.int(FlxG.height * 0.10 - (iconP1.height * 0.5))},1,{ease: FlxEase.expoIn});
			FlxTween.tween(iconP2, {y:Std.int(FlxG.height * 0.10 - (iconP2.height * 0.5))},1,{ease: FlxEase.expoIn});




			FlxTween.tween(PlayState.instance.kadeEngineWatermark, {y:FlxG.height + 200},1,{ease: FlxEase.expoIn});
			FlxTween.tween(PlayState.instance.scoreTxt, {y:if(FlxG.save.data.downscroll) -200 else FlxG.height + 200},1,{ease: FlxEase.expoIn});
			FlxTween.tween(PlayState.instance.judgementCounter, {x: -200},1,{ease: FlxEase.expoIn});
		}
		if(!isError){
			if(win){
				boyfriend.playAnimAvailable(['win','hey','singUP']);
				if (PlayState.SONG.player2 == FlxG.save.data.gfChar) dad.playAnim('cheer'); else {dad.playAnimAvailable(['lose','singDOWNmiss']);}
				PlayState.gf.playAnim('cheer',true);
			}else{
				// boyfriend.playAnim('singDOWNmiss');
				// boyfriend.playAnim('lose');

				// dad.playAnim("hey",true);
				// dad.playAnim("win",true);
				boyfriend.playAnimAvailable(['lose','singDOWNmiss']);
				dad.playAnimAvailable(['win','hey','singUP']);
				if (PlayState.SONG.player2 == FlxG.save.data.gfChar) dad.playAnim('sad'); else dad.playAnim("hey");
				PlayState.gf.playAnim('sad',true);
			}
		}
		super();
		if(autoEnd){
			if (win) boyfriend.animation.finishCallback = this.finishNew; else finishNew();
			if (FlxG.save.data.camMovement){
				PlayState.instance.followChar(if(win) 0 else 1);
			}
		}
	}


	var cam:FlxCamera;
	public function finishNew(?name:String){
			FlxG.camera.alpha = PlayState.instance.camGame.alpha = PlayState.instance.camHUD.alpha = 1;
			cam = new FlxCamera();
			FlxG.cameras.add(cam);
			FlxCamera.defaultCameras = [cam];
			if (win) PlayState.boyfriend.animation.finishCallback = null; else PlayState.dad.animation.finishCallback = null;
			ready = true;
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
				var contText:FlxText = new FlxText(0,FlxG.height + 100,FlxG.width,'Press ENTER to exit\nor R to reload.');
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
				+ '\n\nSicks - ${PlayState.sicks}'
				+ '\nGoods - ${PlayState.goods}'
				+ '\nBads - ${PlayState.bads}'
				+ '\nShits - ${PlayState.shits}'
				+ '\n\nLast combo: ${PlayState.combo} (Max: ${PlayState.maxCombo})'
				+ '\nMisses: ${PlayState.misses}'
				+ (PlayState.badNote > 0 ? '\nBad Note: ${PlayState.badNote}' : '')
				+ '\n\n${scoretype[FlxG.save.data.scoresystem + 1]}: ${PlayState.songScore}'
				+ (FlxG.save.data.altscoresystem > 0 ? '\n${scoretype[FlxG.save.data.altscoresystem]}: ${PlayState.altsongScore}' : '')
				+ '\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%'
				+ '\n\n${Ratings.GenerateLetterRank(PlayState.accuracy)}'
				+ '\n');
				comboText.size = 28;
				comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				comboText.color = FlxColor.WHITE;
				comboText.scrollFactor.set();
				#if windows
				if(!win){
					DiscordClient.changePresence("GAME OVER -- "
					+ PlayState.detailsText
					+ Ratings.GenerateLetterRank(PlayState.accuracy),
					"\nAcc: " + HelperFunctions.truncateFloat(PlayState.accuracy, 2)
					+ "% | Score: " + PlayState.songScore
					+ " | Misses: " + PlayState.misses, PlayState.iconRPC,false,null,"dead");
				}
				else{
					DiscordClient.changePresence("Finish --"
					+ PlayState.detailsText
					+ Ratings.GenerateLetterRank(PlayState.accuracy),
					"\nAcc: " + HelperFunctions.truncateFloat(PlayState.accuracy, 2)
					+ "% | Score: " + PlayState.songScore
					+ " | Misses: " + PlayState.misses, PlayState.iconRPC,false,null,"finish-playstate");
				}
				#end
// Std.int(FlxG.width * 0.45)

				for(i in 0...3){
					switch(FlxG.save.data.scoresystem)
					{
						case 0: noteratingscore[i] = Math.round(noteratingscore[i] * PlayState.songspeed); //FNF
						case 1: noteratingscore[i] = Math.round(noteratingscore[i] + (noteratingscore[i] * ((PlayState.combo * PlayState.songspeed) / 25))); //Osu!
						case 2: noteratingscore[i] = Math.round((1000000 / PlayState.bfnoteamount) * (noteratingscore[i] / 350)); //Osu!mania
						case 3: noteratingscore[i] = Math.round(noteratingscore[i] * PlayState.ScoreMultiplier * PlayState.songspeed); //FF
						case 4: noteratingscore[i] = Math.round(noteratingscore[i] * PlayState.combo * PlayState.songspeed); //Stupid
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
					+(FlxG.save.data.scoresystem == 3 || FlxG.save.data.altscoresystem == 4 ? '\n Bal ScoreMultiplier : ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 2)}' : '')
					+'\n Key count: ' + (QuickOptionsSubState.getSetting("Play Both Side") ? '4k + 4k' : '${PlayState.keyAmmo[PlayState.mania]}K') + (QuickOptionsSubState.getSetting("Force Mania") > -1 ? '*' : '')
					+ (QuickOptionsSubState.getSetting("ADOFAI Chart") ? '\n ADOFAI Mode : true' : '')
					+ (QuickOptionsSubState.getSetting("Random Notes") != 0 ? '\n Random Mode: ${randommode[QuickOptionsSubState.getSetting("Random Notes")]}' : '')
					+'\n'
					;
				settingsText.size = 28;
				settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
				settingsText.color = FlxColor.WHITE;
				settingsText.scrollFactor.set();

				var contText:FlxText = new FlxText(0,FlxG.height + 100,FlxG.width,'Press ENTER to continue Press R to restart\nor Tab for extra info.');
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
				

				if(win && !PlayState.instance.hasDied && FlxG.save.data.scoresystem != 4)
					Highscore.setScore('${PlayState.nameSpace}-${PlayState.actualSongName}${(if(PlayState.invertedChart) "-inverted" else "")}',PlayState.songScore,[PlayState.songScore,'${HelperFunctions.truncateFloat(PlayState.accuracy,2)}%',Ratings.GenerateLetterRank(PlayState.accuracy),(PlayState.songspeed != 1 ? "(" + PlayState.songspeed + "x)" : "")]);
				add(bg);
				add(finishedText);
				add(comboText);
				add(contText);
				add(settingsText);
				// add(chartInfoText);
				healthBar.cameras = healthBarBG.cameras = iconP1.cameras = iconP2.cameras = [cam];

				FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(finishedText, {y:20},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(contText, {y:FlxG.height - 90},0.5,{ease: FlxEase.expoInOut});
				// FlxTween.tween(chartInfoText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
				FlxTween.tween(settingsText, {y:145},0.5,{ease: FlxEase.expoInOut});
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
			{
				retMenu();
			}

			if (FlxG.keys.justPressed.R)
				{
					if(win)FlxG.resetState();
					else restart();
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
							+ (FlxG.save.data.scoresystem == 3 || FlxG.save.data.altscoresystem == 4 ? '\n Bal ScoreMultiplier : ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 2)}' : '')
							+'\n Key count: ' + (QuickOptionsSubState.getSetting("Play Both Side") ? '4k + 4k' : '${PlayState.keyAmmo[PlayState.mania]}K') + (QuickOptionsSubState.getSetting("Force Mania") > -1 ? '*' : '')
							+ (QuickOptionsSubState.getSetting("ADOFAI Chart") ? '\n ADOFAI Mode : true' : '')
							+ (QuickOptionsSubState.getSetting("Random Notes") != 0 ? '\n Random Mode: ${randommode[QuickOptionsSubState.getSetting("Random Notes")]}' : '')
							+'\n'
							;
					else
						settingsText.text = 
							(if (PlayState.stateType == 4) PlayState.actualSongName else '${PlayState.SONG.song} ${PlayState.songDiff}')
							+ (FlxMath.roundDecimal(PlayState.songspeed, 2) != 1.00 ? " (" + FlxMath.roundDecimal(PlayState.songspeed, 2) + "x)" : "")
							+ '\n\nScore System ${scoretype[FlxG.save.data.scoresystem + 1]}'
							+ '\n Sick : ${noteratingscore[0]}'
							+ '\n Good : ${noteratingscore[1]}'
							+ '\n Bad : 0'
							+ '\n Shit : ${noteratingscore[2]}'
							+ (FlxG.save.data.scoresystem == 3 ? '\nScoreMultiplier : ${HelperFunctions.truncateFloat(PlayState.ScoreMultiplier, 2)}' : '')
							+ '\nMax Score : ' + (FlxG.save.data.scoresystem == 1 ? 'OSU! Score is not supported' : FlxG.save.data.scoresystem == 4 ? '2,147,483,647' : QuickOptionsSubState.getSetting("Play Both Side") ? Std.string(noteratingscore[0] * (PlayState.bfnoteamount + PlayState.dadnoteamount)) : Std.string(noteratingscore[0] * PlayState.bfnoteamount))
							+ '\nYour Note Total : ${PlayState.bfnoteamount}'
							+ '\nOpponent Note Total : ${PlayState.dadnoteamount}'
							+ '\nChart difficult : ' + (PlayState.mania != 0 ? 'Multi Key not supported' : chartdifficult > 0.1 ? Std.string(chartdifficult) : PlayState.bfnoteamount < 10 ? '0/10 Where gameplay' : 'Error happen :crying:')
							+ '\nOpponent Chart difficult : ' + (PlayState.mania != 0 ? 'Multi Key not supported' : Opponentchartdifficult > 0.1 ? Std.string(Opponentchartdifficult) : PlayState.dadnoteamount < 10 ? '0/10 Where gameplay' : 'Error happen :crying:')
							+'\n'
							;
					}
		}else{
			if(FlxG.keys.justPressed.ANY){
				PlayState.boyfriend.animation.finishCallback = null;
				finishNew();
			}
		}

	}
	function restart()
	{
		ready = false;
		// FlxG.sound.music.stop();
		// FlxG.sound.play(Paths.music('gameOverEnd'));
		if(isError){
			FlxG.resetState();
			if (shouldveLeft){ // Error if the state hasn't changed and the user pressed r already
				MainMenuState.handleError("Caught softlock!");
			}
			shouldveLeft = true;
			return;
		}
		// Holyshit this is probably a bad idea but whatever
		// PlayState.instance.resetInterps();
		// Conductor.songPosition = 0;
		// Conductor.songPosition -= Conductor.crochet * 5;
		
		// PlayState.instance.persistentUpdate = true;
		// PlayState.instance.resetScore();
		// PlayState.songStarted = false;

		// PlayState.strumLineNotes = null;
		// PlayState.instance.generateSong();
		// PlayState.instance.startCountdown();
		// close();
		FlxG.resetState();
	}
	override function destroy()
	{
		if (music != null){music.destroy();}

		super.destroy();
	}

}