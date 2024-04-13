package onlinemod;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;
import se.ThreadedAction;

import Section.SwagSection;

using StringTools;

class OfflinePlayState extends PlayState {
	public static var instanc:OfflinePlayState;
	// public var loadedVoices:FlxSound;
	public static var loadedVoices_:FlxSound;
	public var loadedVoices(get,set):FlxSound;
	public function get_loadedVoices(){
		return loadedVoices_;
	}
	public function set_loadedVoices(vari){
		return loadedVoices_ = vari;
	}
	public static var loadedInst_:Sound;
	// public var loadedInst:Sound;
	public var loadedInst(get,set):Sound;
	public function get_loadedInst(){
		return loadedInst_;
	}
	public function set_loadedInst(vari){
		return loadedInst_ = vari;
	}
	public var xieneDevWatermark:FlxText;
	var loadingtext:FlxText;
	var shouldLoadJson:Bool = true;
	var stateType = 2;
	var shouldLoadSongs = true;
	public static var voicesFile = "";
	public static var instFile = "";
	public static var lastInstFile = "";
	public static var lastVoicesFile = "";
	public static var chartFile:String = "";
	public static var nameSpace:String = "";
	public static var stateNames:Array<String> = ["","-freep","-Offl","","-Multi","-OSU","-Story","","",""];
	var willChart:Bool = false;
	override public function new(?charting:Bool = false){
		willChart = charting;
		super();
	}

	function loadSongs(){
		LoadingScreen.loadingText = "Loading music";
		if(lastVoicesFile != voicesFile && loadedVoices != null){
			loadedVoices.destroy();
		}
		#if(target.threaded)
		var voicesThread = new ThreadedAction(() -> { // Offload to another thread for faster loading
		#end
			if(loadedVoices == null || lastVoicesFile != voicesFile){
				if(voicesFile == null || voicesFile == ""){
					voicesFile = SELoader.anyExists([
							'assets/onlinedata/songs/${chartFile.substring(chartFile.lastIndexOf('/')+1,chartFile.lastIndexOf('.'))}/Voices.ogg',
							'assets/onlinedata/songs/${PlayState.songDir}/Voices.ogg',
							'assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Voices.ogg',
							'assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Voices.ogg'
						],"");
				}
				if(voicesFile != ""){
					try{
						loadedVoices = SELoader.loadFlxSound(voicesFile);
					}catch(e){
						trace('Unable to load voices ${e.details()}');
						loadedVoices = new FlxSound();
						PlayState.SONG.needsVoices = false;
					}
				}else if(voicesFile == "" && PlayState.SONG != null){
					loadedVoices = new FlxSound();
					PlayState.SONG.needsVoices = false;
				}
				if(loadedVoices.length < 1){
					trace('Voices.ogg didn\'t load properly. Try converting to MP3 and then into OGG Vorbis');
				}

			}
		#if(target.threaded)
		});
		#end

		if(loadedInst == null || lastInstFile != instFile){ // This doesn't need to be threaded
			try{

				if(instFile == null || instFile == ""){
					var list = [
							'assets/onlinedata/songs/${chartFile.substring(chartFile.lastIndexOf('/')+1,chartFile.lastIndexOf('.'))}/Inst.ogg',
							'assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Inst.ogg',
							'assets/onlinedata/songs/${PlayState.songDir.toLowerCase()}/Inst.ogg',
							'assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Inst.ogg'
						];
					instFile = SELoader.anyExists(list,"");
				}
				if (instFile == null || instFile == ""){ // why the fuck is instFile null? :sob:
					throw('${PlayState.actualSongName} is missing a inst file!');
				}
				loadedInst = SELoader.loadSound(instFile);
			}catch(e){
				return MainMenuState.handleError('Error occurred while trying to load inst:${e.details()}');
			}
		}
		#if(target.threaded)
		voicesThread.wait();
		#end
		if(loadedVoices != null)loadedVoices.time = 0;

		lastInstFile = instFile;
		lastVoicesFile = voicesFile;
		loadedVoices.persist = true;
	trace('Loading $voicesFile, $instFile');
	
  }
	override function destroy(){
		if(loadedVoices != null){loadedVoices.pause();loadedVoices.time = 0;}
		super.destroy();
	}
  function loadJSON(){
	try{

		LoadingScreen.loadingText = "Loading chart JSON";
		if (!ChartingState.charting) {
				PlayState.SONG = Song.parseJSONshit(SELoader.getContent(chartFile));
		}
	}catch(e) throw('Error loading chart \'${chartFile}\': ${e.message}');
  }
	override function create()
	{
	try{
		instanc = this;
		if (shouldLoadJson) loadJSON();

		PlayState.stateType=stateType;

		if (shouldLoadSongs) loadSongs();

		var oldScripts:Bool = false;
		if(willChart){ // Loading scripts is redundant when we're just going to go into charting state
			oldScripts = QuickOptionsSubState.getSetting("Song hscripts");
			QuickOptionsSubState.setSetting("Song hscripts",false);
		}
		super.create();


		// Add XieneDev watermark
		xieneDevWatermark = new FlxText(-4, FlxG.height * 0.1 - 50, FlxG.width, 'SuperEngine${stateNames[stateType]}\n${MainMenuState.modver}(${MainMenuState.buildType})', 16)
			.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			xieneDevWatermark.scrollFactor.set();
			add(xieneDevWatermark);
		xieneDevWatermark.cameras = [camHUD];


		FlxG.mouse.visible = false;
		FlxG.autoPause = true;
		if(willChart){
			QuickOptionsSubState.setSetting("Song hscripts",oldScripts);
			FlxG.switchState(new ChartingState());
		}
	  }catch(e){MainMenuState.handleError(e,'Caught "create" crash: ${e.message}');}
	}
  override function startSong(?alrLoaded:Bool = false)
  {
    if (shouldLoadJson) FlxG.sound.playMusic(loadedInst, 1, false);

    // We be good and actually just use an argument to not load the song instead of "pausing" the game
    super.startSong(true);
  }
  override function generateSong(?dataPath:String = "")
  {
	vocals = ((PlayState.SONG.needsVoices && Math.abs(loadedVoices.length - loadedInst.length) < 20000) ? loadedVoices : new FlxSound());
    super.generateSong(dataPath);

  }
  override function endSong()
  {
  	if(PlayState.isStoryMode){
  		super.endSong();
  	}else{

	    canPause = false;
	    FlxG.sound.music.onComplete = null;
	  	if (ChartingState.charting){FlxG.switchState(new ChartingState());return;}
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

	    	super.openSubState(new FinishSubState(PlayState.boyfriend.getScreenPosition().x, PlayState.boyfriend.getScreenPosition().y,true));
  	}
  }
}


