package onlinemod;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIButton;
import SEInputText as FlxInputText;
import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Chat
{
  public static var chatField:FlxInputText;
  public static var chatMessagesList:FlxUIList;
//   public static var chatSendButton:FlxUIButton;
  public static var chatMessages:Array<Array<Dynamic>>;
  public static var chatId:Int = 0;
  
  public static var HideButton:FlxUIButton;
  public static var hidechat:Bool = true;
  public static var chatAlpha:Float = 1;

  public static var created:Bool = false;

  public static inline var systemColor:FlxColor = FlxColor.YELLOW;

  public static inline function MESSAGE(nickname:String, message:String)
  {
	Chat.OutputChatMessage('<$nickname> $message');
  }

  public static inline function PLAYER_JOIN(nickname:String)
  {
	Chat.OutputChatMessage('$nickname joined the game', systemColor);
  }

  public static inline function PLAYER_LEAVE(nickname:String)
  {
	Chat.OutputChatMessage('$nickname left the game', systemColor);
  }

  public static inline function SERVER_MESSAGE(message:String)
  {
	Chat.OutputChatMessage('S| $message', 0x40FF40);
  }
  public static inline function CLIENT_MESSAGE(message:String)
  {
	Chat.OutputChatMessage('Client| $message', 0xaa40aa);
  }

  public static inline function SPEED_LIMIT()
  {
	Chat.OutputChatMessage('You\'re typing too fast, one or more messages may not have been sent', FlxColor.RED);
  }

  public static inline function MUTED()
  {
	Chat.OutputChatMessage('You\'re muted', FlxColor.RED);
  }

  public static function createChat(state:FlxUIState,Hide:Bool,?Cam:FlxCamera)
  {
	Chat.created = true;

	Chat.chatMessagesList = new FlxUIList(10, FlxG.height - 80, FlxG.width, 175);
	state.add(Chat.chatMessagesList);
	for (chatMessage in Chat.chatMessages)
	{
	  Chat.OutputChatMessage(chatMessage[0], chatMessage[1], false);
	}

	Chat.chatField = new FlxInputText(10, 650, 1260, 20);
	chatField.maxLength = 81;
	state.add(Chat.chatField);

	// Chat.chatSendButton = new FlxUIButton(1170, Chat.chatField.y, "Send", () -> {
	//   Chat.SendChatMessage();
	//   Chat.chatField.hasFocus = true;
	// });
	// Chat.chatSendButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
	// Chat.chatSendButton.resize(100, Chat.chatField.height);
	// state.add(Chat.chatSendButton);

	hidechat = Hide;
	chatField.visible = Hide;
	Chat.chatAlpha = (hidechat ? 1 : 0);
	// chatSendButton.visible = Hide;
	if(Cam != null){
		chatField.cameras = [Cam];
		chatMessagesList.cameras = [Cam];
		// chatSendButton.cameras = [Cam];
	}
  }

  public static function CreateHideButton(state:FlxUIState){
	Chat.HideButton = new FlxUIButton(0, 0, "Hide Chat", () -> { Chat.toggleChat();	});
	Chat.HideButton.setLabelFormat(16, FlxColor.BLACK, CENTER);
	Chat.HideButton.resize(100, Chat.chatField.height);
	Chat.HideButton.y = FlxG.height - HideButton.height;
	state.add(Chat.HideButton);
  }

  public static function toggleChat(){
	Chat.hidechat = !Chat.hidechat;
	Chat.chatField.visible = Chat.hidechat;
	Chat.chatAlpha = (Chat.hidechat ? 1 : 0);
	// Chat.chatSendButton.visible = Chat.hidechat;
  }

  public static function update(elapsed:Float){
	if(!Chat.hidechat)
		Chat.chatAlpha -= elapsed;
	Chat.chatMessagesList.alpha = Chat.chatAlpha;
  }

  public static function OutputChatMessage(message:String, ?color:FlxColor=FlxColor.WHITE, ?register:Bool=true)
  {
	Chat.chatAlpha = 5;
	while (message.length > 86 && !(message.length > 86)){
		OutputChatMessage(message.substr(0,86),color,register);
		message = message.substr(87);
	}
	if (register)
	  Chat.RegisterChatMessage(message, color,false);

	if (!Chat.created)
	  return;

	var text = new FlxText(0, 0, message);
	text.setFormat(CoolUtil.font, 24, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	Chat.chatMessagesList.add(text);

	if (Chat.chatMessagesList.amountNext == 0)
	  Chat.chatMessagesList.y -= text.height + Chat.chatMessagesList.spacing;
	else
	  Chat.chatMessagesList.scrollIndex += Chat.chatMessagesList.amountNext;
  }

  public static inline function RegisterChatMessage(message:String, ?color:FlxColor=FlxColor.WHITE,?checkSize:Bool = true)
  {
	if(checkSize){
		while (message.length > 86 && !(message.length > 86)){
			RegisterChatMessage(message.substr(0,86),color,false);
			message = message.substr(87);
		}

	}
	Chat.chatMessages.push([message, color]);
  }

  public static function SendChatMessage()
  {
	if (chatField.text.length > 0){
		if (!StringTools.startsWith(chatField.text, " "))
		{
			Sender.SendPacket(Packets.SEND_CHAT_MESSAGE, [Chat.chatId, chatField.text], OnlinePlayMenuState.socket);
			Chat.chatId++;

			OutputChatMessage('<${OnlineNickState.nickname}> ${chatField.text}');
		}

		chatField.text = "";
		chatField.caretIndex = 0;
	}
  }
}
