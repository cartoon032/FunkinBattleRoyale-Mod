package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import tjson.Json;

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();
	public var modded:Bool = false;
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";
	public final function getName() {
		return _name;
	}

	public function new (catName:String, options:Array<Option>,?mod:Bool = false)
	{
		_name = catName;
		_options = options;
		this.modded = mod;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}
	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;
	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function getValue():String { return throw "stub!"; };
	
	// Returns whether the label is to be updated.
	public function press():Bool { return throw "stub!"; }
	private function updateDisplay():String { return throw "stub!"; }
	public function left():Bool { return throw "stub!"; }
	public function right():Bool { return throw "stub!"; }
}



class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
		description = 'Change your controls';
		acceptValues = true;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	override function getValue():String {
		return KeyBindMenu.getKeyBindsString();
	}
	private override function updateDisplay():String
	{
		return "Key Bindings for 4K";
	}
}

class SixKeyMenu extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
		description = 'Change your controls';
		acceptValues = true;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new SixKeyBindMenu());
		return false;
	}
	override function getValue():String {
		return SixKeyBindMenu.getKeyBindsString();
	}

	private override function updateDisplay():String
	{
		return "Key Bindings for 6K";
	}
}

class NineKeyMenu extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
		description = 'Change your controls';
		acceptValues = true;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new NineKeyBindMenu());
		return false;
	}
	override function getValue():String {
		return NineKeyBindMenu.getKeyBindsString();
	}

	private override function updateDisplay():String
	{
		return "Key Bindings for 9K";
	}
}

class TwelveKeyMenu extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
		description = 'Change your controls';
		acceptValues = true;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new TwelveKeyBindMenu());
		return false;
	}
	override function getValue():String {
		return TwelveKeyBindMenu.getKeyBindsString();
	}

	private override function updateDisplay():String
	{
		return "Key Bindings for 12K";
	}
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  FlxG.save.data.cpuStrums ? "Animated CPU Strums" : "Static CPU Strums";
	}

}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? "Downscroll" : "Upscroll";
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.ghost ? "Ghost Tapping" : "No Ghost Tapping";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy " + (!FlxG.save.data.accuracyDisplay ? "off" : "on");
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Position " + (!FlxG.save.data.songPosition ? "off" : "on");
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Distractions " + (!FlxG.save.data.distractions ? "off" : "on");
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Reset Button " + (!FlxG.save.data.resetButton ? "off" : "on");
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Flashing Lights " + (!FlxG.save.data.flashing ? "off" : "on");
	}
}

class Judgement extends Option
{
	

	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}
	
	public override function press():Bool
	{
		return true;
	}

	private override function updateDisplay():String
	{
		return "Safe Frames";
	}

	override function left():Bool {

		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}

	override function getValue():String {
		return "Safe Frames: " + Conductor.safeFrames +
		" | SICK: " + HelperFunctions.truncateFloat(45 * Conductor.timeScale, 0) +
		"ms, GOOD: " + HelperFunctions.truncateFloat(90 * Conductor.timeScale, 0) +
		"ms, BAD: " + HelperFunctions.truncateFloat(125 * Conductor.timeScale, 0) + 
		"ms, SHIT: " + HelperFunctions.truncateFloat(156 * Conductor.timeScale, 0) +
		"ms, TOTAL: " + HelperFunctions.truncateFloat(Conductor.safeZoneOffset,0) + "ms";
	}

	override function right():Bool {

		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter " + (!FlxG.save.data.fps ? "off" : "on");
	}
}



class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap";
	}
	
	override function right():Bool {
		if (FlxG.save.data.fpsCap >= 300)
		{
			FlxG.save.data.fpsCap = 300;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(300);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 1;
		if (FlxG.save.data.fpsCap < 20) FlxG.save.data.fpsCap = 20;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.fpsCap > 300)
			FlxG.save.data.fpsCap = 300;
		else if (FlxG.save.data.fpsCap < 20)
			FlxG.save.data.fpsCap = 20;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 1;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return "Current FPS Cap: " + FlxG.save.data.fpsCap + 
		(FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Hz (Refresh Rate)" : "");
	}
}


