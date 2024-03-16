package;
// About 90% of code used from OfflineMenuState
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;

import sys.io.File;
import sys.FileSystem;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import Discord.DiscordClient;

using StringTools;

class ArrowSelection extends SearchMenuState
{
	public var playerStrums:FlxTypedGroup<StrumArrow> = new FlxTypedGroup<StrumArrow>();
	function generateStaticArrows():Void
	{
		for (i in 0...PlayState.keyAmmo[PlayState.mania])
		{
			var babyArrow:StrumArrow = new StrumArrow(i,0, if (FlxG.save.data.downscroll) FlxG.height - 165 else 50);
			babyArrow.init();
			babyArrow.screenCenter(X);
			babyArrow.x += (Note.swagWidth[PlayState.mania] * i) + i - (Note.swagWidth[PlayState.mania] + (Note.swagWidth[PlayState.mania] * ((PlayState.keyAmmo[PlayState.mania] * 0.5) - 1.5)));
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease	: FlxEase.circOut, startDelay: 0.33 + (0.1 * i)});
			playerStrums.add(babyArrow);
			babyArrow.playStatic(); 
		}
	}
	override function create()
	{try{
		{ // Looks for all notes, This will probably be rarely accessed, so loading like this shouldn't be a problem
			searchList = ["default"];
			var dataDir:String = Sys.getCwd() + "mods/noteassets/";
			var customArrows:Array<String> = [];
			if (SELoader.exists(dataDir))
			{
				for (file in SELoader.readDirectory(dataDir))
				{
					if (file.endsWith(".png") && !file.endsWith("-bad.png") && !file.endsWith("-splash.png")){
						var name = file.substr(0,-4);
						if (SELoader.exists('${dataDir}${name}.xml'))
						{
							customArrows.push(name);
						}
					}
				}
			}else{MainMenuState.handleError('mods/noteassets is not a folder. You need to create it to use custom arrow skins!');}
			{
				var dataDir = "mods/packs/";
				for (_dir in SELoader.readDirectory(dataDir))
				{
					var dataDir = 'mods/packs/$_dir/noteassets/';
					if(SELoader.exists(dataDir)){
						for (file in SELoader.readDirectory(dataDir))
						{
							if (file.endsWith(".png") && !file.endsWith("-bad.png") && !file.endsWith("-splash.png")){
								var name = file.substr(0,-4);
								if (SELoader.exists('${dataDir}${name}.xml'))
								{
									// Really shit but it works
									customArrows.push('../packs/$_dir/noteassets/$name');
								}
							}
						}
					}
				}
			}
			// customCharacters.sort((a, b) -> );
			haxe.ds.ArraySort.sort(customArrows, function(a, b) {
						 if(a < b) return -1;
						 else if(b > a) return 1;
						 else return 0;
					});
			for (char in customArrows){
				searchList.push(char);
			}
		}

		generateStaticArrows();
		super.create();
		updateInfoText('Press Tab to change mania - current mania ${PlayState.mania} with ${PlayState.keyAmmo[PlayState.mania]} Keys');
		add(playerStrums);

		changeSelection();

	}catch(e) MainMenuState.handleError('Error with notesel "create" ${e.message}');}
	override function changeSelection(change:Int = 0){
		super.changeSelection(change);
		playerStrums.forEach(
			function(arrow:StrumArrow){
				arrow.changeSprite(songs[curSelected]);
				arrow.playStatic(); 
			}
		);
	}
	override function select(sel:Int = 0){
		FlxG.save.data.noteAsset = songs[curSelected];
	}
	override function beatHit(){
		super.beatHit();
		if(playerStrums.members[curBeat % PlayState.keyAmmo[PlayState.mania]] != null) {
			playerStrums.members[curBeat % PlayState.keyAmmo[PlayState.mania]].confirm();
			playerStrums.members[(curBeat - 2) % PlayState.keyAmmo[PlayState.mania]].playStatic();
			playerStrums.members[(curBeat - 1) % PlayState.keyAmmo[PlayState.mania]].press();
		}
	}
	override function extraKeys(){
		if(FlxG.keys.justPressed.TAB){
			for(arrow in playerStrums){
				FlxTween.tween(arrow, {y: arrow.y - 100, alpha: 0}, 0.1, {ease: FlxEase.circOut,
					onComplete: function(twn:FlxTween)
					{
						arrow.destroy();
						arrow.kill();
					}
				});
			}
			trace('Changing skin!');
			PlayState.mania++;
			if(PlayState.mania >= PlayState.keyAmmo.length) PlayState.mania = 0;
			updateInfoText('Press Tab to change mania - current mania ${PlayState.mania} with ${PlayState.keyAmmo[PlayState.mania]} Keys');
			playerStrums = new FlxTypedGroup<StrumArrow>();
			changeColor();
			generateStaticArrows();
			add(playerStrums);
			new FlxTimer().start(0.33, function(tmr)
			{
				playerStrums.forEach(
					function(arrow:StrumArrow){
						arrow.changeSprite(songs[curSelected]);
						arrow.playStatic(); 
					}
				);
			});
		}
	}
	function changeColor(){
		switch (PlayState.mania)
		{
			case 0:
				Note.noteNames = ['purple','aqua','green','red'];
			case 1: 
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','green','red','yellow','aqua','orange'];
				else Note.noteNames = ['purple','aqua','red','yellow','green','orange'];
			case 2: 
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','green','red','white','yellow','aqua','orange'];
				else Note.noteNames = ['purple','aqua','red','white','yellow','green','orange'];
			case 3: 
				Note.noteNames = ['purple','aqua','green','red','white','yellow','pink','blue','orange'];
			case 4:
				Note.noteNames = ['purple','aqua','white','green','red'];
			case 5:
				Note.noteNames = ['purple','aqua','green','red','yellow','pink','blue','orange'];
			case 6:
				Note.noteNames = ['white'];
			case 7:
				Note.noteNames = ['purple','red'];
			case 8:
				Note.noteNames = ['purple','white','red'];
			case 9:
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','aqua','green','red','magenta','cyan','yellow','pink','blue','orange'];
				else Note.noteNames = ['purple','aqua','green','red','cyan','magenta','yellow','pink','blue','orange'];
			case 10:
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','aqua','green','red','magenta','wintergreen','cyan','yellow','pink','blue','orange'];
				else Note.noteNames = ['purple','aqua','green','red','cyan','white','magenta','yellow','pink','blue','orange'];
			case 11:
				Note.noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','yellow','pink','blue','orange'];
			case 12:
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','aqua','green','red','lime','tango','wintergreen','canary','erin','yellow','pink','blue','orange'];
				else Note.noteNames = ['purple','aqua','green','red','lime','cyan','wintergreen','magenta','tango','yellow','pink','blue','orange'];
			case 13:
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','aqua','green','red','lime','tango','white','wintergreen','canary','erin','yellow','pink','blue','orange'];
				else Note.noteNames = ['purple','aqua','green','red','lime','cyan','tango','canary','magenta','tango','yellow','pink','blue','orange'];
			case 14:
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','aqua','green','red','lime','tango','magenta','wintergreen','violet','canary','erin','yellow','pink','blue','orange'];
				else Note.noteNames = ['purple','aqua','green','red','lime','cyan','tango','wintergreen','canary','magenta','tango','yellow','pink','blue','orange'];
			case 15:
				Note.noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 16:
				if(FlxG.save.data.AltMK) Note.noteNames = ['purple','aqua','green','red','wintergreen','lime','white','cyan','wintergreen','magenta','white','tango','wintergreen','yellow','pink','blue','orange'];
				else Note.noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','wintergreen','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 17:
				Note.noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','white','wintergreen','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
			case 18: // 21K
				Note.noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','lime','cyan','wintergreen','violet','erin','canary','scarlet','violet','erin','yellow','pink','blue','orange'];
		}
	}
}