package;

import flixel.FlxCamera;
import flixel.addons.ui.FlxUIText;
import haxe.zip.Writer;
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
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
import lime.media.AudioBuffer;
import flash.geom.Rectangle;
import haxe.io.Bytes;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	public var playClaps:Bool = false;
	public static var charting:Bool = true;

	public var snap:Int = 1;
	public var notesnap:Int = 16;
	public var altnotesnap:Int = 16;
	public var deezNuts:Map<Int, Int> = new Map<Int, Int>(); // snap conversion map
	public var snapSelection = 3;
	public var tempsnapSelection = 3;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dad Battle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var writingNotesText:FlxText;
	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var waveformSprite:FlxSprite;
	var waveformEnabled:FlxUICheckBox;
	var waveformUseInstrumental:FlxUICheckBox;

	var gridBG:FlxSprite;
	var gridBGAbove:FlxSprite;
	var gridBGBelow:FlxSprite;

	var _song:SwagSong;
	var loadedVoices:FlxSound;
	var loadedInst:Sound;
	public static var voicesFile = "";
	public static var instFile = "";
	public var speed = 1.0;

	var typingShit:FlxInputText;
	var anothertypingshit:FlxInputText; // cuz i'm scary something gonna break
	var typingcharactershit:FlxInputText; // that right there a another one
	var forcehurtnote:FlxUICheckBox;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;
	var gridBlackLine:FlxSprite;
	var vocals:FlxSound = null;

	var player2:Character = new Character(0,0, "dad");
	var player1:Character = new Character(0,0, "bf");

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var keyAmmo:Array<Int> = [4, 6, 7, 9, 5, 8, 1, 2, 3, 21];

	private var lastNote:Note;
	var claps:Array<Note> = [];

	override function create()
	{
		curSection = lastSection;

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 1,
				validScore: false,
				mania: 0
			};
		}

		deezNuts.set(4, 1);
		deezNuts.set(8, 2);
		deezNuts.set(12, 3);
		deezNuts.set(16, 4);
		deezNuts.set(24, 6);
		deezNuts.set(32, 8);
		deezNuts.set(48, 12);
		deezNuts.set(64, 16);

		if (FlxG.save.data.showHelp == null)
			FlxG.save.data.showHelp = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);
		gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBGAbove);
		gridBGAbove.y -= gridBG.height;
		gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBGBelow);
		gridBGBelow.y += gridBG.height;

		waveformSprite = new FlxSprite((GRID_SIZE * keyAmmo[_song.mania]) - (GRID_SIZE * 4)).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		add(waveformSprite);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong();
		loadAudioBuffer();
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		leftIcon = new HealthIcon(_song.player1);
		rightIcon = new HealthIcon(_song.player2);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		bpmTxt = new FlxText(1100, 0, 0, "", 16);
		bpmTxt.alignment = LEFT;
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "ZAssets", label: "Extra Features"},
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 - 10;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		updateWaveform();

		add(curRenderedNotes);
		add(curRenderedSustains);

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong();
			loadAudioBuffer();
		});

		
		var restart = new FlxButton(10,140,"Reset Chart", function()
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

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSong.x, reloadSong.y + 30, 'load autosave', loadAutosave);
		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(74,65,'BPM');
		
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(74,80,'Scroll Speed');
		
		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 0.1, 1, 0.1, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(74, 95, 'Vocal Volume');
		
		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';


		var hitsounds = new FlxUICheckBox(10, stepperSongVol.y + 60, null, null, "Play hitsounds", 100);
		hitsounds.checked = false;
		hitsounds.callback = function()
		{
			playClaps = hitsounds.checked;
		};

		var stepperSongVolLabel = new FlxText(74, 110, 'Instrumental Volume');

		
		var shiftNoteDialLabel = new FlxText(10, 245, 'Shift Note FWD by (Section)');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 260, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';
		var shiftNoteDialLabel2 = new FlxText(10, 275, 'Shift Note FWD by (Step)');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 290, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';
		var shiftNoteDialLabel3 = new FlxText(10, 305, 'Shift Note FWD by (ms)');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 320, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';

		var shiftNoteButton:FlxButton = new FlxButton(10, 335, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value),Std.int(stepperShiftNoteDialstep.value),Std.int(stepperShiftNoteDialms.value));
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

		var player1 = new FlxUIInputText(10, 50, 120, _song.player1, 8);
		typingcharactershit = player1;

		var player1Label = new FlxText(10,30,64,'Player 1');

		var player2 = new FlxUIInputText(140, 50, 120, _song.player2, 8);
		typingcharactershit = player2;

		var player2Label = new FlxText(140,30,64,'Player 2');

		var acceptplayer1 = new FlxButton(10,70,'apply', function(){
		_song.player1 = player1.text;
		});
		var acceptplayer2 = new FlxButton(140,70,'apply', function(){
		_song.player2 = player2.text;
		});

		var jumpsectiontext = new FlxText(10,335,128,'Jump Section');
		var jumpsectionbox = new FlxUINumericStepper(jumpsectiontext.x,jumpsectiontext.y + 15, 1, 0, -1000, 1000,0);
		var jumpsectionbutton = new FlxButton(jumpsectionbox.x + 60,jumpsectionbox.y,'Jump', function(){changeSection(Std.int(jumpsectionbox.value));});

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
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
        tab_group_song.add(shiftNoteButton);
		tab_group_song.add(hitsounds);

		var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "ZAssets";
		tab_group_assets.add(player1);
		tab_group_assets.add(player2);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);
		tab_group_assets.add(acceptplayer1);
		tab_group_assets.add(acceptplayer2);
		tab_group_assets.add(waveformEnabled);
		tab_group_assets.add(waveformUseInstrumental);
		tab_group_assets.add(jumpsectiontext);
		tab_group_assets.add(jumpsectionbox);
		tab_group_assets.add(jumpsectionbutton);

		UI_box.addGroup(tab_group_song);
		UI_box.addGroup(tab_group_assets);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		var stepperLengthLabel = new FlxText(74,10,'Section Length (in steps)');

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174,132,'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + keyAmmo[_song.mania]) % (keyAmmo[_song.mania] * 2);
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Camera Points to P1?", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var tab_group_note:FlxUI;
	
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		writingNotesText = new FlxUIText(20,100, 0, "");
		writingNotesText.setFormat("Arial",20,FlxColor.WHITE,FlxTextAlign.LEFT,FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		var stepperSusLengthLabel = new FlxText(75,10,'Note Sustain Length');

		var notetypetxt = new FlxUIText(200,10,'Note Type');
		var notetypeinput = new FlxUIInputText(notetypetxt.x , notetypetxt.y + 20, 70, '', 8);
		anothertypingshit = notetypeinput;

		forcehurtnote = new FlxUICheckBox(notetypeinput.x , notetypeinput.y + 20 ,null,null, 'Hurt note\nWill overwrite above');

		var hurtnotescoretxt = new FlxUIText(150, 100, 'Hurtnote Score');
		var hurtnotescore = new FlxUINumericStepper(hurtnotescoretxt.x , hurtnotescoretxt.y + 20 , 100, _song.noteMetadata.badnoteScore, -1000000, 1000000);
		var hurtnotescoreapply = new FlxButton(hurtnotescore.x + 60 , hurtnotescore.y , 'apply', function(){_song.noteMetadata.badnoteScore = Std.int(hurtnotescore.value);});
		var hurtnotescorenote = new FlxUIText(hurtnotescore.x , hurtnotescore.y + 20 , 'note: add -10 on top of that');

		var hurtnotehealthtxt = new FlxUIText(hurtnotescorenote.x , hurtnotescorenote.y + 20 , 'Hurtnote Health');
		var hurtnotehealth = new FlxUINumericStepper(hurtnotehealthtxt.x , hurtnotehealthtxt.y + 20 , 0.01 , _song.noteMetadata.badnoteHealth, -2, 2, 2);
		var hurtnotehealthapply = new FlxButton(hurtnotehealth.x + 60 , hurtnotehealth.y , 'apply', function(){_song.noteMetadata.badnoteHealth = hurtnotehealth.value;});

		var ammolabel = new FlxText(10,35,64,'Amount of Keys');
		var m_check = new FlxButton(10, 165,"6",function()
		{
			_song.mania = 1;
			updateGrid();
			updateWaveform();
			trace('6 Keys pog');
		});
		var m_check2 = new FlxButton(10, 225,"9", function()
		{
			_song.mania = 3;
			updateGrid();
			updateWaveform();
			trace('9 Keys pog');
		});
		var m_check3 = new FlxButton(10, 145,"5", function()
		{
			_song.mania = 4;
			updateGrid();
			updateWaveform();
			trace('5 keys pog');
		});
		var m_check4 = new FlxButton(10, 185,"7", function()
		{
			_song.mania = 2;
			updateGrid();
			updateWaveform();
			trace('7 keys pog');
		});
		var m_check5 = new FlxButton(10, 205,"8", function()
		{
			_song.mania = 5;
			updateGrid();
			updateWaveform();
			trace('8 keys pog');
		});
		var m_check6 = new FlxButton(10, 65,"1", function()
		{
			_song.mania = 6;
			updateGrid();
			updateWaveform();
			trace('1 keys pog');
		});
		var m_check7 = new FlxButton(10, 85,"2", function()
		{
			_song.mania = 7;
			updateGrid();
			updateWaveform();
			trace('2 keys pog');
		});
		var m_check8 = new FlxButton(10, 105,"3", function()
		{
			_song.mania = 8;
			updateGrid();
			updateWaveform();
			trace('3 keys pog');
		});

		var m_check0 = new FlxButton(10, 125,"4", function()
		{
			_song.mania = 0;
			updateGrid();
			updateWaveform();
			trace('4 keys cringe');
		});

		var m_checkhell = new FlxButton(10, 245,"21", function()
		{
			_song.mania = 9;
			updateGrid();
			updateWaveform();
			trace('WTF 21 Keys!? STOP');
		});

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(ammolabel);
		tab_group_note.add(m_check0);
		tab_group_note.add(m_check);
		tab_group_note.add(m_check2);
		tab_group_note.add(m_check3);
		tab_group_note.add(m_check4);
		tab_group_note.add(m_check5);
		tab_group_note.add(m_check6);
		tab_group_note.add(m_check7);
		tab_group_note.add(m_check8);
		//tab_group_note.add(m_checkhell);
		tab_group_note.add(notetypeinput);
		tab_group_note.add(notetypetxt);
		tab_group_note.add(forcehurtnote);
		tab_group_note.add(hurtnotescoretxt);
		tab_group_note.add(hurtnotescore);
		tab_group_note.add(hurtnotescoreapply);
		tab_group_note.add(hurtnotescorenote);
		tab_group_note.add(hurtnotehealthtxt);
		tab_group_note.add(hurtnotehealth);
		tab_group_note.add(hurtnotehealthapply);

		UI_box.addGroup(tab_group_note);

		/*player2 = new Character(0,gridBG.y, _song.player2);
		player1 = new Boyfriend(player2.width * 0.2,gridBG.y + player2.height, _song.player1);

		player1.y = player1.y - player1.height;

		player2.setGraphicSize(Std.int(player2.width * 0.2));
		player1.setGraphicSize(Std.int(player1.width * 0.2));

		UI_box.add(player1);
		UI_box.add(player2);*/

	}

	function loadSong():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		loadedInst = Sound.fromFile(Paths.inst(_song.song));
		FlxG.sound.playMusic(loadedInst, 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Sound.fromFile(Paths.voices(_song.song)));
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
		};
		trace('Inst - ${loadedInst}');
		trace('Voices - ${vocals}');
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
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
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alternate Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
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
				Conductor.mapBPMChanges(_song);
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
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}else if (wname == 'song_vocalvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				vocals.volume = nums.value;
			}else if (wname == 'song_instvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
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

	var writingNotes:Bool = false;
	var doSnapShit:Bool = true;

	override function update(elapsed:Float)
	{
		updateHeads();
		UI_box.x = FlxG.width / 2 + 80;
		UI_box.y = 100;
		bpmTxt.x = UI_box.x + 300;
		gridBGAbove.y = gridBG.y - gridBG.height;
		gridBGBelow.y = gridBG.y + gridBG.height;
		gridBGAbove.alpha = 0.7;
		gridBGBelow.alpha = 0.7;

		curStep = recalculateSteps();

		if (FlxG.keys.pressed.SHIFT)doSnapShit = false; else doSnapShit = true;

		if (curSection == 0)
			gridBGAbove.alpha = 0;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		var left = false;
		var down = false;
		var up = false;
		var right = false;
		var leftO = false;
		var downO = false;
		var upO = false;
		var rightO = false;

		if (FlxG.keys.justPressed.F1)
			FlxG.save.data.showHelp = !FlxG.save.data.showHelp;

		var pressArray = [left, down, up, right, leftO, downO, upO, rightO];
		var delete = false;
		curRenderedNotes.forEach(function(note:Note)
			{
				if (strumLine.overlaps(note) && pressArray[Math.floor(Math.abs(note.noteData))])
				{
					deleteNote(note);
					delete = true;
					trace('deelte note');
				}
			});
		for (p in 0...pressArray.length)
		{
			var i = pressArray[p];
			if (i && !delete)
			{
				addNote(new Note(Conductor.songPosition,p));
			}
		}

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (FlxG.sound.music != null)
			{
				if (FlxG.sound.music.playing)
				{
					@:privateAccess
					{
						// The __backend.handle attribute is only available on native.
						lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, speed);
						try
						{
							// We need to make CERTAIN vocals exist and are non-empty
							// before we try to play them. Otherwise the game crashes.
							if (vocals != null && vocals.length > 0)
							{
								lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, speed);
							}
						}
						catch (e)
						{
							trace("failed to pitch vocals (probably cuz they don't exist)");
						}
					}
				}
			}

		if (playClaps)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.overlap(strumLine, note, function(_, _)
					{
						if(!claps.contains(note))
						{
							claps.push(note);
							FlxG.sound.play(Paths.sound('SNAP'));
						}
					});
				}
			});
		}
		/*curRenderedNotes.forEach(function(note:Note) {
			if (strumLine.overlaps(note) && strumLine.y == note.y) // yandere dev type shit
			{
				if (_song.notes[curSection].mustHitSection)
					{
						trace('must hit ' + Math.abs(note.noteData));
						if (note.noteData < 4)
						{
							switch (Math.abs(note.noteData))
							{
								case 2:
									player1.playAnim('singUP', true);
								case 3:
									player1.playAnim('singRIGHT', true);
								case 1:
									player1.playAnim('singDOWN', true);
								case 0:
									player1.playAnim('singLEFT', true);
							}
						}
						if (note.noteData >= 4)
						{
							switch (note.noteData)
							{
								case 6:
									player2.playAnim('singUP', true);
								case 7:
									player2.playAnim('singRIGHT', true);
								case 5:
									player2.playAnim('singDOWN', true);
								case 4:
									player2.playAnim('singLEFT', true);
							}
						}
					}
					else
					{
						trace('hit ' + Math.abs(note.noteData));
						if (note.noteData < 4)
						{
							switch (Math.abs(note.noteData))
							{
								case 2:
									player2.playAnim('singUP', true);
								case 3:
									player2.playAnim('singRIGHT', true);
								case 1:
									player2.playAnim('singDOWN', true);
								case 0:
									player2.playAnim('singLEFT', true);
							}
						}
						if (note.noteData >= 4)
						{
							switch (note.noteData)
							{
								case 6:
									player1.playAnim('singUP', true);
								case 7:
									player1.playAnim('singRIGHT', true);
								case 5:
									player1.playAnim('singDOWN', true);
								case 4:
									player1.playAnim('singLEFT', true);
							}
						}
					}
			}
		});*/

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null || _song.notes[curSection + 2] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
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
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else if (FlxG.keys.pressed.ALT)
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / (altnotesnap / 16))) * (GRID_SIZE / (altnotesnap / 16));
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / (notesnap / 16))) * (GRID_SIZE / (notesnap / 16));
		}

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();

			if(FlxG.keys.pressed.CONTROL && curSection > 0){
				PlayState.sectionStart = true;
				changeSection(curSection, true);
				PlayState.sectionStartPoint = curSection;
				PlayState.sectionStartTime = FlxG.sound.music.time - (sectionHasBfNotes(curSection) ? Conductor.crochet : 0);
			}

			gotoPlaystate();
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus && !anothertypingshit.hasFocus && !typingcharactershit.hasFocus)
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
					var index = 7;
					if (snapSelection > 7)
						snapSelection = 7;
					if (snapSelection < 0)
						snapSelection = 0;
					for (v in deezNuts.keys())
					{
						trace(v);
						if (index == snapSelection)
						{
							trace("found " + v + " at " + index);
							notesnap = v;
						}
						index--;
					}
					trace("new snap " + notesnap + " | " + snapSelection);
				}
				if (FlxG.keys.justPressed.LEFT && FlxG.keys.pressed.CONTROL)
				{
					snapSelection--;
					if (snapSelection > 7)
						snapSelection = 7;
					if (snapSelection < 0)
						snapSelection = 0;
					var index = 7;
					for (v in deezNuts.keys())
					{
						trace(v);
						if (index == snapSelection)
						{
							trace("found " + v + " at " + index);
							notesnap = v;
						}
						index--;
					}
					trace("new snap " + notesnap + " | " + snapSelection);
				}

			if (FlxG.keys.justPressed.RIGHT && FlxG.keys.pressed.ALT)
				{
					tempsnapSelection++;
					var index = 7;
					if (tempsnapSelection > 7)
						tempsnapSelection = 7;
					if (tempsnapSelection < 0)
						tempsnapSelection = 0;
					for (v in deezNuts.keys())
					{
						trace(v);
						if (index == tempsnapSelection)
						{
							trace("found " + v + " at " + index);
							altnotesnap = v;
						}
						index--;
					}
					trace("new Alt snap " + altnotesnap + " | " + tempsnapSelection);
				}
				if (FlxG.keys.justPressed.LEFT && FlxG.keys.pressed.ALT)
				{
					tempsnapSelection--;
					if (tempsnapSelection > 7)
						tempsnapSelection = 7;
					if (tempsnapSelection < 0)
						tempsnapSelection = 0;
					var index = 7;
					for (v in deezNuts.keys())
					{
						trace(v);
						if (index == tempsnapSelection)
						{
							trace("found " + v + " at " + index);
							altnotesnap = v;
						}
						index--;
					}
					trace("new Alt snap " + altnotesnap + " | " + tempsnapSelection);
				}

			if (FlxG.keys.justPressed.RBRACKET)
				FlxG.camera.zoom += 0.25;
			if (FlxG.keys.justPressed.LBRACKET)
				FlxG.camera.zoom -= 0.25;

			if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						speed += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						speed -= 0.1;
				if (FlxG.keys.justPressed.D)
					changeSection(curSection + 5);
				if (FlxG.keys.justPressed.A)
					changeSection(curSection - 5);
					if (speed > 5)
						speed = 5;
					if (speed <= 0.01)
						speed = 0.1;
				}else if(!FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.ALT)
			{
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
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
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


				trace(Conductor.stepCrochet / snap);

				if (doSnapShit)
					FlxG.sound.music.time = stepMs - (FlxG.mouse.wheel * Conductor.stepCrochet / snap);
				else
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				trace(stepMs + " + " + Conductor.stepCrochet / snap + " -> " + FlxG.sound.music.time);

				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ ' / '
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ '(' + Std.string(FlxMath.roundDecimal(((Conductor.songPosition / 1000) / (FlxG.sound.music.length / 1000)) * 100, 2)) + '%)'
			+ '\nSection: '
			+ curSection 
			+ '\nCurStep: '
			+ curStep
			+ "\nSpeed: "
			+ HelperFunctions.truncateFloat(speed, 1)
			+ "\n\nSnap: "
			+ notesnap
			+ '\nAlt Snap: '
			+ altnotesnap
			+ '\n'
			+ (doSnapShit ? "Snap enabled" : "Snap disabled")
			+ (FlxG.save.data.showHelp ? '\n\nShift-Left/Right :\n Change playback speed\nCTRL-Left/Right :\n Change Snap\nALT-Left/Right :\n Change Alt Snap\nHold Alt :\n for Alt Snap\nHold Shift :\n Disable Snap\nEnter : Preview\nCTRL + Enter :\n to play this section\nPress F1 to hide/show this!' : "");
		super.update(elapsed);
	}

	function loadAudioBuffer() {
		audioBuffers[0] = AudioBuffer.fromFile(Paths.inst(_song.song));
		audioBuffers[1] = AudioBuffer.fromFile(Paths.voices(_song.song));
	}

	var waveformPrinted:Bool = true;
	var audioBuffers:Array<AudioBuffer> = [null, null];
	function updateWaveform() {
		if(waveformPrinted) {
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * (keyAmmo[_song.mania] * 2)), Std.int(gridBG.height), 0x00FFFFFF);
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
				// trace("min: " + min + ", max: " + max);

				/*if (drawIndex > gridBG.height)
				{
					drawIndex = 0;
				}*/

				var pixelsMin:Float = Math.abs(min * (GRID_SIZE * (keyAmmo[_song.mania] * 2)));
				var pixelsMax:Float = max * (GRID_SIZE * (keyAmmo[_song.mania] * 2));
				waveformSprite.pixels.fillRect(new Rectangle(Std.int((GRID_SIZE * keyAmmo[_song.mania]) - pixelsMin), drawIndex, pixelsMin + pixelsMax, 1), if(checkForVoices == 1)FlxColor.BLUE else FlxColor.RED);
				drawIndex++;

				min = 0;
				max = 0;

				if(drawIndex > gridBG.height) break;
			}

			index++;
		}
		waveformPrinted = true;
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
		trace('beat');

		super.beatHit();
		if (!player2.animation.curAnim.name.startsWith("sing"))
		{
			player2.playAnim('idle');
		}
		player1.dance();
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
		updateGrid();

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
		updateSectionUI();
		updateWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section ' + sec);

		if (_song.notes[sec] != null)
		{
			trace('naw im not null');
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.time = sectionStartTime(curSection);
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
			updateWaveform();
		}
		else
			trace('bro wtf I AM NULL');
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;
		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.setPosition(0, -100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
		else
		{
			rightIcon.setPosition(0, -100);
			leftIcon.setPosition(gridBG.width / 2, -100);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		if (gridBG.width != GRID_SIZE * (keyAmmo[_song.mania] * 2))
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[_song.mania] * 2), GRID_SIZE * 16);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[_song.mania] * 2), GRID_SIZE * 16);
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (keyAmmo[_song.mania] * 2), GRID_SIZE * 16);
				add(gridBGBelow);
			}
		gridBlackLine.x = gridBG.x + gridBG.width / 2;
		waveformSprite.x = 0;
		waveformSprite.alpha = 0.35;

		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		var lastSectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;
		if (curSection != 0)
			lastSectionInfo = _song.notes[curSection - 1].sectionNotes;

		var nextSectionInfo:Array<Dynamic> = _song.notes[curSection + 1].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daType = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % keyAmmo[_song.mania], daType, false, true, i[3], i[4]);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

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

		if (curSection != 0)
			{
				for (i in lastSectionInfo)
					{
						var daNoteInfo = i[1];
						var daStrumTime = i[0];
						var daSus = i[2];
						var daType = i[3];
			
						var note:Note = new Note(daStrumTime, daNoteInfo % keyAmmo[_song.mania], null, false, true, i[3], i[4]);
						note.sustainLength = daSus;
						note.setGraphicSize(GRID_SIZE, GRID_SIZE);
						note.updateHitbox();
						note.x = Math.floor(daNoteInfo * GRID_SIZE);
						note.y = Math.floor(getAboveYfromStrum((daStrumTime - sectionStartTime(curSection - 1)) % (Conductor.stepCrochet * _song.notes[curSection - 1].lengthInSteps)));
			
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
	
				var note:Note = new Note(daStrumTime, daNoteInfo % keyAmmo[_song.mania], null, false, true, i[3], i[4]);
				note.sustainLength = daSus;
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
				note.x = Math.floor(daNoteInfo * GRID_SIZE);
				note.y = Math.floor(getBelowYfromStrum((daStrumTime - sectionStartTime(curSection + 1)) % (Conductor.stepCrochet * _song.notes[curSection + 1].lengthInSteps)));
	
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

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % keyAmmo[_song.mania] == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}


	function deleteNote(note:Note):Void
		{
			lastNote = note;
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] % keyAmmo[_song.mania] == note.noteData)
				{
					_song.notes[curSection].sectionNotes.remove(i);
				}
			}
	
			updateGrid();
		}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
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

	function shiftNotes(measure:Int=0,step:Int=0,ms:Int = 0):Void
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
				var aimtosetsection = daSection+Std.int((totaladdsection));
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
	
						//newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
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
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime(curSection);
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var type = null;
		if(forcehurtnote.checked){type = "hurt note";} else {type = anothertypingshit.text;}

		if (n != null)
			_song.notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.type]);
		else
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, type]);

		var thingy = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		curSelectedNote = thingy;

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}
	function getAboveYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBGAbove.y, gridBGAbove.y + gridBGAbove.height);
	}
	function getBelowYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBGBelow.y, gridBGBelow.y + gridBGBelow.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

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
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
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