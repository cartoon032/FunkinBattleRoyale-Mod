import openfl.system.System;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import Song.SwagSong;
import sys.FileSystem;
import sys.io.File;
import tjson.Json;

class SmallNote // basically Note.hx but small as fuck
{
	public var strumTime:Float;
	public var noteData:Int;

	public function new(strum, data)
	{
		strumTime = strum;
		noteData = data;
	}
}

class NoteStuffExtra
{
	public static var scale = 3 * 1.8;
	public static var bfNotes:Array<SmallNote> = [];
	public static var dadNotes:Array<SmallNote> = [];
	public static var eventNotes:Array<SmallNote> = [];
	public static var shitNotes:Int = 0;
	public static function CalculateNoteAmount(song:SwagSong,instLength:Float)
	{
		bfNotes = [];
		dadNotes = [];

		if (song.notes == null)
			return 0.0;

		if (song.notes.length == 0)
			return 0.0;

		// find all of the notes
		for (section in song.notes) // sections
		{
			for (note in section.sectionNotes) // notes
			{
				var gottaHitNote:Bool = section.mustHitSection;
				if(note[1] == -1)
					eventNotes.push(new SmallNote(note[0] / onlinemod.OfflineMenuState.rate, note[1]));
				// else if(note[1] >= song.playerKeyCount + song.keyCount || note[0] >= instLength)
				// 	shitNotes++;
				else if(gottaHitNote){
					if(note[1] >= song.playerKeyCount)
						dadNotes.push(new SmallNote(note[0] / onlinemod.OfflineMenuState.rate, note[1]));
					else
						bfNotes.push(new SmallNote(note[0] / onlinemod.OfflineMenuState.rate, note[1]));
				}else{
					if(note[1] >= song.keyCount)
						bfNotes.push(new SmallNote(note[0] / onlinemod.OfflineMenuState.rate, note[1]));
					else
						dadNotes.push(new SmallNote(note[0] / onlinemod.OfflineMenuState.rate, note[1]));
				}
			}
		}
		getUniqueSameArray(bfNotes);
		getUniqueSameArray(dadNotes);
		return 0.0;
	}

