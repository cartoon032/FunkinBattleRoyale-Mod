package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import tjson.Json;
import Discord.DiscordClient;

class OptionCategory
{
	public var options(default,null):Array<Option> = new Array<Option>();
	public var modded:Bool = false;
	public var description:String = "";
	@:keep inline public final function getOptions():Array<Option>
	{
		return options;
	}

	@:keep inline public final function addOption(opt:Option)
	{
		options.push(opt);
	}

	
	@:keep inline public final function removeOption(opt:Option)
	{
		options.remove(opt);
	}

	public var name(default,null):String = "New Category";

	public function new(catName:String, options:Array<Option>,?desc:String = "",?mod:Bool = false)
	{
		description = desc;
		name = catName;
		this.options = options;
		this.modded = mod;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}
	public var description(default,null):String = "";
	public var display(default,null):String = "";
	public var acceptValues(default,null):Bool = false;

	public function getValue():String { return throw "you forgot to replace getValue!"; };
	
	// Returns whether the label is to be updated.
	public function press():Bool { return throw "you forgot to replace press!"; }
	private function updateDisplay():String { return throw "you forgot to replace updateDisplay!"; }
	public function left():Bool { return throw "you forgot to replace left!"; }
	public function right():Bool { return throw "you forgot to replace right!"; }
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
		return "Key Bindings for 4K >";
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
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	override function getValue():String {
		return SixKeyBindMenu.getKeyBindsString();
	}

	private override function updateDisplay():String
	{
		return "Key Bindings for 6K >";
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
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	override function getValue():String {
		return NineKeyBindMenu.getKeyBindsString();
	}

	private override function updateDisplay():String
	{
		return "Key Bindings for 9K >";
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
	override function right():Bool {
		return false;
	}
	override function left():Bool {
		return false;
	}
	override function getValue():String {
		return TwelveKeyBindMenu.getKeyBindsString();
	}

	private override function updateDisplay():String
	{
		return "Key Bindings for 10K+ >";
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
		return "Safe Frames: " + FlxG.save.data.frames;
	}

	override function left():Bool {

		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		display = updateDisplay();
		return true;
	}

	override function getValue():String {
		return "MARVELOUS: " + HelperFunctions.truncateFloat(22.5 * Conductor.timeScale, 0) +
		"ms, SICK: " + HelperFunctions.truncateFloat(45 * Conductor.timeScale, 0) +
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
		display = updateDisplay();
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
		return "Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1);
	}

	override function right():Bool {
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed > 5)
			FlxG.save.data.scrollSpeed = 5;
		display = updateDisplay();
		return true;
	}

	override function getValue():String {
		return "Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1);
	}

	override function left():Bool {
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;
		display = updateDisplay();
		return true;
	}
}

class BreakTimerOption extends Option
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
		return "Break Timer: " + (FlxG.save.data.breakTimer > 0 ? HelperFunctions.truncateFloat(FlxG.save.data.breakTimer,1) : "OFF");
	}

	override function right():Bool {
		FlxG.save.data.breakTimer += 0.1;

		if (FlxG.save.data.breakTimer > 10)
			FlxG.save.data.breakTimer = 10;
		display = updateDisplay();
		return true;
	}

	override function getValue():String {
		return "Break Timer: " + HelperFunctions.truncateFloat(FlxG.save.data.breakTimer,1);
	}

	override function left():Bool {
		FlxG.save.data.breakTimer -= 0.1;

		if (FlxG.save.data.breakTimer < 1)
			FlxG.save.data.breakTimer = 0;
		display = updateDisplay();
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
class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
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
		return "Player Character >";
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
		return "GF Character >";
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
		return "Opponent Character >";
	}

	override function getValue():String {
		return "Current Opponent: " + FlxG.save.data.opponent;
	}

}
class AccurateNoteHoldOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if(FlxG.save.data.inputHandler == 1){

