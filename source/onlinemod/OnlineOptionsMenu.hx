package onlinemod;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import Discord.DiscordClient;

class OnlineOptionsMenu extends OptionsMenu
{
	public static var instance:OnlineOptionsMenu;
	var ChatBGBox:FlxSprite;
	override function create()
	{
		OnlinePlayMenuState.receiver.HandleData = HandleData;
		DiscordClient.changePresence("In Online Option Menu",null);
		ChatBGBox = new FlxSprite().makeGraphic(FlxG.width, 175, 0x7F3F3F3F); // #3F3F3F
		ChatBGBox.setPosition(0, FlxG.height - 250);
		add(ChatBGBox);
		Chat.createChat(this,false);
		super.create();
	}
  static function HandleData(packetId:Int, data:Array<Dynamic>)
  {
	if(onlinemod.OnlinePlayMenuState.RespondKeepAlive(packetId)) return;
	try{

	  switch (packetId)
	  {
		case Packets.BROADCAST_NEW_PLAYER:
		  var id:Int = data[0];
		  var nickname:String = data[1];

		  // OnlineLobbyState.addPlayerUI(id, nickname);
		  OnlineLobbyState.addPlayer(id, nickname);
		  if (OnlineLobbyState.receivedPrevPlayers)
			Chat.PLAYER_JOIN(nickname);
		case Packets.PLAYER_LEFT:
		  var id:Int = data[0];
		  var nickname:String = OnlineLobbyState.clients[id];
		  Chat.PLAYER_LEAVE(nickname);

		  OnlineLobbyState.removePlayer(id);
		  // createNamesUI();
		case Packets.GAME_START:
		  var jsonInput:String = data[0];
		  var folder:String = data[1];
		  var count = 0;
		  for (i in OnlineLobbyState.clients.keys())
		  {
			count++;
		  }
		  if (count == 2 && TitleState.supported) {
			TitleState.p2canplay = true;
		  }else{
			TitleState.p2canplay = false;
		  }
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
		  Chat.SERVER_MESSAGE(data[0]);

		case Packets.DISCONNECT:
		  TitleState.p2canplay = false;
		  FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
		case Packets.CUSTOMPACKETSTRING:
			switch (data[0]){
				case "SetSong":
					var dataarr:Array<String> = data[1].split(' ');
					OnlineLobbyState.songText = dataarr[0] + "\n" + dataarr[1] + "\n";
					OnlineLobbyState.songFolder = dataarr[0];
					OnlineLobbyState.songChange = true;
				case "Set_Status":
					var dataarr:Array<String> = data[1].split('/*/');
					OnlineLobbyState.clientsStatus[Std.parseInt(dataarr[0])] = dataarr[1];
				}
	  }
	}catch(e){
	  Chat.OutputChatMessage("[Client] You had an error when receiving packet '" + '$packetId' + "':");
	  Chat.OutputChatMessage(e.message);
	  FlxG.sound.play(Paths.sound('cancelMenu'));
	  FlxG.switchState(new OnlineLobbyState(true));
	}
  }
  override function goBack(){
	FlxG.switchState(new OnlineLobbyState(true));
  }
  override function update(elapsed:Float) {
    super.update(elapsed);
    ChatBGBox.visible = Chat.hidechat;
      if(((!Chat.hidechat && FlxG.keys.justPressed.T) || (Chat.hidechat && FlxG.keys.justPressed.ESCAPE)))
        Chat.toggleChat();
      if(FlxG.keys.justPressed.ESCAPE)
        Chat.chatField.hasFocus = false;
      if(FlxG.keys.justPressed.T)
        Chat.chatField.hasFocus = true;
      if (Chat.chatField.hasFocus && FlxG.keys.justPressed.ENTER)
        Chat.SendChatMessage();
		Chat.update(elapsed);
  }
}