
package;

// Code from https://github.com/Tr1NgleBoss/Funkin-0.2.8.0-Port/
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
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
			super();
			// frames = Paths.getSparrowAtlas("noteSplashes");
			if(PlayState.instance != null){
				PlayState.instance.callInterp("newNoteSplash",[this]);
			}
			if(frames == null){
				frames = FlxAtlasFrames.fromSparrow(NoteAssets.splashImage,NoteAssets.splashXml);
			}
			animation.addByPrefix("purple", "NoteSplashPurple", 24, false);
			animation.addByPrefix("aqua", "NoteSplashAqua", 24, false);
			animation.addByPrefix("green", "NoteSplashGreen", 24, false);
			animation.addByPrefix("red", "NoteSplashRed", 24, false);
			animation.addByPrefix("white", "NoteSplashWhite", 24, false);
			animation.addByPrefix("yellow", "NoteSplashYellow", 24, false);
			animation.addByPrefix("pink", "NoteSplashPink", 24, false);
			animation.addByPrefix("blue", "NoteSplashBlue", 24, false);
			animation.addByPrefix("orange", "NoteSplashOrange", 24, false);
			animation.addByPrefix("lime", "NoteSplashLime", 24, false);
			animation.addByPrefix("cyan", "NoteSplashCyan", 24, false);
			animation.addByPrefix("magenta", "NoteSplashMagenta", 24, false);
			animation.addByPrefix("tango", "NoteSplashTango", 24, false);
			animation.addByPrefix("wintergreen", "NoteSplashWintergreen", 24, false);
			animation.addByPrefix("canary", "NoteSplashCanary", 24, false);
			animation.addByPrefix("scarlet", "NoteSplashScarlet", 24, false);
			animation.addByPrefix("violet", "NoteSplashViolet", 24, false);
			animation.addByPrefix("erin", "NoteSplashErin", 24, false);
			if(PlayState.instance != null){
				PlayState.instance.callInterp("newNoteSplashAfter",[this]);
			}
		}catch(e){
			MainMenuState.handleError('Error while loading NoteSplashes ${e.message}\n ${e.stack}');
		}
		

	}

	public function setupNoteSplash(?obj:FlxObject = null,?note:Int = 0)
	{
		try{
			if(PlayState.instance != null){
				PlayState.instance.callInterp("setupNoteSplash",[this]);
			}
			alpha = 0.6;
			animation.play(Note.noteNames[note], true);
			animation.finishCallback = finished;
			animation.curAnim.frameRate = 24;
			data = note;
			updateHitbox();
			centerOffsets();
			centerOrigin();

			if(obj != null){
				@:privateAccess
				{
					cameras = obj.cameras;
				}
				scrollFactor.set(obj.scrollFactor.x,obj.scrollFactor.y);
				x=(obj.x);
				y=(obj.y);
			}
			// animation.play(anim, true);
			switch (NoteAssets.splashType.toLowerCase()) {
				case "psych":
					setPosition(x - Note.swagWidth[0] * 0.95, y - Note.swagWidth[0]);
					offset.set(10, 10);
				case "vanilla": // From DotEngine
					offset.set(width * 0.3, height * 0.3);
				case "custom":
					// Do nothing
				default:
					setPosition(x - Note.swagWidth[0] * 0.95, y - Note.swagWidth[0]);
					offset.set(-40, -40);
			}

			if(PlayState.instance != null){
				PlayState.instance.callInterp("setupNoteSplashAfter",[this]);
			}
		}catch(e){
			// MainMenuState.handleError(e,'Error while setting up a NoteSplash ${e.message}');// i rather have it not doing anything if error
		}
		// offset.set(-0.5 * -width, 0.5 * -height);
	}
	function finished(name:String){
		kill();
	}
}