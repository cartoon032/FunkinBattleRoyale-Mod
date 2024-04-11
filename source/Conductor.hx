package;

import Song.SwagSong;
import flixel.FlxG;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}
typedef ManiaChangeEvent =
{
	var Section:Int;
	var Mania:Int;
	var Skip:Bool;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var crochetSecs(get,set):Float;
	public static function get_crochetSecs():Float{
		return crochet * 0.001;
	}
	public static function set_crochetSecs(val:Float):Float{
		return crochet = val * 1000;
	}
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var rawPosition:Float;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var ManiaChangeMap:Array<ManiaChangeEvent> = [];

	public function new(){}

	public static function recalculateTimings()
	{
		Conductor.safeFrames = FlxG.save.data.frames;
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm * PlayState.songspeed;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm * PlayState.songspeed;
				bpmChangeMap.push({
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				});
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}
	public static function mapManiaChanges(song:SwagSong)
	{
		ManiaChangeMap = [];

		var curMania:Int = song.mania;
		var totalSections:Int = -100;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeMania >= 0 && song.notes[i].changeMania != curMania)
			{
				curMania = song.notes[i].changeMania;
				ManiaChangeMap.push({
					Section: totalSections,
					Mania: curMania,
					Skip: false
				});
			}

			totalSections = i + 1;
		}
		trace("new Mania map BUDDY " + ManiaChangeMap);
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}