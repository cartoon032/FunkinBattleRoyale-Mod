package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIText;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

import sys.io.File;
import sys.FileSystem;

import Discord.DiscordClient;
using StringTools;

class OfflineMenuState extends SearchMenuState
{
  var sideButton:FlxUIButton;

  // var songs:Array<String> = [];
  var songFiles:Array<String> = [];
  var songDirs:Array<String> = [];
  var dataDir:String = "assets/onlinedata/data/";
  var optionsButton:FlxUIButton;
  var invertedChart:Bool = false;
	var SpeedText:FlxText;
	var Speedtwee:FlxTween;
	public static var rate:Float = 1.0;

  function goOptions(){
      FlxG.mouse.visible = false;
      OptionsMenu.lastState = 3;
      FlxG.switchState(new OptionsMenu());
  }
  function chartOptions(){
      openSubState(new QuickOptionsSubState());
  }
  override function create()
  {
    DiscordClient.changePresence('Browsing Offline Menu',null);
    PlayState.sectionStart = false;
    scriptSubDirectory = "/offlinemenu/";
    useNormalCallbacks = true;
    loadScripts(true);
		PlayState.hsBrToolsPath = "assets/";
    super.create();
    optionsButton = new FlxUIButton(1120, 30, "Options", goOptions);
    optionsButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    optionsButton.resize(150, 30);
    add(optionsButton);
    sideButton = new FlxUIButton(1020, 65, "Chart Options", chartOptions);
    sideButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
    sideButton.resize(250, 30);
    add(sideButton);
		SpeedText = new FlxText(0, 5, 0, "Song Speed : " + rate + "x", 24);
		SpeedText.font = CoolUtil.font;
    SpeedText.setFormat(CoolUtil.font, 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		SpeedText.borderSize = 1;
		SpeedText.alignment = CENTER;
		SpeedText.screenCenter(X);
		add(SpeedText);
  }
  function sortDirListing(listing:Array<String>){
    
    return listing;
  }
  override function reloadList(?reload=false,?search = ""){
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = [];
    songFiles = [];
    songDirs = [];
    var i:Int = 0;

    var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
    if (FileSystem.exists(dataDir))
    {
      var dirs = orderList(FileSystem.readDirectory(dataDir));
      for (directory in dirs)
      {
        for (file in FileSystem.readDirectory(dataDir + directory))
        {
          if ( StringTools.endsWith(file, '.json') && (search == "" || query.match(file.toLowerCase())) ) // Handles searching
          {
            songs.push(dataDir + directory + "/" + file);
            songFiles.push(file);
            songDirs.push(directory);

            var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, file.substr(0, file.length - 5), true, false);
            controlLabel.isMenuItem = true;
            controlLabel.targetY = i;
            if (i != 0)
              controlLabel.alpha = 0.6;
            grpSongs.add(controlLabel);

            i++;
          }
        }
      }
    }
  }

  override function ret(){
    FlxG.mouse.visible = false;
    FlxG.switchState(new MainMenuState());
  }
  override function extraKeys(){
    if (FlxG.keys.justPressed.R && !FlxG.keys.pressed.SHIFT){
      changeSelection(FlxG.random.int(-curSelected,grpSongs.length - curSelected));
    }
		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.justPressed.LEFT)
				{
					if(Speedtwee != null)Speedtwee.cancel();
					SpeedText.scale.set(1.2,1.2);
					Speedtwee = FlxTween.tween(SpeedText.scale,{x:1,y:1},(30 / Conductor.bpm));
					rate -= 0.05 * (FlxG.keys.pressed.ALT ? 5 : 1);
				}
			if (FlxG.keys.justPressed.RIGHT)
				{
					if(Speedtwee != null)Speedtwee.cancel();
					SpeedText.scale.set(1.2,1.2);
					Speedtwee = FlxTween.tween(SpeedText.scale,{x:1,y:1},(30 / Conductor.bpm));
					rate += 0.05 * (FlxG.keys.pressed.ALT ? 5 : 1);
				}
			if (FlxG.keys.justPressed.R)
				{
					if(Speedtwee != null)Speedtwee.cancel();
					SpeedText.scale.set(1.2,1.2);
					Speedtwee = FlxTween.tween(SpeedText.scale,{x:1,y:1},(30 / Conductor.bpm));
					rate = 1;
				}

			else if (rate < 0.25)
				rate = 0.25;
			SpeedText.text = "Song Speed : " + HelperFunctions.truncateFloat(rate, 2) + "x";
		}
  }
  override function select(sel:Int = 0){
      FlxG.sound.music.fadeOut(0.4);
      OfflinePlayState.chartFile = songs[curSelected];
      PlayState.songScript = "";
      PlayState.isStoryMode = false;
      var songName = songFiles[curSelected];
      PlayState.songDir = songDirs[curSelected];
      // Set difficulty
      PlayState.storyDifficulty = 1;
      PlayState.songspeed = rate;
      if (StringTools.endsWith(songs[curSelected], '-hard.json'))
      {
        songName = songName.substr(0,songName.indexOf('-hard.json'));
        PlayState.storyDifficulty = 2;
      }
      else if (StringTools.endsWith(songs[curSelected], '-easy.json'))
      {
        songName = songName.substr(0,songName.indexOf('-easy.json'));
        PlayState.storyDifficulty = 0;
      }
      PlayState.actualSongName = songName;

      LoadingState.loadAndSwitchState(new OfflinePlayState());
  }
  override function update(e){
		super.update(e);
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, rate);
		}
  }
}