import flixel.FlxG;

@:structInit class Rating{
	public var accuracy:Float = 0;
	public var name:String = "";
}

class Ratings
{
	public static var rankings:Array<Rating> = [
		{name:"Bro Hacking",accuracy:101.0001},
		{name:"X",accuracy:100.99},
		{name:"U",accuracy:100},
		{name:"S",accuracy:95},
		{name:"A",accuracy:90},
		{name:"B",accuracy:80},
		{name:"C",accuracy:70},
		{name:"Nice",accuracy:69},
		{name:"C",accuracy:60},
		{name:"D",accuracy:50},
		{name:"F",accuracy:40},
		{name:"FU",accuracy:30},
		{name:"FUC",accuracy:20},
		{name:"FUCK",accuracy:10},
		{name:"afk",accuracy:1},
		{name:"N/A",accuracy:-1},
		{name:"actual bot moment",accuracy:-100}
	];
	public static function getLetterRankFromAcc(?accuracy:Float = 0) // generate a letter ranking
	{
		for (ranking in rankings){
			if(accuracy >= ranking.accuracy){
				return ranking.name;
			}
		}
		return "what";

	}
	public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = "N/A";

		// These ratings are pretty self explanatory
		if (PlayState.misses > 10)
			ranking = "(Clear)";
		else if (PlayState.misses > 0) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else if (PlayState.shits > 0) 
			ranking = "(ShitFC)";
		else if (PlayState.bads > 0)
			ranking = "(BadFC)";
		else if (PlayState.goods > 0)
			ranking = "(GoodFC)";
		else if (PlayState.sicks > 0)
			ranking = "(SickFC)";
		else
			ranking = "(MarvelousFC)";

		ranking += getLetterRankFromAcc(accuracy);
		return ranking;
	}
	
	public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
	{
		noteDiff = Math.abs(noteDiff);
		var customTimeScale = Conductor.timeScale;

		if (customSafeZone != null)
			customTimeScale = customSafeZone / 166;
		
		// if (noteDiff > 156 * customTimeScale) // so god damn early its a miss
		// 	return "miss";
		if (noteDiff > 125 * customTimeScale) // way early
			return "shit";
		if (noteDiff > 90 * customTimeScale) // early
			return "bad";
		if (noteDiff > 45 * customTimeScale) // your kinda there
			return "good";
		if (noteDiff > 22.5 * customTimeScale) // it good but it can be better
			return "sick";
		return "marvelous";
	}

	public static function CalculateRanking(score:Int,scoreDef:Int,nps:Int,maxNPS:Int,accuracy:Float,combo:Int,maxCombo:Int):String
	{
		return switch(FlxG.save.data.songInfo){
			case 0:(FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")" : "") +                // NPS Toggle
				" | Score:" + score +                               // Score
				" | Combo:" + combo + (combo < maxCombo ? " (Max " + maxCombo + ")" : "") +
				" | Combo Breaks:" + PlayState.misses + 																				// Misses/Combo Breaks
				"\n | Accuracy:" + (FlxG.save.data.botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
				"| " + GenerateLetterRank(accuracy) + " |";
			case 1:(FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")" : "") +                // NPS Toggle
				" | Score:" + score +                               // Score
				"\n | Accuracy:" + (FlxG.save.data.botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
				"| " + GenerateLetterRank(accuracy) + " |";
			case 2:(FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")" : "") +                // NPS Toggle
				"\nScore: " + score +                               // Score
				"\nCombo: " + combo + (combo < maxCombo ? " (Max " + maxCombo + ")" : "") +
				"\nAccuracy: " + (FlxG.save.data.botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
				"\nRank: " + GenerateLetterRank(accuracy); 
			case 3:(FlxG.save.data.npsDisplay ? "NPS: " + nps + " (Max " + maxNPS + ")" : "") +                // NPS Toggle
				"\nScore: " + score +                               // Score
				"\nCombo: " + combo + (combo < maxCombo ? " (Max " + maxCombo + ")" : "") +
				"\nCombo Breaks/Misses: " + PlayState.misses + 																				// Misses/Combo Breaks
				'\nSicks: ${PlayState.sicks}\nGoods: ${PlayState.goods}\nBads: ${PlayState.bads}\nShits: ${PlayState.shits}'+
				"\nAccuracy: " + (FlxG.save.data.botplay ? "N/A" : HelperFunctions.truncateFloat(accuracy, 2) + " %") +  				// Accuracy
				"\nRank: " + GenerateLetterRank(accuracy); 
			case 4:'Misses:${PlayState.misses}    Score:' + score;
			default:"";

		}
	}
}
