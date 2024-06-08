package onlinemod;

import flixel.FlxCamera;
import openfl.net.Socket;
import openfl.utils.ByteArray;
import flixel.tweens.FlxEase;
import onlinemod.Packets.Packet;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIButton;
import flash.media.Sound;
import lime.media.AudioBuffer;
import SEInputText as FlxInputText;
import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import Song.MoreChar;

import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;

import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;
import tjson.Json;
using StringTools;
import Discord.DiscordClient;

class OnlineLobbyState extends ScriptMusicBeatState
{
	public static var instance:OnlineLobbyState = null;
	var clientTexts:Map<Int, Int> = []; // Maps a player ID to the corresponding index in clientsGroup
	var clientsGroup:Array<Array<Dynamic>> = [[]]; // Stores all FlxText instances used to display names
	public static var clientCount:Int = 0; // Amount of clients in the lobby
	var targetY:Float = 8;
	var targetX:Array<Float> = [40,640]; // playerlist and songbox thing
	var camPlayerList:FlxCamera = new FlxCamera(0,64,0,406);

  static inline var NAMES_SIZE:Int = 32;
  static inline var NAMES_VERTICAL_SPACING:Int = 56;

  public static var clients:Map<Int, String> = []; // Maps a player ID to the corresponding nickname
  public static var clientsStatus:Map<Int, String> = []; // Maps a player ID to the corresponding status
  public static var clientsOrder:Array<Int> = []; // This array holds ID values in order of join time (including ID -1 for self)
  public static var receivedPrevPlayers:Bool = false;
  public static var isAdmin:Bool = false;
  public static var songText:String = "Neither Server didn't set a song yet\nor Server is running an old version\n";
  public static var songChange:Bool = false;
  public static var hasSong:Bool = true;
  public static var optionsButton:FlxUIButton;
  public static var songFolder:String = "";
  var playerIClicked:String = "";

  var downloadButton:FlxUIButton;
  var loadingText:FlxText;
  var fileSizeText:FlxText;
  var loadingBar:FlxBar;
  var loadingText2:FlxText;
  var fileSizeText2:FlxText;
  var loadingBar2:FlxBar;

  var instprogress:Float = 0;
  var vocalprogress:Float = 0;
  static var loadingSong:Array<Bool> = [false,false];
  static var wasloadingSong:Bool = false;
  public static var ExSocket:Array<Array<Dynamic>> = [];

  var songTextBG:FlxSprite;
  var songTextTxt:FlxText;

  var topText:FlxText;
  var readyButton:FlxUIButton;
  var adminButton:Array<Dynamic> = [];
  var countdowntimer:Float = 0;
  var countdowntimerbutInt:Int = 0;
  var initCountdown:Bool = false;

  var quitHeld:Float = 0;
  var quitHeldBar:FlxBar;
  var quitHeldBG:FlxSprite;
  var ChatBGBox:FlxSprite;

  static var AutoOffset:Array<Float> = [250.0,-250.0];
  public static var ExChar:Array<MoreChar> = [];
  public static var CharID:Int = 0;
  static var Speed:Float = 1.0;
  static var SettingText:FlxText;
  static var Settingtwee:FlxTween;

  var keepClients:Bool;

	static var clientsName:Map<Int, String>;
	public static var showingLeaderBoard:Bool = true;
	public static var hasLeaderboard:Bool = false;
	var clientsGroupLeaderboard:FlxTypedGroup<FlxText>;

	public function new(keepClients:Bool=false,?PSclients:Map<Int, String>)
	{
		super();
		if(PSclients != null){
			showingLeaderBoard = true;
			hasLeaderboard = true;
			clientsName = PSclients;
		}
		if (!keepClients)
		{
		  clients = [];
		  clientsOrder = [];
		  receivedPrevPlayers = false;

		  Chat.chatMessages = [];
		}

		this.keepClients = keepClients;
	}

	function toggleLeaderboard(){
		showingLeaderBoard = !showingLeaderBoard;
		if(showingLeaderBoard){
			topText.text = "< Leaderboard";
			targetX = [-560,1600];
			readyButton.visible = false;
			SettingText.visible = false;
			for(thing in adminButton){thing.visible = false;}
			for(thing in clientsGroupLeaderboard){thing.visible = true;}
		}else{
			topText.text = "Lobby >";
			targetX = [40,640];
			readyButton.visible = true;
			SettingText.visible = true;
			for(thing in adminButton){thing.visible = true;}
			for(thing in clientsGroupLeaderboard){thing.visible = false;}
		}
	}

