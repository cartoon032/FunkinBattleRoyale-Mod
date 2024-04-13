package;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
import haxe.Exception;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import tjson.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import flash.media.Sound;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;
import sys.io.File;
import lime.media.AudioBuffer;
import flash.geom.Rectangle;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import haxe.io.Bytes;
import Discord.DiscordClient;

using StringTools;

class ChartingState extends MusicBeatState
{
	public var playClaps:Bool = false;
	public var playBeat:Bool = false;
	public static var charting:Bool = false;

	public var snap:Int = 1;
	public var notesnap:Int = 16;
	public var altnotesnap:Int = 32;
	public var deezNuts:Map<Int, Int> = new Map<Int, Int>(); // snap conversion map
	public var snapSelection = 4;
	public var tempsnapSelection = 6;
	public static var tempMania = 0;
	var SectiontoCopy:Int = 0;

	var camFollow:FlxObject;
	var FreeCam:Bool = false;
	var lastRMouseY = 0;
	var lastRMouseX = 0;

	var UI_box:FlxUITabMenu;
	var hideBox:Bool = false;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;
	var curNoteInfoLOL:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dad Battle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;
	var WhichSectionToPlace:Int = 0;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var waveformSprite:FlxSprite;
	var waveformEnabled:FlxUICheckBox;
	var waveformUseInstrumental:FlxUICheckBox;
	var visualiser:FlxSpriteGroup;
	var ToggleNoteType:FlxUICheckBox;

	var gridBG:FlxSprite;
	var gridBGAbove:FlxSprite;
	var gridBGBelow:FlxSprite;
	var gridBGEvent:FlxSprite;
	var gridBGEventAbove:FlxSprite;
	var gridBGEventBelow:FlxSprite;

	var _song:SwagSong;
	var loadedVoices:FlxSound;
	var loadedInst:Sound;
	public static var voicesFile = "";
	public static var instFile = "";
	public var speed = 1.0;

	var typingShit:FlxInputText;
	var anothertypingshit:FlxUIInputText;
	var notetype1shit:FlxUIInputText;
	var notetype2shit:FlxUIInputText;
	var notetype3shit:FlxUIInputText;
	var notetype4shit:FlxUIInputText;
	var notetype5shit:FlxUIInputText;
	var notetype6shit:FlxUIInputText;
	var notetype7shit:FlxUIInputText;
	var notetype8shit:FlxUIInputText;
	var Exnotetype:FlxUIInputText;
	var typingcharacter1shit:FlxInputText;
	var typingcharacter2shit:FlxInputText;
	var forcehurtnote:FlxUICheckBox;
	var inputtypeatint:FlxUICheckBox;
	var hurtnotescore:FlxUINumericStepper;
	var hurtnotehealth:FlxUINumericStepper;
	var ShiftJumpModbox:FlxUINumericStepper;
	var NoteTypeArray:Array<FlxUIInputText>;
	var notetypeselect = 0;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;
	var gridBlackLine:FlxSprite;
	var gridEventBlackLine:FlxSprite;
	var vocals:FlxSound;

	// var player2:Character = new Character(0,0, "bf");
	// var player1:Character = new Character(0,0, "bf");

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var gfIcon:HealthIcon;
	var keyAmmo:Array<Int> = [4, 6, 7, 9, 5, 8, 1, 2, 3, 10, 11, 12, 13, 14, 15, 16 ,17, 18, 21];

	private var lastNote:Note;
	var claps:Array<Note> = [];