	public static function CalculateDifficult(?accuracy:Float = 0.93, NoteSet:Int)
	{
			var handOne:Array<SmallNote> = [];
			var handTwo:Array<SmallNote> = [];
			var Notedata:Array<SmallNote> = [];
			var mania:Int = 0;
			if(NoteSet == 0)
				{
					Notedata = bfNotes;
					mania = PlayState.playermania;
				}
			else
				{
					Notedata = dadNotes;
					mania = PlayState.mania;
				}
			if(Notedata.length > 10)
		{
			Notedata.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var firstNoteTime = Notedata[0].strumTime;
			// normalize the notes

			for (i in Notedata)
			{
				i.strumTime = (i.strumTime - firstNoteTime) * 2;
			}

			for (i in Notedata)
			{
				if (i.noteData % PlayState.keyAmmo[mania] < PlayState.keyAmmo[mania] / 2)
					handOne.push(i);
				else
					handTwo.push(i);
			}
			// collect all of the notes in each col
			var leftHandCol:Array<Array<Float>> = [];
			var rightHandCol:Array<Array<Float>> = [];
			for (i in 0...PlayState.keyAmmo[PlayState.mania] + PlayState.keyAmmo[PlayState.playermania])
			{
				leftHandCol.push([]);
				rightHandCol.push([]);
			}
			for (i in 0...handOne.length)
			{
				leftHandCol[handOne[i].noteData % PlayState.keyAmmo[mania]].push(handOne[i].strumTime);
			}
			for (i in 0...handTwo.length)
			{
				rightHandCol[handTwo[i].noteData % PlayState.keyAmmo[mania]].push(handTwo[i].strumTime);
			}
			// length in segments of the song
			var length = ((Notedata[Notedata.length - 1].strumTime / 1000) / 0.5);
	
			// hackey way of creating a array with a length
			var segmentsOne = new haxe.ds.Vector(Math.floor(length));
	
			var segmentsTwo = new haxe.ds.Vector(Math.floor(length));
	
			// set em all to array's (so no null's)
	
			for (i in 0...segmentsOne.length)
				segmentsOne[i] = new Array<SmallNote>();
			for (i in 0...segmentsTwo.length)
				segmentsTwo[i] = new Array<SmallNote>();
	
			// algo loop
			for (i in handOne)
			{
				var index = Std.int((((i.strumTime * 2) / 1000)));
				if (index + 1 > length)
					continue;
				segmentsOne[index].push(i);
			}
	
			for (i in handTwo)
			{
				var index = Std.int((((i.strumTime * 2) / 1000)));
				if (index + 1 > length)
					continue;
				segmentsTwo[index].push(i);
			}
	
			// get nps for both hands
	
			var hand_npsOne:Array<Float> = new Array<Float>();
			var hand_npsTwo:Array<Float> = new Array<Float>();
	
			for (i in segmentsOne)
			{
				if (i == null)
					continue;
				hand_npsOne.push(i.length * scale * 1.6);
			}
			for (i in segmentsTwo)
			{
				if (i == null)
					continue;
				hand_npsTwo.push(i.length * scale * 1.6);
			}
	
			// get the diff vector's for all of the hands
	
			var hand_diffOne:Array<Float> = new Array<Float>();
			var hand_diffTwo:Array<Float> = new Array<Float>();
	
			for (i in 0...segmentsOne.length)
			{
				var ve = segmentsOne[i];
				if (ve == null)
					continue;
				var fuckYou:Array<Array<SmallNote>> = [];
				for (i in 0...PlayState.keyAmmo[PlayState.mania] + PlayState.keyAmmo[PlayState.playermania])
				{
					fuckYou.push([]);
				}
				for (note in ve)
				{
					fuckYou[note.noteData].push(note);
				}
	
				var bignumber:Float = 0;
				for (i in 0...fuckYou.length){
					var number = fingieCalc(fuckYou[i], leftHandCol[i]);
					bignumber = Math.max(bignumber, number);
				}
	
				var bigFuck = (((bignumber * 8) + (hand_npsOne[i] / scale) * 5) / 13) * scale;
	
				// trace(bigFuck + " - hand one [" + i + "]");
	
				hand_diffOne.push(bigFuck);
			}
			for (i in 0...segmentsTwo.length)
			{
				var ve = segmentsTwo[i];
				if (ve == null)
					continue;
				var fuckYou:Array<Array<SmallNote>> = [];
				for (i in 0...PlayState.keyAmmo[PlayState.mania] + PlayState.keyAmmo[PlayState.playermania])
				{
					fuckYou.push([]);
				}
				for (note in ve)
				{
					fuckYou[note.noteData].push(note);
				}
	
				var bignumber:Float = 0;
				for (i in 0...fuckYou.length){
					var number = fingieCalc(fuckYou[i], rightHandCol[i]);
					bignumber = Math.max(bignumber, number);
				}
	
				var bigFuck = (((bignumber * 8) + (hand_npsTwo[i] / scale) * 5) / 13) * scale;
	
				hand_diffTwo.push(bigFuck);
	
				// trace(bigFuck + " - hand two [" + i + "]");
			}
			for (i in 0...4)
			{
				smoothBrain(hand_npsOne, 0);
				smoothBrain(hand_npsTwo, 0);
	
				smoothBrainTwo(hand_diffOne);
				smoothBrainTwo(hand_diffTwo);
			}
	
			// trace(hand_diffOne);
			// trace(hand_diffTwo);
	
			// trace(hand_npsOne);
			// trace(hand_npsTwo);
	
			var point_npsOne:Array<Float> = new Array<Float>();
			var point_npsTwo:Array<Float> = new Array<Float>();
	
			for (i in segmentsOne)
			{
				if (i == null)
					continue;
				point_npsOne.push(i.length);
			}
			for (i in segmentsTwo)
			{
				if (i == null)
					continue;
				point_npsTwo.push(i.length);
			}
	
			var maxPoints:Float = 0;
	
			for (i in point_npsOne)
				maxPoints += i;
			for (i in point_npsTwo)
				maxPoints += i;
	
			if (accuracy > .965)
				accuracy = .965;
	
			return HelperFunctions.truncateFloat(chisel(accuracy, hand_diffOne, hand_diffTwo, point_npsOne, point_npsTwo, maxPoints), 2);
		}else return 0.0;
	}