  override function create()
  {
	new FlxTimer().start(0.1, function(tmr)
	{
		DiscordClient.changePresence('In Online Lobby with ${onlinemod.OnlineLobbyState.clientCount} player' + (onlinemod.OnlineLobbyState.clientCount > 1 ? 's' : ''),if(FlxG.save.data.ShowConnectedIP)'IP : ${FlxG.save.data.lastServer}:${FlxG.save.data.lastServerPort}' else null,false,null,(onlinemod.OnlineLobbyState.clientCount <= 1 ? 'empty-' : '') + "online-lobby");
	});
	scriptSubDirectory = '/onlinelobby/';
	useNormalCallbacks = true;
	loadScripts(true);
	instance?.destroy();
	ScriptMusicBeatState.instance=cast(instance=this);
	if(onlinemod.OnlinePlayMenuState.rawLobbyScripts.length > 0)
		for (i in 0 ... onlinemod.OnlinePlayMenuState.rawLobbyScripts.length) {
			parseHScript(onlinemod.OnlinePlayMenuState.rawLobbyScripts[i][1],null,onlinemod.OnlinePlayMenuState.rawLobbyScripts[i][0],'lobbyScript');
		}
	AutoOffset = [200.0,-200.0];
	FlxG.sound.music.looped = true;
	FlxG.sound.music.onComplete = null;
	wasloadingSong = false; loadingSong = [false,false]; // if you just got on looby this shouldn't be on
  	if(!FlxG.sound.music.playing) FlxG.sound.music.play();
	var bg:FlxSprite = new FlxSprite().loadGraphic(SearchMenuState.background);
	bg.color = 0x9BD2F5;
	add(bg);

	var topBox = new FlxSprite().makeGraphic(FlxG.width, 64, 0x7F3F3F3F); // #3F3F3F
	add(topBox);

	topText = new FlxText(0, 0, 640, "Lobby");
	topText.setFormat(CoolUtil.font, 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	topText.screenCenter(FlxAxes.X);
	add(topText);

	camPlayerList.bgColor = 0x00000000;
	FlxG.cameras.add(camPlayerList,false);
	var leaveButton = new FlxUIButton(10, 15, "Leave Room", () -> {
		quitHeld += 999;
		quitHeldBar.visible = true;
		quitHeldBG.visible = true;
		if (quitHeld > 1000) disconnect();
	});
	leaveButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
	leaveButton.resize(1240 * 0.25, 30);
	add(leaveButton);

	SettingText = new FlxText(640, 150, 640,"", 24);
	updatesetting();
	SettingText.setFormat(CoolUtil.font, 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	SettingText.borderSize = 1;
	add(SettingText);

	createNamesUI();

	songTextBG = new FlxSprite().makeGraphic(660, 90, 0xFF3F3F3F);
	songTextBG.alpha = 0.5;
	songTextBG.setPosition(1600,180);
	add(songTextBG);
	songTextTxt = new FlxText(1600, 190, songText);
	songTextTxt.setFormat(CoolUtil.font, 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	add(songTextTxt);

	downloadButton = new FlxUIButton(0, 0, "Download Song", () -> {
		DownloadSong();
	});
	downloadButton.setLabelFormat(16, FlxColor.BLACK, CENTER);
	downloadButton.resize(240, 20);
	downloadButton.setPosition(FlxG.width - downloadButton.width, songTextBG.y + songTextBG.height);
	if(!hasSong) add(downloadButton);

{ // create 2 download bar WOAH ✋😆🤚
	loadingBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 640, 10, this, 'instprogress', 0, 1);
	loadingBar.createFilledBar(FlxColor.RED, FlxColor.LIME, true, FlxColor.BLACK);
	loadingBar.setPosition(songTextBG.x, songTextBG.y + songTextBG.height);
	loadingBar.alpha = 0;
	add(loadingBar);

	loadingText = new FlxText(songTextBG.x, songTextBG.y + songTextBG.height - 2.5, 640, "Downloading Instrumental...");
	loadingText.setFormat(CoolUtil.font, 12, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	loadingText.alpha = 0;
	add(loadingText);

	fileSizeText = new FlxText(songTextBG.x, songTextBG.y + songTextBG.height - 2.5, 640, "?/?");
	fileSizeText.setFormat(CoolUtil.font, 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	fileSizeText.alpha = 0;
	add(fileSizeText);

	loadingBar2 = new FlxBar(0, 0, LEFT_TO_RIGHT, 640, 10, this, 'vocalprogress', 0, 1);
	loadingBar2.createFilledBar(FlxColor.RED, FlxColor.LIME, true, FlxColor.BLACK);
	loadingBar2.setPosition(songTextBG.x, songTextBG.y + songTextBG.height + 10);
	loadingBar2.alpha = 0;
	add(loadingBar2);

	loadingText2 = new FlxText(songTextBG.x, songTextBG.y + songTextBG.height - 2.5 + 10, 640, "Downloading Voices...");
	loadingText2.setFormat(CoolUtil.font, 12, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	loadingText2.alpha = 0;
	add(loadingText2);

	fileSizeText2 = new FlxText(songTextBG.x, songTextBG.y + songTextBG.height - 2.5 + 10, 640, "?/?");
	fileSizeText2.setFormat(CoolUtil.font, 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	fileSizeText2.alpha = 0;
	add(fileSizeText2);
}

	ChatBGBox = new FlxSprite().makeGraphic(FlxG.width, 175, 0x7F3F3F3F); // #3F3F3F
	ChatBGBox.setPosition(0, FlxG.height - 250);
	add(ChatBGBox);
	Chat.createChat(this,true);
	Chat.CreateHideButton(this);

	readyButton = new FlxUIButton(640, 410, "Ready", () -> {
		if(clientsGroup[clientTexts[-1]][2] != null && clientsGroup[clientTexts[-1]][2].text == "Ready")
			setSelfStatus("");
		else
			setSelfStatus("Ready");
	});
	readyButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
	readyButton.resize(1240 * 0.5, 50);
	add(readyButton);

	if(isAdmin)
		createAdminButton();

	if (!keepClients)
	  Chat.PLAYER_JOIN(OnlineNickState.nickname);

	OnlinePlayMenuState.AddXieneText(this);

	FlxG.mouse.visible = true;
	FlxG.autoPause = false;

	OnlinePlayMenuState.receiver.HandleData = HandleData;
	if (!keepClients)
	  Sender.SendPacket(Packets.JOINED_LOBBY, [], OnlinePlayMenuState.socket);

	optionsButton = new FlxUIButton(FlxG.width - (1240 * 0.25) - 10, 15, "Quick Options", () -> {
	  Chat.created = false;
	  FlxG.switchState(new OnlineOptionsMenu());
	});
	optionsButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
	optionsButton.resize(1240 * 0.25, 30);
	add(optionsButton);

	quitHeldBG = new FlxSprite(15 - 150, 45).loadGraphic(Paths.image('healthBar','shared'));
	quitHeldBG.scale.x = 0.5;
	add(quitHeldBG);

	quitHeldBar = new FlxBar(quitHeldBG.x + 4, quitHeldBG.y + 4, LEFT_TO_RIGHT, Std.int(quitHeldBG.width - 8), Std.int(quitHeldBG.height - 8), this, 'quitHeld', 0, 1000);
	quitHeldBar.numDivisions = 1000;
	quitHeldBar.scale.x = 0.5;
	quitHeldBar.scrollFactor.set();
	quitHeldBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
	add(quitHeldBar);

	if(OnlineSongList.pickedsong != ''){
			if(isAdmin)Sender.SendPacket(Packets.SEND_CHAT_MESSAGE, [Chat.chatId, '!setsong ${OnlineSongList.pickedsong}'], OnlinePlayMenuState.socket);
			else{
				Chat.chatField.text = 'want to play ${OnlineSongList.pickedsong.substring(0,OnlineSongList.pickedsong.indexOf(" "))}';
				Chat.SendChatMessage();
			}
			OnlineSongList.pickedsong = '';
		}

	if(songText == "Neither Server didn't set a song yet\nor Server is running an old version\n")
		Sender.SendPacket(Packets.CUSTOMPACKETSTRING, ['REQUEST_SongName',OnlineNickState.nickname], OnlinePlayMenuState.socket);

	if(songChange){
		songTextTxt.text = songText;
		songChange = false;
		if(FileSystem.exists('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg')){
			FlxG.sound.playMusic(Sound.fromFile('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg'),FlxG.save.data.instVol,true);
			hasSong = true;
		}
		else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.sound.music.volume = 0.1;
				add(downloadButton);
				setSelfStatus("No Song");
				hasSong = false;
			}
		}

	clientsGroupLeaderboard = new FlxTypedGroup<FlxText>();
	if(hasLeaderboard){
		var orderedKeys:Array<Int> = [for(k in OnlinePlayState.clientScores.keys()) k];
		orderedKeys.sort((a, b) -> OnlinePlayState.clientScores[b] - OnlinePlayState.clientScores[a]);

		var x:Int = 0;
		for (i in orderedKeys)
		{
			var name:String = clientsName[i];
			var score = OnlinePlayState.clientText[i];
			if (score == null) score = "N/A";
			if (name == null) name = "N/A";
			var text:FlxText = new FlxText(0, FlxG.height*0.1 + 30*x, '${x+1}. $name: $score');

			if (i == -1) text.text += " (YOU)";

			var color:FlxColor = FlxColor.WHITE;
			if (!OnlineLobbyState.clients.exists(i) && i != -1) color = FlxColor.RED;

			text.setFormat(CoolUtil.font, 24, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.screenCenter(FlxAxes.X);
			text.visible = false;
			add(text);
			clientsGroupLeaderboard.add(text);
			x++;
		}
		if(showingLeaderBoard){
			showingLeaderBoard = false;
			toggleLeaderboard();
		}else topText.text = "Lobby >";
	}
	super.create();
  }

  function createAdminButton() {
	readyButton.resize(1240 * 0.187, 50);

	var startButton = new FlxUIButton(readyButton.x + readyButton.width + 10, readyButton.y, "Start Match", () -> {
		Sender.SendPacket(Packets.SEND_CHAT_MESSAGE, [Chat.chatId, "!start"], OnlinePlayMenuState.socket);
	});
	startButton.setLabelFormat(24, FlxColor.BLACK, CENTER);
	startButton.resize(1240 * 0.187, 50);
	adminButton.push(add(startButton));

	var startwithcouthdownButton = new FlxUIButton(startButton.x + startButton.width + 10, startButton.y, "Start Match\nIn 10 Sec", () -> {
		initCountdown = true;
		countdowntimer = 10;
		Sender.SendPacket(Packets.CUSTOMPACKETINT, ["Start", 10], OnlinePlayMenuState.socket);
	});
	startwithcouthdownButton.setLabelFormat(16, FlxColor.BLACK, CENTER);
	startwithcouthdownButton.resize(1240 * 0.125, 50);
	adminButton.push(add(startwithcouthdownButton));
  }

 function deleteAdminButton() {
	while(adminButton.length > 0){
			var thing = adminButton.pop();
			remove(thing);
			thing.destroy();
		}
	readyButton.resize(1240 * 0.5, 50);
 }

  function createNamesUI()
  {
	clientsGroup = [];
	clientTexts = [];
	clientCount = 0;

	for (i in clientsOrder)
	{
	  var nick:String = i != -1 ? clients[i] : OnlineNickState.nickname;
	  addPlayerUI(i, nick, i == -1 ? FlxColor.YELLOW : null);
	  if(clientsStatus[i] != null && clientsStatus[i] != "")
		addStatustext(clientsGroup[clientTexts[i]],clientTexts[i],clientsStatus[i],true);
	}
  }

  var lastPacket:Array<Dynamic> = [];
  var lastPacketID:Int = 0;
  function HandleData(packetId:Int, data:Array<Dynamic>)
  {
	if(packetId != Packets.SEND_VOICES && packetId != Packets.SEND_INST){ // it will crash most of the time try to show audio data at text
		lastPacketID = packetId;
		lastPacket = data;
	}
	if(onlinemod.OnlinePlayMenuState.RespondKeepAlive(packetId)) return;
	callInterp("packetRecieve",[packetId,data]);
	if(cancelCurrentFunction) return;
	switch (packetId)
	{
		case Packets.BROADCAST_NEW_PLAYER:
			var id:Int = data[0];
			var nickname:String = data[1];

			addPlayerUI(id, nickname);
			addPlayer(id, nickname);
			if (receivedPrevPlayers)
				Chat.PLAYER_JOIN(nickname);
			DiscordClient.changePresence('In Online Lobby with ${onlinemod.OnlineLobbyState.clientCount} player' + (onlinemod.OnlineLobbyState.clientCount > 1 ? 's' : ''),if(FlxG.save.data.ShowConnectedIP)'IP : ${FlxG.save.data.lastServer}:${FlxG.save.data.lastServerPort}' else null,false,null,(onlinemod.OnlineLobbyState.clientCount <= 1 ? 'empty-' : '') + "online-lobby");
		case Packets.END_PREV_PLAYERS:
			receivedPrevPlayers = true;
			addPlayerUI(-1, OnlineNickState.nickname, FlxColor.YELLOW);
			clientsOrder.push(-1);
		case Packets.PLAYER_LEFT:
			var id:Int = data[0];
			var nickname:String = OnlineLobbyState.clients[id];
			Chat.PLAYER_LEAVE(nickname);

			removePlayer(id);
			removePlayerUI(id);
			DiscordClient.changePresence('In Online Lobby with ${onlinemod.OnlineLobbyState.clientCount} player' + (onlinemod.OnlineLobbyState.clientCount > 1 ? 's' : ''),if(FlxG.save.data.ShowConnectedIP)'IP : ${FlxG.save.data.lastServer}:${FlxG.save.data.lastServerPort}' else null,false,null,(onlinemod.OnlineLobbyState.clientCount <= 1 ? 'empty-' : '') + "online-lobby");
		case Packets.GAME_START:
			var jsonInput:String = data[0];
			var folder:String = data[1];

			StartGame(jsonInput, folder);
		case Packets.BROADCAST_CHAT_MESSAGE:
			var id:Int = data[0];
			var message:String = data[1];
			if(StringTools.contains(message.toLowerCase(),"@"+OnlineNickState.nickname.toLowerCase()))
				FlxG.sound.play(Paths.sound('confirmMenu'));
			Chat.MESSAGE(OnlineLobbyState.clients[id], message);
		case Packets.REJECT_CHAT_MESSAGE:
			Chat.SPEED_LIMIT();
		case Packets.MUTED:
			Chat.MUTED();
		case Packets.SERVER_CHAT_MESSAGE:
			if(data[0] == "'ceabf544' This is a compatibility message, Ignore me!"){
				TitleState.supported = true;
				Sender.SendPacket(Packets.SUPPORTED, [], OnlinePlayMenuState.socket);
				Chat.SERVER_MESSAGE("This server is compatible with extra features!");
			}else if(StringTools.startsWith(data[0],"'32d5d167'"))
				handleServerCommand(data[0],0);
			else if(data[0] == "You are an admin! Do !help for help." || data[0] == "You are now an admin! Do !help for help."){
				isAdmin = true;
				if(adminButton.length == 0)
					createAdminButton();
				Chat.SERVER_MESSAGE(data[0]);
			}
			else if(data[0] == "You are no longer an admin! :("){
				isAdmin = false;
				deleteAdminButton();
				Chat.SERVER_MESSAGE(data[0]);
			}
			else Chat.SERVER_MESSAGE(data[0]);
		case Packets.DISCONNECT:
			TitleState.p2canplay = false;
			FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
		case Packets.DENY:
			Chat.SERVER_MESSAGE("Server missing some file. Tell Server host to add it!");
			loadingSong = [false,false];
			wasloadingSong = false;
		case Packets.CUSTOMPACKETSTRING:
			switch (data[0]){
				case "SetSong":
					var dataarr:Array<String> = data[1].split(' ');
					songFolder = dataarr[0];
					songTextTxt.text = songText = dataarr[0] + "\n" + dataarr[1] + "\n";
					if(FileSystem.exists('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg'))
						FlxG.sound.playMusic(Sound.fromFile('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg'),FlxG.save.data.instVol,true);
					else
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							FlxG.sound.music.volume = 0.1;
							add(downloadButton);
							setSelfStatus("No Song");
							hasSong = false;
						}
				case "SetFolder":
					var dataarr:Array<String> = data[1].split(' ');
					songFolder = dataarr[0];
					songTextTxt.text = songText = dataarr[0] + "\n" + dataarr[1] + "\n";
					remove(downloadButton);
					if(FileSystem.exists('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg'))
						FlxG.sound.playMusic(Sound.fromFile('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg'),FlxG.save.data.instVol,true);
					else
						{
							Sender.SendPacket(Packets.REQUEST_INST, [], ExSocket[0][0]);
							Sender.SendPacket(Packets.REQUEST_VOICES, [], ExSocket[1][0]);
						}
				case "Song":
					var dataarr:Array<String> = data[1].split(' ');
					for(chart in dataarr){
						var chartarr:Array<String> = chart.split(',');
						OnlineSongList.songLists.push([chartarr[0],chartarr[1]]);
					}
					Chat.created = false;
					FlxG.switchState(new OnlineSongList());
				case "Set_Status":
					var dataarr:Array<String> = data[1].split('/*/');
					var array = clientsGroup[clientTexts[Std.parseInt(dataarr[0])]];
					clientsStatus[Std.parseInt(dataarr[0])] = dataarr[1];
					while(array.length > 2){
							var thing = array.pop();
							remove(thing);
							thing.destroy();
						}
					addStatustext(array,clientTexts[Std.parseInt(dataarr[0])],dataarr[1]);
				case "StopTimer":
					initCountdown = false;
					countdowntimer = countdowntimerbutInt = 0;
					new FlxTimer().start(1, (timer:FlxTimer) -> {
						readyButton.getLabel().text = 'Ready';
					}, 0);
			}
		case Packets.CUSTOMPACKETINT:
			switch (data[0]){
				case "listVersion":
					if(OnlineSongList.listVersion == data[1])
						FlxG.switchState(new OnlineSongList());
					else {
						OnlineSongList.listVersion = data[1];
						OnlineSongList.songLists = [[]];
						Sender.SendPacket(Packets.CUSTOMPACKETSTRING, ['REQUEST_SongLists'], OnlinePlayMenuState.socket);
					}
				case "Start":
					countdowntimer = data[1];
					initCountdown = false;
			}
	}
  }

  function HandleDownload(ID:Int,packetId:Int, data:Array<Dynamic>){
	callInterp("packetRecieve",[packetId,data]);
	if(cancelCurrentFunction) return;
	switch(packetId){
		case Packets.SEND_INST:
			var file:Bytes = cast(data[0], Bytes);
			if (!FileSystem.exists('assets/onlinedata/songs/${songFolder.toLowerCase()}')) FileSystem.createDirectory('assets/onlinedata/songs/${songFolder.toLowerCase()}');
			File.saveBytes('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg', file);
			loadingSong[0] = false;
		case Packets.SEND_VOICES:
			var file:Bytes = cast(data[0], Bytes);
			if (!FileSystem.exists('assets/onlinedata/songs/${songFolder.toLowerCase()}')) FileSystem.createDirectory('assets/onlinedata/songs/${songFolder.toLowerCase()}');
			File.saveBytes('assets/onlinedata/songs/${songFolder.toLowerCase()}/Voices.ogg', file);
			loadingSong[1] = false;
		}
  }

public static function handleServerCommand(command:String,?version = 0) // Not sure if I'll ever actually use the version variable for anything
{
	var args:Array<String> = command.split(' ');
	try{ // All responses start with '32d5d168'
	switch (args[1].toLowerCase()){
		case "set":{
			if (args[3] == "true" || args[3] == "on" || args[3] == "false" || args[3] == "off"){
				var bool = (args[3] == "true" || args[3] == "on");
				switch(args[2]){
					case "invertnotes":
						PlayState.invertedChart = bool;
						updatesetting();
					case "invertchars":
						QuickOptionsSubState.setSetting("Swap characters",bool);
					case "inputsync":
						OnlinePlayState.autoDetPlayer2 = false;
						PlayState.p2canplay = bool;
					case "p2show":
						OnlinePlayState.autoDetPlayer2 = false;
						PlayState.dadShow = bool;
					case "clientscript": // CAN ALLOW CHEATING, ALLOW WITH CAUTION! Allows players to use custom scripts online!
						QuickOptionsSubState.setSetting("Song hscripts",bool);
					case "bothside":
						QuickOptionsSubState.setSetting("Play Both Side",bool);
						updatesetting();
					case "adofai":
						QuickOptionsSubState.setSetting("ADOFAI Chart",bool);
						updatesetting();
					case "coop":
						QuickOptionsSubState.setSetting("CO OP Mode",bool);
						updatesetting();
					default:
						throw("Invalid option");
				}
			}else{
				switch(args[2]){
					case "player1",'bf','p1':
						OnlinePlayState.useSongChar[0] = args[3];
					case "player2",'dad','p2':
						OnlinePlayState.useSongChar[1] = args[3];
					case "gf":
						OnlinePlayState.useSongChar[2] = args[3];
					case "charid":
						CharID = Std.parseInt(args[3]);
						updatesetting();
					case "scoremode":
						FlxG.save.data.scoresystem = Std.parseInt(args[3]);
						Chat.SERVER_MESSAGE('Server has changed your score mode to ' + PlayState.scoretype[Std.parseInt(args[3])] + ".");
					case "speed":
						if(Std.parseFloat(args[3]) < 0.25)
						{
							Speed = 1;
							sendResponse("No");
						}
						else if(Std.parseFloat(args[3]) > 1.25)
						{
							Speed = 1.25;
							sendResponse("Speed higher than 1.25 crash here");
						}
						else
							Speed = Std.parseFloat(args[3]);
						updatesetting();
					case "forcemania":
						if(Std.parseInt(args[3]) < -1 && Std.parseInt(args[3]) > 19)
						{
							QuickOptionsSubState.setSetting("Force Mania",-1);
							sendResponse("force mania only have -1 - 19");
						}
						else
							QuickOptionsSubState.setSetting("Force Mania",Std.parseInt(args[3]));
						updatesetting();
					case "randomnote":
						if(Std.parseInt(args[3]) < 0 && Std.parseInt(args[3]) > 3)
						{
							QuickOptionsSubState.setSetting("Random Notes",0);
							sendResponse("random note only have 0 - 3");
						}
						else
							QuickOptionsSubState.setSetting("Random Notes",Std.parseInt(args[3]));
						updatesetting();
					case "mirrormode":
						if(Std.parseInt(args[3]) < 0 && Std.parseInt(args[3]) > 2)
						{
							QuickOptionsSubState.setSetting("Mirror Mode",0);
							sendResponse("mirror mode only have 0 - 2");
						}
						else
							QuickOptionsSubState.setSetting("Mirror Mode",Std.parseInt(args[3]));
						updatesetting();
					default:
						throw("Invalid option");
				}
			}
			Chat.SERVER_MESSAGE('Server \'${args[1]}\' \'${args[2]}\' to \'${args[3]}\'');
		}
		case "addchar":
			var Char:MoreChar = {
				char: args[2],
				side: Std.parseInt(args[3]),
				offset: if(args[4] == null) AutoOffset[Std.parseInt(args[3])] else Std.parseFloat(args[4])
			};
			switch(Std.parseInt(args[3])){case 0: AutoOffset[0] += 250; case 1: AutoOffset[1] -= 250;}
			ExChar.push(Char);
			Chat.SERVER_MESSAGE('Server Add \'${Char.char}\' on \'${Char.side}\' with offset \'${Char.offset}\'');
		case "clearchar":
			ExChar = [];
			Chat.SERVER_MESSAGE('Server clear all Extra Character');
		case "sendhscript":{ // Allows downloading of hscripts
			QuickOptionsSubState.setSetting("Song hscripts",true);
			if(!FlxG.save.data.allowServerScripts){
				Chat.CLIENT_MESSAGE("Server tried to send script but you're blocking server scripts.");
				Chat.CLIENT_MESSAGE("You can change this in your options if you trust the server.");
				sendResponse("Client has scripts disabled",false);
				return;
			}
			if(args[2] == null) throw('No name for script specified!');
			if(args[3] == null) throw('Script contents are empty!');
			var scriptName = ~/[^_a-zA-Z0-9\-]/g.replace(args[2],"");
			if(args[2].startsWith("temp-")){
				scriptName = scriptName + ".hscript";
				args.splice(0,3);
				var script = args.join(" ");
				OnlinePlayMenuState.rawScripts.push([scriptName,script]);
				Chat.CLIENT_MESSAGE('Server has temporarily enabled ${scriptName}, This will be unloaded when you leave');

				sendResponse('Script "${scriptName}" enabled!',true);
				return;
			}
			if(args[2].startsWith("lobby-")){
				scriptName = scriptName + ".hscript";
				args.splice(0,3);
				var script = args.join(" ");
				ScriptMusicBeatState.instance.parseHScript(script,null,scriptName,"lobbyScript");
				OnlinePlayMenuState.rawLobbyScripts.push([scriptName,script]);
				Chat.CLIENT_MESSAGE('Server has temporarily enabled ${scriptName}, This will be unloaded when you leave');

				sendResponse('Script "${scriptName}" enabled!',true);
				return;
			}

			scriptName = "serv-" + scriptName;
			Chat.CLIENT_MESSAGE('Server is attempting to install hscript ${scriptName}');
		
			if(FileSystem.exists('mods/scripts/${scriptName}/script.hscript')) {sendResponse("Script Already exists!",true);return;}
			args.splice(0,3);
			var script = args.join(" ");
			Chat.CLIENT_MESSAGE('Installing hscript of ${script.length} characters');
			SELoader.createDirectory('mods/scripts/${scriptName}/');
			SELoader.saveContent('mods/scripts/${scriptName}/script.hscript',script);
			if(!SELoader.exists('mods/scripts/${scriptName}/script.hscript')) {sendResponse("Script couldn't be downloaded!",true);return;}

			OnlinePlayMenuState.scripts.push(scriptName);
			sendResponse('Script "${scriptName}" installed and enabled!',true);
		}
		case "sendlua":{ // Allows downloading of lua
			QuickOptionsSubState.setSetting("Song hscripts",true);
			if(!FlxG.save.data.allowServerScripts){
				Chat.CLIENT_MESSAGE("Server tried to send script but you're blocking server scripts.");
				Chat.CLIENT_MESSAGE("You can change this in your options if you trust the server.");
				sendResponse("Client has scripts disabled",false);
				return;
			}
			if(args[2] == null) throw('No name for script specified!');
			if(args[3] == null) throw('Script contents are empty!');
			var scriptName = ~/[^_a-zA-Z0-9\-]/g.replace(args[2],"");
			if(args[2].startsWith("temp-")){
				scriptName = scriptName + ".lua";
				args.splice(0,3);
				var script = args.join(" ");
				OnlinePlayMenuState.rawScripts.push([scriptName,script]);
				Chat.CLIENT_MESSAGE('Server has temporarily enabled ${scriptName}, This will be unloaded when you leave');

				sendResponse('Script "${scriptName}" enabled!',true);
				return;
			}
			if(args[2].startsWith("lobby-")){
				scriptName = scriptName + ".lua";
				args.splice(0,3);
				var script = args.join(" ");
				ScriptMusicBeatState.instance.parseLua(script,null,scriptName,"lobbyScript");
				OnlinePlayMenuState.rawLobbyScripts.push([scriptName,script]);
				Chat.CLIENT_MESSAGE('Server has temporarily enabled ${scriptName}, This will be unloaded when you leave');

				sendResponse('Script "${scriptName}" enabled!',true);
				return;
			}

			scriptName = "serv-" + scriptName;
			Chat.CLIENT_MESSAGE('Server is attempting to install lua ${scriptName}');
		
			if(FileSystem.exists('mods/scripts/${scriptName}/script.lua')) {sendResponse("Script Already exists!",true);return;}
			args.splice(0,3);
			var script = args.join(" ");
			Chat.CLIENT_MESSAGE('Installing lua of ${script.length} characters');
			SELoader.createDirectory('mods/scripts/${scriptName}/');
			SELoader.saveContent('mods/scripts/${scriptName}/script.lua',script);
			if(!SELoader.exists('mods/scripts/${scriptName}/script.lua')) {sendResponse("Script couldn't be downloaded!",true);return;}

			OnlinePlayMenuState.scripts.push(scriptName);
			sendResponse('Script "${scriptName}" installed and enabled!',true);
		}
		case "disablescript":{ // Allows disabling of hscripts
			if(!FlxG.save.data.allowServerScripts){
				Chat.CLIENT_MESSAGE("Server tried to disable a script but you're blocking server scripts. You can change this in your options if you trust the server.");
				sendResponse("Client has scripts disabled",false);
				return;
			}
			var scriptName = ~/[^_a-zA-Z0-9\-]/g.replace(args[2],"");
			scriptName = "serv-" + scriptName;
			if(OnlinePlayMenuState.scripts.contains(scriptName)){
				OnlinePlayMenuState.scripts.remove(scriptName);
				sendResponse("Script removed!");return;
			}else{
				for (_ => v in OnlinePlayMenuState.rawScripts) {
					if(v[0] != scriptName){continue;}
					OnlinePlayMenuState.rawScripts.remove(v);
					Chat.CLIENT_MESSAGE('Server unloaded script "${scriptName}"');
					return;
				}

				sendResponse("Script isn't enabled!");
				return;
			}
			Chat.CLIENT_MESSAGE('Server Disabled script "${scriptName}"');

			sendResponse("Script enabled!");
		}
		case "enablescript":{ // Allows enabling of hscripts
			QuickOptionsSubState.setSetting("Song hscripts",true);
			if(!FlxG.save.data.allowServerScripts){
				Chat.CLIENT_MESSAGE("Server tried to enable a script but you're blocking server scripts. You can change this in your options if you trust the server.");
				sendResponse("Client has scripts disabled",false);
				return;
			}
			var scriptName = ~/[^_a-zA-Z0-9\-]/g.replace(args[2],"");
			scriptName = "serv-" + scriptName;
			if(OnlinePlayMenuState.scripts.contains(scriptName)){sendResponse("Script already loaded!");return;}
			if(!FileSystem.exists('mods/scripts/${scriptName}/script.hscript')) {sendResponse("Script doesn't exist!");return;}
			OnlinePlayMenuState.scripts.push(scriptName);
			Chat.CLIENT_MESSAGE('Server enabled script "${scriptName}"');

			sendResponse("Script enabled!");
		}
		case "hasscript":{ // Allows enabling of hscripts
			QuickOptionsSubState.setSetting("Song hscripts",true);
			if(!FlxG.save.data.allowServerScripts){
				Chat.CLIENT_MESSAGE("Server checked if you have a script but you're blocking server scripts. You can change this in your options if you trust the server.");
				sendResponse("Client has scripts disabled",false);
				return;
			}
			var scriptName = ~/[^_a-zA-Z0-9\-]/g.replace(args[2],"");
			scriptName = "serv-" + scriptName;
			if(OnlinePlayMenuState.scripts.contains(scriptName)){sendResponse("Script is loaded!");return;}
			if(!FileSystem.exists('mods/scripts/${scriptName}/script.hscript')) {sendResponse("Script doesn't exist!");return;}

			sendResponse("Client has script!");
		}
		case "get":{ // Anything sent from this has to be filtered by the server, All responses start with '32d5d168'
			switch(args[2]){
				case "info":{
					var clientInfo = {
						version: MainMenuState.ver,
						modVer: MainMenuState.modver,
						// supported: ["inputsync","invertnotes","p2show","clientscript","setchar","sendscript","enablescript","removescript","tempscript"],
					};
					sendResponse("info:" + Json.stringify(clientInfo));
				}
				case "character" | "char":{
					sendResponse("character:" + FlxG.save.data.playerChar);
				}
			}
		}
	}
	 
	}catch(e){
		Chat.SERVER_MESSAGE('Server sent an invalid command ${e.message}, ${command}');
		trace('Server sent an invalid command ${e.message}, ${command}, ${args}');
	} // I don't expect servers to always handle this properly, always better to have error catching
  }
  public static function sendResponse(text:String,?sendToPlayer:Bool = false){
	if(sendToPlayer)Chat.CLIENT_MESSAGE(text);
	Sender.SendPacket(Packets.SEND_CHAT_MESSAGE, [Chat.chatId,"'32d5d168' " + text], OnlinePlayMenuState.socket);
  }

  public static function StartGame(jsonInput:String, folder:String)
  {
	FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	PlayState.songspeed = Speed;
	PlayState.isStoryMode = false;
	FlxG.switchState(new OnlineLoadState(jsonInput, folder));

	if (FlxG.sound.music != null)
	  FlxG.sound.music.stop();
  }

  public static function addPlayer(id:Int, nickname:String)
  {
	OnlineLobbyState.clients[id] = nickname;
	OnlineLobbyState.clientsOrder.push(id);
  }

  function addPlayerUI(id:Int, nickname:String, ?color:FlxColor=FlxColor.WHITE)
  {
	var playerArray:Array<Dynamic> = [];
	clientTexts[id] = clientsGroup.length;
	clientsGroup.push(playerArray);
	var playerBG = new FlxSprite().makeGraphic(480, 48,0x7F3F3F3F); // #3F3F3F
	playerBG.setPosition(-560,targetY + clientCount * NAMES_VERTICAL_SPACING);
	playerBG.cameras = [camPlayerList];
	playerArray.push(playerBG);
	add(playerBG);
	var text:FlxText = new FlxText(-560, targetY + clientCount * NAMES_VERTICAL_SPACING, 460, nickname);
	text.setFormat(CoolUtil.font, NAMES_SIZE, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	text.cameras = [camPlayerList];
	playerArray.push(text);
	add(text);
	clientCount++;
	callInterp("addPlayerUI",[playerBG,text]);
  }

  public static function removePlayer(id:Int)
  {
	OnlineLobbyState.clients.remove(id);
	clientsOrder.remove(id);
  }

  function removePlayerUI(id:Int)
  {
	for(thing in clientsGroup[clientTexts[id]]){
		FlxTween.tween(thing,{x: -560},0.5,{ease: FlxEase.expoIn,
			onComplete: function(tween:FlxTween)
			{
				thing.destroy();
			}
		});
	}
	for (i=>k in clientTexts){
		if (k > clientTexts[id])
			clientTexts[i] = clientTexts[i] - 1;
	}
	clientsGroup.remove(clientsGroup[clientTexts[id]]);
	clientTexts.remove(id);
	clientCount--;
	callInterp("removePlayerUI",[]);
  }
  function disconnect(){
	  if (OnlinePlayMenuState.socket.connected)
		OnlinePlayMenuState.socket.close();
	  FlxG.switchState(new OnlinePlayMenuState());
  }

static function updatesetting(){
	if(Settingtwee != null)Settingtwee.cancel();
	SettingText.scale.set(1.2,1.2);
	Settingtwee = FlxTween.tween(SettingText.scale,{x:1,y:1},(30 / Conductor.bpm));
	SettingText.text = (Speed != 1 ? "Song Speed : " + Speed + "x | " : '')
	+ (PlayState.invertedChart ? " Invert Chart : True | " : '')
	+ (QuickOptionsSubState.getSetting("Force Mania") > -1 ? " Force Mania : " + QuickOptionsSubState.getSetting("Force Mania") + " | " : '')
	+ (QuickOptionsSubState.getSetting("Random Notes") > 0 ? " Random Mode : " + QuickOptionsSubState.getSetting("Random Notes") + " | " : '')
	+ (QuickOptionsSubState.getSetting("Mirror Mode") > 0 ? " Mirror Mode : " + QuickOptionsSubState.getSetting("Mirror Mode") + " | " : '')
	+ (QuickOptionsSubState.getSetting("Play Both Side") ? " Both Side : True | " : '')
	+ (QuickOptionsSubState.getSetting("ADOFAI Chart") ? " ADOFAI Chart : True | " : '')
	+ (QuickOptionsSubState.getSetting("CO OP Mode") ? " CO-OP Mode : True | " : '')
	+ (CharID != 0 ? "CharID : " + CharID + " | ": '')
	;
}

function setSelfStatus(status:String) {
	var array = clientsGroup[clientTexts[-1]];
	clientsStatus[-1] = status;
	while(array.length > 2){
			var thing = array.pop();
			remove(thing);
			thing.destroy();
		}
	addStatustext(array,clientTexts[-1],status);
	Sender.SendPacket(Packets.CUSTOMPACKETSTRING, ["Set_Status", status], OnlinePlayMenuState.socket);
}

function addStatustext(array:Array<Dynamic>,order:Int,status:String,?animation:Bool = false) { // as much as i hate it for god know what haxe doesn't want the function here to just edit the text.
	var statusText:FlxText = new FlxText(animation ? -560 : 50, targetY + order * NAMES_VERTICAL_SPACING, 460, status);
	statusText.setFormat(CoolUtil.font, NAMES_SIZE, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	statusText.cameras = [camPlayerList];
	array.push(statusText);
	add(statusText);
	callInterp("addStatustext",[statusText,array]);
}

public function clientCommand(command:String) {
	var commandarr:Array<String> = command.split(" ");
	switch(commandarr[0]){
		case "help" | "h":
			Chat.CLIENT_MESSAGE('redownload/rd: redownload the voice and inst');
			Chat.CLIENT_MESSAGE('canceldownload/ccd: cancel song download');
			Chat.CLIENT_MESSAGE('setstatus/ss: set your status to whatever you want');
			if(isAdmin){
				Chat.CLIENT_MESSAGE('start/s: start the game with optional cooldown in seconds Ex.//start [time]');
				Chat.CLIENT_MESSAGE('stoptimer/st: stop the on going timer to start game');
			}
		case "redownload" | "rd":
			if(loadingSong.contains(true) && commandarr[1] != "-f") {Chat.CLIENT_MESSAGE("You are already currently downloading a song!");return;}
			if(commandarr[1] == "-f")cancelDownload();
			Chat.CLIENT_MESSAGE("ReDownload The song!");
			DownloadSong();
		case "canceldownload" | "ccd":
			if(loadingSong.contains(true)) {Chat.CLIENT_MESSAGE("There are no on going download!");return;}
			cancelDownload();
			Chat.CLIENT_MESSAGE("CancelDownload The song!");
		case "setstatus" | "ss":
			if(commandarr.length < 2) {Chat.CLIENT_MESSAGE("Expected an argument: status");return;}
			var ss:String = command.substring(command.indexOf(" ") + 1,command.length);
			Chat.CLIENT_MESSAGE('Set your status to \'${ss}\'!');
			setSelfStatus(ss);
		case "start" | "s":
			if(!isAdmin) {Chat.CLIENT_MESSAGE("You don't have permission!");return;}
			if(commandarr.length < 2)
				Sender.SendPacket(Packets.SEND_CHAT_MESSAGE, [Chat.chatId, "!start"], OnlinePlayMenuState.socket);
			else {
				initCountdown = true;
				var timer:Int = Std.parseInt(commandarr[1]);
				countdowntimer = timer;
				Sender.SendPacket(Packets.CUSTOMPACKETINT, ["Start", timer], OnlinePlayMenuState.socket);
			}
		case "stoptimer" | "st":
			if(!isAdmin) {Chat.CLIENT_MESSAGE("You don't have permission!");return;}
			initCountdown = false;
			countdowntimer = 0;
			Sender.SendPacket(Packets.CUSTOMPACKETSTRING, ["StopTimer", "stop it"], OnlinePlayMenuState.socket);
		default:
			callInterp("clientCommand",[commandarr,command]); // hey if anyone using this make sure to set cancelCurrentFunction to true so it doesn't say it Couldn't recognize command
			if(cancelCurrentFunction) return;
			Chat.CLIENT_MESSAGE("Couldn't recognize command '" + commandarr[0] + "'. Try using '//help'");
	}
}

function createMoreSocket(ID:Int){
	if(ExSocket.length > 3) return; // im not letting anything create more than the 2 for download and maybe 1 for script
	var socket = new Socket();
	var receiver = new Receiver(HandleDownload.bind(ID,_,_));
	socket.addEventListener(ProgressEvent.SOCKET_DATA, OnDownloadData.bind(ID,_));
	socket.connect(FlxG.save.data.lastServer, Std.parseInt(FlxG.save.data.lastServerPort));
	ExSocket[ID] = [socket,receiver];
}

function DownloadSong() {
	if(ExSocket[0] == null){
		createMoreSocket(0);
		ExSocket[0][0].addEventListener(Event.CONNECT, (e:Event) -> {
			actuallyDownloadSong();
		});
	}
	if(ExSocket[1] == null) createMoreSocket(1);
	if(!ExSocket[0][0].connect)
		ExSocket[0][0].connect(FlxG.save.data.lastServer, Std.parseInt(FlxG.save.data.lastServerPort));
	if(!ExSocket[1][0].connect)
		ExSocket[1][0].connect(FlxG.save.data.lastServer, Std.parseInt(FlxG.save.data.lastServerPort));
	if(ExSocket[0][0].connect)
		actuallyDownloadSong();
}

function actuallyDownloadSong() {
	loadingSong = [true,true];
	wasloadingSong = true;
	Sender.SendPacket(Packets.CUSTOMPACKETSTRING, ['REQUEST_SongFolder',"ello server"], OnlinePlayMenuState.socket);
}

function cancelDownload() {
	if(ExSocket[0][0].connected)ExSocket[0][0].close();
	if(ExSocket[1][0].connected)ExSocket[1][0].close();
	wasloadingSong = false;
	loadingSong = [false,false];
}

override function update(elapsed:Float)
{
	@:privateAccess
	{
		if (FlxG.sound.music.playing)
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__audioSource.__backend.handle, lime.media.openal.AL.PITCH, Speed);
	}

	if(/* isAdmin &&  */!loadingSong.contains(true)){
		if (FlxG.mouse.overlaps(songTextBG)){
			targetX[1] = 620;
			songTextBG.alpha = FlxMath.lerp(songTextBG.alpha, 0.75, elapsed * 10);
			songTextBG.x = FlxMath.lerp(songTextBG.x, targetX[1], elapsed * 10);
			songTextTxt.x = FlxMath.lerp(songTextTxt.x, targetX[1] + 20, elapsed * 10);
			if(FlxG.mouse.justPressed)
				Sender.SendPacket(Packets.CUSTOMPACKETSTRING, ['REQUEST_listVersion'], OnlinePlayMenuState.socket);
		}else{
			targetX[1] = (showingLeaderBoard && hasLeaderboard ? 1600 : 640);
			songTextBG.alpha = FlxMath.lerp(songTextBG.alpha, 0.5, elapsed * 10);
			songTextBG.x = FlxMath.lerp(songTextBG.x, targetX[1], elapsed * 10);
			songTextTxt.x = FlxMath.lerp(songTextTxt.x, targetX[1] + 20, elapsed * 10);
		}
	}

	if(hasLeaderboard && (FlxG.keys.justPressed.TAB || FlxG.mouse.overlaps(topText) && FlxG.mouse.justPressed))
		toggleLeaderboard();

	if(FlxG.mouse.justPressedMiddle)
		targetY = 8;
	if(FlxG.mouse.wheel != 0 && FlxG.mouse.y < 470)
		targetY += -FlxG.mouse.wheel * (FlxG.keys.pressed.SHIFT ? 1 : 12);
	else if(FlxG.mouse.wheel != 0)
		Chat.chatMessagesList.scrollIndex += -((Chat.chatMessagesList.amountNext > 0 && FlxG.mouse.wheel < 0) || (Chat.chatMessagesList.amountPrevious > 0 && FlxG.mouse.wheel > 0) ? FlxG.mouse.wheel : 0);

	if(targetY > 8)
		targetY = FlxMath.lerp(targetY, 8, elapsed * 10);
	if(targetY < 8 - (clientsGroup.length - 1) * NAMES_VERTICAL_SPACING)
		targetY = FlxMath.lerp(targetY, 8 - (clientsGroup.length - 1) * NAMES_VERTICAL_SPACING, elapsed * 10);

	for(array in 0...clientsGroup.length){
		var _targetY = targetY + array * NAMES_VERTICAL_SPACING;
		for(thing in 0...clientsGroup[array].length){
			clientsGroup[array][thing].x = FlxMath.lerp(clientsGroup[array][thing].x, (thing > 0 ? targetX[0] + 10 : targetX[0]), elapsed * 10);
			clientsGroup[array][thing].y = FlxMath.lerp(clientsGroup[array][thing].y, _targetY, elapsed * 10);
		}
	}

	// for(array in 0...clientsGroup.length){ // i will working on it later
	// 	if(FlxG.mouse.overlaps(clientsGroup[array][0]) && FlxG.mouse.justPressedRight){
	// 		playerIClicked = clientsGroup[array][1].text;
	// 	}
	// }

	if(countdowntimer > 0){
		countdowntimer -= elapsed;
		if(countdowntimerbutInt != Std.int(countdowntimer)){
			countdowntimerbutInt = Std.int(countdowntimer);
			if(countdowntimerbutInt < 5) FlxG.sound.play(Paths.sound('scrollMenu'));
			readyButton.getLabel().text = '' + countdowntimerbutInt;
		}
	}else if(initCountdown) {
		initCountdown = false;
		Sender.SendPacket(Packets.SEND_CHAT_MESSAGE, [Chat.chatId, "!start"], OnlinePlayMenuState.socket);
	}

	if(loadingSong[0]){
		loadingText.alpha = fileSizeText.alpha = loadingBar.alpha = FlxMath.lerp(loadingText.alpha, 1, elapsed*5);
		if (ExSocket[0][1].varLength > 4)
		{
			var fileSize:Int = Std.int(ExSocket[0][1].varLength - 4);
			var bytesReceived:Int = Std.int(ExSocket[0][1].bufferedBytes - 5);
			instprogress = bytesReceived / fileSize;
			fileSizeText.text = Std.int(bytesReceived/10000)/100 + "/" + Std.int(fileSize/10000)/100 + "MB" + " (" + FlxMath.roundDecimal(instprogress * 100, 2) + "%)";
		}
	}else loadingText.alpha = fileSizeText.alpha = loadingBar.alpha = FlxMath.lerp(loadingText.alpha, 0, elapsed*5);
	if(loadingSong[1]){
		loadingText2.alpha = fileSizeText2.alpha = loadingBar2.alpha = FlxMath.lerp(loadingText2.alpha, 1, elapsed*5);
		if (ExSocket[1][1].varLength > 4)
		{
			var fileSize2:Int = Std.int(ExSocket[1][1].varLength - 4);
			var bytesReceived2:Int = Std.int(ExSocket[1][1].bufferedBytes - 5);
			vocalprogress = bytesReceived2 / fileSize2;
			fileSizeText2.text = Std.int(bytesReceived2/10000)/100 + "/" + Std.int(fileSize2/10000)/100 + "MB" + " (" + FlxMath.roundDecimal(vocalprogress * 100, 2) + "%)";
		}
	}else loadingText2.alpha = fileSizeText2.alpha = loadingBar2.alpha = FlxMath.lerp(loadingText2.alpha, 0, elapsed*5);
	if(wasloadingSong && !loadingSong.contains(true)){
		wasloadingSong = false;
		if(FileSystem.exists('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg'))
			FlxG.sound.playMusic(Sound.fromFile('assets/onlinedata/songs/${songFolder.toLowerCase()}/Inst.ogg'),FlxG.save.data.instVol,true);
		hasSong = true;
		setSelfStatus("");
	}


	if (quitHeldBar.visible && quitHeld <= 0){
		quitHeldBar.visible = false;
		quitHeldBG.visible = false;
	}

	Chat.update(elapsed);
	ChatBGBox.visible = Chat.hidechat;

	if (FlxG.keys.pressed.ESCAPE)
	{
		quitHeld += 10 * (elapsed * 100);
		quitHeldBar.visible = true;
		quitHeldBG.visible = true;
		if (quitHeld > 1000) disconnect();
	}else if (quitHeld > 0){
	  quitHeld -= 20 * (elapsed * 100);
	}
	super.update(elapsed);
	if(FlxG.save.data.animDebug){
		Overlay.debugVar += '\nLast Packet: ${lastPacketID};${lastPacket}';
	}
	FlxG.mouse.visible = true;
}

function OnDownloadData(ID:Int,e:ProgressEvent)
{
	var data:ByteArray = new ByteArray();
	ExSocket[ID][0].readBytes(data); // socket
	ExSocket[ID][1].OnData(data); // receiver
}
}
