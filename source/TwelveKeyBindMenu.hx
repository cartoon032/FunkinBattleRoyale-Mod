package;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky

import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;


using StringTools;

class TwelveKeyBindMenu extends FlxSubState
{

	var keyTextDisplay:FlxText;
	var keyWarning:FlxText;
	var warningTween:FlxTween;
	var keyText:Array<Array<String>> = [
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11", "KEY 12"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11", "KEY 12","KEY 13"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11", "KEY 12","KEY 13","KEY 14"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11", "KEY 12","KEY 13","KEY 14","KEY 15"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11", "KEY 12","KEY 13","KEY 14","KEY 15","KEY 16"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11", "KEY 12","KEY 13","KEY 14","KEY 15","KEY 16","KEY 17"],
		["KEY 1", "KEY 2", "KEY 3", "KEY 4", "KEY 5", "KEY 6", "KEY 7", "KEY 8", "KEY 9", "KEY 10", "KEY 11", "KEY 12","KEY 13","KEY 14","KEY 15","KEY 16","KEY 17","KEY 18"],
	];
	var defaultKeys:Array<String> = ["A", "S", "W", "D", "Z", "X", "N", "M", "R"];
	var curSelected:Int = 0;

	var keys:Array<Array<String>> = FlxG.save.data.keys;
	var tempKey:String = "";
	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "TAB","ONE","TWO","SEVEN","THREE"];

	var blackBox:FlxSprite;
	var infoText:FlxText;

	var state:String = "select";
	var keyMode:Int = 0;

	public static function getKeyBindsString():String{
		return 'Edit KeyBind From 10K-18K';
	}

	override function create()
	{   

		var _keys:Array<Array<String>> =FlxG.save.data.keys;
		for(count => keyArr in _keys){
			keys[count] = keyArr.copy();
			for(i => v in KeyBinds.defaultKeys[count]){
				if(keys[count][i] == null){
					keys[count][i] = v;
				}
			}
		}
	
		//FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

		persistentUpdate = true;

		keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(CoolUtil.font, 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;

		blackBox = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
		add(blackBox);

		infoText = new FlxText(-10, 580, 1280, 'Key mode: ${keyMode}. \n(Escape to save, Backspace to leave without saving.)', 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat(CoolUtil.font, 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
		infoText.screenCenter(FlxAxes.X);
		add(infoText);
		add(keyTextDisplay);

		infoText.alpha = blackBox.alpha = keyTextDisplay.alpha = 0;

		FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

		OptionsMenu.instance.acceptInput = false;

		textUpdate();

		super.create();
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		#if (!FLX_NO_GAMEPAD)
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		#end
		if (frames <= 10) frames++;

		infoText.text = #if(!mobile) 'Key mode: ${keyMode + 10}K. Press Left/Right to switch' + #end'\n(' + #if(mobile) 'Tap or press ' + #end'Escape to save, Backspace to leave without saving. )\n${lastKey != "" ? lastKey + " is blacklisted!" : ""}'; //'//Shitty haxe syntax moment

		switch(state){

			case "select":
				if (FlxG.keys.justPressed.UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}else if (FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
				#if !mobile
				else if (FlxG.keys.justPressed.LEFT)
				{
					if(keyText[keyMode - 1] == null){
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}else{
						keyMode--;
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					
				}else if (FlxG.keys.justPressed.RIGHT){
					if(keyText[keyMode + 1] == null){
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}else{
						keyMode++;
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
				}
				#end

				if (FlxG.keys.justPressed.ENTER){
					FlxG.sound.play(Paths.sound('scrollMenu'));
					state = "input";
				}else if(FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE #if(mobile) || FlxG.mouse.justReleased #end){
					quit();
				}

			case "input":
				tempKey = keys[keyMode][curSelected];
				keys[keyMode][curSelected] = "?";
				textUpdate();
				state = "waiting";

			case "waiting":
				if(FlxG.keys.justPressed.ESCAPE){
					keys[keyMode][curSelected] = tempKey;
					state = "select";
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				else if(FlxG.keys.justPressed.ENTER){
					addKey(KeyBinds.defaultKeys[keyMode][curSelected]);
					save();
					state = "select";
				}else if(FlxG.keys.justPressed.ANY){
					addKey(FlxG.keys.getIsDown()[0].ID.toString());
					save();
					state = "select";
				}


			case "exiting":


			default:
				state = "select";

		}

		if(FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
		
	}

	function textUpdate(){

		keyTextDisplay.text = "\n\n";
		for(i => str in keyText[keyMode]){

			var textStart = (i == curSelected) ? "> " : "  ";
			keyTextDisplay.text += textStart + str + ": " + keys[keyMode][i] + " / " + "\n";

		}
		

		keyTextDisplay.screenCenter();

	}

	function save(){
		var _keys = FlxG.save.data.keys = [];
		for(count => keyArr in keys){
			_keys[count] = keyArr.copy();
			if(keyText[count] == null) continue;
			for(i in 0...keyText[count].length){
				if(_keys[count][i] == null){
					_keys[count][i] = "F12";
				}
			}
			
		}
	}

	function quit(){

		state = "exiting";

		save();

		OptionsMenu.instance.acceptInput = true;

		FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0}, 1.1, {ease: FlxEase.expoInOut, onComplete: function(flx:FlxTween){close();}});
		FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
	}

	public var lastKey:String = "";

	function addKey(r:String){

		var shouldReturn:Bool = true;
		if (blacklist.contains(r)){
			keys[keyMode][curSelected] = tempKey;
			lastKey = r;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}
		
		for(i => v in keys[keyMode]){
			if(v == r) keys[keyMode][i] = null;
			// if (blacklist.contains(v)){
			// 	keys[keyMode][i] = null;
			// 	lastKey = v;
			// 	return;
			// }
		}

		lastKey = "";

		if(shouldReturn){
			keys[keyMode][curSelected] = r;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;
				
		if (curSelected >= keys[keyMode].length) curSelected = 0;
		if (curSelected < 0) curSelected = keys[keyMode].length - 1;
	}
}