class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Scroll Speed";
	}

	override function right():Bool {
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String {
		return "Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1);
	}

	override function left():Bool {
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}


class RainbowFPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
		(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Rainbow " + (!FlxG.save.data.fpsRain ? "off" : "on");
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "NPS Display " + (!FlxG.save.data.npsDisplay ? "off" : "on");
	}
}

class ReplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new LoadReplayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Load replays";
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Mode: " + (FlxG.save.data.accuracyMod == 0 ? "Simple" : "Complex");
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Customize Gameplay";
	}
}

// class WatermarkOption extends Option
// {
// 	public function new(desc:String)
// 	{
// 		super();
// 		description = desc;
// 	}

// 	public override function press():Bool
// 	{
// 		Main.watermarks = !Main.watermarks;
// 		FlxG.save.data.watermark = Main.watermarks;
// 		display = updateDisplay();
// 		return true;
// 	}

// 	private override function updateDisplay():String
// 	{
// 		return "Watermarks " + (Main.watermarks ? "on" : "off");
// 	}
// }

class OffsetMenu extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		var poop:String = Highscore.formatSong("Tutorial", 1);

		PlayState.SONG = Song.loadFromJson(poop, "Tutorial");
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		PlayState.storyWeek = 0;
		PlayState.offsetTesting = true;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Time your offset";
	}
}
class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.botplay = false;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "BotPlay " + (FlxG.save.data.botplay ? "on" : "off");
}
// Added options
class PlayerOption extends Option
{
	public static var playerEdit:Int = 0;
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;

	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}

	public override function press():Bool
	{
		playerEdit = 0;
		FlxG.switchState(new CharSelection());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Player Character";
	}

	override function getValue():String {
		return "Current Player: " + FlxG.save.data.playerChar;
	}
}
class GFOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;

	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}

	public override function press():Bool
	{
		PlayerOption.playerEdit = 2;
		FlxG.switchState(new CharSelection());
		return true;
	}

	private override function updateDisplay():String
	{
		return "GF Character";
	}

	override function getValue():String {
		return "Current GF: " + FlxG.save.data.gfChar;
	}
}
class OpponentOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;

	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	public override function press():Bool
	{
		PlayerOption.playerEdit = 1;
		FlxG.switchState(new CharSelection());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Opponent Character";
	}

	override function getValue():String {
		return "Current Opponent: " + FlxG.save.data.opponent;
	}

}
class CharAutoOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.charAuto = !FlxG.save.data.charAuto;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Force selected opponent " + (!FlxG.save.data.charAuto ? "on" : "off");
	}
}
class AnimDebugOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.animDebug = !FlxG.save.data.animDebug;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Anim Debug " + (!FlxG.save.data.animDebug ? "off" : "on");
	}
}
class NoteSplashOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.noteSplash = !FlxG.save.data.noteSplash;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note Splashes " + (!FlxG.save.data.noteSplash ? "off" : "on");
	}
}
class ShitQualityOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.preformance = !FlxG.save.data.preformance;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Shit Quality " + (!FlxG.save.data.preformance ? "off" : "on");
	}
}
class NoteRatingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.noterating = !FlxG.save.data.noterating;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note Ratings " + (!FlxG.save.data.noterating ? "off" : "on");
	}
}

class GUIGapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "GUI Gap";
	}
	
	override function right():Bool {
		FlxG.save.data.guiGap += 1;

		return true;
	}

	override function left():Bool {
		FlxG.save.data.guiGap -= 1;
		return true;
	}

	override function getValue():String
	{
		return 'Hud distance: ${FlxG.save.data.guiGap}, Press enter to reset to 0';
	}
}
class SelStageOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;

	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	public override function press():Bool
	{
		FlxG.switchState(new StageSelection());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Selected Stage";
	}

	override function getValue():String {
		return "Current Stage: " + FlxG.save.data.selStage;
	}

}
class ReloadCharlist extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;

	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	public override function press():Bool
	{
		TitleState.checkCharacters();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Reload Char/Stage List";
	}

	override function getValue():String {
		return '${TitleState.choosableCharacters.length} character${CoolUtil.multiInt(TitleState.choosableCharacters.length)} loaded';
	}

}
class InputHandlerOption extends Option
{
	var ies:Array<String> = ["Kade","Super Engine"];
	var iesDesc:Array<String> = ["Kade 1.5/1.4 Input","A custom input engine based off of Kade 1.4/1.5"];
	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.inputHandler >= ies.length) FlxG.save.data.inputHandler = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.inputHandler];
	}

	override function right():Bool {
		FlxG.save.data.inputHandler += 1;
		if (FlxG.save.data.inputHandler >= ies.length) FlxG.save.data.inputHandler = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.inputHandler -= 1;
		if (FlxG.save.data.inputHandler < 0) FlxG.save.data.inputHandler = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return '${ies[FlxG.save.data.inputHandler]} Input';
	}
}
class ScoreSystem extends Option
{
	var ies:Array<String> = ["FNF","OSU!","OSU!Mania","Balance Score","Stupid"];
	var iesDesc:Array<String> = ["Good old FNF score","More Combo = More Score, Miss = BIG L","The Max score for every song is about 1M, The reason it not exactly 1M cuz rounding issue","You will get a Score Multiplier if your side have less note than opponent","Fuck it, Score * Combo * songspeed everything count at combo even miss"];
	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.scoresystem >= ies.length) FlxG.save.data.scoresystem = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.scoresystem];
	}

	override function right():Bool {
		FlxG.save.data.scoresystem += 1;
		if (FlxG.save.data.scoresystem >= ies.length) FlxG.save.data.scoresystem = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.scoresystem -= 1;
		if (FlxG.save.data.scoresystem < 0) FlxG.save.data.scoresystem = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Score Mode : ${ies[FlxG.save.data.scoresystem]}';
	}
}
class AltScoreSystem extends Option
{
	var ies:Array<String> = ["Disable","FNF","OSU!","OSU!Mania","Balance Score","Stupid"];
	var iesDesc:Array<String> = [":Peace:","Good old FNF score","More Combo = More Score","score cap at 1M i think","less note more score definitely","so i saw a FNF mod that give you alot of score base on RNG and i was also kinda bored so i add one but with no RNG"];
	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.altscoresystem >= ies.length) FlxG.save.data.altscoresystem = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.altscoresystem];
	}

	override function right():Bool {
		FlxG.save.data.altscoresystem += 1;
		if (FlxG.save.data.altscoresystem >= ies.length) FlxG.save.data.altscoresystem = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.altscoresystem -= 1;
		if (FlxG.save.data.altscoresystem < 0) FlxG.save.data.altscoresystem = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Extra Score Mode : ${ies[FlxG.save.data.altscoresystem]}';
	}
}
class NoteSelOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;

	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}

	public override function press():Bool
	{
		FlxG.switchState(new ArrowSelection());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note Style Selection";
	}

	override function getValue():String {
		return "Current note style: " + FlxG.save.data.noteAsset;
	}
}

class MMCharOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.mainMenuChar = !FlxG.save.data.mainMenuChar;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Char on main menu : " + (!FlxG.save.data.mainMenuChar ? "off" : "on");
	}
}


class HitSoundOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.hitSound = !FlxG.save.data.hitSound;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note Hit Sound " + (!FlxG.save.data.hitSound ? "off" : "on");
	}
}

class CamMovementOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.camMovement = !FlxG.save.data.camMovement;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Camera Movement " + (!FlxG.save.data.camMovement ? "off" : "on");
	}
}

class PracticeModeOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.practiceMode = !FlxG.save.data.practiceMode;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Practice Mode " + (!FlxG.save.data.practiceMode ? "off" : "on");
	}
}
class ShowP2Option extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.dadShow = !FlxG.save.data.dadShow;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Opponent " + (!FlxG.save.data.dadShow ? "off" : "on");
	}
}
class ShowP1Option extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.bfShow = !FlxG.save.data.bfShow;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Player " + (!FlxG.save.data.bfShow ? "off" : "on");
	}
}
class ShowGFOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.gfShow = !FlxG.save.data.gfShow;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Girlfriend " + (!FlxG.save.data.gfShow ? "off" : "on");
	}
}
class PlayVoicesOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.playVoices = !FlxG.save.data.playVoices;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Play voices " + (!FlxG.save.data.playVoices ? "off" : "on");
	}
}
class CheckForUpdatesOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.updateCheck = !FlxG.save.data.updateCheck;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Check for updates " + (!FlxG.save.data.updateCheck ? "off" : "on");
	}
}
class UnloadSongOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.songUnload = !FlxG.save.data.songUnload;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Unload song " + (!FlxG.save.data.songUnload ? "off" : "on");
	}
}
class UseBadArrowsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.useBadArrowTex = !FlxG.save.data.useBadArrowTex;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Hurt arrow texture " + (!FlxG.save.data.useBadArrowTex ? "off" : "on");
	}

}
class MiddlescrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Middle scroll " + (!FlxG.save.data.middleScroll ? "off" : "on");
	}

}
class OpponentStrumlineOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.oppStrumLine = !FlxG.save.data.oppStrumLine;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Show Opponent Strumline " + (!FlxG.save.data.oppStrumLine ? "off" : "on");
	}

}

class SongInfoOption extends Option
{
	var ies:Array<String> = ["Opposite of scroll direction","Opposite of scroll direction+","side","Advanced Side","vanilla + misses","Disabled"];
	var iesDesc:Array<String> = ["Kade 1.7 styled","Kade 1.8 styled","Show on the side","Also shows judgements","Vanilla styled with misses","Disabled altogether"];
	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.songInfo >= ies.length) FlxG.save.data.songInfo = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.songInfo];
	}

	override function right():Bool {
		FlxG.save.data.songInfo += 1;
		if (FlxG.save.data.songInfo >= ies.length) FlxG.save.data.songInfo = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.songInfo -= 1;
		if (FlxG.save.data.songInfo < 0) FlxG.save.data.songInfo = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Song Info: ${ies[FlxG.save.data.songInfo]}';
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.playMisses = !FlxG.save.data.playMisses;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Play miss sounds " + (!FlxG.save.data.playMisses ? "off" : "on");
	}

}

class SelScriptOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;

	}
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	public override function press():Bool
	{
		FlxG.switchState(new ScriptSel());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Toggle scripts";
	}

	override function getValue():String {
		return "Current Script count: " + FlxG.save.data.scripts.length;
	}

}

class IntOption extends Option{
	var min:Int = 0;
	var max:Int;
	var script:String;
	var name:String;

	public function new(desc:String,name:String,min:Int,max:Int,mod:String)
	{
		this.name = name;
		// display = name;
		script = mod;
		this.min = min;
		this.max = max;
		super();
		acceptValues = true;
		description = desc;

	}
	override function getValue():String {
		return '${OptionsMenu.modOptions[script][name]}';
	}

	override function right():Bool {

		OptionsMenu.modOptions[script][name] += 1;
		if (OptionsMenu.modOptions[script][name] > max) OptionsMenu.modOptions[script][name] = min;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		OptionsMenu.modOptions[script][name] -= 1;
		if (OptionsMenu.modOptions[script][name] < min) OptionsMenu.modOptions[script][name] = max;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}
	private override function updateDisplay():String
	{
		return name;
	}
}
class FloatOption extends Option{
	var min:Float = 0;
	var max:Float;
	var script:String;
	var name:String;

