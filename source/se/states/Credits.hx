package se.states;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class Credits extends SearchMenuState
{
	var exampleImage:FlxSprite;
	var uiIcon:HealthIcon;
	var charNameText:FlxText;
	var descriptions:Array<Array<String>> = [
		["Super Engine" , "Super Engine, The engine you're using right now.

* Superpowers04 - Pretty much everything specific to Super Engine
* NayToon - Many fixes, multiplayer improvements, providing early Windows builds, etc.
* Henry.xml/Harley.xml - Created the note splash animation
* BeastlyGabi/BeastlyGhost - Some general help
* XieneDev - Made Battle Royale. This engine actually wouldn't exist if it wasn't for this pog FNF mod
"],["Funkin' Team" , "The base game!

* ninjamuffin99 - Programming
* PhantomArcade3K - Art
* Evilsk8r - Art
* Kawai Sprite - Music
"],["Kade Engine 1.4.2" , "The original engine.

* KadeDeveloper - Maintainer and lead programmer
"], ["Modding Plus" , "Several improvements and the original base for HScript

* BulbyVR-Gamer) - Owner/Programmer
* DJ Popsicle/1780306) - Co-Owner/Additional Programmer
* Matheus L/Mlops, AndreDoodles, riko, Raf, ElBartSinsoJaJa, and plum - Artist & Animation
* ThePinkPhantom/JuliettePink - Portrait Artist
* Alex Director - Icon Fixer
* TrafficKid - GitHub Wikipedia
* GwebDev - Edited WebM code
* Axy - Poggers help
"], ["TJSON","Library used for parsing JSON's quickly

* JWambaugh - Making the library
"]/* ,["Shoutouts" , "Some general shoutouts

* Anthonyjrvill - He makes Note Skins specially for SE-T. What a mad lad"
] */
];
	override function reloadList(?reload:Bool = false,?search:String=""){try{
			curSelected = 0;
			if(reload){CoolUtil.clearFlxGroup(grpSongs);}
			songs = [];

			var i:Int = 0;
			for (_ => name in descriptions){
				_addToList(name[0],i);
				i++;
			}
		}catch(e) MainMenuState.handleError('Error with loading credits list ${e.message}');
	}
	function _addToList(char:String,i:Int = 0){
		songs.push(char);
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, char, true, false);
		controlLabel.cutOff = 12;
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		if (i != 0) controlLabel.alpha = 0.6;
		grpSongs.add(controlLabel);
	}

	override function create()
	{try{
		toggleables['search'] = false;
		super.create();
		bg.color = 0xFF501050;
		infoTextBorder.makeGraphic(500,720,FlxColor.BLACK);
		infoTextBorder.setPosition(1280 - infoTextBorder.width,0);
		infotext.fieldWidth = infoTextBorder.width - 20;

		addTitleText('Credits');
		titleText.screenCenter(X);

		charNameText = new FlxText(5, 50, 0, "yes", 20);
		charNameText.wordWrap = false;
		charNameText.scrollFactor.set();
		charNameText.setFormat(CoolUtil.font, 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		overLay.add(charNameText);
		retAfter = false;

		// FlxTween.angle(uiIcon, -40, 40, 1.12, {ease: FlxEase.quadInOut, type: PINGPONG});
		changeSelection(0);

	}catch(e) MainMenuState.handleError('Error with credits "create" ${e.message}');}

	inline function updateName(?name = "funninameherelmaomlmaonjosn"){
		if(name != "funninameherelmaomlmaonjosn"){
			charNameText.text = name;
			charNameText.x = (infoTextBorder.x + (infoTextBorder.width * 0.5) - (charNameText.width * 0.5));
		}

	}
	override function updateInfoText(str:String = ""){
		if(infotext != null){
			infotext.text = str;
			infotext.wordWrap = true;
			infotext.scrollFactor.set();
			infotext.y = charNameText.y + 50;
			infotext.x = infoTextBorder.x + 10;
		}
	}
	override function changeSelection(change:Int = 0){
		var _oldSel = curSelected;
		super.changeSelection(change);
		retAfter = true;
		updateInfoText(descriptions[curSelected][1]);
		updateName(songs[curSelected]);

	}

	override function select(sel:Int = 0){
		FlxG.sound.play(Paths.sound('cancelMenu'));
		return;
	}

}