			FlxG.save.data.accurateNoteSustain = !FlxG.save.data.accurateNoteSustain;
			display = updateDisplay();
			return true;
		}else{
			return false;
		}
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.inputHandler == 0 ? "Kade Note Sustain" : "Accurate Note Sustain " + (FlxG.save.data.accurateNoteSustain ? "on" : "off"));
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
		return "Selected Stage >";
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
	var ies:Array<String> = ["Super Engine LEGACY","Super Engine"];
	var iesDesc:Array<String> = ["A custom input engine based off of Kade 1.4/1.5","A new input engine that is based off of key events; Usually faster"];
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
	var ies:Array<String> = ["FNF","OSU!","OSU!Mania","Balance Score","Invert Balance Score","VC","VC Uncap","Stupid"];
	var iesDesc:Array<String> = [
		"Good old FNF score",
		"More Combo = More Score",
		"The Max score for every song is 1M",
		"You will get a Score Multiplier if your side have less note than opponent",
		"You will get a Score Divider if your side have more note than opponent",
		"short for Voiid Chronicles. It like Osu! score but there a Multiplier cap. Note: Song Speed will not affected score",
		"It like Osu! score but score ramp up way quicker. Song Speed also affected score now",
		"Fuck it, Score * Combo * songspeed everything count at combo even miss"
	];
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
		return 'Score Mode: ${ies[FlxG.save.data.scoresystem]}';
	}
}
class AltScoreSystem extends Option
{
	var ies:Array<String> = ["Disable","FNF","OSU!","OSU!Mania","Balance Score","Invert Balance Score","VC","VC Uncap","Stupid"];
	var iesDesc:Array<String> = [
		":Peace:",
		"Good old FNF score",
		"Combo Gaming",
		"You could say this is a vs Camellia Score system but i added this before that mod did",
		"less note more score definitely",
		"Why do i get less score, Whose idea is it Said the guy both think and code it in",
		"good luck try to catch up when you miss.",
		"Now i really would like to see you try catch up when you miss.",
		"so i saw a FNF mod that give you alot of score base on RNG and i was also kinda bored so i add one but with no RNG"];
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
		return 'Extra Score Mode: ${ies[FlxG.save.data.altscoresystem]}';
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
		return "Note Style Selection >";
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
		return "Char on main menu: " + (!FlxG.save.data.mainMenuChar ? "off" : "on");
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

class DadHitSoundOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.dadhitSound = !FlxG.save.data.dadhitSound;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Opponent Note Hit Sound " + (!FlxG.save.data.dadhitSound ? "off" : "on");
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
		return "Toggle scripts >";
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
class MKScrollSpeedOption extends Option
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
		return "Multikey Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.MKScrollSpeed,1);
	}

	override function right():Bool {
		FlxG.save.data.MKScrollSpeed += 0.1;

		if (FlxG.save.data.MKScrollSpeed > 5)
			FlxG.save.data.MKScrollSpeed = 5;
		display = updateDisplay();
		return true;
	}

	override function getValue():String {
		return "Multikey Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.MKScrollSpeed,1);
	}

	override function left():Bool {
		FlxG.save.data.MKScrollSpeed -= 0.1;

		if (FlxG.save.data.MKScrollSpeed < 1)
			FlxG.save.data.MKScrollSpeed = 1;
		display = updateDisplay();
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
class DiscordRPCOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.DiscordRPC = !FlxG.save.data.DiscordRPC;
		if(FlxG.save.data.DiscordRPC) DiscordClient.initialize();
		else DiscordClient.shutdown();
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return ("DiscordRPC: " + (FlxG.save.data.DiscordRPC ? "on" : "off"));
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

class JudgementCounterOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.JudgementCounter = !FlxG.save.data.JudgementCounter;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Judgement Counter " + (!FlxG.save.data.JudgementCounter ? "off" : "on");
	}
}
class ExtraIconOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ExtraIcon = !FlxG.save.data.ExtraIcon;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Load More Icon " + (!FlxG.save.data.ExtraIcon ? "off" : "on");
	}
}
class HCBoolOption extends Option{
	var id:String;
	var name:String;
	var trueText:String = "";
	var falseText:String = "";