	public function new(desc:String,name:String,min:Float,max:Float,mod:String)
	{
		this.name = name;
		// display = name;
		script = mod;
		this.min = min;
		this.max = max;
		super();
		acceptValues = true;
		description = desc;

	}
	override function getValue():String {
		return '${OptionsMenu.modOptions[script][name]}';
	}

	override function right():Bool {

		OptionsMenu.modOptions[script][name] += 0.1;
		if (OptionsMenu.modOptions[script][name] > max) OptionsMenu.modOptions[script][name] = min;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		OptionsMenu.modOptions[script][name] -= 0.1;
		if (OptionsMenu.modOptions[script][name] < min) OptionsMenu.modOptions[script][name] = max;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}
	private override function updateDisplay():String
	{
		return name;
	}
}
class BoolOption extends Option{
	var script:String;
	var name:String;

	public function new(desc:String,name:String,mod:String)
	{
		// acceptValues = true;
		this.name = name;
		// display = name;
		script = mod;
		super();
		description = desc;

	}
	override function getValue():String {
		return '${OptionsMenu.modOptions[script][name]}';
	}
	public override function press():Bool{
		OptionsMenu.modOptions[script][name] = !OptionsMenu.modOptions[script][name];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return name + ":" + getValue();
	}
}
class FontOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.useFontEverywhere = !FlxG.save.data.useFontEverywhere;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Force generic font " + (FlxG.save.data.useFontEverywhere ? "on" : "off");
	}
}
class BackTransOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Underlay opacity";
	}

	override function right():Bool {
		FlxG.save.data.undlaTrans += 0.05;

		if (FlxG.save.data.undlaTrans > 1)
			FlxG.save.data.undlaTrans = 1;
		return true;
	}

	override function getValue():String {
		return "Underlay opacity: " + HelperFunctions.truncateFloat(FlxG.save.data.undlaTrans,2);
	}

	override function left():Bool {
		FlxG.save.data.undlaTrans -= 0.05;

		if (FlxG.save.data.undlaTrans < 0)
			FlxG.save.data.undlaTrans = 0;

		return true;
	}
}
class BackgroundSizeOption extends Option
{
	var ies:Array<String> = ["Strumline Only","Fill screen"];
	var iesDesc:Array<String> = ["Only show underlay below strumline","Fill underlay to entire screen",];
	public function new(desc:String)
	{
		if (FlxG.save.data.undlaSize >= ies.length) FlxG.save.data.undlaSize = 0;
		super();
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.undlaSize];
	}

	override function right():Bool {
		FlxG.save.data.undlaSize += 1;
		if (FlxG.save.data.undlaSize >= ies.length) FlxG.save.data.undlaSize = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.undlaSize -= 1;
		if (FlxG.save.data.undlaSize < 0) FlxG.save.data.undlaSize = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Underlay style';
	}
}
class LogGameplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{

