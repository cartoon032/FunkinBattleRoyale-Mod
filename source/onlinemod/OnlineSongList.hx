package onlinemod;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

import Discord.DiscordClient;
using StringTools;

class OnlineSongList extends OfflineMenuState
{
	public static var songLists:Array<Array<String>> = [[]];
  var modes:Map<Int,Array<String>> = [];
	var selMode:Int = 0;
	public static var listVersion:Int = 0;
	public static var pickedsong:String = '';
	var diffText:FlxText;
	var ChatBGBox:FlxSprite;
  override function create()
  {
	OnlinePlayMenuState.receiver.HandleData = HandleData;
	bgColor = 0xF1A0B1;
	scriptSubDirectory = '/onlinesonglist/';
  useNormalCallbacks = true;
  loadScripts(true);
  super.create();
	DiscordClient.changePresence('Browsing Server Song Menu',null);
  ChatBGBox = new FlxSprite().makeGraphic(FlxG.width, 175, 0x7F3F3F3F); // #3F3F3F
  ChatBGBox.setPosition(0, FlxG.height - 250);
  add(ChatBGBox);
  Chat.createChat(this,false);
	diffText = new FlxText(0, 5, FlxG.width, "", 24);
	diffText.font = CoolUtil.font;
	diffText.borderSize = 2;
  diffText.alignment = CENTER;
  diffText.screenCenter(X);
	add(diffText);
	remove(optionsButton);
	remove(sideButton);
	remove(SpeedText);
  changeDiff();
  updateInfoText("Use shift to scroll faster; " + (OnlineLobbyState.isAdmin ? "You are an admin! Pick a song for people to play." : "You are not an admin. Pick a song to show people what you want to play."));
  }
  override function reloadList(?reload=false,?search = ""){
    curSelected = 0;
    if(reload){grpSongs.destroy();}
    grpSongs = new FlxTypedGroup<Alphabet>();
    add(grpSongs);
    songs = ["Nothing"];
    songFiles = [];
    songDirs = [];
		modes = [0 => ["None"]];
    var lastsong:String = "";
    var order:Int = 0;
    var songorder:Int = -1;

    var query = new EReg((~/[-_ ]/g).replace(search.toLowerCase(),'[-_ ]'),'i'); // Regex that allows _ and - for songs to still pop up if user puts space, game ignores - and _ when showing
    for (file in songLists)
    {
      if (search == "" || query.match(file[0].toLowerCase())) // Handles searching
      {
        if(lastsong != file[1]){
          songorder++;
          lastsong = file[1];
          modes[songorder] = [];
          var controlLabel:Alphabet = new Alphabet(0, (70 * order) + 30, file[1], true, false);
          controlLabel.isMenuItem = true;
          controlLabel.targetY = order;
          if (order != 0)
            controlLabel.alpha = 0.6;
          grpSongs.add(controlLabel);
          order++;
        }
        songs[songorder] = file[1]+"\n"+file[0] + "\n";
        // songFiles[songorder] = file[0];
        modes[songorder].push(file[0]);
        songDirs[songorder] = file[1];
      }
    }
  }

	function changeDiff(change:Int = 0,?forcedInt:Int= -100){ // -100 just because it's unlikely to be used
		if (songs.length == 0 || songs[curSelected] == null || songs[curSelected] == "") {
			diffText.text = 'No song selected';
			return;
		}
		// diffText.text = songs[curSelected];
		if (forcedInt == -100) selMode += change; else selMode = forcedInt;
		if (selMode >= modes[curSelected].length) selMode = 0;
		if (selMode < 0) selMode = modes[curSelected].length - 1;
    diffText.text = (if(modes[curSelected][selMode - 1 ] != null ) '< ' else '|  ') + modes[curSelected][selMode] + (if(modes[curSelected][selMode + 1 ] != null) ' >' else '  |');
	}

  override function ret(){
    if(Chat.chatField.hasFocus)
      return;
    FlxG.mouse.visible = true;
    FlxG.switchState(new OnlineLobbyState(true));
  }
  override function extraKeys(){
    if (FlxG.keys.justPressed.R)
      changeSelection(FlxG.random.int(-curSelected,songs.length - curSelected));
		if(controls.LEFT_P && !FlxG.keys.pressed.SHIFT){changeDiff(-1);}
		if(controls.RIGHT_P && !FlxG.keys.pressed.SHIFT){changeDiff(1);}
		if(FlxG.mouse.justPressedMiddle){
			changeDiff(1);
		}
		changeDiff();
  }
  override function select(sel:Int = 0){
    if(Chat.chatField.hasFocus)
      return;
    pickedsong = '${modes[sel][selMode]} ${songDirs[sel]}';
    FlxG.switchState(new OnlineLobbyState(true));
  }
  override function update(elapsed:Float) {
    super.update(elapsed);
    ChatBGBox.visible = Chat.hidechat;
    if(!searchField.hasFocus){
      if(((!Chat.hidechat && FlxG.keys.justPressed.T) || (Chat.hidechat && FlxG.keys.justPressed.ESCAPE)))
        Chat.toggleChat();
      if(FlxG.keys.justPressed.ESCAPE)
        Chat.chatField.hasFocus = false;
      if(FlxG.keys.justPressed.T)
        Chat.chatField.hasFocus = true;
      if (Chat.chatField.hasFocus && FlxG.keys.justPressed.ENTER)
        Chat.SendChatMessage();
    }
		Chat.update(elapsed);
  }
}