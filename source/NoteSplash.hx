
package;

// Code from https://github.com/Tr1NgleBoss/Funkin-0.2.8.0-Port/
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;


using StringTools;

class NoteSplash extends FlxSprite
{  
	public var data:Int = 0;
	override public function new()
	{
		try{

			super();
			frames = Paths.getSparrowAtlas("noteSplashes");
			animation.addByPrefix("blue", "NoteSplashBlue", 24, false);
			animation.addByPrefix("green", "NoteSplashGreen", 24, false);
			animation.addByPrefix("purple", "NoteSplashPurple", 24, false);
			animation.addByPrefix("red", "NoteSplashRed", 24, false);
			animation.addByPrefix("white", "NoteSplashWhite", 24, false);
		}catch(e){
			MainMenuState.handleError('Error while loading NoteSplashes ${e.message}');
		}
		

	}

	public function setupNoteSplash(xPos:Float, yPos:Float,?note:Int = 0)
	{
		try{
			x = xPos;
			y = yPos;
			alpha = 0.6;
			animation.play(Note.noteNames[note], true);
			animation.finishCallback = finished;
			animation.curAnim.frameRate = 24;
			data = note;
			updateHitbox();
			switch (NoteAssets.splashType) {
				case "psych":
					setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
					offset.set(10, 10);
				case "vanilla": // From DotEngine
					offset.set(width * 0.3, height * 0.3);
				case "custom":
					// Do nothing
				default:
					setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
					offset.set(-40, -40);
			}
		}catch(e){
			MainMenuState.handleError('Error while setting up a NoteSplash ${e.message}');
		}
		// offset.set(-0.5 * -width, 0.5 * -height);
	}
	function finished(name:String){
		kill();
	}
}