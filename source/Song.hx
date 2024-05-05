package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var ?chartVersion:String;
	var mania:Int;
	var ?Smania:Int;
	var ?keyCount:Int;
	var ?eventObjects:Array<Event>;

	var player1:String;
	var player2:String;
	var ?defplayer1:String;
	var ?defplayer2:String;
	var ?defgf:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
	var ?events:Array<Dynamic>; // Events
	var ?noteMetadata:NoteMetadata;
	var ?difficultyString:String;
	var ?inverthurtnotes:Bool;
	var ?rawJSON:Dynamic;
	var ?chartType:String;
	var ?forceCharacters:Bool;
	var ?playerKeyCount:Int;
	var ?timescale:Array<Int>;
	var ?multichar:Array<MoreChar>;
}
typedef MoreChar={
	var char:String;
	var side:Int;
	var offset:Float;
}
typedef NoteMetadata={
	var badnoteHealth:Float;
	var badnoteScore:Int;
	// var healthGain:Float;
	var missScore:Int;
	var missHealth:Float;
	// var tooLateScore:Float;
	var tooLateHealth:Float;
}
class Event
{
	public var name:String;
	public var position:Float;
	public var value:Float;
	public var type:String;

	public function new(name:String, pos:Float, value:Float, type:String)
	{
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}
class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var mania:Int = 0;

	public var player1:String = 'bf';
	public var player2:String = 'bf';
	public var gfVersion:String = 'gf';
	public var player3:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';
	public static var defNoteMetadata:NoteMetadata = {
				badnoteHealth : -0.24,
				badnoteScore : -7490,
				missScore : -10,
				missHealth : -0.04,
				tooLateHealth : -0.075
			};


	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = CoolUtil.cleanJSON(Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())));

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	static function invertChart(swagShit:SwagSong):SwagSong{
		for (sid => section in swagShit.notes) {
			section.mustHitSection = !section.mustHitSection;
			swagShit.notes[sid] = section;
		}
		var PKC = swagShit.playerKeyCount;
		var KC = swagShit.keyCount;
		swagShit.keyCount = PKC;
		swagShit.playerKeyCount = KC;
		return swagShit;
	}

	@:keep inline public static function getEmptySong():SwagSong{
		return cast Json.parse(getEmptySongJSON()).song;
	}
	public static function getEmptySongJSON():String{
		return '{
			"song": {
				"player1": "bf",
				"events": [],
				"gfVersion": "gf",
				"notes": [
				{
					"lengthInSteps": 16,
					"sectionNotes": [],
					"typeOfSection": 0,
					"mustHitSection": true,
					"changeBPM": false,
					"bpm": 150
				},
				{
					"lengthInSteps": 16,
					"sectionNotes": [],
					"typeOfSection": 0,
					"mustHitSection": false,
					"changeBPM": false,
					"bpm": 150
				}
				],
				"player2": "bf",
				"player3": null,
				"song": "Unset song name",
				"stage": "stage",
				"validScore": true,
				"sections": 0,
				"needsVoices": false,
				"bpm": 150,
				"speed": 2.0,
				"chartType": "FNF/Super-T"
			}
		}';
	}

	static function modifyChart(swagShit:SwagSong,charting:Bool = false):SwagSong{
		var hurtArrows = (QuickOptionsSubState.getSetting("Custom Arrows") || onlinemod.OnlinePlayMenuState.socket != null || charting);
		var opponentArrows = (onlinemod.OnlinePlayMenuState.socket != null || QuickOptionsSubState.getSetting("Opponent arrows") || charting);
		var invertedNotes:Array<Int> = [4,5,6,7];
		var oppNotes:Array<Int> = [0,1,2,3];

		for (sid => section in swagShit.notes) {
			if(section.sectionNotes == null || section.sectionNotes[0] == null) continue;

			var sN:Array<Array<Dynamic>> = [];

			for (nid in 0 ... section.sectionNotes.length){ // Regenerate section, is a bit fucky but only happens when loading
				var note:Array<Dynamic> = section.sectionNotes[nid];
				// Removes opponent arrows 
				if (!opponentArrows && (section.mustHitSection && invertedNotes.contains(note[1]) || !section.mustHitSection && oppNotes.contains(note[1]))){trace("Skipping note");continue;}


				if (hurtArrows){ // Weird if statement to prevent the game from removing hurt arrows unless they should be removed
					if(note[4] == 1 || note[1] > swagShit.keyCount * 2 - 1) {note[3] = 1;} // Support for Andromeda and tricky notes
				}else{
					note[3] = 0;
				}
				sN.push(note);

			}
			swagShit.notes[sid].sectionNotes = sN;

		}
		return swagShit;

	}

	public static function parseJSONshit(rawJson:String,charting:Bool = false):SwagSong
		{
			#if !debug
			try{
			#end
				var rawJson:Dynamic = Json.parse(rawJson);
				var swagShit:SwagSong = cast rawJson.song;
				swagShit.rawJSON = rawJson;
				swagShit.validScore = true;

				if (swagShit.events != null && swagShit.mania > 0 && swagShit.keyCount == null)
					swagShit.keyCount = swagShit.mania + 1;
				else if(swagShit.mania > 0)swagShit.keyCount = PlayState.keyAmmo[swagShit.mania];
				else if(swagShit.keyCount == null)swagShit.keyCount = 4;
				if(swagShit.playerKeyCount == null)swagShit.playerKeyCount = swagShit.keyCount;

				if (PlayState.invertedChart || (onlinemod.OnlinePlayMenuState.socket == null && QuickOptionsSubState.getSetting("Inverted chart")) && !charting){
					PlayState.invertedChart = true;
					swagShit = invertChart(swagShit);
				}
				// swagShit = modifyChart(swagShit,charting);
				if(QuickOptionsSubState.getSetting("Scroll speed") > 0) swagShit.speed = QuickOptionsSubState.getSetting("Scroll speed");
				if (swagShit.noteMetadata == null) swagShit.noteMetadata = Song.defNoteMetadata;
				swagShit.chartType = ChartingState.detectChartType(swagShit);
				return swagShit;
			#if !debug
			}catch(e){
				MainMenuState.handleError('Error parsing chart: ${e.message}');
				return getEmptySong();
			}
			#end
		}
}
