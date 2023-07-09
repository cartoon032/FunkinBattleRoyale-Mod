package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

using StringTools;

import Discord.DiscordClient;
class OnlineResultState extends MusicBeatState
{
  var clients:Map<Int, String>;
  var ChatBGBox:FlxSprite;

  public function new(clients:Map<Int, String>)
  {
    super();

    this.clients = clients;
  }

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(SearchMenuState.background);
    bg.color = 0xF1A0B1;
		add(bg);


    var topText:FlxText = new FlxText(0, FlxG.height * 0.05, "Results");
    topText.setFormat(CoolUtil.font, 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    topText.screenCenter(FlxAxes.X);
    add(topText);


    var backButton = new FlxUIButton(10, 10, "Back to Lobby", () -> {
      FlxG.switchState(new OnlineLobbyState(true));
    });
    backButton.setLabelFormat(28, FlxColor.BLACK, CENTER);
    backButton.resize(300, FlxG.height * 0.1);
    add(backButton);


    var orderedKeys:Array<Int> = [for(k in OnlinePlayState.clientScores.keys()) k];
    orderedKeys.sort((a, b) -> OnlinePlayState.clientScores[b] - OnlinePlayState.clientScores[a]);

    var x:Int = 0;
    for (i in orderedKeys)
    {
      var name:String = clients[i];
      var score = OnlinePlayState.clientText[i];
      if (score == null) score = "N/A";
      if (name == null) name = "N/A";
      var text:FlxText = new FlxText(0, FlxG.height*0.2 + 30*x, '${x+1}. $name: $score');

      if (i == -1)
        text.text += " (YOU)";

      var color:FlxColor = FlxColor.WHITE;
      if (!OnlineLobbyState.clients.exists(i) && i != -1)
        color = FlxColor.RED;

      text.setFormat(CoolUtil.font, 24, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      text.screenCenter(FlxAxes.X);
      add(text);
      x++;
    }

    ChatBGBox = new FlxSprite().makeGraphic(FlxG.width, 175, 0x7F3F3F3F); // #3F3F3F
    ChatBGBox.setPosition(0, FlxG.height - 290);
    add(ChatBGBox);
    Chat.createChat(this,true);
    Chat.CreateHideButton(this);

    FlxG.sound.music.time = 0;
    FlxG.sound.music.resume();

    OnlinePlayMenuState.receiver.HandleData = HandleData;

    FlxG.mouse.visible = true;
    FlxG.autoPause = false;

    super.create();
    DiscordClient.changePresence('Looking at Result Screen with ${onlinemod.OnlineLobbyState.clientCount} player' + (onlinemod.OnlineLobbyState.clientCount > 1 ? 's' : ''),if(FlxG.save.data.ShowConnectedIP)'IP : ${FlxG.save.data.lastServer}:${FlxG.save.data.lastServerPort}' else null,false,null,(onlinemod.OnlineLobbyState.clientCount <= 1 ? 'empty-' : '') + "online-lobby");
  }

  function HandleData(packetId:Int, data:Array<Dynamic>)
  {
    OnlinePlayMenuState.RespondKeepAlive(packetId);
    switch (packetId)
    {
      case Packets.BROADCAST_NEW_PLAYER:
        var id:Int = data[0];
        var nick:String = data[1];

        OnlineLobbyState.addPlayer(id, nick);
        Chat.PLAYER_JOIN(nick);
        DiscordClient.changePresence('Looking at Result Screen with ${onlinemod.OnlineLobbyState.clientCount} player' + (onlinemod.OnlineLobbyState.clientCount > 1 ? 's' : ''),if(FlxG.save.data.ShowConnectedIP)'IP : ${FlxG.save.data.lastServer}:${FlxG.save.data.lastServerPort}' else null,false,null,(onlinemod.OnlineLobbyState.clientCount <= 1 ? 'empty-' : '') + "online-lobby");
      case Packets.PLAYER_LEFT:
        var id:Int = data[0];
        var nickname:String = OnlineLobbyState.clients[id];

        Chat.PLAYER_LEAVE(nickname);
        OnlineLobbyState.removePlayer(id);
        DiscordClient.changePresence('Looking at Result Screen with ${onlinemod.OnlineLobbyState.clientCount} player' + (onlinemod.OnlineLobbyState.clientCount > 1 ? 's' : ''),if(FlxG.save.data.ShowConnectedIP)'IP : ${FlxG.save.data.lastServer}:${FlxG.save.data.lastServerPort}' else null,false,null,(onlinemod.OnlineLobbyState.clientCount <= 1 ? 'empty-' : '') + "online-lobby");
      case Packets.GAME_START:
        var jsonInput:String = data[0];
        var folder:String = data[1];

        OnlineLobbyState.StartGame(jsonInput, folder);

      case Packets.BROADCAST_CHAT_MESSAGE:
        var id:Int = data[0];
        var message:String = data[1];

        Chat.MESSAGE(OnlineLobbyState.clients[id], message);
      case Packets.REJECT_CHAT_MESSAGE:
        Chat.SPEED_LIMIT();
      case Packets.MUTED:
        Chat.MUTED();
      case Packets.SERVER_CHAT_MESSAGE:
         if(StringTools.startsWith(data[0],"'32d5d167'")) OnlineLobbyState.handleServerCommand(data[0].toLowerCase(),0); else Chat.SERVER_MESSAGE(data[0]);

      case Packets.DISCONNECT:
        FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
    }
  }

  override function update(elapsed:Float)
  {
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, onlinemod.OnlineLobbyState.Speed);
		}
    if (Chat.chatField.hasFocus && FlxG.keys.justPressed.ENTER)
      Chat.SendChatMessage();
    Chat.update(elapsed);
    ChatBGBox.visible = Chat.hidechat;
    if (FlxG.keys.justPressed.ESCAPE)
      FlxG.switchState(new OnlineLobbyState(true));
    super.update(elapsed);
		FlxG.mouse.visible = true;
  }
}