		FlxG.save.data.logGameplay = !FlxG.save.data.logGameplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return ("Log Gameplay " + (FlxG.save.data.logGameplay ? "on" : "off"));
	}
}
class PopupScoreLocationOption extends Option
{
	var ies:Array<String> = ["Center","Left Side","Right Side","Opposite Side","Same Side"];
	var iesDesc:Array<String> = ["Center","Left Side","Right Side","Opposite Side","Same Side"];
	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.popupscorelocation >= ies.length) FlxG.save.data.popupscorelocation = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.popupscorelocation];
	}

	override function right():Bool {
		FlxG.save.data.popupscorelocation += 1;
		if (FlxG.save.data.popupscorelocation >= ies.length) FlxG.save.data.popupscorelocation = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.popupscorelocation -= 1;
		if (FlxG.save.data.popupscorelocation < 0) FlxG.save.data.popupscorelocation = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Popup Score Location : ${ies[FlxG.save.data.popupscorelocation]}';
	}
}
class PopupScoreOffset extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "PopupScoreOffset";
	}

	override function right():Bool {
		FlxG.save.data.popupscoreoffset += 0.01;

		if (FlxG.save.data.popupscoreoffset > 0.25)
			FlxG.save.data.popupscoreoffset = 0.25;
		return true;
	}

	override function getValue():String {
		return "Popup Score Offset: " + HelperFunctions.truncateFloat(FlxG.save.data.popupscoreoffset,2);
	}

	override function left():Bool {
		FlxG.save.data.popupscoreoffset -= 0.01;

		if (FlxG.save.data.popupscoreoffset < -0.25)
			FlxG.save.data.popupscoreoffset = -0.25;
		return true;
	}
}
class FastSongScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Fast Song Scroll Speed";
	}

	override function right():Bool {
		FlxG.save.data.FastSongScrollSpeed += 0.1;

		if (FlxG.save.data.FastSongScrollSpeed < 1)
			FlxG.save.data.FastSongScrollSpeed = 1;

		if (FlxG.save.data.FastSongScrollSpeed > 4)
			FlxG.save.data.FastSongScrollSpeed = 4;
		return true;
	}

	override function getValue():String {
		return "Fast Song Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.FastSongScrollSpeed,1);
	}

	override function left():Bool {
		FlxG.save.data.FastSongScrollSpeed -= 0.1;

		if (FlxG.save.data.FastSongScrollSpeed < 1)
			FlxG.save.data.FastSongScrollSpeed = 1;

		if (FlxG.save.data.FastSongScrollSpeed > 4)
			FlxG.save.data.FastSongScrollSpeed = 4;

		return true;
	}
}
class AllowServerScriptsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{

		FlxG.save.data.allowServerScripts = !FlxG.save.data.allowServerScripts;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return ("Allow Server Scripts: " + (FlxG.save.data.allowServerScripts ? "on" : "off"));
	}
}
class NoteFadeOption extends Option
{
	var ies:Array<String> = ["Off","Default","Faster","Even Faster"];
	var iesDesc:Array<String> = ["No Note Fade","Slowly fade in note one as a time","Fade in note one as a time but faster","Need to go even further beyond"];
	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.notefade >= ies.length) FlxG.save.data.notefade = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.notefade];
	}

	override function right():Bool {
		FlxG.save.data.notefade += 1;
		if (FlxG.save.data.notefade >= ies.length) FlxG.save.data.notefade = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.notefade -= 1;
		if (FlxG.save.data.notefade < 0) FlxG.save.data.notefade = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Note Fade Mode: ${ies[FlxG.save.data.notefade]}';
	}
}
class AltSingMultiKeyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{

		FlxG.save.data.altsingformultikey = !FlxG.save.data.altsingformultikey;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return ("Multi Key use Sing2: " + (FlxG.save.data.altsingformultikey ? "on" : "off"));
	}
}
class ShowConnectedIPOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{

		FlxG.save.data.ShowConnectedIP = !FlxG.save.data.ShowConnectedIP;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return ("Show Connected Server IP: " + (FlxG.save.data.ShowConnectedIP ? "on" : "off"));
	}
}
class VolumeOption extends Option
{
	var opt = "";
	public function new(desc:String,option:String = "")
	{
		opt = option;
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return  opt + " Volume";}

	override function right():Bool {
		Reflect.setField(FlxG.save.data,opt+"Vol", Reflect.field(FlxG.save.data,opt+"Vol") + (if(FlxG.keys.pressed.SHIFT) 0.01 else 0.1));

		if (Reflect.field(FlxG.save.data,opt+"Vol") > 1)
			Reflect.setField(FlxG.save.data,opt+"Vol", 1);
		// display = updateDisplay();
		return true;
	}