	public static function detectChartType(_song:SwagSong):String{
		if(_song.chartType != null && _song.chartType != "" && _song.chartType != "KE1")
			return _song.chartType;
		_song.chartType = "FNF";
		if(_song.rawJSON != null && _song.rawJSON is String){
			var rawSong = Json.parse(_song.rawJSON);
			if(rawSong.generatedBy != null){
				_song.chartType += 'Generated by ${rawSong.generatedBy}';
			}
		}
		if(_song.eventObjects != null || _song.chartType == "KE1")
			_song.chartType += "/KADE";
		if(_song.timescale != null)
			_song.chartType += "/LEATHER";
		if(_song.events != null && _song.timescale == null)
			_song.chartType += "/PSYCH";
		if(_song.keyCount != 4)
			_song.chartType += '/MULTIKEY';
		return _song.chartType;
	}
	var chartType = "FNF";
	override function create()
	{
		TitleState.loadNoteAssets();
		curSection = lastSection;

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [
					{
						lengthInSteps : 16,
						altAnim : false,
						typeOfSection : 0,
						sectionNotes : [],
						bpm: 150,
						changeBPM : false,
						mustHitSection : true
					},
					{
						lengthInSteps : 16,
						altAnim : false,
						typeOfSection : 0,
						sectionNotes : [],
						bpm: 150,
						changeBPM : false,
						mustHitSection : true
					}
				],
				bpm: 150,
				needsVoices: false,
				player1: 'bf',
				player2: 'bf',
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 1,
				validScore: false,
				mania: 0,
				keyCount: 4,
				chartType:"FNF/Super-T"
			};
		}
		DiscordClient.changePresence("Editing The chart",_song.song,null,true);
		FlxG.autoPause = false;

		deezNuts.set(4, 1);
		deezNuts.set(8, 2);
		deezNuts.set(12, 3);
		deezNuts.set(16, 4);
		deezNuts.set(24, 6);
		deezNuts.set(32, 8);
		deezNuts.set(48, 12);
		deezNuts.set(64, 16);
		deezNuts.set(96, 24);
		deezNuts.set(128, 32);
		chartType = detectChartType(_song);
		_song.keyCount = keyAmmo[_song.mania];
		tempMania = _song.mania;

		if (FlxG.save.data.showHelp == null)
			FlxG.save.data.showHelp = true;
		if (FlxG.save.data.notetype == null || Std.isOfType(FlxG.save.data.notetype[0],Array))
			FlxG.save.data.notetype = ["The","Heavy","is","died!","The","Heavy","is","died?!"];
		if (FlxG.save.data.notetypeatInt == null)
			FlxG.save.data.notetypeatInt == false;
		if (FlxG.save.data.showNoteType == null)
			FlxG.save.data.showNoteType = false;

		var bg:FlxSprite = new FlxSprite().loadGraphic(SearchMenuState.background);
		bg.scrollFactor.set();
		bg.color = 0xFF23283d;
		add(bg);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[tempMania] * 2), GRID_SIZE * 16);
		gridBG.screenCenter(X);
		add(gridBG);
		gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[tempMania] * 2), GRID_SIZE * 32);
		gridBGAbove.y -= GRID_SIZE * 32;
		gridBGAbove.screenCenter(X);
		add(gridBGAbove);
		gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[tempMania] * 2), GRID_SIZE * 32);
		gridBGBelow.y += GRID_SIZE * 16;
		gridBGBelow.screenCenter(X);
		add(gridBGBelow);
		gridBGEvent = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * 16);
		gridBGEvent.x = gridBG.x - GRID_SIZE;
		add(gridBGEvent);
		gridBGEventAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * 32);
		gridBGEventAbove.x = gridBG.x - GRID_SIZE;
		gridBGEventAbove.y -= GRID_SIZE * 32;
		add(gridBGEventAbove);
		gridBGEventBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * 32);
		gridBGEventBelow.x = gridBG.x - GRID_SIZE;
		gridBGEventBelow.y += GRID_SIZE * 16;
		add(gridBGEventBelow);

		waveformSprite = new FlxSprite((GRID_SIZE * keyAmmo[tempMania]) - (GRID_SIZE * 4)).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		waveformSprite.x = gridBG.x;
		waveformSprite.alpha = 0.35;
		add(waveformSprite);

		gridBlackLine = new FlxSprite(0,gridBGAbove.y).makeGraphic(2, Std.int(gridBG.height * 5), FlxColor.BLACK);
		gridBlackLine.screenCenter(X);
		add(gridBlackLine);
		gridEventBlackLine = new FlxSprite(gridBG.x,gridBGAbove.y).makeGraphic(2, Std.int(gridBG.height * 5), FlxColor.BLACK);
		add(gridEventBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.mouse.visible = true;
		// FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		while (_song.notes[curSection + 5] == null){addSection();}
		if(chartType.contains("PSYCH")){
			trace('Convert Section Beat to Length In Steps');
			for(section in _song.notes){
				if(section.sectionBeats > 0)
					section.lengthInSteps = section.sectionBeats * 4;
			}
		}

		updateGrid();

		loadSong();
		loadAudioBuffer();
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		leftIcon = new HealthIcon(_song.player1);
		rightIcon = new HealthIcon(_song.player2);
		gfIcon = new HealthIcon("gf");
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);
		gfIcon.scrollFactor.set(1, 1);
		gfIcon.visible = false;

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);
		gfIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);
		add(gfIcon);

		leftIcon.setPosition(gridBG.x, -100);
		rightIcon.setPosition(gridBG.x + (gridBG.width / 2), -100);
		gfIcon.setPosition(gridBG.x, -100);

		bpmTxt = new FlxText(0, 0, FlxG.width, "", 16);
		bpmTxt.alignment = RIGHT;
		bpmTxt.scrollFactor.set();
		add(bpmTxt);
		curNoteInfoLOL = new FlxText(0, (FlxG.height * (1/6)), FlxG.width, "Current Select Note Info", 16);
		curNoteInfoLOL.alignment = LEFT;
		curNoteInfoLOL.visible = false;
		curNoteInfoLOL.scrollFactor.set();
		add(curNoteInfoLOL);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width * 2), 4);
		strumLine.screenCenter(X);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'},
			{name: "ZAssets", label: "Extra Features"}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(350, 450);
		UI_box.x = 0;
		UI_box.y = FlxG.height - UI_box.height;
		add(UI_box);

		visualiser = new FlxSpriteGroup(gridBG.x + gridBG.width + 10, 10);
		visualiser.scrollFactor.set(1,0);
		add(visualiser);
		{
			var vBack:FlxSprite = new FlxSprite().loadGraphic(FlxGraphic.fromRectangle(100,26,0xff000000));
			vBack.scrollFactor.set();
			visualiser.add(vBack);
			var v:FlxSprite = new FlxSprite(3,3).loadGraphic(FlxGraphic.fromRectangle(94,20,0xffffffff));
			v.origin.x = 0;
			v.origin.y = 0;
			v.scrollFactor.set();
			visualiser.add(v);
		}

		addSongUI();
		addSectionUI();
		addNoteUI();
		updateWaveform();
		updateSectionUI();
		updateHeads();

		add(curRenderedNotes);
		add(curRenderedSustains);

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 325, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
		};

		var saveButton:FlxUIButton = new FlxUIButton(160, 28, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxUIButton = new FlxUIButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong();
			loadAudioBuffer();
		});

		
		var restart = new FlxUIButton(10,150,"Reset Chart", function()
            {
                for (ii in 0..._song.notes.length)
                {
                    for (i in 0..._song.notes[ii].sectionNotes.length)
                        {
                            _song.notes[ii].sectionNotes = [];
                        }
                }
                resetSection(true);
            });

		var loadAutosaveBtn:FlxUIButton = new FlxUIButton(reloadSong.x, reloadSong.y + 30, 'load autosave', loadAutosave);
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(75,65,'BPM');
		
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(75,80,'Scroll Speed');
		
		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 0.1, 1, 0, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(75, 95, 'Vocal Volume');
		
		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';

		var stepperSongVolLabel = new FlxText(75, 110, 'Instrumental Volume');

		var check_mute_inst = new FlxUICheckBox(120, 130, null, null, "Mute Inst", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var check_mute_Voice = new FlxUICheckBox(10, 130, null, null, "Mute Voice", 100);
		check_mute_Voice.checked = false;
		check_mute_Voice.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_Voice.checked)
				vol = 0;

			vocals.volume = vol;
		};


		var hitsounds = new FlxUICheckBox(10, restart.y + 20, null, null, "Play hitsounds", 100);
		hitsounds.checked = false;
		hitsounds.callback = function()
		{
			playClaps = hitsounds.checked;
		};

		var beatsounds = new FlxUICheckBox(10, hitsounds.y + 20, null, null, "Play Beat Clap", 100);
		beatsounds.checked = false;
		beatsounds.callback = function()
		{
			playBeat = beatsounds.checked;
		};
		
		var shiftNoteDialLabel = new FlxText(10, 245, 'Shift Note FWD by (Section)');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 260, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';
		var shiftNoteDialLabel2 = new FlxText(10, 275, 'Shift Note FWD by (Step)');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 290, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';
		var shiftNoteDialLabel3 = new FlxText(10, 305, 'Shift Note FWD by (ms)');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 320, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';

		var shiftEntireChartNoteButton:FlxUIButton = new FlxUIButton(10, 335, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value),Std.int(stepperShiftNoteDialstep.value),Std.int(stepperShiftNoteDialms.value),true);
		});
		var shiftNoteButton:FlxUIButton = new FlxUIButton(110, 335, "Shift from this point", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value),Std.int(stepperShiftNoteDialstep.value),Std.int(stepperShiftNoteDialms.value),false);
		});

		waveformEnabled = new FlxUICheckBox(10, 10, null, null, "Visible Waveform", 100);
		if (FlxG.save.data.chart_waveform == null) FlxG.save.data.chart_waveform = true;
		waveformEnabled.checked = FlxG.save.data.chart_waveform;
		waveformEnabled.callback = function()
		{
			FlxG.save.data.chart_waveform = waveformEnabled.checked;
			updateWaveform();
		};

		waveformUseInstrumental = new FlxUICheckBox(waveformEnabled.x + 120, waveformEnabled.y, null, null, "Waveform for Instrumental", 100);
		waveformUseInstrumental.checked = false;
		waveformUseInstrumental.callback = function()
		{
			updateWaveform();
		};

		var player1DropDown = new FlxInputText(10, 50, 120, _song.player1, 8);
		typingcharacter1shit = player1DropDown;
		var player1Label = new FlxText(10,30,96,'Player');
		var acceptplayer1 = new FlxUIButton(10,70,'apply', function(){
			_song.player1 = player1DropDown.text;
			leftIcon.changeSprite(_song.player1);
			leftIcon.scrollFactor.set(1, 1);
		});

		var player2Label = new FlxText(200,30,96,'Opponent');
		var player2DropDown = new FlxInputText(200, 50, 120, _song.player2, 8);
		typingcharacter2shit = player2DropDown;
		var acceptplayer2 = new FlxUIButton(200,70,'apply', function(){
			_song.player2 = player2DropDown.text;
			rightIcon.changeSprite(_song.player2);
			rightIcon.scrollFactor.set(1, 1);
		});

		ToggleNoteType = new FlxUICheckBox(10, 150, null, null, "Show Note Type", 100);
		ToggleNoteType.checked = FlxG.save.data.showNoteType;

		var ShiftJumpModtext = new FlxText(10,355,128,'Shift Jump Modify');
		ShiftJumpModbox = new FlxUINumericStepper(ShiftJumpModtext.x,ShiftJumpModtext.y + 15, 1, 4, 0, 1000,0);

		var jumpsectiontext = new FlxText(10,385,128,'Jump Section');
		var jumpsectionbox = new FlxUINumericStepper(jumpsectiontext.x,jumpsectiontext.y + 15, 1, 0, -1000, 1000,0);
		var jumpsectionbutton = new FlxUIButton(jumpsectionbox.x + 60,jumpsectionbox.y - 5,'Jump', function(){changeSection(Std.int(jumpsectionbox.value));});
		var jumpbackbutton = new FlxUIButton(jumpsectionbutton.x + 100,jumpsectionbutton.y,'Jump Back Section', function(){changeSection(lastSection);});

		var hurtnotescoretxt = new FlxUIText(180, 200, 'Hurtnote Score');
		hurtnotescore = new FlxUINumericStepper(hurtnotescoretxt.x , hurtnotescoretxt.y + 20 , 100, _song.noteMetadata.badnoteScore, -1000000, 1000000);
		var hurtnotescorenote = new FlxUIText(hurtnotescore.x , hurtnotescore.y + 20 , 'note: add -10 on top of that');

		var hurtnotehealthtxt = new FlxUIText(hurtnotescorenote.x , hurtnotescorenote.y + 20 , 'Hurtnote Health');
		hurtnotehealth = new FlxUINumericStepper(hurtnotehealthtxt.x , hurtnotehealthtxt.y + 20 , 0.01 , _song.noteMetadata.badnoteHealth, -2, 2, 2);

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_Voice);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(stepperVocalVol);
		tab_group_song.add(stepperVocalVolLabel);
		tab_group_song.add(stepperSongVol);
		tab_group_song.add(stepperSongVolLabel);
        tab_group_song.add(shiftNoteDialLabel);
        tab_group_song.add(stepperShiftNoteDial);
        tab_group_song.add(shiftNoteDialLabel2);
        tab_group_song.add(stepperShiftNoteDialstep);
        tab_group_song.add(shiftNoteDialLabel3);
        tab_group_song.add(stepperShiftNoteDialms);
        tab_group_song.add(shiftEntireChartNoteButton);
        tab_group_song.add(shiftNoteButton);
		tab_group_song.add(hitsounds);
		tab_group_song.add(beatsounds);
		tab_group_song.add(hurtnotescoretxt);
		tab_group_song.add(hurtnotescore);
		tab_group_song.add(hurtnotescorenote);
		tab_group_song.add(hurtnotehealthtxt);
		tab_group_song.add(hurtnotehealth);

		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "ZAssets";
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);
		tab_group_assets.add(acceptplayer1);
		tab_group_assets.add(acceptplayer2);
		tab_group_assets.add(waveformEnabled);
		tab_group_assets.add(waveformUseInstrumental);
		tab_group_assets.add(ToggleNoteType);
		tab_group_assets.add(jumpsectiontext);
		tab_group_assets.add(jumpsectionbox);
		tab_group_assets.add(jumpsectionbutton);
		tab_group_assets.add(jumpbackbutton);
		tab_group_assets.add(ShiftJumpModtext);
		tab_group_assets.add(ShiftJumpModbox);

		UI_box.addGroup(tab_group_song);
		UI_box.addGroup(tab_group_assets);
		UI_box.scrollFactor.set();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		camFollow.y -= GRID_SIZE * 2; 
		add(camFollow);
		FlxG.camera.follow(strumLine);
	}

	// var stepperLength:FlxUINumericStepper; // it gonna break a lot of stuff and nobody should use it anyway
	var check_mustHitSection:FlxUICheckBox;
	var check_gfSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		// stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		// stepperLength.value = _song.notes[curSection].lengthInSteps;
		// stepperLength.name = "section_length";

		// var stepperLengthLabel = new FlxText(74,10,'Section Length (in steps)');

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(230, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(295,132,'sections back');

		var copyfromButton:FlxUIButton = new FlxUIButton(10, 130, "Copy from section", function(){copySection(Std.int(stepperCopy.value),false);});
		copyfromButton.resize(100,20);
		var replacefromButton:FlxUIButton = new FlxUIButton(120, 130, "Replace from section", function(){copySection(Std.int(stepperCopy.value),true);});
		replacefromButton.resize(100,20);

		var CopyButton:FlxUIButton = new FlxUIButton(10, 150, "Copy section", function(){SectiontoCopy = curSection;});
		CopyButton.resize(100,20);
		var PasteButton:FlxUIButton = new FlxUIButton(120, 150, "Paste section", function(){copySection(curSection - SectiontoCopy,false);});
		PasteButton.resize(100,20);
		var ReplaceButton:FlxUIButton = new FlxUIButton(230, 150, "Replace section", function(){copySection(curSection - SectiontoCopy,true);});
		ReplaceButton.resize(100,20);

		var clearSectionButton:FlxUIButton = new FlxUIButton(10, 170, "Clear Section", clearSection);
		clearSectionButton.resize(100,20);
		var clearSectionOppButton:FlxUIButton = new FlxUIButton(120, 170, "Clear Opp", clearSectionOpp);
		clearSectionOppButton.resize(100,20);
		var clearSectionBFButton:FlxUIButton = new FlxUIButton(230, 170, "Clear BF", clearSectionBF);
		clearSectionBFButton.resize(100,20);

		var swapSection:FlxUIButton = new FlxUIButton(10, 190, "Swap Section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				_song.notes[curSection].sectionNotes[i][1] = (_song.notes[curSection].sectionNotes[i][1] + keyAmmo[tempMania]) % (keyAmmo[tempMania] * 2);
			}
			updateGrid();
		});
		swapSection.resize(100,20);
		var Warnlabel = new FlxText(10,275,0,'This can take some time.\nif there alot of note save before click. you can ran ouf of ram and crash');
		var replaceSectionNoteTypeButton = new FlxUIButton(10, 300, "Replace Note Type",replaceNoteType);
		replaceSectionNoteTypeButton.resize(100,25);
		var replaceDadNoteTypeButton = new FlxUIButton(120, 300, "Replace Dad Note Type", replaceDadNoteType);
		replaceDadNoteTypeButton.resize(100,25);
		var replaceBFNoteTypeButton = new FlxUIButton(230, 300, "Replace BF Note Type", replaceBFNoteType);
		replaceBFNoteTypeButton.resize(100,25);

		check_mustHitSection = new FlxUICheckBox(10, 20, null, null, "Camera Points to P1?", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		check_gfSection = new FlxUICheckBox(10, 50, null, null, "GF section", 100);
		check_gfSection.name = 'check_gf';
		check_gfSection.checked = false;

		check_altAnim = new FlxUICheckBox(150, 20, null, null, "Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 80, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';
		var ReBuildBPMMapButton:FlxUIButton = new FlxUIButton(check_changeBPM.x + 80, check_changeBPM.y + 10, "Update BPM Map", function(){Conductor.mapBPMChanges(_song);});
		ReBuildBPMMapButton.resize(100,20);
		stepperSectionBPM = new FlxUINumericStepper(check_changeBPM.x, check_changeBPM.y + 20, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		// tab_group_section.add(stepperLength);
		// tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_gfSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(ReBuildBPMMapButton);
		tab_group_section.add(copyfromButton);
		tab_group_section.add(replacefromButton);
		tab_group_section.add(CopyButton);
		tab_group_section.add(PasteButton);
		tab_group_section.add(ReplaceButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(clearSectionOppButton);
		tab_group_section.add(clearSectionBFButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(Warnlabel);
		tab_group_section.add(replaceSectionNoteTypeButton);
		tab_group_section.add(replaceDadNoteTypeButton);
		tab_group_section.add(replaceBFNoteTypeButton);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var tab_group_note:FlxUI;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		var stepperSusLengthLabel = new FlxText(75,10,'Note Sustain Length');

		var notetypetxt = new FlxUIText(180,10,'Note Type');
		var dummyUIinput = new FlxUIInputText(notetypetxt.x , notetypetxt.y + 20, 70, '', 8);
		notetype1shit = new FlxUIInputText(notetypetxt.x , notetypetxt.y + 20, 70, FlxG.save.data.notetype[0], 8);
		notetype2shit = new FlxUIInputText(notetypetxt.x , notetype1shit.y + 20, 70, FlxG.save.data.notetype[1], 8);
		notetype3shit = new FlxUIInputText(notetypetxt.x , notetype2shit.y + 20, 70, FlxG.save.data.notetype[2], 8);
		notetype4shit = new FlxUIInputText(notetypetxt.x , notetype3shit.y + 20, 70, FlxG.save.data.notetype[3], 8);
		notetype5shit = new FlxUIInputText(notetypetxt.x , notetype4shit.y + 20, 70, FlxG.save.data.notetype[4], 8);
		notetype6shit = new FlxUIInputText(notetypetxt.x , notetype5shit.y + 20, 70, FlxG.save.data.notetype[5], 8);
		notetype7shit = new FlxUIInputText(notetypetxt.x , notetype6shit.y + 20, 70, FlxG.save.data.notetype[6], 8);
		notetype8shit = new FlxUIInputText(notetypetxt.x , notetype7shit.y + 20, 70, FlxG.save.data.notetype[7], 8);

		Exnotetype = new FlxUIInputText(0 , 0, 70, '0', 8);// this don't need to be show and is suppose to be hidden
		NoteTypeArray = [dummyUIinput,notetype1shit,notetype2shit,notetype3shit,notetype4shit,notetype5shit,notetype6shit,notetype7shit,notetype8shit,Exnotetype];
		anothertypingshit = dummyUIinput;

		forcehurtnote = new FlxUICheckBox(notetypetxt.x , notetype8shit.y + 20 ,null,null, 'Hurt note\nWill overwrite above', 150);
		inputtypeatint = new FlxUICheckBox(notetypetxt.x , forcehurtnote.y + 20 ,null,null, 'Input Note Type at int/array', 150);
		inputtypeatint.checked = FlxG.save.data.notetypeatInt;
		var clearnotetype = new FlxUIButton(180, inputtypeatint.y + 20,"Clear Note Type Box",function()
		{
			notetype1shit.text = "";
			notetype2shit.text = "";
			notetype3shit.text = "";
			notetype4shit.text = "";
			notetype5shit.text = "";
			notetype6shit.text = "";
			notetype7shit.text = "";
			notetype8shit.text = "";
		});
		clearnotetype.resize(150,25);

		var ammolabel = new FlxText(10,35,96,'Amount of Keys');
		var maniabutton1 = new FlxUIButton(10, ammolabel.y + 15,"1", function(){changemania(6);}); maniabutton1.resize(64,20);
		var maniabutton2 = new FlxUIButton(10, maniabutton1.y + 20,"2", function(){changemania(7);}); maniabutton2.resize(64,20);
		var maniabutton3 = new FlxUIButton(10, maniabutton2.y + 20,"3", function(){changemania(8);}); maniabutton3.resize(64,20);
		var maniabutton4 = new FlxUIButton(10, maniabutton3.y + 20,"4", function(){changemania(0);}); maniabutton4.resize(64,20);
		var maniabutton5 = new FlxUIButton(10, maniabutton4.y + 20,"5", function(){changemania(4);}); maniabutton5.resize(64,20);
		var maniabutton6 = new FlxUIButton(10, maniabutton5.y + 20,"6",function(){changemania(1);}); maniabutton6.resize(64,20);
		var maniabutton7 = new FlxUIButton(10, maniabutton6.y + 20,"7", function(){changemania(2);}); maniabutton7.resize(64,20);
		var maniabutton8 = new FlxUIButton(10, maniabutton7.y + 20,"8", function(){changemania(5);}); maniabutton8.resize(64,20);
		var maniabutton9 = new FlxUIButton(10, maniabutton8.y + 20,"9", function(){changemania(3);}); maniabutton9.resize(64,20);
		var maniabutton10 = new FlxUIButton(10, maniabutton9.y + 20,"10", function(){changemania(9);}); maniabutton10.resize(64,20);
		var maniabutton11 = new FlxUIButton(10, maniabutton10.y + 20,"11", function(){changemania(10);}); maniabutton11.resize(64,20);
		var maniabutton12 = new FlxUIButton(10, maniabutton11.y + 20,"12", function(){changemania(11);}); maniabutton12.resize(64,20);
		var maniabutton13 = new FlxUIButton(10, maniabutton12.y + 20,"13", function(){changemania(12);}); maniabutton13.resize(64,20);
		var maniabutton14 = new FlxUIButton(10, maniabutton13.y + 20,"14", function(){changemania(13);}); maniabutton14.resize(64,20);
		var maniabutton15 = new FlxUIButton(10, maniabutton14.y + 20,"15", function(){changemania(14);}); maniabutton15.resize(64,20);
		var maniabutton16 = new FlxUIButton(10, maniabutton15.y + 20,"16", function(){changemania(15);}); maniabutton16.resize(64,20);
		var maniabutton17 = new FlxUIButton(10, maniabutton16.y + 20,"17", function(){changemania(16);}); maniabutton17.resize(64,20);
		var maniabutton18 = new FlxUIButton(10, maniabutton17.y + 20,"18", function(){changemania(17);}); maniabutton18.resize(64,20);
		var maniabutton21 = new FlxUIButton(10, maniabutton18.y + 20,"21", function(){changemania(18);}); maniabutton21.resize(64,20);

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(ammolabel);
		tab_group_note.add(maniabutton1);
		tab_group_note.add(maniabutton2);
		tab_group_note.add(maniabutton3);
		tab_group_note.add(maniabutton4);
		tab_group_note.add(maniabutton5);
		tab_group_note.add(maniabutton6);
		tab_group_note.add(maniabutton7);
		tab_group_note.add(maniabutton8);
		tab_group_note.add(maniabutton9);
		tab_group_note.add(maniabutton10);
		tab_group_note.add(maniabutton11);
		tab_group_note.add(maniabutton12);
		tab_group_note.add(maniabutton13);
		tab_group_note.add(maniabutton14);
		tab_group_note.add(maniabutton15);
		tab_group_note.add(maniabutton16);
		tab_group_note.add(maniabutton17);
		tab_group_note.add(maniabutton18);
		tab_group_note.add(maniabutton21);
		tab_group_note.add(notetype1shit);
		tab_group_note.add(notetype2shit);
		tab_group_note.add(notetype3shit);
		tab_group_note.add(notetype4shit);
		tab_group_note.add(notetype5shit);
		tab_group_note.add(notetype6shit);
		tab_group_note.add(notetype7shit);
		tab_group_note.add(notetype8shit);
		tab_group_note.add(notetypetxt);
		tab_group_note.add(forcehurtnote);
		tab_group_note.add(inputtypeatint);
		tab_group_note.add(clearnotetype);

		UI_box.addGroup(tab_group_note);

/*
		player2 = new Character(0,FlxG.height - player2.height, _song.player2,false,1);
		player1 = new Character(player2.width * 0.2,FlxG.height - player1.height, _song.player1,true,0);

		player1.y = player1.y - player1.height;

		player2.setGraphicSize(Std.int(player2.width));
		player1.setGraphicSize(Std.int(player1.width));

		UI_box.add(player1);
		UI_box.add(player2);
*/
	}

	var noVocals:Bool = false;
	function loadSong():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		loadedInst = Sound.fromFile(if(onlinemod.OfflinePlayState.instFile != "") onlinemod.OfflinePlayState.instFile else 'assets/songs/' + _song.song.toLowerCase() + "/Inst.ogg");
		FlxG.sound.playMusic(loadedInst, 0.6,true);

		lastInst = onlinemod.OfflinePlayState.instFile;
		lastVoices = onlinemod.OfflinePlayState.voicesFile;
		lastChart = onlinemod.OfflinePlayState.chartFile;

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		if(_song.needsVoices || (onlinemod.OfflinePlayState.voicesFile != "" && FileSystem.exists(onlinemod.OfflinePlayState.voicesFile))){
			vocals = new FlxSound().loadEmbedded(Sound.fromFile(if(onlinemod.OfflinePlayState.voicesFile != "")  onlinemod.OfflinePlayState.voicesFile else ('assets/songs/' + _song.song.toLowerCase() + "/Voices.ogg")));
		}
		if(vocals == null){
			vocals = new FlxSound();
			noVocals = true;
		}

		FlxG.sound.list.add(vocals);
		FlxG.sound.music.pause();
		vocals.pause();
		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
			vocals.play();
		};
		FlxG.sound.music.time = sectionStartTime(lastSection);
		if(vocals != null) vocals.time = FlxG.sound.music.time;
		trace('Inst - ${loadedInst}');
		trace('Voices - ${vocals}');
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Camera Points to P1?':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
				case 'Camera Points to GF?':
					_song.notes[curSection].gfSection = check.checked;
					updateHeads();
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
				case "Alternate Animation":
					_song.notes[curSection].altAnim = check.checked;
				case "Show Note Type":
					FlxG.save.data.showNoteType = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			trace(wname);
			if (wname == 'section_length')
			{
				if (nums.value <= 4)
					nums.value = 4;
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = nums.value;
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote == null)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
			}else if (wname == 'song_vocalvol')
			{
				if (nums.value <= 0)
					nums.value = 0;
				vocals.volume = nums.value;
			}else if (wname == 'song_instvol')
			{
				if (nums.value <= 0)
					nums.value = 0;
				FlxG.sound.music.volume = nums.value;
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}

	function sectionStartTime(section:Int):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var doSnapShit:Bool = true;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.GRAVEACCENT) notetypeselect = 0;
		if (FlxG.keys.justPressed.ONE) notetypeselect = 1;
		if (FlxG.keys.justPressed.TWO) notetypeselect = 2;
		if (FlxG.keys.justPressed.THREE) notetypeselect = 3;
		if (FlxG.keys.justPressed.FOUR) notetypeselect = 4;
		if (FlxG.keys.justPressed.FIVE) notetypeselect = 5;
		if (FlxG.keys.justPressed.SIX) notetypeselect = 6;
		if (FlxG.keys.justPressed.SEVEN) notetypeselect = 7;
		if (FlxG.keys.justPressed.EIGHT) notetypeselect = 8;

		if (FlxG.keys.justPressed.NUMPADONE) {notetypeselect = 9;Exnotetype.text = "SNote0";}
		if (FlxG.keys.justPressed.NUMPADTWO) {notetypeselect = 9;Exnotetype.text = "SNote1";}
		if (FlxG.keys.justPressed.NUMPADTHREE) {notetypeselect = 9;Exnotetype.text = "SNote2";}
		if (FlxG.keys.justPressed.NUMPADFOUR) {notetypeselect = 9;Exnotetype.text = "SNote3";}
		if (FlxG.keys.justPressed.NUMPADFIVE) {notetypeselect = 9;Exnotetype.text = "SNote4";}
		if (FlxG.keys.justPressed.NUMPADSIX) {notetypeselect = 9;Exnotetype.text = "SNote5";}
		if (FlxG.keys.justPressed.NUMPADSEVEN) {notetypeselect = 9;Exnotetype.text = "SNote6";}
		if (FlxG.keys.justPressed.NUMPADEIGHT) {notetypeselect = 9;Exnotetype.text = "SNote7";}
		if (FlxG.keys.justPressed.NUMPADNINE) {notetypeselect = 9;Exnotetype.text = "SNote8";}

		if(_song.noteMetadata.badnoteScore != Std.int(hurtnotescore.value))_song.noteMetadata.badnoteScore = Std.int(hurtnotescore.value);
		if(_song.noteMetadata.badnoteHealth != hurtnotehealth.value)_song.noteMetadata.badnoteHealth = hurtnotehealth.value;

		anothertypingshit = NoteTypeArray[notetypeselect];
		curStep = recalculateSteps();

		doSnapShit = !FlxG.keys.pressed.SHIFT;

		gridBGAbove.alpha = gridBGEventAbove.alpha = gridBGBelow.alpha = gridBGEventBelow.alpha = 0.8;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		if (FlxG.keys.justPressed.F12)
			FlxG.save.data.showHelp = !FlxG.save.data.showHelp;
		if (FlxG.keys.justPressed.F2)
			curNoteInfoLOL.visible = !curNoteInfoLOL.visible;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps),0);

		if (FlxG.sound.music != null)
			{
				if(vocals.playing && (vocals.time > (FlxG.sound.music.time + 10) || vocals.time < FlxG.sound.music.time - 10)){
					vocals.time = FlxG.sound.music.time;
				}
				if (FlxG.sound.music.playing)
				{
					@:privateAccess
					{
						// The __backend.handle attribute is only available on native.
						lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, speed);
						try
						{
							// We need to make CERTAIN vocals exist and are non-empty
							// before we try to play them. Otherwise the game crashes.
							if (vocals != null && vocals.length > 0)
								lime.media.openal.AL.sourcef(vocals._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, speed);
						}
						catch (e){}
					}
				}
			}
		updateVisualiser(elapsed);

		if (playClaps)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (note.strumTime <= Conductor.songPosition && !claps.contains(note) && FlxG.sound.music.playing)
				{
					FlxG.overlap(strumLine, note, function(_, _)
					{
						if(!claps.contains(note))
						{
							claps.push(note);
							if(_song.notes[curSection].mustHitSection)
								FlxG.sound.play(
									if (FileSystem.exists('mods/hitSound.ogg')) Sound.fromFile('mods/hitSound.ogg')
									else Sound.fromFile('./assets/sounds/Normal_Hit.ogg'));
							else FlxG.sound.play(Paths.sound('SNAP'));
						}
					});
				}
			});
		}
		/* curRenderedNotes.forEach(function(note:Note) {
			if (strumLine.overlaps(note) && strumLine.y == note.y) // yandere dev type shit // i fix your crap. but the offset is fuck lol
			{
				if (_song.notes[curSection].mustHitSection)
					{
						if (note.noteData < keyAmmo[tempMania])
							player1.playAnim(Note.noteAnims[note.noteData % Note.noteAnims.length], true);
						if (note.noteData >= 4)
							player2.playAnim(Note.noteAnims[note.noteData % Note.noteAnims.length], true);
					}
					else
					{
						if (note.noteData < 4)
							player2.playAnim(Note.noteAnims[note.noteData % Note.noteAnims.length], true);
						if (note.noteData >= 4)
							player1.playAnim(Note.noteAnims[note.noteData % Note.noteAnims.length], true);
					}
			}
		}); */

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			while (_song.notes[curSection + 5] == null)
				addSection();
			changeSection(curSection + 1, false);
		}
		if (curSection != 0 && curStep < (16 * curSection) - 1)
			changeSection(curSection - 1, false);

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if(FlxG.mouse.justPressedRight){
			lastRMouseX = Std.int(FlxG.mouse.screenX);
			lastRMouseY = Std.int(FlxG.mouse.screenY);
		}

		if(FlxG.mouse.pressedRight && FlxG.mouse.justMoved){

			var mx = Std.int(FlxG.mouse.screenX);
			var my = Std.int(FlxG.mouse.screenY);

			camFollow.x+=lastRMouseX - mx;
			camFollow.y+=lastRMouseY - my;
			lastRMouseX = mx;
			lastRMouseY = my;
		}
		if(FlxG.mouse.justPressedMiddle) {camFollow.screenCenter(); camFollow.y -= GRID_SIZE * 2;}

		if(FlxG.mouse.y > gridBGBelow.y + (GRID_SIZE * 16)) WhichSectionToPlace = 2;
		else if(FlxG.mouse.y > gridBGBelow.y) WhichSectionToPlace = 1;
		else if(FlxG.mouse.y > gridBG.y) WhichSectionToPlace = 0;
		else if(FlxG.mouse.y > gridBGAbove.y + (GRID_SIZE * 16)) WhichSectionToPlace = -1;
		else if(FlxG.mouse.y > gridBGAbove.y) WhichSectionToPlace = -2;

		if(FlxG.mouse.pressed && FlxG.keys.pressed.SHIFT){
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
						deleteNote(note);
				});
			}
		}

		if (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(UI_box))
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBGAbove.y
					&& FlxG.mouse.y < gridBGBelow.y + gridBGBelow.height
					&& curSection + WhichSectionToPlace >= 0 && !FlxG.keys.pressed.SHIFT)
				{
					trace('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBGAbove.y
			&& FlxG.mouse.y < gridBGBelow.y + gridBGBelow.height
			&& curSection + WhichSectionToPlace >= 0)
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else if (FlxG.keys.pressed.ALT)
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / (altnotesnap / 16))) * (GRID_SIZE / (altnotesnap / 16));
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / (notesnap / 16))) * (GRID_SIZE / (notesnap / 16));
		}

		if (FlxG.keys.pressed.SHIFT && (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE))
			FlxG.switchState(new MainMenuState());
		else if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();

			if(FlxG.keys.pressed.CONTROL && curSection > 0){
				PlayState.sectionStart = true;
				changeSection(curSection, true);
				PlayState.songspeed = speed;
				PlayState.sectionStartPoint = curSection;
				PlayState.sectionStartTime = FlxG.sound.music.time - (sectionHasBfNotes(curSection) ? Conductor.crochet : 0);
			}
			else
			{
				PlayState.sectionStart = false;
				PlayState.songspeed = 1;
			}
			gotoPlaystate();
		}

		if (FlxG.keys.justPressed.E) changeNoteSustain(Conductor.stepCrochet * (FlxG.keys.pressed.SHIFT ? 4 : 1) * (FlxG.keys.pressed.ALT ? 0.5 : 1));
		if (FlxG.keys.justPressed.Q) changeNoteSustain(-Conductor.stepCrochet * (FlxG.keys.pressed.SHIFT ? 4 : 1) * (FlxG.keys.pressed.ALT ? 0.5 : 1));
		if (FlxG.keys.justPressed.F){
			FreeCam = !FreeCam;
			if(!FreeCam)
				FlxG.camera.follow(strumLine);
			else
				FlxG.camera.follow(camFollow);
		}
		if (FlxG.keys.justPressed.TAB){
			hideBox = !hideBox;
			FlxTween.tween(UI_box, {x: (hideBox ? -UI_box.width * 2 : 0),alpha: (hideBox ? 0 : 1)}, 0.1, {ease: FlxEase.quadInOut});
		}

		if (!typingShit.hasFocus && !(notetype1shit.hasFocus || notetype2shit.hasFocus || notetype3shit.hasFocus || notetype4shit.hasFocus) && !typingcharacter1shit.hasFocus && !typingcharacter2shit.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.Z && lastNote != null)
				{
					trace(curRenderedNotes.members.contains(lastNote) ? "delete note" : "add note");
					if (curRenderedNotes.members.contains(lastNote))
						deleteNote(lastNote);
					else
						addNote(lastNote);
				}
			}

			if (FlxG.keys.justPressed.RIGHT && FlxG.keys.pressed.CONTROL)
				{
					snapSelection++;
					var index = 10;
					if (snapSelection > 10)
						snapSelection = 10;
					if (snapSelection < 0)
						snapSelection = 0;
					for (v in deezNuts.keys())
					{
						if (index == snapSelection)
							notesnap = v;
						index--;
					}
				}
			if (FlxG.keys.justPressed.LEFT && FlxG.keys.pressed.CONTROL)
				{
					snapSelection--;
					if (snapSelection > 10)
						snapSelection = 10;
					if (snapSelection < 0)
						snapSelection = 0;
					var index = 10;
					for (v in deezNuts.keys())
					{
						if (index == snapSelection)
							notesnap = v;
						index--;
					}
				}

			if (FlxG.keys.justPressed.RIGHT && FlxG.keys.pressed.ALT && !FlxG.keys.pressed.SHIFT)
				{
					tempsnapSelection++;
					var index = 10;
					if (tempsnapSelection > 10)
						tempsnapSelection = 10;
					if (tempsnapSelection < 0)
						tempsnapSelection = 0;
					for (v in deezNuts.keys())
					{
						if (index == tempsnapSelection)
						{
							altnotesnap = v;
						}
						index--;
					}
				}
			if (FlxG.keys.justPressed.LEFT && FlxG.keys.pressed.ALT && !FlxG.keys.pressed.SHIFT)
				{
					tempsnapSelection--;
					if (tempsnapSelection > 10)
						tempsnapSelection = 10;
					if (tempsnapSelection < 0)
						tempsnapSelection = 0;
					var index = 10;
					for (v in deezNuts.keys())
					{
						if (index == tempsnapSelection)
						{
							altnotesnap = v;
						}
						index--;
					}
				}

			if (FlxG.keys.justPressed.RBRACKET)
				{
					FlxG.camera.zoom += 0.25;
					showTempmessage("Zoom: "+ FlxG.camera.zoom);
				}
			if (FlxG.keys.justPressed.LBRACKET)
				{
					FlxG.camera.zoom -= 0.25;
					showTempmessage("Zoom: "+ FlxG.camera.zoom);
				}

			if (FlxG.keys.pressed.SHIFT){
				if (FlxG.keys.justPressed.RIGHT)
					speed += 0.05 * (FlxG.keys.pressed.ALT ? 5 : 1);
				else if (FlxG.keys.justPressed.LEFT)
					speed -= 0.05 * (FlxG.keys.pressed.ALT ? 5 : 1);
				if (FlxG.keys.justPressed.D)
					changeSection(curSection + Std.int(ShiftJumpModbox.value));
				if (FlxG.keys.justPressed.A)
					changeSection(curSection - Std.int(ShiftJumpModbox.value));
				if (speed > 5)
					speed = 5;
				if (speed < 0.1)
					speed = 0.1;
			}else if(!FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.ALT){
				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + 1);
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - 1);
			}
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT){
						lastSection = curSection;
						resetSection(true);
					}
				else
					resetSection();
			}

			
			if (FlxG.sound.music.time < 0 || curStep < 0)
				FlxG.sound.music.time = 0;

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				claps.splice(0, claps.length);

				var stepMs = curStep * Conductor.stepCrochet;

				if (doSnapShit)
					FlxG.sound.music.time = stepMs - (FlxG.mouse.wheel * Conductor.stepCrochet / snap);
				else
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);

				vocals.time = FlxG.sound.music.time;
			}
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S){
				if (FlxG.keys.pressed.ALT)
					saveQBP();
				else if (FlxG.keys.pressed.SHIFT || lastPath == null || lastPath == '')
					saveLevelAs();
				else
					saveLevel();
			}
			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S || FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				claps.splice(0, claps.length);

				var daTime:Float = 700 * FlxG.elapsed;

				if (FlxG.keys.pressed.W || FlxG.keys.pressed.UP)
					FlxG.sound.music.time -= daTime;
				else
					FlxG.sound.music.time += daTime;

				vocals.time = FlxG.sound.music.time;
			}
		}

		_song.bpm = tempBpm;

		bpmTxt.text = FlxMath.roundDecimal(Conductor.songPosition / 1000, 2) + ' / ' + FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2) + '(' + FlxMath.roundDecimal((Conductor.songPosition / FlxG.sound.music.length) * 100, 2) + '%)'
			+ '\nSection: ' + curSection
			+ '\nCurStep: ' + curStep
			+ '\nCurBeat: ' + curBeat
			+ "\nSpeed: " + HelperFunctions.truncateFloat(speed, 2)
			+ '\nCurrent Section Copy: ${SectiontoCopy}'
			+ "\n\nSnap: " + notesnap
			+ '\nAlt Snap: ' + altnotesnap
			+ '\n' + (doSnapShit ? "Snap enabled" : "Snap disabled")
			+ '\nCurrent Note Type[${notetypeselect}]: ' + (notetypeselect == 0 ? 'None' : anothertypingshit.text)
			+ '\n' + (tempMania != _song.mania ? 'Song Mania: ${_song.mania} / Temp Mania: ${tempMania}' : '')
			+ '\n' + (FlxG.save.data.showHelp ? '1-8 : to select note type\nGaveaccent "`": Disable Note Type\nShift + Left/Right : Change playback speed\nCTRL + Left/Right : Change Snap\nALT-Left/Right : Change Alt Snap\nHold Alt : for Alt Snap\nHold Shift : Disable Snap\nTab : Hide UI Box\nF : Toggle FreeCam\nHold Right Click : To Move Cam\nMiddle Click : Recenter Cam\nLeft Bracket "[" : Zoom Out\nRight Bracket "]" : Zoom In\nEnter : To Play Chart\nCTRL + Enter : To Play This Section\nF2 : Show/Hide Currently Select Note Info\nPress F12 to hide/show this!' : "")
			+ '\n';
		if(curSelectedNote != null) curNoteInfoLOL.text = 'Current Select Note Info'
		+ (curSelectedNote[0] != null ? '\nStrumTime: ${curSelectedNote[0]}' : '')
		+ (curSelectedNote[1] != null ? '\nNoteData: ${curSelectedNote[1]}' : '')
		+ (curSelectedNote[2] != null ? curSelectedNote[1] == -1 ? '\nEvent Note Type: ${curSelectedNote[2]}' : '\nSustain Length: ${curSelectedNote[2]} (${HelperFunctions.truncateFloat(curSelectedNote[2] / Conductor.stepCrochet,2)})' : '')
		+ (curSelectedNote[3] != null ? curSelectedNote[1] == -1 ? '\nVar: ${curSelectedNote[3]}' : '\nNote Type: ${curSelectedNote[3]}' : '')
		+ '\nRawNote: ${curSelectedNote}'
		+ '\n';
		super.update(elapsed);
	}

	function loadAudioBuffer() {
		audioBuffers[0] = AudioBuffer.fromFile(if(onlinemod.OfflinePlayState.instFile != "") onlinemod.OfflinePlayState.instFile else ('assets/songs/' + _song.song.toLowerCase() + "/Inst.ogg"));
		audioBuffers[1] = AudioBuffer.fromFile(if(onlinemod.OfflinePlayState.voicesFile != "") onlinemod.OfflinePlayState.voicesFile else ('assets/songs/' + _song.song.toLowerCase() + "/Voices.ogg"));
	}

	public static var lastInst:String = "";
	public static var lastVoices:String = "";
	public static var lastChart:String = "";
	var waveformPrinted:Bool = true;
	var audioBuffers:Array<AudioBuffer> = [null, null];
	function updateVisualiser(e:Float){
		var checkForVoices:Int = (if(waveformUseInstrumental.checked) 0 else 1);
		if(!waveformEnabled.checked || audioBuffers[checkForVoices] == null) {
			return;
		}
		var vol = .0;
		if(FlxG.sound.music.playing){

			var sampleMult:Float = audioBuffers[checkForVoices].sampleRate / 44100;
			var index:Int = Std.int(FlxG.sound.music.time * 44.100 * sampleMult);
			vol = audioBuffers[checkForVoices].data.toBytes().getUInt16(index * 4) / 65535;
		}

		visualiser.members[1].scale.x = FlxMath.lerp(visualiser.members[1].scale.x,vol,e * 2.5);
		// visualiser.members[0].scale.x = (audioBuffers[checkForVoices].data.toBytes().getUInt16(index * 4) / 65535 );
	}
	function updateWaveform() {
		if(waveformPrinted) {
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * (keyAmmo[tempMania] * 2)), Std.int(gridBG.height), 0x00FFFFFF);
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, gridBG.width, gridBG.height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		var checkForVoices:Int = 1;
		if(waveformUseInstrumental.checked) checkForVoices = 0;

		if(!waveformEnabled.checked || audioBuffers[checkForVoices] == null) {
			return;
		}

		var sampleMult:Float = audioBuffers[checkForVoices].sampleRate / 44100;
		var index:Int = Std.int(sectionStartTime(curSection) * 44.0875 * sampleMult);
		var drawIndex:Int = 0;

		var steps:Int = _song.notes[curSection].lengthInSteps;
		if(Math.isNaN(steps) || steps < 1) steps = 16;
		var samplesPerRow:Int = Std.int(((Conductor.stepCrochet * steps * 1.1 * sampleMult) / 16));
		if(samplesPerRow < 1) samplesPerRow = 1;
		var waveBytes:Bytes = audioBuffers[checkForVoices].data.toBytes();
		
		var min:Float = 0;
		var max:Float = 0;
		while (index < (waveBytes.length - 1))
		{
			var byte:Int = waveBytes.getUInt16(index * 4);

			if (byte > 65535 / 2)
				byte -= 65535;

			var sample:Float = (byte / 65535);

			if (sample > 0)
			{
				if (sample > max)
					max = sample;
			}
			else if (sample < 0)
			{
				if (sample < min)
					min = sample;
			}

			if ((index % samplesPerRow) == 0)
			{
				var pixelsMin:Float = Math.abs(min * (GRID_SIZE * (keyAmmo[tempMania] * 2)));
				var pixelsMax:Float = max * (GRID_SIZE * (keyAmmo[tempMania] * 2));
				waveformSprite.pixels.fillRect(new Rectangle(Std.int((GRID_SIZE * keyAmmo[tempMania]) - pixelsMin), drawIndex, pixelsMin + pixelsMax, 1), if(checkForVoices == 1)FlxColor.BLUE else FlxColor.RED);
				drawIndex++;

				min = 0;
				max = 0;

				if(drawIndex > gridBG.height) break;
			}

			index++;
		}
		waveformPrinted = true;
	}

	function changemania(newmania:Int)
	{
		if(FlxG.keys.pressed.SHIFT){
			if(keyAmmo[newmania] > keyAmmo[_song.mania]){
				showTempmessage('Mid Song Change Mania can not be bigger than Song overall mania : ${keyAmmo[newmania]} > ${keyAmmo[_song.mania]}');
				return;
			}
			_song.notes[curSection].changeMania = newmania;
			showTempmessage('Mark Section ${curSection} For Mid Song Change Mania to ${newmania}');
		}
		tempMania = newmania;
		if(!FlxG.keys.pressed.SHIFT)_song.mania = newmania;
		_song.keyCount = keyAmmo[_song.mania];
		updateGrid();
		updateWaveform();
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	override function beatHit() 
	{
		super.beatHit();
		if(playBeat && FlxG.sound.music.playing) // Weird ifstatement but don't change hasClapped unless playBeatClaps is true
			FlxG.sound.play(Sound.fromFile('./assets/shared/sounds/CLAP.ogg'));
		leftIcon.bounce(60 / Conductor.bpm);
		rightIcon.bounce(60 / Conductor.bpm);
		gfIcon.bounce(60 / Conductor.bpm);
		// player1.dance();
		// player2.dance();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime(curSection);

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateHeads();
		updateSectionUI();
		updateWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSection = sec;

			if (updateMusic)
			{
				FlxG.sound.music.time = sectionStartTime(curSection);
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
			updateWaveform();
			updateHeads();
		}
	}

	function copySection(?sectionNum:Int = 1,replace:Bool = false)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);
		if(replace)_song.notes[daSec].sectionNotes = [];

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3], note[4]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		// stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_gfSection.checked = (sec.gfSection != null ? sec.gfSection : false);
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			gfIcon.setPosition(gridBG.x, -100);
			leftIcon.setPosition(gridBG.x, -100);
			rightIcon.setPosition(gridBG.x + (gridBG.width / 2), -100);
			gfIcon.visible = check_gfSection.checked;
			leftIcon.visible = !check_gfSection.checked;
			rightIcon.visible = true;
		}
		else
		{
			gfIcon.setPosition(gridBG.x, -100);
			rightIcon.setPosition(gridBG.x, -100);
			leftIcon.setPosition(gridBG.x + (gridBG.width / 2), -100);
			gfIcon.visible = check_gfSection.checked;
			rightIcon.visible = !check_gfSection.checked;
			leftIcon.visible = true;
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		if (gridBG.width != GRID_SIZE * (keyAmmo[tempMania] * 2))
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[tempMania] * 2), GRID_SIZE * 16);
				gridBG.screenCenter(X);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[tempMania] * 2), GRID_SIZE * 32);
				gridBGAbove.screenCenter(X);
				gridBGAbove.y -= GRID_SIZE * 32;
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[tempMania] * 2), GRID_SIZE * 32);
				gridBGBelow.screenCenter(X);
				gridBGBelow.y += GRID_SIZE * 16;
				add(gridBGBelow);
				updateHeads();

				visualiser.x = gridBG.x + gridBG.width + 10;
				waveformSprite.x = gridEventBlackLine.x = gridBG.x;
				gridBGEvent.x = gridBGEventAbove.x = gridBGEventBelow.x = gridBG.x - GRID_SIZE;
			}

		CoolUtil.clearFlxGroup(curRenderedNotes);
		CoolUtil.clearFlxGroup(curRenderedSustains);

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		var lastSectionInfo:Array<Dynamic> = null;
		if (_song.notes[curSection - 1] != null)
			lastSectionInfo = _song.notes[curSection - 1].sectionNotes;

		var AnotherlastSectionInfo:Array<Dynamic> = null;
		if (_song.notes[curSection - 2] != null)
			AnotherlastSectionInfo = _song.notes[curSection - 2].sectionNotes;

		var nextSectionInfo:Array<Dynamic> = null;
		if (_song.notes[curSection + 1] != null)
			nextSectionInfo = _song.notes[curSection + 1].sectionNotes;

		var AnothernextSectionInfo:Array<Dynamic> = null;
		if (_song.notes[curSection + 2] != null)
			AnothernextSectionInfo = _song.notes[curSection + 2].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
			Conductor.changeBPM(_song.notes[curSection].bpm);
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daStrumTime = i[0];
			var daNoteInfo = i[1];
			var daSus = i[2];
			var daType = i[3];
			if (tempMania != _song.mania && daNoteInfo >= keyAmmo[tempMania]) daNoteInfo = daNoteInfo % keyAmmo[_song.mania] + keyAmmo[tempMania];
			var note:Note = new Note(daStrumTime, daNoteInfo, null, false, true, daType, i[4]);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE);
			note.updateHitbox();
			note.x = gridBG.x + Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps),0));

			if (curSelectedNote != null)
				if (curSelectedNote[0] == note.strumTime)
					lastNote = note;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}

		if (curSection > 0)
			{
				for (i in lastSectionInfo)
					{
						var daNoteInfo = i[1];
						var daStrumTime = i[0];
						var daSus = i[2];
						var daType = i[3];
						if (tempMania != _song.mania && daNoteInfo >= keyAmmo[tempMania]) daNoteInfo = daNoteInfo % keyAmmo[_song.mania] + keyAmmo[tempMania];
						var note:Note = new Note(daStrumTime, daNoteInfo, null, false, true, daType, i[4]);
						note.sustainLength = daSus;
						note.setGraphicSize(GRID_SIZE);
						note.updateHitbox();
						note.x = gridBGAbove.x + Math.floor(daNoteInfo * GRID_SIZE);
						note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection - 1)) % (Conductor.stepCrochet * _song.notes[curSection - 1].lengthInSteps),-GRID_SIZE * 16));
						note.alpha = 0.7;
			
						if (curSelectedNote != null)
							if (curSelectedNote[0] == note.strumTime)
								lastNote = note;
			
						curRenderedNotes.add(note);
			
						if (daSus > 0)
						{
							var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
								note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
							curRenderedSustains.add(sustainVis);
						}
					}
			}

		if (curSection > 1)
			{
				for (i in AnotherlastSectionInfo)
					{
						var daNoteInfo = i[1];
						var daStrumTime = i[0];
						var daSus = i[2];
						var daType = i[3];
						if (tempMania != _song.mania && daNoteInfo >= keyAmmo[tempMania]) daNoteInfo = daNoteInfo % keyAmmo[_song.mania] + keyAmmo[tempMania];
						var note:Note = new Note(daStrumTime, daNoteInfo, null, false, true, daType, i[4]);
						note.sustainLength = daSus;
						note.setGraphicSize(GRID_SIZE);
						note.updateHitbox();
						note.x = gridBGAbove.x + Math.floor(daNoteInfo * GRID_SIZE);
						note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection - 2)) % (Conductor.stepCrochet * _song.notes[curSection - 2].lengthInSteps),-GRID_SIZE * 32));
						note.alpha = 0.7;
			
						if (curSelectedNote != null)
							if (curSelectedNote[0] == note.strumTime)
								lastNote = note;
			
						curRenderedNotes.add(note);
			
						if (daSus > 0)
						{
							var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
								note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
							curRenderedSustains.add(sustainVis);
						}
					}
			}

		for (i in nextSectionInfo)
			{
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daType = i[3];
				if (tempMania != _song.mania && daNoteInfo >= keyAmmo[tempMania]) daNoteInfo = daNoteInfo % keyAmmo[_song.mania] + keyAmmo[tempMania];
				var note:Note = new Note(daStrumTime, daNoteInfo, null, false, true, daType, i[4]);
				note.sustainLength = daSus;
				note.setGraphicSize(GRID_SIZE);
				note.updateHitbox();
				note.x = gridBGBelow.x + Math.floor(daNoteInfo * GRID_SIZE);
				note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection + 1)) % (Conductor.stepCrochet * _song.notes[curSection + 1].lengthInSteps),GRID_SIZE * 16));
				note.alpha = 0.7;
	
				if (curSelectedNote != null)
					if (curSelectedNote[0] == note.strumTime)
						lastNote = note;
	
				curRenderedNotes.add(note);
	
				if (daSus > 0)
				{
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
					curRenderedSustains.add(sustainVis);
				}
			}

		for (i in AnothernextSectionInfo)
			{
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daType = i[3];
				if (tempMania != _song.mania && daNoteInfo >= keyAmmo[tempMania]) daNoteInfo = daNoteInfo % keyAmmo[_song.mania] + keyAmmo[tempMania];
				var note:Note = new Note(daStrumTime, daNoteInfo, null, false, true, daType, i[4]);
				note.sustainLength = daSus;
				note.setGraphicSize(GRID_SIZE);
				note.updateHitbox();
				note.x = gridBGBelow.x + Math.floor(daNoteInfo * GRID_SIZE);
				note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection + 2)) % (Conductor.stepCrochet * _song.notes[curSection + 2].lengthInSteps),GRID_SIZE * 32));
				note.alpha = 0.7;
	
				if (curSelectedNote != null)
					if (curSelectedNote[0] == note.strumTime)
						lastNote = note;
	
				curRenderedNotes.add(note);
	
				if (daSus > 0)
				{
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
					curRenderedSustains.add(sustainVis);
				}
			}
		}
	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function sectionHasBfNotes(section:Int):Bool{
		var notes = _song.notes[section].sectionNotes;
		var mustHit = _song.notes[section].mustHitSection;

		for(x in notes){
			if(mustHit) { if(x[1] < 4) { return true; } }
			else { if(x[1] > 3) { return true; } }
		}

		return false;

	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;
		if(note.noteData >= keyAmmo[tempMania]) note.noteData = note.noteData % keyAmmo[tempMania] + keyAmmo[_song.mania];
		for (i in _song.notes[curSection + WhichSectionToPlace].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % keyAmmo[_song.mania] == note.noteData)
			{
				curSelectedNote = _song.notes[curSection + WhichSectionToPlace].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		// updateGrid(); // why the hell do i need to update grid if i just select a note!?
		// updateNoteUI();
	}


	function deleteNote(note:Note):Void
		{
			lastNote = note;
			if(note.noteData >= keyAmmo[tempMania]) note.noteData = note.noteData % keyAmmo[tempMania] + keyAmmo[_song.mania];
			for (i in _song.notes[curSection + WhichSectionToPlace].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] % keyAmmo[_song.mania] == note.noteData)
				{
					_song.notes[curSection + WhichSectionToPlace].sectionNotes.remove(i);
				}
			}
	
			updateGrid();
		}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSectionBF():Void
	{

		var newSectionNotes:Array<Dynamic> = [];

		if(_song.notes[curSection].mustHitSection){
			for(x in _song.notes[curSection].sectionNotes){
				if(x[1] >= keyAmmo[_song.mania])
					newSectionNotes.push(x);
			}
		}
		else{
			for(x in _song.notes[curSection].sectionNotes){
				if(x[1] < keyAmmo[_song.mania])
					newSectionNotes.push(x);
			}
		}


		_song.notes[curSection].sectionNotes = newSectionNotes;

		updateGrid();
	}

	function clearSectionOpp():Void
		{
	
			var newSectionNotes:Array<Dynamic> = [];
	
			if(_song.notes[curSection].mustHitSection){
				for(x in _song.notes[curSection].sectionNotes){
					if(x[1] < keyAmmo[_song.mania])
						newSectionNotes.push(x);
				}
			}
			else{
				for(x in _song.notes[curSection].sectionNotes){
					if(x[1] >= keyAmmo[_song.mania])
						newSectionNotes.push(x);
				}
			}
	
	
			_song.notes[curSection].sectionNotes = newSectionNotes;
	
			updateGrid();
		}

	function replaceNoteType(){
		var type:Dynamic = 0;
		var amount:Int = 0;
		var LeatherNoteType:Dynamic = null;
		if(forcehurtnote.checked && !inputtypeatint.checked)type = "hurt note"; else type = anothertypingshit.text;

		if(inputtypeatint.checked){
			var numinarray:Array<Int> = [];
			if(anothertypingshit.text != "" && anothertypingshit.text != " ")
			{
				var numtype = anothertypingshit.text.split(",");
				for(char in numtype)
				{
					numinarray.push(Std.parseInt(char));
				}
			}
			if(numinarray.length > 1) type = numinarray; else type = Std.parseInt(type);
			if(forcehurtnote.checked) LeatherNoteType = "death";
		}
		for (i in 0..._song.notes[curSection].sectionNotes.length)
		{
			var note = _song.notes[curSection].sectionNotes[i];
			note[3] = type;
			if(LeatherNoteType != null) note[4] = LeatherNoteType;
			_song.notes[curSection].sectionNotes[i] = note;
			amount++;
		}
		updateGrid();
		showTempmessage('Replace ${amount} Note with Note Type ' + (Std.isOfType(type,String) ? '"${type}"' : type));
	}

	function replaceDadNoteType(){
		var type:Dynamic = 0;
		var amount:Int = 0;
		var LeatherNoteType:Dynamic = null;
		if(forcehurtnote.checked && !inputtypeatint.checked)type = "hurt note"; else type = anothertypingshit.text;

		if(inputtypeatint.checked){
			var numinarray:Array<Int> = [];
			if(anothertypingshit.text != "" && anothertypingshit.text != " ")
			{
				var numtype = anothertypingshit.text.split(",");
				for(char in numtype)
				{
					numinarray.push(Std.parseInt(char));
				}
			}
			if(numinarray.length > 1) type = numinarray; else type = Std.parseInt(type);
			if(forcehurtnote.checked) LeatherNoteType = "death";
		}
		if(!_song.notes[curSection].mustHitSection){
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				if(_song.notes[curSection].sectionNotes[i][1] < keyAmmo[_song.mania]){
					var note = _song.notes[curSection].sectionNotes[i];
					note[3] = type;
					if(LeatherNoteType != null) note[4] = LeatherNoteType;
					_song.notes[curSection].sectionNotes[i] = note;
					amount++;
				}
			}
		}
		else{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				if(_song.notes[curSection].sectionNotes[i][1] >= keyAmmo[_song.mania]){
					var note = _song.notes[curSection].sectionNotes[i];
					note[3] = type;
					if(LeatherNoteType != null) note[4] = LeatherNoteType;
					_song.notes[curSection].sectionNotes[i] = note;
					amount++;
				}
			}
		}
		updateGrid();
		showTempmessage('Replace ${amount} Note with Note Type ' + (Std.isOfType(type,String) ? '"${type}"' : type));
	}

	function replaceBFNoteType(){
		var type:Dynamic = 0;
		var amount:Int = 0;
		var LeatherNoteType:Dynamic = null;
		if(forcehurtnote.checked && !inputtypeatint.checked)type = "hurt note"; else type = anothertypingshit.text;

		if(inputtypeatint.checked){
			var numinarray:Array<Int> = [];
			if(anothertypingshit.text != "" && anothertypingshit.text != " ")
			{
				var numtype = anothertypingshit.text.split(",");
				for(char in numtype)
				{
					numinarray.push(Std.parseInt(char));
				}
			}
			if(numinarray.length > 1) type = numinarray; else type = Std.parseInt(type);
			if(forcehurtnote.checked) LeatherNoteType = "death";
		}
		if(_song.notes[curSection].mustHitSection){
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				if(_song.notes[curSection].sectionNotes[i][1] < keyAmmo[_song.mania]){
					var note = _song.notes[curSection].sectionNotes[i];
					note[3] = type;
					if(LeatherNoteType != null) note[4] = LeatherNoteType;
					_song.notes[curSection].sectionNotes[i] = note;
					amount++;
				}
			}
		}
		else{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				if(_song.notes[curSection].sectionNotes[i][1] >= keyAmmo[_song.mania]){
					var note = _song.notes[curSection].sectionNotes[i];
					note[3] = type;
					if(LeatherNoteType != null) note[4] = LeatherNoteType;
					_song.notes[curSection].sectionNotes[i] = note;
					amount++;
				}
			}
		}
		updateGrid();
		showTempmessage('Replace ${amount} Note with Note Type ' + (Std.isOfType(type,String) ? '"${type}"' : type));
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function newSection(lengthInSteps:Int = 16,mustHitSection:Bool = false,altAnim:Bool = true):SwagSection
		{
			var sec:SwagSection = {
				lengthInSteps: lengthInSteps,
				bpm: _song.bpm,
				changeBPM: false,
				mustHitSection: mustHitSection,
				sectionNotes: [],
				typeOfSection: 0,
				altAnim: altAnim
			};

			return sec;
		}

	function shiftNotes(measure:Int=0,step:Int=0,ms:Int = 0,shiftEntireSong:Bool):Void
		{
			var newSong = [];
			
			var millisecadd = (((measure*4)+step/4)*(60000/_song.bpm))+ms;
			var totaladdsection = Std.int((millisecadd/(60000/_song.bpm)/4));
			trace(millisecadd,totaladdsection);
			if(millisecadd > 0)
				{
					for(i in 0...totaladdsection)
						{
							newSong.unshift(newSection());
						}
				}
			for (daSection1 in 0..._song.notes.length)
				{
					newSong.push(newSection(16,_song.notes[daSection1].mustHitSection,_song.notes[daSection1].altAnim));
				}
	
			for (daSection in 0...(_song.notes.length))
			{
				var aimtosetsection = daSection+Std.int(((shiftEntireSong || daSection > curSection ? totaladdsection : 0)));
				if(aimtosetsection<0) aimtosetsection = 0;
				newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
				newSong[aimtosetsection].altAnim = _song.notes[daSection].altAnim;
				//trace("section "+daSection);
				for(daNote in 0...(_song.notes[daSection].sectionNotes.length))
					{	
						var newtiming = _song.notes[daSection].sectionNotes[daNote][0]+millisecadd;
						if(newtiming<0)
						{
							newtiming = 0;
						}
						var futureSection = Math.floor(newtiming/4/(60000/_song.bpm));
						_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
						newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);
					}
	
			}
			//trace("DONE BITCH");
			_song.notes = newSong;
			updateGrid();
			updateSectionUI();
			updateNoteUI();
		}
	private function addNote(?n:Note):Void
	{
		try{

			var noteStrum = sectionStartTime(curSection) + getStrumTime(dummyArrow.y);
			var noteData = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);
			var noteSus = 0;
			var type:Dynamic = 0;
			var LeatherNoteType:Dynamic = null;
			if(forcehurtnote.checked && !inputtypeatint.checked)type = "hurt note"; else type = anothertypingshit.text;
			if (noteData >= keyAmmo[tempMania]) noteData = noteData % keyAmmo[tempMania] + keyAmmo[_song.mania];

			if(inputtypeatint.checked){
				var numinarray:Array<Int> = [];
				if(anothertypingshit.text != "" && anothertypingshit.text != " ")
				{
					var numtype = anothertypingshit.text.split(",");
					for(char in numtype)
					{
						numinarray.push(Std.parseInt(char));
					}
				}
				if(numinarray.length > 1) type = numinarray; else type = Std.parseInt(type);
				if(forcehurtnote.checked) LeatherNoteType = "death";
			}

			if (n != null)
				_song.notes[curSection + WhichSectionToPlace].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.type, n.rawNote[4]]);
			else if(LeatherNoteType != null)
				_song.notes[curSection + WhichSectionToPlace].sectionNotes.push([noteStrum, noteData, noteSus, type, LeatherNoteType]);
			else
				_song.notes[curSection + WhichSectionToPlace].sectionNotes.push([noteStrum, noteData, noteSus, type]);

			var thingy = _song.notes[curSection + WhichSectionToPlace].sectionNotes[_song.notes[curSection + WhichSectionToPlace].sectionNotes.length - 1];

			curSelectedNote = thingy;

			updateGrid();
			updateNoteUI();
			autosaveSong();
		}catch(e){
			MainMenuState.handleError('Error while placing note! ${e.message}');
		}
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float,offset:Int):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y + offset, gridBG.y + offset + (GRID_SIZE * 16));
	}

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.encode({
			"song": _song
		},"fancy",true);
		FlxG.save.flush();
	}
	var fd:FileDialog;
	public static var lastPath:String;

	private function saveQBP()
	{
		/* curNoteInfoLOL.text = 'Current Select Note Info' // it here not to use it or anything
		StrumTime: note[0]'
		NoteData: note[1]'
		Sustain Length: note[2] (${Math.floor(note[2] / Conductor.stepCrochet)})'
		Note Type: note[3]'
		*/
		if(_song.mania != 0) {showTempmessage('NO!'); return;}
		try{
			trace("Convert song to QBP file");
			var data:String = "$version=1.0\n$mapName=" + _song.song + "\n$musicAuth=\n$mapAuth=" + FlxG.save.data.nickname + "\n$mapDifficulty=Unknown\n$songFile=Song.ogg\n$tracks=8\n$realTracks=4\n\n";
			var SectionArray:Array<Array<String>> = [];
			for(Section in 1..._song.notes.length + 1){
				while(SectionArray.length < Section * 16){SectionArray.push(["-","-","-","-","-","-","-","-","/4"]);}
				var SectionBackward = _song.notes.length - Section; // Quatrack reading chart backward
				var _sectionStartTime = sectionStartTime(SectionBackward);
				for(i in 0..._song.notes[SectionBackward].sectionNotes.length){
					var note = _song.notes[SectionBackward].sectionNotes[i];
					var Step:Int = ((Section - 1) * 16) + 15 - Math.round((note[0] - _sectionStartTime) / Conductor.stepCrochet);
					var Data:Int = 0;
					if (_song.notes[SectionBackward].mustHitSection)
					{
						switch(note[1])
						{
							case 0: Data = 4;
							case 1: Data = 5;
							case 2: Data = 6;
							case 3: Data = 7;
							case 4: Data = 0;
							case 5: Data = 1;
							case 6: Data = 2;
							case 7: Data = 3;
						}
					}
					else
					{
						switch(note[1])
						{
							case 0: Data = 0;
							case 1: Data = 1;
							case 2: Data = 2;
							case 3: Data = 3;
							case 4: Data = 4;
							case 5: Data = 5;
							case 6: Data = 6;
							case 7: Data = 7;
						}
					}
					if(note[2] > 0){
						SectionArray[Step][Data] = "U";
						var HoldEnd:Int = Math.floor(note[2] / Conductor.stepCrochet);
						if(SectionArray[Step - HoldEnd][Data] == "U")SectionArray[Step - HoldEnd][Data] = "O"; else SectionArray[Step - HoldEnd][Data] = "H";
					}
					else SectionArray[Step][Data] = "O";
				}
				if(_song.notes[SectionBackward].changeBPM) SectionArray[(Section * 16) - 1].push(";!" + _song.notes[SectionBackward].bpm);
			}
			trace('Writing Data to File');
			for(Step in 0...SectionArray.length){
				data += SectionArray[Step].join("") + '\n';
			}
			data += ">0\n";
			if(FlxG.save.data.downscroll)
				data += "# "; // leave the modchart in but comment it out just cuz
				data += "[1,2,3,4,5,6,7,8]r,180;[1,2,3,4,5,6,7,8]p,0,-630; # UpScroll\n";
			// if(FlxG.save.data.middleScroll)
				data += "[1,2,3,4]S,0.5,1;[1]p,-70,0;[2]p,-140,0;[3]p,-210,0;[4]p,-280,0; [1,2,3,4]T,10;(1,2,3,4)T,10; [5,6,7,8]p,-280,0; # Middle Scroll\n";
			data += "%x,x,x,x,L2,L1,R1,R2;!" + _song.bpm + ";\n";
			data += ">start";
			if ((data != null) && (data.length > 0))
			{// Not copied from FunkinVortex, dunno what you mean
				fd = new FileDialog();
				fd.onSelect.add(function(path){
				try{
					lastPath = path;
					onlinemod.OfflinePlayState.chartFile = path;}catch(e){return;}
					//Bodgey as hell but doesn't work otherwise
					sys.io.File.saveContent(path,data);
					showTempmessage('Saved Quatrack QBP File to ${path}');
				});
				fd.browse(FileDialogType.SAVE, 'qbp', sys.FileSystem.absolutePath(lastPath), "Save chart");
			}
		}catch(e){showTempmessage('Something error while Convert chart to QBP: ${e.message} \n Maybe somthing wrong in the chart? \n ${e.stack}');}
	}

	private function saveLevel()
	{
		try{
			FlxG.save.data.notetype = [notetype1shit.text,notetype2shit.text,notetype3shit.text,notetype4shit.text,notetype5shit.text,notetype6shit.text,notetype7shit.text,notetype8shit.text];
			FlxG.save.data.notetypeatInt = inputtypeatint.checked;
			_song.chartType = "FNF/Super-T";
			trace("Saving song...");
			var data:String = Json.encode(_song,"fancy",true);
			if ((data != null) && (data.length > 0))
			{// Not copied from FunkinVortex, dunno what you mean
				try{onlinemod.OfflinePlayState.chartFile = lastPath;}catch(e){return;}
				//Bodgey as hell but doesn't work otherwise
				sys.io.File.saveContent(lastPath,'{"song":' + data + "}");
				showTempmessage('Saved chart to ${lastPath}');
			}
		}catch(e){showTempmessage('Something error while saving chart: ${e.message}');}
	}

	private function saveLevelAs()
	{
		try{
			FlxG.save.data.notetype = [notetype1shit.text,notetype2shit.text,notetype3shit.text,notetype4shit.text,notetype5shit.text,notetype6shit.text,notetype7shit.text,notetype8shit.text];
			FlxG.save.data.notetypeatInt = inputtypeatint.checked;
			_song.chartType = "FNF/Super-T";
			trace("Saving song...");
			var data:String = Json.encode(_song,"fancy",true);
			if ((data != null) && (data.length > 0))
			{// Not copied from FunkinVortex, dunno what you mean
				fd = new FileDialog();
				fd.onSelect.add(function(path){
				try{
					lastPath = path;
					onlinemod.OfflinePlayState.chartFile = path;}catch(e){return;}
					//Bodgey as hell but doesn't work otherwise
					sys.io.File.saveContent(path,'{"song":' + data + "}");
					showTempmessage('Saved chart to ${path}');
				});
				fd.browse(FileDialogType.SAVE, 'json', sys.FileSystem.absolutePath(lastPath), "Save chart");
			}
		}catch(e){showTempmessage('Something error while saving chart: ${e.message}');}
	}

	function gotoPlaystate(){
		charting = true;
		switch(PlayState.stateType){
			case 2: LoadingState.loadAndSwitchState(new onlinemod.OfflinePlayState()); 
			case 4: LoadingState.loadAndSwitchState(new multi.MultiPlayState());
			case 5: LoadingState.loadAndSwitchState(new osu.OsuPlayState());
			default: LoadingState.loadAndSwitchState(new PlayState());
		}
	}
}