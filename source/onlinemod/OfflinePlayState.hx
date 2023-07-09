package onlinemod;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
import sys.thread.Lock;
import sys.thread.Thread;

import Section.SwagSection;

class OfflinePlayState extends PlayState
{
	public static var instanc:OfflinePlayState;
	public var loadedVoices:FlxSound;
	public var loadedInst:Sound;
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
	public static var stateNames:Array<String> = ["-freep","","-Offl","","-Multi","-OSU","-Story","","",""];
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
		var lock = new Lock();
		sys.thread.Thread.create(() -> { // Offload to another thread for faster loading
		#end
			if(!(lastVoicesFile == voicesFile && loadedVoices != null)){
				if(voicesFile == ""){
					for (i in ['assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Voices.ogg','assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Voices.ogg','assets/onlinedata/songs/${PlayState.SONG.song}/Voices.ogg','assets/onlinedata/songs/${PlayState.songDir.toLowerCase()}/Voices.ogg']) {
						trace('looking for voice at $i');
						if (FileSystem.exists('${Sys.getCwd()}/$i')){
							voicesFile = i;
							break;
						}
					}
				}
				if(voicesFile != ""){loadedVoices = SELoader.loadFlxSound(voicesFile);}
				if(voicesFile == "" && PlayState.SONG != null){
					loadedVoices =  new FlxSound();
					PlayState.SONG.needsVoices = false;
				}
				if(loadedVoices.length < 1){
					trace('Voices.ogg didn\'t load properly. Try converting to MP3 and then into OGG Vorbis');
				}

			}
		#if(target.threaded)
			lock.release();
		});
		#end
			if(!(lastInstFile == instFile && loadedInst != null)){ // This doesn't need to be threaded
				if(instFile == ""){

					for (i in ['assets/onlinedata/songs/${PlayState.actualSongName.toLowerCase()}/Inst.ogg','assets/onlinedata/songs/${PlayState.SONG.song.toLowerCase()}/Inst.ogg','assets/onlinedata/songs/${PlayState.SONG.song}/Inst.ogg','assets/onlinedata/songs/${PlayState.songDir.toLowerCase()}/Inst.ogg']) {
						trace('looking for inst at $i');
						if (FileSystem.exists('${Sys.getCwd()}/$i')){
							instFile = i;
							break;
						}
					}
					if (instFile == ""){MainMenuState.handleError('${PlayState.actualSongName} is missing a inst file!');}

				}
				loadedInst = SELoader.loadSound(instFile);
			}
		#if(target.threaded)
		lock.wait();
		#end
		if(loadedVoices != null)loadedVoices.time = 0;

		lastInstFile = instFile;
		lastVoicesFile = voicesFile;
		loadedVoices.persist = true;
	trace('Loading $voicesFile, $instFile');
	
  }
function loadJSON(){
	try{
		if (!ChartingState.charting)
			{
				PlayState.SONG = Song.parseJSONshit(File.getContent(chartFile));
				if(nameSpace != ""){
				if(TitleState.retChar(nameSpace + "|" + PlayState.player2) != null){
					PlayState.player2 = nameSpace + "|" + PlayState.player2;
				}
				if(TitleState.retChar(nameSpace + "|" + PlayState.SONG.player1) != null){
					PlayState.player1 = nameSpace + "|" + PlayState.player1;
				}
			}
		}
	}catch(e) MainMenuState.handleError('Error loading chart \'${chartFile}\': ${e.message}');
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
	    var xieneDevWatermark:FlxText = new FlxText(-4, FlxG.height * 0.1 - 50, FlxG.width, "SE-T" + stateNames[stateType] + " " + MainMenuState.ver + "-" + MainMenuState.modver, 16);
			xieneDevWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			xieneDevWatermark.scrollFactor.set();
			add(xieneDevWatermark);
	    xieneDevWatermark.cameras = [camHUD];


	    FlxG.mouse.visible = false;
	    FlxG.autoPause = true;
	    if(willChart){
	    	QuickOptionsSubState.setSetting("Song hscripts",oldScripts);
			FlxG.switchState(new ChartingState());
	    }
	  }catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}
	}

  override function startSong(?alrLoaded:Bool = false)
  {
    if (shouldLoadJson) FlxG.sound.playMusic(loadedInst, 1, false);

    // We be good and actually just use an argument to not load the song instead of "pausing" the game
    super.startSong(true);
  }
  override function generateSong(?dataPath:String = "")
  {
  //   // I have to code the entire code over so that I can remove the offset thing
  //   var songData = PlayState.SONG;
		// Conductor.changeBPM(songData.bpm);

		// curSong = songData.song;

		if (PlayState.SONG.needsVoices && loadedVoices.length > Math.max(4000,loadedInst.length - 20000) && loadedVoices.length < loadedInst.length + 10000)
			vocals = loadedVoices;
		else
			vocals = new FlxSound();
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


