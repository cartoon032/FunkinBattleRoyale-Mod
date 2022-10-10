import openfl.system.System;
import flixel.math.FlxMath;
import Song.SwagSong;
import sys.FileSystem;
import sys.io.File;
import tjson.Json;

class SmallNote // basically Note.hx but small as fuck
{
	public var strumTime:Float;
	public var noteData:Int;
	public var notetype:String;

	public function new(strum, data, type)
	{
		strumTime = strum;
		noteData = data;
		notetype = type;
	}
}

class NoteStuffExtra
{
	public static var scale = 3 * 1.8;
	public static var lastDiffHandOne:Array<Float> = [];
	public static var lastDiffHandTwo:Array<Float> = [];
	public static var bfNotes:Array<SmallNote> = [];
	public static var dadNotes:Array<SmallNote> = [];
	public static function CalculateNoteAmount(song:SwagSong)
	{
		bfNotes = [];
		dadNotes = [];

		if (song.notes == null)
			return 0.0;

		if (song.notes.length == 0)
			return 0.0;

		// find all of the notes
		for (i in song.notes) // sections
		{
			for (ii in i.sectionNotes) // notes
			{
				var gottaHitNote:Bool = i.mustHitSection;

				if (ii[1] >= PlayState.keyAmmo[PlayState.mania] && !gottaHitNote && ii[1] != -1)
					bfNotes.push(new SmallNote(ii[0] / onlinemod.OfflineMenuState.rate, Math.floor(Math.abs(ii[1])),ii[3]));
				if (ii[1] <= PlayState.keyAmmo[PlayState.mania] - 1 && gottaHitNote && ii[1] != -1)
					bfNotes.push(new SmallNote(ii[0] / onlinemod.OfflineMenuState.rate, Math.floor(Math.abs(ii[1])),ii[3]));

				if (ii[1] >= PlayState.keyAmmo[PlayState.mania] && gottaHitNote && ii[1] != -1)
					dadNotes.push(new SmallNote(ii[0] / onlinemod.OfflineMenuState.rate, Math.floor(Math.abs(ii[1])),ii[3]));
				if (ii[1] <= PlayState.keyAmmo[PlayState.mania] - 1 && !gottaHitNote && ii[1] != -1)
					dadNotes.push(new SmallNote(ii[0] / onlinemod.OfflineMenuState.rate, Math.floor(Math.abs(ii[1])),ii[3]));
			}
		}
		return 0.0;
	}

	public static function CalculateDifficult(?accuracy:Float = 0.93, NoteSet:Int)
	{
			var handOne:Array<SmallNote> = [];
			var handTwo:Array<SmallNote> = [];
			var Notedata:Array<SmallNote> = [];
			if(NoteSet == 0) Notedata = bfNotes; else Notedata = dadNotes;
			if(Notedata.length != 0){
			Notedata.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var firstNoteTime = Notedata[0].strumTime;
			// normalize the notes

			for (i in Notedata)
			{
				i.strumTime = (i.strumTime - firstNoteTime) * 2;
			}

			for (i in Notedata)
			{
				switch (i.noteData)
				{
					case 0:
						handOne.push(i);
					case 1:
						handOne.push(i);
					case 2:
						handTwo.push(i);
					case 3:
						handTwo.push(i);
					case 4:
						handOne.push(i);
					case 5:
						handOne.push(i);
					case 6:
						handTwo.push(i);
					case 7:
						handTwo.push(i);
				}
			}
			// collect all of the notes in each col
			var leftHandCol:Array<Float> = [];
			var leftMHandCol:Array<Float> = [];
			var rightMHandCol:Array<Float> = [];
			var rightHandCol:Array<Float> = [];

			for (i in 0...handOne.length)
			{
				if (handOne[i].noteData == 0 || handOne[i].noteData == 4)
					leftHandCol.push(handOne[i].strumTime);
				else
					leftMHandCol.push(handOne[i].strumTime);
			}
			for (i in 0...handTwo.length)
			{
				if (handTwo[i].noteData == 3 || handTwo[i].noteData == 6)
					rightHandCol.push(handTwo[i].strumTime);
				else
					rightMHandCol.push(handTwo[i].strumTime);
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
				var fuckYouOne:Array<SmallNote> = [];
				var fuckYouTwo:Array<SmallNote> = [];
				for (note in ve)
				{
					switch (note.noteData)
					{
						case 0: // fingie 1
							fuckYouOne.push(note);
						case 1: // fingie 2
							fuckYouTwo.push(note);
						case 4: // fingie 1
							fuckYouOne.push(note);
						case 5: // fingie 2
							fuckYouTwo.push(note);
					}
				}
	
				var one = fingieCalc(fuckYouOne, leftHandCol);
				var two = fingieCalc(fuckYouTwo, leftMHandCol);
	
				var bigFuck = ((((one > two ? one : two) * 8) + (hand_npsOne[i] / scale) * 5) / 13) * scale;
	
				// trace(bigFuck + " - hand one [" + i + "]");
	
				hand_diffOne.push(bigFuck);
			}
	
			for (i in 0...segmentsTwo.length)
			{
				var ve = segmentsTwo[i];
				if (ve == null)
					continue;
				var fuckYouOne:Array<SmallNote> = [];
				var fuckYouTwo:Array<SmallNote> = [];
				for (note in ve)
				{
					switch (note.noteData)
					{
						case 2: // fingie 1
							fuckYouOne.push(note);
						case 3: // fingie 2
							fuckYouTwo.push(note);
						case 6: // fingie 1
							fuckYouOne.push(note);
						case 7: // fingie 2
							fuckYouTwo.push(note);
					}
				}
	
				var one = fingieCalc(fuckYouOne, rightMHandCol);
				var two = fingieCalc(fuckYouTwo, rightHandCol);
	
				var bigFuck = ((((one > two ? one : two) * 8) + (hand_npsTwo[i] / scale) * 5) / 13) * scale;
	
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
	
			lastDiffHandOne = hand_diffOne;
			lastDiffHandTwo = hand_diffTwo;
	
			return HelperFunctions.truncateFloat(chisel(accuracy, hand_diffOne, hand_diffTwo, point_npsOne, point_npsTwo, maxPoints), 2);
		}else return 0.0;
	}

	public static function chisel(scoreGoal:Float, diffOne:Array<Float>, diffTwo:Array<Float>, pointsOne:Array<Float>, pointsTwo:Array<Float>, maxPoints:Float)
	{
		var lowerBound:Float = 0;
		var upperBound:Float = 100;

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
}