	public static function chisel(scoreGoal:Float, diffOne:Array<Float>, diffTwo:Array<Float>, pointsOne:Array<Float>, pointsTwo:Array<Float>, maxPoints:Float)
	{
		var lowerBound:Float = 0;
		var upperBound:Float = 1000;

		while (upperBound - lowerBound > 0.01)
		{
			var average:Float = (upperBound + lowerBound) / 2;
			var amtOfPoints:Float = calcuate(average, diffOne, pointsOne) + calcuate(average, diffTwo, pointsTwo);
			if (amtOfPoints / maxPoints < scoreGoal)
				lowerBound = average;
			else
				upperBound = average;
		}
		return upperBound;
	}

	public static function calcuate(midPoint:Float, diff:Array<Float>, points:Array<Float>)
	{
		var output:Float = 0;

		for (i in 0...diff.length)
		{
			var res = diff[i];
			if (midPoint > res)
				output += points[i];
			else
				output += points[i] * Math.pow(midPoint / res, 1.2);
		}
		return output;
	}

	public static function findStupid(strumTime:Float, array:Array<Float>)
	{
		for (i in 0...array.length)
			if (array[i] == strumTime)
				return i;
		return -1;
	}

	public static function fingieCalc(floats:Array<SmallNote>, columArray:Array<Float>):Float
	{
		var sum:Float = 0;
		if (floats.length == 0)
			return 0;
		var startIndex = findStupid(floats[0].strumTime, columArray);
		if (startIndex == -1)
			return 0;
		for (i in floats)
		{
			sum += columArray[startIndex + 1] - columArray[startIndex];
			startIndex++;
		}

		if (sum == 0)
			return 0;

		return (1375 * (floats.length)) / sum;
	}

	// based arrayer
	// basicily smmoth the shit
	public static function smoothBrain(npsVector:Array<Float>, weirdchamp:Float)
	{
		var floatOne = weirdchamp;
		var floatTwo = weirdchamp;

		for (i in 0...npsVector.length)
		{
			var result = npsVector[i];

			var chunker = floatOne;
			floatOne = floatTwo;
			floatTwo = result;

			npsVector[i] = (chunker + floatOne + floatTwo) / 3;
		}
	}

	// Smooth the shit but less
	public static function smoothBrainTwo(diffVector:Array<Float>)
	{
		var floatZero:Float = 0;

		for (i in 0...diffVector.length)
		{
			var result = diffVector[i];

			var fuck = floatZero;
			floatZero = result;
			diffVector[i] = (fuck + floatZero) / 2;
		}
	}

    public static function getUniqueSameArray<T>(array:Array<T>) {
        var values = getUniqueAsNewArray(array);
        for (v in values) {
            var origIndex = array.indexOf(v);
			while (true) {
                var i = array.indexOf(v, origIndex + 1);
                if (i == -1) 
					break; // not found
                else{
					array.splice(i, 1); // remove
					shitNotes++;
				}
            }
        }
        return array;
    }

	public static function getUniqueAsNewArray<T>(array:Array<T>) {
        var l = [];
        for (v in array) {
         	if (l.indexOf(v) == -1)  // array has not v
				l.push(v);
		}
        return l;
    }
}
