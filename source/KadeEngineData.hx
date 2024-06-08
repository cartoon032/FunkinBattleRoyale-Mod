import openfl.Lib;
import flixel.FlxG;
import sys.FileSystem;

class KadeEngineData
{
    public static function initSave()
    {

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;

		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = true;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap < 30)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine
		
		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = true;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;
		
		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		if (FlxG.save.data.opponent == null)
			FlxG.save.data.opponent = "bf";

		if (FlxG.save.data.playerChar == null)
			FlxG.save.data.playerChar = "bf";

		if (FlxG.save.data.gfChar == null)
			FlxG.save.data.gfChar = "gf";

		if (FlxG.save.data.selStage == null)
			FlxG.save.data.selStage = "default";

		if (FlxG.save.data.animDebug == null)
			FlxG.save.data.animDebug = false;

		if (FlxG.save.data.PlayStateanimDebug == null)
			FlxG.save.data.PlayStateanimDebug = false;
		// Note Splash
		if (FlxG.save.data.noteSplash == null)
			FlxG.save.data.noteSplash = true;

		// Preformance
		if (FlxG.save.data.preformance == null)
			FlxG.save.data.preformance = false;
		// View Character on Character Select
		if (FlxG.save.data.charAuto == null) FlxG.save.data.charAuto = true;
		if (FlxG.save.data.charAutoBF == null) FlxG.save.data.charAutoBF = false;
		if (FlxG.save.data.stageAuto == null) FlxG.save.data.stageAuto = true;

		if (FlxG.save.data.lastServer == null)
			FlxG.save.data.lastServer = "";
		if (FlxG.save.data.lastServerPort == null)
			FlxG.save.data.lastServerPort = "";
		if (FlxG.save.data.nickname == null)
			FlxG.save.data.nickname = "";

		if (FlxG.save.data.guiGap == null) FlxG.save.data.guiGap = 0;

		if (FlxG.save.data.inputHandler == null) FlxG.save.data.inputHandler = 1;

		if (FlxG.save.data.hitSound == null) FlxG.save.data.hitSound = false;
		if (FlxG.save.data.dadhitSound == null) FlxG.save.data.dadhitSound = false;

		if (FlxG.save.data.noteAsset == null) FlxG.save.data.noteAsset = ["default"];

		if (FlxG.save.data.camMovement == null) FlxG.save.data.camMovement = true;
		if (FlxG.save.data.practiceMode == null) FlxG.save.data.practiceMode = false;
		if (FlxG.save.data.dadShow == null) FlxG.save.data.dadShow = true;
		if (FlxG.save.data.bfShow == null) FlxG.save.data.bfShow = true;
		if (FlxG.save.data.gfShow == null) FlxG.save.data.gfShow = true;
		if (FlxG.save.data.bfShow == null) FlxG.save.data.bfShow = true;

