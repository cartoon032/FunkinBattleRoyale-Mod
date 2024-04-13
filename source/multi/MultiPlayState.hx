package multi;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSubState;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;

import Section.SwagSection;

class MultiPlayState extends onlinemod.OfflinePlayState
{
  public static var scriptLoc= "";
  override function create()
    {try{
    if (scriptLoc != "" ) PlayState.songScript = File.getContent(scriptLoc); else PlayState.songScript = "";
    if(!PlayState.isStoryMode) stateType=4;
  	super.create();

  }catch(e){MainMenuState.handleError('Caught "create" crash: ${e.message}');}}
}