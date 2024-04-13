package;

import openfl.Lib;

import Controls.Control;
import flixel.FlxG; 
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
// import flixel.tweens.FlxTweenManager;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;

using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var songLengthTxt = "N/A";
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var ready = true;

	var offsetChanged:Bool = false;
	var levelInfo:FlxText;
	var levelDifficulty:FlxText;
	var startTimer:FlxTimer;
	var quitHeld:Int = 0;
	var quitHeldBar:FlxBar;
	var quitHeldBG:FlxSprite;

	var songPath = '';
	var shouldveLeft = false;
	var finishCallback:()->Void;
	var time:Float = 0;
	var volume:Float = 0;
	var timers:Array<FlxTimer> = [];
	var tweens:Array<FlxTween> = [];
	var bg:FlxSprite;

	var currentChart = -1;
	public function new(x:Float, y:Float){
		if(FlxG.sound.music != null ) songLengthTxt = FlxStringUtil.formatTime(Math.floor((FlxG.sound.music.length) / 1000), false);
		time = Conductor.rawPosition;
		menuItems = ['Resume', 'Restart Song',"Options Menu",'Exit to menu'];

		#if !mobile
			if(ChartingState.charting){
				menuItems.insert(3,'Back to chart editor');
				menuItems.insert(4,'Exit Charting Mode');
			}else if (PlayState.songDifficulties.length > 0) menuItems.insert(2,'Swap Charts');
		#end

		openfl.system.System.gc();
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer){
			if(tmr.active){tmr.active = false;timers.push(tmr);}
		});
		FlxTween.globalManager.forEach(function(tmr:FlxTween){
			if(tmr.active){tmr.active = false;tweens.push(tmr);}
		});
		super();
		PlayState.instance.callInterp("pauseCreate",[this]);

		finishCallback = FlxG.sound.music.onComplete;

		FlxG.sound.music.onComplete = null;
		FlxG.sound.music.looped = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FlxText(20, -15, 0, "", 32);
		levelInfo.text = CoolUtil.formatChartName(PlayState.SONG.song);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(CoolUtil.font, 32,OUTLINE,0xff000000);
		levelInfo.borderSize = 2;
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, -47, 0, "", 24);
		levelDifficulty.text = CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(CoolUtil.font, 24,OUTLINE,0xff000000);
		levelDifficulty.borderSize = 2;
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartIn});
		FlxTween.tween(levelInfo, {alpha: 1, y: -levelInfo.y}, 0.4, {ease: FlxEase.bounceOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: -levelDifficulty.y}, 0.4, {ease: FlxEase.bounceOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length){
			var _text = menuItems[i];
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, _text, true, false,true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
			songText.screenCenter(X);
			var sX = songText.x;
			songText.x = -(20 + songText.width);
			FlxTween.tween(songText,{x : sX},0.9,{ease:FlxEase.cubeInOut});
		}
		changeSelection();

		quitHeldBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar','shared'));
		quitHeldBG.screenCenter(X);
		quitHeldBG.scrollFactor.set();
		add(quitHeldBG);


		quitHeldBar = new FlxBar(quitHeldBG.x + 4, quitHeldBG.y + 4, LEFT_TO_RIGHT, Std.int(quitHeldBG.width - 8), Std.int(quitHeldBG.height - 8), this,'quitHeld', 0, 1000);
		quitHeldBar.numDivisions = 1000;
		quitHeldBar.scrollFactor.set();
		quitHeldBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
		add(quitHeldBar);
		songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		PlayState.instance.callInterp("pause",[this]);
		volume = FlxG.sound.music.volume;
		FlxTween.tween(FlxG.sound.music,{volume:0.2},0.5);
		FlxG.sound.music.looped = true;
	}
	@:keep inline function getChartSel(){
		var chart = PlayState.songDifficulties[currentChart];
		return '< ${chart.substring(chart.lastIndexOf('/') + 1,chart.lastIndexOf('.'))} >';
	}
	@:keep inline function updateChartSel(){
		if(currentChart > PlayState.songDifficulties.length - 1) currentChart = 0;
		if(currentChart < 0) currentChart = PlayState.songDifficulties.length - 1;
		var i = menuItems.indexOf('Swap Charts');
		if(i > 0){
			grpMenuShit.members[i].text = getChartSel();
			grpMenuShit.members[i].screenCenter(X);
		}
	}
	inline function callInterp(name:String,args:Array<Dynamic>){args.unshift(this); if(PlayState.instance != null) PlayState.instance.callInterp(name,args);}
	override function update(elapsed:Float){
		super.update(elapsed);
		
		if (quitHeldBar.visible && quitHeld <= 0){
			quitHeldBar.visible = false;
			quitHeldBG.visible = false;
		}else if (FlxG.keys.pressed.ESCAPE){
			quitHeld += 5;
			quitHeldBar.visible = true;
			quitHeldBG.visible = true;
			if (quitHeld > 1000) {quit();quitHeld = 0;}
			}else if (quitHeld > 0){
			quitHeld -= 10;
		}

		if (ready){

			callInterp("pauseUpdate",[]);


		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		var daSelected:String = menuItems[curSelected];
		if(controls.LEFT || controls.RIGHT){

			#if !mobile
			if(daSelected.startsWith('Swap Charts')){
				if(controls.LEFT_P){
					currentChart--;
					updateChartSel();
				}
				if(controls.RIGHT_P){
					currentChart++;
					updateChartSel();
				}

			}#end
		}
		if (controls.ACCEPT) select(curSelected);

	}else{
		if (controls.ACCEPT && menuItems[curSelected] == "Exit to menu") quit();
	}
}
	function disappearMenu(?time:Float = 0.3){
		for (_ => v in grpMenuShit.members)
		{
			ready = false;
			FlxTween.tween(v,{x : -(100 + v.width),alpha : 0},time,{ease:FlxEase.cubeIn});
		}
	}
	function quit(){

		if (FlxG.save.data.fpsCap > 290) (cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
		FlxG.sound.music.stop();
		retMenu();

		return;
	}
	function retMenu(){
		if (PlayState.isStoryMode){FlxG.switchState(new StoryMenuState());return;}
		PlayState.actualSongName = ""; // Reset to prevent issues
		if (shouldveLeft || ChartingState.charting) {
			ChartingState.charting = false;
			Main.game.forceStateSwitch(new MainMenuState());
			return;
		}
		switch (PlayState.stateType){
			case 2:FlxG.switchState(new onlinemod.OfflineMenuState());
			case 4:FlxG.switchState(new multi.MultiMenuState());
			case 5:FlxG.switchState(new osu.OsuMenuState());
			default:FlxG.switchState(new MainMenuState());
		}
		shouldveLeft = true;
		return;
	}
	function select(sel:Int){
		var sel =menuItems[sel];
		switch (sel){
			case "Resume":
				switch(FlxG.save.data.PauseMode){
					case 0:resume();
					case 1:countdown();
					case 2:
						if(time > Conductor.crochet * 4)time -= Conductor.crochet * 4;
						resume();
				}
			case "Restart Song":
				disappearMenu();
				new FlxTimer().start(0.3,function(tmr:FlxTimer){
					Main.game.funniLoad = true;
					FlxG.resetState();
				},1);
			case 'Back to chart editor':
				disappearMenu();
				new FlxTimer().start(0.3,function(tmr:FlxTimer){
					PlayState.songspeed = 1;
					PlayState.sectionStart = false;
					PlayState.SHUTUP();
					LoadingState.loadAndSwitchState(new ChartingState());
				},1);
			case "Exit Charting Mode":
				PlayState.sectionStart = false;
				disappearMenu();
				new FlxTimer().start(0.3,function(tmr:FlxTimer){
					ChartingState.charting = false;
					FlxG.resetState();
				},1);
			case "Options Menu":
				disappearMenu();
				new FlxTimer().start(0.3,function(tmr:FlxTimer){
					SearchMenuState.doReset = false;
					OptionsMenu.lastState = PlayState.stateType + 10;
					FlxG.switchState(new OptionsMenu());
				},1);

			case "Exit to menu":
				disappearMenu();
				new FlxTimer().start(0.3,function(tmr:FlxTimer){
					FlxTween.globalManager.clear();
					quit();
				},1);
			case "Swap Charts":
				if(currentChart < 0 || PlayState.songDifficulties[currentChart] == null) {FlxG.sound.play(Paths.sound('cancelMenu'));return;}
				ChartingState.charting = false;
				var chart = PlayState.songDifficulties[currentChart];
				multi.MultiMenuState.gotoSong(chart.substring(0,chart.lastIndexOf('/')),chart.substring(chart.lastIndexOf('/') + 1));
				FlxG.resetState();
			default:
				callInterp("pauseSelect",[sel]);
		}
	}
	var _tween:FlxTween;
	public function countdown(){try{
		ready = false;
		var swagCounter:Int = 1;
		try{
			_tween = FlxTween.tween(FlxG.sound.music,{volume:0},0.5);
		}catch(e){}
		for (i in [levelDifficulty,levelInfo]) {
			if(i == null) continue;
			FlxTween.tween(i,{x:FlxG.width + 10},0.3,{ease:FlxEase.quartIn,
				onComplete:function(_){i.destroy();}
			});
		}
		FlxG.sound.music.pause();
		FlxG.sound.music.time = Conductor.songPosition = Conductor.rawPosition = time;
		disappearMenu(0.4);
		callInterp("pauseResume",[]);
		FlxTween.tween(bg,{alpha:0},2.5,{ease:FlxEase.quartOut});

		startTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer){

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			switch (swagCounter) {
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y + 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {ready.destroy();}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();



					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y + 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {set.destroy();}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();


					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y + 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween) {go.destroy();}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
					resume(true);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}catch(e){MainMenuState.handleError(e,'Something went wrong on countdown ${e.message}');}}
	
	function resume(dont:Bool = false){
		if(!dont)PlayState.instance.callInterp("pauseResume",[this]);
		PlayState.instance.callInterp("pauseExit",[]);
		for (i in tweens) i.active = true;
		for (i in timers) i.active = true;
		if(_tween != null)_tween.cancel();
		FlxG.sound.music.pause();
		FlxG.sound.music.time = Conductor.songPosition = Conductor.rawPosition = time;
		FlxG.sound.music.volume = volume;
		if(FlxG.save.data.PauseMode != 2)FlxTween.tween(FlxG.sound.music,{volume:volume},0.01);
		else FlxTween.tween(FlxG.sound.music,{volume:volume},Conductor.crochet * 0.003);
		FlxG.sound.music.onComplete = finishCallback;
		close();
	}

	override function destroy() {
		if (pauseMusic != null){pauseMusic.destroy();}

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		curSelected += change;

		if (curSelected < 0) curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length) curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;
			#if(!mobile)
				item.alpha = (item.targetY == 0 ? 1 : 0.6);
			#else
				item.alpha = 1;
			#end
		}
	}
}