		if (FlxG.save.data.playVoices == null) FlxG.save.data.playVoices = false;
		if (FlxG.save.data.updateCheck == null) FlxG.save.data.updateCheck = true;
		if (FlxG.save.data.songUnload == null) FlxG.save.data.songUnload = true;
		if (FlxG.save.data.useBadArrowTex == null) FlxG.save.data.useBadArrowTex = true;
		if (FlxG.save.data.middleScroll == null) FlxG.save.data.middleScroll = false;
		if (FlxG.save.data.oppStrumLine == null) FlxG.save.data.oppStrumLine = true;
		if (FlxG.save.data.playMisses == null) FlxG.save.data.playMisses = true;
		if (FlxG.save.data.scripts == null) FlxG.save.data.scripts = [];
		if (FlxG.save.data.songInfo == null) FlxG.save.data.songInfo = 0;
		if (FlxG.save.data.mainMenuChar == null) FlxG.save.data.mainMenuChar = false;
		if (FlxG.save.data.useFontEverywhere == null) FlxG.save.data.useFontEverywhere = false;
		if (FlxG.save.data.scoresystem == null) FlxG.save.data.scoresystem = 0;
		if (FlxG.save.data.altscoresystem == null) FlxG.save.data.altscoresystem = 0;
		if (FlxG.save.data.popupscorelocation == null) FlxG.save.data.popupscorelocation = 0;
		if (FlxG.save.data.popupscoreoffset == null) FlxG.save.data.popupscoreoffset = 0;
		if (FlxG.save.data.MKScrollSpeed == null) FlxG.save.data.MKScrollSpeed = 1;
		if (FlxG.save.data.allowServerScripts == null) FlxG.save.data.allowServerScripts = false;
		if (FlxG.save.data.notefade == null) FlxG.save.data.notefade = 1;
		if (FlxG.save.data.ShowConnectedIP == null) FlxG.save.data.ShowConnectedIP = false;
		if (FlxG.save.data.DiscordRPC == null) FlxG.save.data.DiscordRPC = true;
		if (FlxG.save.data.logGameplay == null) FlxG.save.data.logGameplay = false;
		if (FlxG.save.data.JudgementCounter == null) FlxG.save.data.JudgementCounter = true;
		if (FlxG.save.data.PauseMode == null) FlxG.save.data.PauseMode = 1;
		if (FlxG.save.data.ExtraIcon == null) FlxG.save.data.ExtraIcon = false;
		if (FlxG.save.data.Server == null) FlxG.save.data.Server = [];
		if (FlxG.save.data.OnlineEXCharLimit == null) FlxG.save.data.OnlineEXCharLimit = 5;
		if (FlxG.save.data.accurateNoteSustain == null) FlxG.save.data.accurateNoteSustain = false;
		if (FlxG.save.data.ReplaceDadWithGF == null) FlxG.save.data.ReplaceDadWithGF = true;
		if (FlxG.save.data.ShitCombo == null) FlxG.save.data.ShitCombo = false;
		if (FlxG.save.data.keys == null) FlxG.save.data.keys = KeyBinds.defaultKeys;
		if (FlxG.save.data.gfTitleShow == null) FlxG.save.data.gfTitleShow = true;
		if (FlxG.save.data.AltMK == null)FlxG.save.data.AltMK = false;
		if (FlxG.save.data.menuScripts == null)FlxG.save.data.menuScripts = true;
		if (FlxG.save.data.UsingSystemMouse == null)FlxG.save.data.UsingSystemMouse = true;
		if (FlxG.save.data.luaScripts == null)FlxG.save.data.luaScripts = true;
		if (FlxG.save.data.noterating == null)FlxG.save.data.noterating = true;
		if (FlxG.save.data.showTimings == null)FlxG.save.data.showTimings = 1;
		if (FlxG.save.data.showCombo == null)FlxG.save.data.showCombo = 1;
		if (FlxG.save.data.comboStacking == null)FlxG.save.data.comboStacking = 1;

		if (FlxG.save.data.instVol == null) FlxG.save.data.instVol = 0.8;
		if (FlxG.save.data.masterVol == null) FlxG.save.data.masterVol = 1;
		if (FlxG.save.data.voicesVol == null) FlxG.save.data.voicesVol = 1;
		if (FlxG.save.data.missVol == null) FlxG.save.data.missVol = 0.1;
		if (FlxG.save.data.hitVol == null) FlxG.save.data.hitVol = 0.6;
		if (FlxG.save.data.otherVol == null) FlxG.save.data.otherVol = 0.6;

		if(FlxG.save.data.doCoolLoading == null) FlxG.save.data.doCoolLoading = false;
		if(FlxG.save.data.fullscreen == null) FlxG.save.data.fullscreen = false;

		if(FlxG.save.data.lastUpdateID == null) FlxG.save.data.lastUpdateID = MainMenuState.versionIdentifier;

		MainMenuState.lastVersionIdentifier = FlxG.save.data.lastUpdateID;
		FlxG.save.data.lastUpdateID = MainMenuState.versionIdentifier;
		if(MainMenuState.lastVersionIdentifier != MainMenuState.versionIdentifier){ // This is going to be ugly but only executed every time the game's updated
			var lastVersionIdentifier = MainMenuState.lastVersionIdentifier;
			if(lastVersionIdentifier < 1)
				FlxG.save.data.inputEngine = 1; // Update to new input
			if(lastVersionIdentifier < 3){
				FlxG.save.data.noteAsset = [FlxG.save.data.noteAsset];
			}
		}

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}