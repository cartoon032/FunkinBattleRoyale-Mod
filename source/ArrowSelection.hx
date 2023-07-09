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
		DiscordClient.changePresence("Changing Arrow Skin",null);
		{ // Looks for all notes, This will probably be rarely accessed, so loading like this shouldn't be a problem
			searchList = ["default"];
			var dataDir:String = Sys.getCwd() + "mods/noteassets/";
			var customArrows:Array<String> = [];
			if (FileSystem.exists(dataDir))
			{
				for (file in FileSystem.readDirectory(dataDir))
				{
					if (file.endsWith(".png") && !file.endsWith("-bad.png") && !file.endsWith("-splash.png")){
						var name = file.substr(0,-4);
						if (FileSystem.exists('${dataDir}${name}.xml'))
						{
							customArrows.push(name);

						}
					}
				}
			}else{MainMenuState.handleError('mods/noteassets is not a folder!');}
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
		add(playerStrums);
		changeSelection();
		new FlxTimer().start(0.1, function(tmr)
		{
			updateInfoText('Press Tab to change mania - current mania ${PlayState.mania} with ${PlayState.keyAmmo[PlayState.mania]} Keys');
		});

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
		playerStrums.forEach(
			function(arrow:StrumArrow){
				switch(curBeat % 3){
					case 0:arrow.playStatic(); 
					case 1:arrow.press(); 
					case 2:arrow.confirm();
				}
			}
		);
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
			case 0:Note.noteNames = ['purple','aqua','green','red'];
			case 1:Note.noteNames = ['purple','aqua','red','yellow','green','orange'];
			case 2:Note.noteNames = ['purple','aqua','red','white','yellow','green','orange'];
			case 3:Note.noteNames = ['purple','aqua','green','red','white','yellow','pink','blue','orange'];
			case 4:Note.noteNames = ['purple','aqua','white','green','red'];
			case 5:Note.noteNames = ['purple','aqua','green','red','yellow','pink','blue','orange'];
			case 6:Note.noteNames = ['white'];
			case 7:Note.noteNames = ['purple','red'];
			case 8:Note.noteNames = ['purple','white','red'];
			case 9:Note.noteNames = ['purple','aqua','green','red','cyan','magenta','yellow','pink','blue','orange'];
			case 10:Note.noteNames = ['purple','aqua','green','red','cyan','white','magenta','yellow','pink','blue','orange'];
			case 11:Note.noteNames = ['purple','aqua','green','red','lime','cyan','magenta','tango','yellow','pink','blue','orange'];
			case 12:Note.noteNames = ['purple','aqua','green','red','lime','cyan','white','magenta','tango','yellow','pink','blue','orange'];
		}
	}
}