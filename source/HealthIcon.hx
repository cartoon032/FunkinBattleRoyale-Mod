package;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;
import flash.display.BitmapData;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	var vanIcon:Bool = false;
	var isPlayer:Bool = false;
	var isMenuIcon:Bool = false;

	public function new(?char:String = 'bf', ?isPlayer:Bool = false,?clone:String = "",?isMenuIcon:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		this.isMenuIcon = isMenuIcon;
		changeSprite(char,"");
	}

	public function updateAnim(health:Float){
		if (health < 20)
			animation.curAnim.curFrame = 1;
		else if (health > 80)
			{animation.curAnim.curFrame = 2;if(animation.curAnim.curFrame == 1) animation.curAnim.curFrame = 0;}
		else
			animation.curAnim.curFrame = 0;
	}

	public function changeSprite(?char:String = 'bf',?clone:String = "face",?useClone:Bool = true)
	{
		var chars:Array<String> = ["bf","spooky","pico","mom","mom-car",'parents-christmas',"senpai","senpai-angry","spirit","spooky","bf-pixel","gf","dad","monster","monster-christmas","parents-christmas","bf-old","gf-pixel","gf-christmas","face","tankman"];
		var relAnims:Bool = true;
		if (!chars.contains(char) &&FileSystem.exists(Sys.getCwd() + "mods/characters/"+char+"/healthicon.png")){
			// trace('Custom character with custom icon! Loading custom icon.');
			loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$char/healthicon.png')), true, 150, 150);
			char = "bf";
			vanIcon = false;
		}else if ((chars.contains(char) || chars.contains(clone)) && FileSystem.exists(Sys.getCwd() + "mods/characters/"+char+"/icongrid.png")){
			// trace('Custom character with custom icongrid! Loading custom icon.');
			loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/characters/$char/icongrid.png')), true, 150, 150);
			if (clone != "") char = clone;
			vanIcon = false;
		}else{
			if (clone != "" && (useClone || !chars.contains(char))) char = clone;
			if (!vanIcon) loadGraphic(Paths.image('iconGrid'), true, 150, 150); else relAnims = false;
			vanIcon = true;
		}
		
		antialiasing = true;
		animation.add('bf', [0, 1, 2], 0, false, isPlayer);
		if(chars.contains(char.toLowerCase())){ // For vanilla characters
			if (relAnims){
				animation.add('bf-car', [0, 1, 2], 0, false, isPlayer);
				animation.add('bf-christmas', [0, 1, 2], 0, false, isPlayer);
				animation.add('bf-pixel', [20], 0, false, isPlayer);
				animation.add('spooky', [6, 7], 0, false, isPlayer);
				animation.add('pico', [10, 11], 0, false, isPlayer);
				animation.add('mom', [12, 13], 0, false, isPlayer);
				animation.add('mom-car', [12, 13], 0, false, isPlayer);
				animation.add('tankman', [18, 19], 0, false, isPlayer);
				animation.add('face', [23, 24], 0, false, isPlayer);
				animation.add('dad', [4, 5], 0, false, isPlayer);
				animation.add('senpai', [16], 0, false, isPlayer);
				animation.add('senpai-angry', [16], 0, false, isPlayer);
				animation.add('spirit', [17], 0, false, isPlayer);
				animation.add('bf-old', [21, 22], 0, false, isPlayer);
				animation.add('gf', [3], 0, false, isPlayer);
				animation.add('gf-christmas', [16], 0, false, isPlayer);
				animation.add('gf-pixel', [16], 0, false, isPlayer);
				animation.add('parents-christmas', [14, 15], 0, false, isPlayer);
				animation.add('monster', [8, 9], 0, false, isPlayer);
				animation.add('monster-christmas', [8, 9], 0, false, isPlayer);
			}
			animation.play(char.toLowerCase());
		}else{trace('Invalid character icon $char, Using BF!');animation.play("bf");}
		switch(char)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				antialiasing = false;
		}

		scrollFactor.set();
		if(isMenuIcon) offset.set(75,75);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