	override function getValue():String {

		switch(opt){
			case "master":{
				FlxG.sound.volume = FlxG.save.data.masterVol;
			}
			case "inst":{
				FlxG.sound.music.volume = FlxG.save.data.instVol;
			}
		}
		return opt + " Volume: " + (HelperFunctions.truncateFloat(Reflect.field(FlxG.save.data,opt+"Vol"),2) * 100) + "%"; // Multiplied by 100 to appear as 0-100 instead of 0-1

	}

	override function left():Bool {
		Reflect.setField(FlxG.save.data,opt+"Vol", Reflect.field(FlxG.save.data,opt+"Vol") - (if(FlxG.keys.pressed.SHIFT) 0.01 else 0.1));
		if (Reflect.field(FlxG.save.data,opt+"Vol") < 0)
			Reflect.setField(FlxG.save.data,opt+"Vol", 0);
		// display = updateDisplay();

		return true;
	}
}

class ImportOption extends Option
{
	var opt = "";
	public function new(desc:String,option:String = "")
	{
		opt = option;
		super();
		description = desc;
	}

	public override function press():Bool
	{
		try{
			var optionsFile = Json.parse(sys.io.File.getContent('SEOPTIONS.json'));
			for (_ => v in Reflect.fields(optionsFile)) {
				if(v.toLowerCase() == "songScores"){continue;} // Importing scores is probably not the best of ideas
				Reflect.setProperty(FlxG.save.data,v,Reflect.getProperty(optionsFile,v));
			}
			OptionsMenu.instance.showTempmessage('Imported options successfully! Exit from the Options Menu to the Main Menu to save them',FlxColor.GREEN,10);
		}catch(e){
			FlxG.save.destroy();
			KadeEngineData.initSave();
			OptionsMenu.instance.showTempmessage('Unable to import options! Reset back to before this menu was opened! ${e.message}',FlxColor.RED,10);
		}
		return true;
	}

	private override function updateDisplay():String
	{
		return "Import Options";
	}

	override function right():Bool {
		
		return false;
	}


	override function left():Bool {
		return false;
	}
}

class EraseOption extends Option
{
	var opt = "";
	public function new(desc:String,option:String = "")
	{
		opt = option;
		super();
		description = desc;
	}

	public override function press():Bool
	{
		try{
			var e:String = Json.stringify(FlxG.save.data,"fancy");
			sys.io.File.saveContent('SEOPTIONS-BACKUP.json',e);
			FlxG.save.erase();
			KadeEngineData.initSave();
			OptionsMenu.instance.showTempmessage('Reset options back to defaults and backed them up to SEOPTIONS-BACKUP.json',FlxColor.GREEN,10);
		}catch(e){
			OptionsMenu.instance.showTempmessage('Unable to export options! ${e.message}',FlxColor.RED,10);
		}
		
		return true;
	}

	private override function updateDisplay():String
	{
		return "reset Options to defaults";
	}

	override function right():Bool {
		
		return false;
	}


	override function left():Bool {
		return false;
	}
}
class ExportOption extends Option
{
	var opt = "";
	public function new(desc:String,option:String = "")
	{
		opt = option;
		super();
		description = desc;
	}

	public override function press():Bool
	{
		try{
			var e:String = Json.stringify(FlxG.save.data,"fancy");
			sys.io.File.saveContent('SEOPTIONS.json',e);
			OptionsMenu.instance.showTempmessage('Exported options successfully!',FlxColor.GREEN,10);
		}catch(e){
			OptionsMenu.instance.showTempmessage('Unable to export options! ${e.message}',FlxColor.RED,10);
		}
		return true;
	}

	private override function updateDisplay():String
	{
		return "Export Options";
	}

	override function right():Bool {
		
		return false;
	}


	override function left():Bool {
		return false;
	}
}