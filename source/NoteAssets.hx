package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;

class NoteAssets{
	public static var name:Array<String> = [];
	static var path:String = "mods/noteassets"; // The slash not being here is just for ease of reading
	public static var image:Array<FlxGraphic> = [];
	public static var xml:Array<String> = [];
	public static var splashImage:FlxGraphic; // Is this getting cleared or something?
	public static var splashXml:String;
	public static var badImage:FlxGraphic;
	public static var badXml:String;
	public static var splashType:String = "se";
	static var splTypes:Array<String> = [
		"se",
		"psych",
		"vanilla",
		"custom"
	];
	function perm(){
		for (i in [badImage,splashImage]){
			i.destroyOnNoUse = false;
			i.persist = true;
		}
		for (i in image){
			if(i != null){
				i.destroyOnNoUse = false;
				i.persist = true;
			}
		}
	}
	public function new(name_:Array<String>):Void{
		name = name_;
		while(image.length > 0){
			var _image = image.pop();_image.destroy();
			var _xml = xml.pop();_xml.destroy();
		}
		doThing();
		perm(); // Prevents Flixel from being flixel and unloading things

	}
	static function doThing(){
		try{
			trace('Loading noteAssets');
			splashType = "se";
			if (name[0] == 'default'){
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
				// genSplashes();
				for(skin in 0...name.length){
					if(name[skin] != null){
						if(name[skin] == "default"){
							image[skin] = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/T_Mod_NOTE_assets.png'));
							xml[skin] = File.getContent("assets/shared/images/T_Mod_NOTE_assets.xml");
						}
						else if(!FileSystem.exists('${path}/${name[skin]}.png') || !FileSystem.exists('${path}/${name[skin]}.xml'))
							MainMenuState.handleError('${name[skin]} isn\'t a valid note asset!');
						else{
							image[skin] = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name[skin]}.png'));
							xml[skin] = File.getContent('${path}/${name[skin]}.xml');
						}
					}
				}
				splashImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/T_Mod_noteSplashes.png'));
				splashXml = File.getContent("assets/shared/images/T_Mod_noteSplashes.xml");
				return;
			} // Default arrows

			if (FileSystem.exists('${path}/${name[0]}-splash.png') && FileSystem.exists('${path}/${name[0]}-splash.xml')){ // Splashes
				splashImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name[0]}-splash.png'));
				splashXml = File.getContent('${path}/${name[0]}-splash.xml');
				if(FileSystem.exists('${path}/${name[0]}-splashType.json')){
					var _Type = File.getContent('${path}/${name[0]}-splash.xml').toLowerCase();
					if(splTypes.contains(_Type)){
						splashType = _Type;
					}
				}
			}else{
				splashImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/T_Mod_noteSplashes.png'));
				splashXml = File.getContent("assets/shared/images/T_Mod_noteSplashes.xml");
			}

			if (FileSystem.exists('${path}/${name[0]}-bad.png') && FileSystem.exists('${path}/${name[0]}-bad.xml')){ // Hurt notes
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name[0]}-bad.png'));
				badXml = File.getContent('${path}/${name[0]}-bad.xml');
			}else{
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
			}

			for(skin in 0...name.length){
				if(name[skin] != null){
					if(name[skin] == "default"){
						image[skin] = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/T_Mod_NOTE_assets.png'));
						xml[skin] = File.getContent("assets/shared/images/T_Mod_NOTE_assets.xml");
					}
					else if(!FileSystem.exists('${path}/${name[skin]}.png') || !FileSystem.exists('${path}/${name[skin]}.xml'))
						MainMenuState.handleError('${name[skin]} isn\'t a valid note asset!');
					else{
						image[skin] = FlxGraphic.fromBitmapData(BitmapData.fromFile('${path}/${name[skin]}.png'));
						xml[skin] = File.getContent('${path}/${name[skin]}.xml');
					}
				}
			}

			if (badImage == null) {
				badImage = FlxGraphic.fromBitmapData(BitmapData.fromFile('assets/shared/images/NOTE_assets_bad.png'));
				badXml = File.getContent("assets/shared/images/NOTE_assets_bad.xml");
			}
			return;

		}catch(e){MainMenuState.handleError('Error occurred while loading notes ${e.message}');}
	}
}