	public function new(name:String,desc:String,id:String,?trueText:String = "",falseText:String = "")
	{
		// acceptValues = true;
		this.name = name;
		this.id = id;
		this.trueText = trueText;
		this.falseText = falseText;
		super();
		description = desc;

	}
	override function getValue():String {
		return '${Reflect.getProperty(FlxG.save.data,id)}';
	}
	public override function press():Bool{
		Reflect.setProperty(FlxG.save.data,id,!Reflect.getProperty(FlxG.save.data,id));
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String
	{
		var ret:Bool = cast(Reflect.getProperty(FlxG.save.data,id),Bool);
		if(trueText == "" || falseText == ""){
			return '$name: $ret';
		}
		return (if(ret) trueText else falseText);
	}
}
class PauseMode extends Option
{
	var ies:Array<String> = ["FNF","SE","Guitar Hero"];
	var iesDesc:Array<String> = ["Immediately go back to gaming","Do a countdown before resume","Go back 4 Beat in the song"];
	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.PauseMode >= ies.length) FlxG.save.data.PauseMode = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.PauseMode];
	}

	override function right():Bool {
		FlxG.save.data.PauseMode += 1;
		if (FlxG.save.data.PauseMode >= ies.length) FlxG.save.data.PauseMode = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.PauseMode -= 1;
		if (FlxG.save.data.PauseMode < 0) FlxG.save.data.PauseMode = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Pause Mode: ${ies[FlxG.save.data.PauseMode]}';
	}
}
class ShowRatingOption extends Option
{
	var ies:Array<String> = ["OFF","Stacking","Only One"];
	var iesDesc:Array<String> = ["No more Rating in the way","just like how the FNF dev wanted","will only see the most recent hit"];

	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.noterating >= ies.length) FlxG.save.data.noterating = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.noterating];
	}

	override function right():Bool {
		FlxG.save.data.noterating += 1;
		if (FlxG.save.data.noterating >= ies.length) FlxG.save.data.noterating = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.noterating -= 1;
		if (FlxG.save.data.noterating < 0) FlxG.save.data.noterating = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Note Ratings: ${ies[FlxG.save.data.noterating]}';
	}
}
class ShowComboOption extends Option
{
	var ies:Array<String> = ["OFF","Stacking","Only One"];
	var iesDesc:Array<String> = ["No more Combo in the way","just like how the FNF dev wanted","will only see the most recent hit"];

	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.showCombo >= ies.length) FlxG.save.data.showCombo = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.showCombo];
	}

	override function right():Bool {
		FlxG.save.data.showCombo += 1;
		if (FlxG.save.data.showCombo >= ies.length) FlxG.save.data.showCombo = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.showCombo -= 1;
		if (FlxG.save.data.showCombo < 0) FlxG.save.data.showCombo = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Current Combo: ${ies[FlxG.save.data.showCombo]}';
	}
}
class ShowMSOption extends Option
{
	var ies:Array<String> = ["OFF","Stacking","Only One Per Land"];
	var iesDesc:Array<String> = ["No more Combo in the way","just like how the Super wanted","will only see the most recent hit of land"];

	public function new(desc:String)
	{
		super();
		if (FlxG.save.data.showTimings >= ies.length) FlxG.save.data.showTimings = 0;
		description = desc;

		acceptValues = true;
	}

	override function getValue():String {
		return iesDesc[FlxG.save.data.showTimings];
	}

	override function right():Bool {
		FlxG.save.data.showTimings += 1;
		if (FlxG.save.data.showTimings >= ies.length) FlxG.save.data.showTimings = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool {
		FlxG.save.data.showTimings -= 1;
		if (FlxG.save.data.showTimings < 0) FlxG.save.data.showTimings = ies.length - 1;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'Note Timings: ${ies[FlxG.save.data.showTimings]}';
	}
}

class ReplaceDadwithGFOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ReplaceDadWithGF = !FlxG.save.data.ReplaceDadWithGF;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Replace Dad With GF: " + (!FlxG.save.data.ReplaceDadWithGF ? "off" : "on");
	}
}

class UsingSystemMouseOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.mouse.useSystemCursor = FlxG.save.data.UsingSystemMouse = !FlxG.save.data.UsingSystemMouse;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Using System cursor: " + (!FlxG.save.data.UsingSystemMouse ? "off" : "on");
	}
}

class OnlineEXCharLimitOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	override function getValue():String {
		return "";
	}

	override function right():Bool
	{
		FlxG.save.data.OnlineEXCharLimit++;
		if (FlxG.save.data.OnlineEXCharLimit > 100) FlxG.save.data.OnlineEXCharLimit = 0;
		display = updateDisplay();
		return true;
	}
	override function left():Bool
	{
		FlxG.save.data.OnlineEXCharLimit--;
		if (FlxG.save.data.OnlineEXCharLimit > 100) FlxG.save.data.OnlineEXCharLimit = 10;
		if (FlxG.save.data.OnlineEXCharLimit < 0) FlxG.save.data.OnlineEXCharLimit = 128;
		display = updateDisplay();
		return true;
	}
	public override function press():Bool{return right();}

	private override function updateDisplay():String
	{
		return 'EXChar Limit : ' + (FlxG.save.data.OnlineEXCharLimit > 100 ? "Basically Unlimited" : FlxG.save.data.OnlineEXCharLimit);
	}
}

class DeleteChartAutoSaveOption extends Option
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
		FlxG.save.data.autosave = "";
		OptionsMenu.instance.showTempmessage('Auto Save have been deleted',FlxColor.GREEN,10);
		return true;
	}

	private override function updateDisplay():String
	{
		return "Delete Chart editor AutoSave";
	}

	override function right():Bool {
		return false;
	}


	override function left():Bool {
		return false;
	}
}