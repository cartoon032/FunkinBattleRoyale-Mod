package onlinemod;

import haxe.display.Display.Package;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;
import flash.media.Sound;
import onlinemod.Packets;
import Song.MoreChar;

import Section.SwagSection;

class OnlinePlayState extends PlayState
{
	var clients:Map<Int, String> = [];
	public static var clientScores:Map<Int, Int> = [];
	public static var clientText:Map<Int, String> = [];
	public static var useSongChar:Array<String> = ["","",""];
	public static var autoDetPlayer2:Bool = true;
	var clientTexts:Map<Int, Int> = [];
	var clientCharacters:Map<Int, Array<Int>> = [];
	var clientsGroup:FlxTypedGroup<FlxText>;

	var CoolLeaderBoard:Array<Array<Dynamic>>;
	var scoreY:Float;

	var ChatBGBox:FlxSprite;

	var clientCount:Int = 1;

	var xieneDevWatermark:FlxText;
	var waitingBg:FlxSprite;
	var waitingText:FlxText;

	var customSong:Bool;
	var loadedVoices:FlxSound;
	var loadedInst:Sound;

	var ready:Bool = false;
	var waitMusic:FlxSound;

	var inPause:Bool = false;

	var originalSafeFrames:Int = FlxG.save.data.frames;

	public function new(customSong:Bool, voices:FlxSound, inst:Sound)
	{
		PlayState.stateType =3;
		super();

		this.customSong = customSong;
		this.loadedVoices = voices;
		this.loadedInst = inst;
	}

	override function create()
	{try{
		handleNextPacket = true;
		OnlinePlayMenuState.SetVolumeControls(true); // Make sure volume is enabled
		if (customSong){
			if (useSongChar[0] != "") PlayState.SONG.player1 = FlxG.save.data.playerChar;
			
			if ((FlxG.save.data.charAuto || useSongChar[1] != "") && TitleState.retChar(PlayState.player2) != ""){ // Check is second player is a valid character
				PlayState.player2 = TitleState.retChar(PlayState.player2);
			}else{
				PlayState.player2 = FlxG.save.data.opponent;
			}
			for (i => v in useSongChar) {
				if (v != ""){
					switch(i){
						case 0: PlayState.player1 = v;
						case 1: PlayState.player2 = v;
						case 2: PlayState.player3 = v;
					}
				}
			}
		}

		clients = OnlineLobbyState.clients.copy();
		if (autoDetPlayer2){
				var count = 0;
				for (i in clients.keys())
				{
					count++;
					if(count > 1){break;}
				}
				// PlayState.dadShow = (count == 1);
			}

		super.create();
		ChatBGBox = new FlxSprite().makeGraphic(FlxG.width, 175, 0x7F3F3F3F); // #3F3F3F
		ChatBGBox.setPosition(0, FlxG.height - 250);
		ChatBGBox.cameras = [camHUD];
		add(ChatBGBox);
		Chat.createChat(this,false,camTOP);
		clientScores = [];
		clientText = [];
		clientsGroup = new FlxTypedGroup<FlxText>();
		CoolLeaderBoard = [];

		CoolLeaderBoard.push([]);
		var Box1 = new FlxSprite().makeGraphic(275, 50, 0x7FFF7F00); // #FF7F00
		Box1.screenCenter(Y);
		scoreY = Box1.y;
		CoolLeaderBoard[0].push(Box1);
		Box1.cameras = [camHUD];
		add(Box1);
		var Box2 = new FlxSprite().makeGraphic(150, 50, 0x7FFFFF00); // #FFFF00
		CoolLeaderBoard[0].push(Box2);
		Box2.cameras = [camHUD];
		add(Box2);
		var nametext = new FlxText(Box2.x + 10, Box2.y + 12.5, OnlineNickState.nickname,16);
		nametext.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		CoolLeaderBoard[0].push(nametext);
		nametext.cameras = [camHUD];
		add(nametext);
		var scoretext = new FlxText(Box2.x + Box2.width + 10, Box2.y + 5, '0\nn/a%  0\n',16);
		scoretext.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		CoolLeaderBoard[0].push(scoretext);
		scoretext.cameras = [camHUD];
		add(scoretext);
		clientsGroup.add(scoretext);

		// Add the score UI for other players
		for (i in clients.keys())
		{
			clientScores[i] = 0;
			clientCount++;

			CoolLeaderBoard.push([]);
			var Box1 = new FlxSprite().makeGraphic(275, 50, 0x7F0000FF); // #0000FF
			Box1.screenCenter(Y);
			CoolLeaderBoard[CoolLeaderBoard.length - 1].push(Box1);
			Box1.cameras = [camHUD];
			add(Box1);
			var Box2 = new FlxSprite().makeGraphic(150, 50, 0x7F007FFF); // #007FFF
			CoolLeaderBoard[CoolLeaderBoard.length - 1].push(Box2);
			Box2.cameras = [camHUD];
			add(Box2);
			var nametext = new FlxText(Box2.x + 10, Box2.y + 12.5, OnlineLobbyState.clients[i],16);
			nametext.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			CoolLeaderBoard[CoolLeaderBoard.length - 1].push(nametext);
			nametext.cameras = [camHUD];
			add(nametext);
			var scoretext = new FlxText(Box2.x + Box2.width + 10, Box2.y + 5, '0\nn/a%  0\n',16);
			scoretext.setFormat(CoolUtil.font, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			CoolLeaderBoard[CoolLeaderBoard.length - 1].push(scoretext);
			scoretext.cameras = [camHUD];
			add(scoretext);
			clientTexts[i] = clientsGroup.length;
			clientsGroup.add(scoretext);
		}
		for(i in 0...CoolLeaderBoard.length){
				// Long Box
				CoolLeaderBoard[i][0].y = scoreY + (CoolLeaderBoard[i][0].height * i) - (CoolLeaderBoard[i][0].height + (CoolLeaderBoard[i][0].height * ((CoolLeaderBoard.length * 0.5) - 1.5)));
				CoolLeaderBoard[i][0].x = (!PlayState.invertedChart ? 125 - (Math.abs(0 - i) * 10) : FlxG.width - 375 + (Math.abs(0 - i) * 10));
				// Name Box
				CoolLeaderBoard[i][1].y = CoolLeaderBoard[i][0].y;
				CoolLeaderBoard[i][1].x = CoolLeaderBoard[i][0].x + 10;
				// Name Text
				CoolLeaderBoard[i][2].y = CoolLeaderBoard[i][1].y + 5;
				CoolLeaderBoard[i][2].x = CoolLeaderBoard[i][1].x + 10;
				// Score Text
				CoolLeaderBoard[i][3].y = CoolLeaderBoard[i][1].y + 5;
				CoolLeaderBoard[i][3].x = CoolLeaderBoard[i][1].x + CoolLeaderBoard[i][1].width + 10;
			}


		// Add XieneDev watermark
		xieneDevWatermark = new FlxText(-4, FlxG.height * 0.9 + 50, FlxG.width, 'SE-T-BattleRoyale ${MainMenuState.modver}', 16);
		xieneDevWatermark.setFormat(CoolUtil.font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		xieneDevWatermark.scrollFactor.set();
		xieneDevWatermark.cameras = [camHUD];
		add(xieneDevWatermark);


		// The screen with 'Waiting for players (1/4)' stuff
		waitingBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		waitingBg.alpha = 0.5;
		waitingBg.cameras = [camHUD];
		add(waitingBg);

		waitingText = new FlxText(0, 0, FlxG.width, 'Waiting for players (?/${clientCount})');
		waitingText.setFormat(CoolUtil.font, 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		waitingText.screenCenter(FlxAxes.XY);
		waitingText.cameras = [camHUD];
		add(waitingText);

		waitMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		waitMusic.volume = 0;
		waitMusic.play(false, FlxG.random.int(0, Std.int(waitMusic.length / 2)));
		FlxG.sound.list.add(waitMusic);

		// Remove healthbar
		scoreTxt.visible = false;
		remove(healthBarBG);
		remove(healthBar);
		for(icon in iconP1Array){remove(icon);}
		for(icon in iconP2Array){remove(icon);}
		camGame.alpha = 1;
		camGame.visible = true;

		OnlinePlayMenuState.receiver.HandleData = HandleData;
		new FlxTimer().start(transIn.duration, (timer:FlxTimer) -> Sender.SendPacket(Packets.GAME_READY, [], OnlinePlayMenuState.socket));

		FlxG.mouse.visible = false;
		FlxG.autoPause = false;
	}catch(e){MainMenuState.handleError('Crash in "create" caught: ${e.message}');}}

	override function startCountdown()
	{
		try{

			if (!ready)
				return;

		super.startCountdown();
			
		}catch(e){MainMenuState.handleError(e,'Crash in "startCountdown" caught: ${e.message}');}
	}

	override function startSong(?alrLoaded:Bool = false)
	{
		FlxG.sound.playMusic(loadedInst, 1, false);
		super.startSong(true);
	}

	override function generateSong(?dataPath:String = "")
	{
	//   // I have to code the entire code over so that I can remove the offset thing
	//   var songData = PlayState.SONG;
		// Conductor.changeBPM(songData.bpm);

		// curSong = songData.song;

		if (PlayState.SONG.needsVoices)
			vocals = loadedVoices;
		else
			vocals = new FlxSound();
		super.generateSong(dataPath);

		// Instantly get note id's, if this isn't done now, a note might not get added to the list
		var _note:Note;
		for (i in 0 ... unspawnNotes.length) {
			_note = unspawnNotes[i];
			if(_note == null || _note.noteData == -1) continue;
			noteData[_note.noteID] = [_note,_note.noteData % PlayState.keyAmmo[PlayState.SONG.mania]];
		}
	}

	override function popUpScore(daNote:Note):Void
	{
		super.popUpScore(daNote);
		clientsGroup.members[0].text = PlayState.songScore + "\n" + HelperFunctions.truncateFloat(PlayState.accuracy,2) + "%  " + PlayState.misses + "\n";

		SendScore();
	}

	override function noteMiss(direction:Int = 1, daNote:Note,?forced:Bool = false):Void
	{
		super.noteMiss(direction, daNote,forced);
		clientsGroup.members[0].text = PlayState.songScore + "\n" + HelperFunctions.truncateFloat(PlayState.accuracy,2) + "%  " + PlayState.misses + "\n";

		SendScore();
	}

	override function resyncVocals()
	{
		if (inPause)
			return;

		super.resyncVocals();
	}

	override function beatHit(){
		super.beatHit();
		CoolLeaderBoard.sort((a,b) -> Std.int(b[3].text.split(' ')[0]) - Std.int(a[3].text.split(' ')[0]));
		var WhereME = 1;
		for(Array in CoolLeaderBoard){
			if(StringTools.contains(Array[1].text,OnlineNickState.nickname))
				break;
			else
				WhereME++;
		}
		if(CoolLeaderBoard.length > 1){
			for(i in 0...CoolLeaderBoard.length){
					var YMove = scoreY + ((CoolLeaderBoard[i][0].height * (i - (WhereME - (CoolLeaderBoard.length * 0.5)))) - (CoolLeaderBoard[i][0].height + (CoolLeaderBoard[i][0].height * ((CoolLeaderBoard.length * 0.5) - 1.5))));
					var XMove = (!PlayState.invertedChart ?
						125 - (Math.abs((WhereME - 1) - i) * 10) :
						(FlxG.width - 375) + (Math.abs((WhereME - 1) - i) * 10)
						);
					CoolLeaderBoard[i][2].text = XMove;
					if(YMove - CoolLeaderBoard[i][0].y >= 20 || YMove - CoolLeaderBoard[i][0].y <= -20 || YMove - CoolLeaderBoard[i][1].y >= 20 || YMove - CoolLeaderBoard[i][1].y <= -20){
						FlxTween.tween(CoolLeaderBoard[i][0],{y: YMove,x: XMove},0.1,{ease: FlxEase.quadInOut});
						FlxTween.tween(CoolLeaderBoard[i][1],{y: YMove,x: XMove + 10},0.1,{ease: FlxEase.quadInOut});
						FlxTween.tween(CoolLeaderBoard[i][2],{y: YMove + 12.5,x: XMove + 10},0.1,{ease: FlxEase.quadInOut});
						FlxTween.tween(CoolLeaderBoard[i][3],{y: YMove + 5,x: XMove + CoolLeaderBoard[i][1].width + 20},0.1,{ease: FlxEase.quadInOut});
					}
				}
			}
	}

	override function finishSong(?win=true){}
	override function endSong():Void
	{
		clients[-1] = OnlineNickState.nickname;
		clientScores[-1] = PlayState.songScore;
		clientText[-1] = "S:" + PlayState.songScore + " M:" + PlayState.misses + " A:" + HelperFunctions.truncateFloat(PlayState.accuracy,2) + " " + Ratings.GenerateLetterRank(PlayState.accuracy);

		canPause = false;
		FlxG.sound.playMusic(loadedInst, FlxG.save.data.instVol, true);
		FlxG.sound.music.onComplete = null;
		FlxG.sound.music.pause();
		vocals.volume = 0;
		vocals.pause();

		Sender.SendPacket(Packets.GAME_END, [], OnlinePlayMenuState.socket);

		FlxG.switchState(new OnlineLobbyState(true,clients));
	}


	override function keyShit()
	{
		if (inPause)
			return;

		super.keyShit();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (Type.getClass(SubState) == PauseSubState)
		{
			var realPaused:Bool = paused;
			paused = false;

			super.openSubState(new OnlinePauseSubState());
			inPause = true;

			paused = realPaused;
			persistentUpdate = true;
			
			canPause = false;

			return;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			canPause = true;
			inPause = false;
		}

		super.closeSubState();
	}

	public static var handleNextPacket = true;
	static var noteData:Array<Array<Dynamic>> = []; // Stores notes so they can be hit by other players
	var lastPacket:Array<Dynamic> = [];
	var lastPacketID:Int = 0;
	function HandleData(packetId:Int, data:Array<Dynamic>)
	{try{
		lastPacketID = packetId;
		lastPacket = data;

		if(!handleNextPacket){
			handleNextPacket = true;
			return;
		}
		if(onlinemod.OnlinePlayMenuState.RespondKeepAlive(packetId)) return;
		callInterp("packetRecieve",[packetId,data]);
		switch (packetId)
		{
			case Packets.PLAYERS_READY:
				var count:Int = data[0];
				waitingText.text = 'Waiting for players ($count/${clientCount})';
			case Packets.EVERYONE_READY:
				var safeFrames:Int = data[0];
				waitingText.text = 'Ready!';
				ready = true;
				startCountdown();
				FlxTween.tween(waitingBg, {alpha: 0}, 0.5);
				FlxTween.tween(waitingText, {alpha: 0}, 0.5);
				FlxTween.tween(waitMusic, {volume: 0}, 0.5);

				FlxG.save.data.frames = safeFrames;
				Conductor.recalculateTimings();
			case Packets.BROADCAST_SCORE:
				var id:Int = data[0];
				var score:Int = data[1];
				if(Math.isNaN(id)){
					trace('Error for Packet BROADCAST_CURRENT_INFO: Invalid ID(${data[0]}) ');
					showTempmessage('Error for Packet BROADCAST_CURRENT_INFO: Invalid ID(${data[0]}) ');
					return;
				}
				if(Math.isNaN(score)){
					trace('Error for Packet BROADCAST_CURRENT_INFO, ID($id): Invalid Score(${data[1]}) ');
					return;
				}

				clientScores[id] = score;
				clientText[id] = "S:" + score+ " M:n/a A:n/a";
				clientsGroup.members[clientTexts[id]].text = Std.string(score);
			case Packets.BROADCAST_CURRENT_INFO:
				var id:Int = data[0];
				var score:Int = data[1];
				var misses:Int = data[2];
				var accuracy:Float = data[3];
				if(accuracy > 100) accuracy /= 100;
				if(Math.isNaN(id)){
					trace('Error for Packet BROADCAST_CURRENT_INFO: Invalid ID(${data[0]}) ');
					showTempmessage('Error for Packet BROADCAST_CURRENT_INFO: Invalid ID(${data[0]}) ');
					return;
				}
				if(Math.isNaN(score)){
					trace('Error for Packet BROADCAST_CURRENT_INFO, ID($id): Invalid Score(${data[1]}) ');
					return;
				}
				if(Math.isNaN(misses)){
					trace('Error for Packet BROADCAST_CURRENT_INFO, ID($id): Invalid Miss count(${data[2]}) ');
					return;
				}
				if(Math.isNaN(accuracy)){
					trace('Error for Packet BROADCAST_CURRENT_INFO, ID($id): Invalid Accuracy(${data[3]}) ');
					return;
				}

				clientScores[id] = score;
				clientText[id] = "S:" + score+ " M:" + misses+ " A:" + accuracy;
				clientsGroup.members[clientTexts[id]].text = score + "\n" + accuracy + "%  " + misses + "\n";

			case Packets.PLAYER_LEFT:
				var id:Int = data[0];
				var nickname:String = OnlineLobbyState.clients[id];

				clientsGroup.members[clientTexts[id]].setFormat(CoolUtil.font, 16, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				if(clientScores[id] == null) clientsGroup.members[clientTexts[id]].text = 'left';
				for(Array in CoolLeaderBoard){
					if(Array[3] == clientsGroup.members[clientTexts[id]]){
						var Box1 = new FlxSprite().makeGraphic(275, 50, 0x7FBF0000); // #BF0000
						Box1.y = FlxG.height - Box1.height;
						Box1.cameras = [camHUD];
						Box1.setPosition(Array[0].x,Array[0].y);
						add(Box1);
						var Box2 = new FlxSprite().makeGraphic(150, 50, 0x7FFF0000); // #FF0000
						Box2.cameras = [camHUD];
						Box2.setPosition(Array[1].x,Array[1].y);
						add(Box2);
						remove(Array[0]); Array[0].destroy();
						remove(Array[1]); Array[1].destroy();
						Array[0] = Box1;
						Array[1] = Box2;
						Array[2].setFormat(CoolUtil.font, 16, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
						remove(Array[2]); add(Array[2]);
						remove(Array[3]); add(Array[3]);
						break;
					}
				}

				OnlineLobbyState.removePlayer(id);
				Chat.PLAYER_LEAVE(nickname);
				clientCount--;

			case Packets.REJECT_CHAT_MESSAGE:
				Chat.SPEED_LIMIT();
			case Packets.SERVER_CHAT_MESSAGE:
				if(StringTools.startsWith(data[0],"'32d5d167'")) OnlineLobbyState.handleServerCommand(data[0].toLowerCase(),0); else Chat.SERVER_MESSAGE(data[0]);

			case Packets.FORCE_GAME_END:
				FlxG.switchState(new OnlineLobbyState(true));
			case Packets.KEYPRESS:
				// if (PlayState.p2canplay){
					try{

					if(data[1] == null){data[1] = 0;}
					var charID = data[2];
					var Side = data[3];
					if(Side != 0 && Side != 1) return; // gonna throw that away
					// if(charID >= 100) {
					// 	Side = clientCharacters[Std.int(charID/100)][1];
					// 	charID = clientCharacters[Std.int(charID/100)][0];
					// 	if(Side == 0)
					// 		PlayState.boyfriendArray[charID].visible = true;
					// 	else
					// 		PlayState.dadArray[charID].visible = true;
					// }
					// if(charID == 0 && PlayState.SONG.multichar == null) charID = PlayState.onlinecharacterID;

					if(data[0] == -1 && data[1] != null && data[1] != 0){
						if(PlayState.invertedChart){if(Side == 0) Side = 1; else Side = 0;}
						var anim = if(Side == 0) Note.playernoteAnims else Note.noteAnims;
						PlayState.charAnim(Side,anim[Std.int(data[1] - 1)],true,charID);
					}else{
						PlayState.instance.vocals.volume = FlxG.save.data.voicesVol;
						if(noteData[data[0]] != null){
							if(noteData[data[0]][0] != null){
								var note = noteData[data[0]][0];
								PlayState.ShouldAIPress[if(note.ourNote) 0 else 1][charID] = false;
								if(data[1] != null && data[1] != 0 || note.shouldntBeHit){ // Miss
									note.miss(if(note.ourNote) 0 else 1,note,false,(if(PlayState.SONG.multichar == null)charID else null),if(note.ourNote && !PlayState.instance.COOPMode) false else true);
								}else{
									note.hit(if(note.ourNote) 0 else 1,note,false,(if(PlayState.SONG.multichar == null)charID else null),if(note.ourNote && !PlayState.instance.COOPMode) false else true);
								}
								if(!note.mustPress){ // Oi, dumbass, don't delete notes from the player
									note.kill();
									notes.remove(note, true);
									note.destroy();
								}
							}else{
								var noteData:Int = noteData[data[0]][1];
								var anim = if(Side == 0) Note.playernoteAnims else Note.noteAnims;
								PlayState.charAnim(0,anim[noteData] = (if(data[1] != null && data[1] != 0 ) "miss" else ""),true,charID); // Play animation
							}
						}
						for (i => note in notes.members){
							if(note.noteID == data[0]){
								if(data[1] != null && data[1] != 0 || note.shouldntBeHit){ // Miss
									note.miss(if(note.ourNote) 0 else 1,note,false,(if(PlayState.SONG.multichar == null)charID else null),if(note.ourNote && !PlayState.instance.COOPMode) false else true);
								}else{
									note.hit(if(note.ourNote) 0 else 1,note,false,(if(PlayState.SONG.multichar == null)charID else null),if(note.ourNote && !PlayState.instance.COOPMode) false else true);
								}
								if(!note.mustPress){ // Oi, dumbass, don't delete notes from the player
									note.kill();
									notes.remove(note, true);
									note.destroy();
								}
							}
						}
					}
				}catch(e){
					trace('Error with KEYPRESS: $data ${e.message}');
				}
				// }
			case Packets.BROADCAST_NEW_PLAYER:
				var id:Int = data[0];
				var nickname:String = data[1];

				OnlineLobbyState.addPlayer(id, nickname);
				Chat.PLAYER_JOIN(nickname);
				clientCount++;

				CoolLeaderBoard.push([]);
				var Box1 = new FlxSprite().makeGraphic(275, 50, 0x7F7F7F7F); // #7F7F7F
				Box1.y = FlxG.height - Box1.height;
				CoolLeaderBoard[CoolLeaderBoard.length - 1].push(Box1);
				Box1.cameras = [camHUD];
				add(Box1);
				var Box2 = new FlxSprite().makeGraphic(150, 50, 0x7FBFBFBF); // #BFBFBF
				CoolLeaderBoard[CoolLeaderBoard.length - 1].push(Box2);
				Box2.cameras = [camHUD];
				Box2.x += 10;
				Box2.y = Box1.y;
				add(Box2);
				var nametext = new FlxText(Box2.x + 10, Box2.y + 12.5, '${nickname}',16);
				nametext.setFormat(CoolUtil.font, 16, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				CoolLeaderBoard[CoolLeaderBoard.length - 1].push(nametext);
				nametext.cameras = [camHUD];
				add(nametext);
				var scoretext = new FlxText(Box2.x + Box2.width + 10, Box2.y + 5, 'In lobby',16);
				scoretext.setFormat(CoolUtil.font, 16, FlxColor.YELLOW, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				CoolLeaderBoard[CoolLeaderBoard.length - 1].push(scoretext);
				scoretext.cameras = [camHUD];
				add(scoretext);
				clientTexts[id] = clientsGroup.length;
				clientsGroup.add(scoretext);
			case Packets.DISCONNECT:
				FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
			case Packets.BROADCAST_CHAT_MESSAGE:
				var id:Int = data[0];
				var message:String = data[1];

				Chat.MESSAGE(OnlineLobbyState.clients[id], message);
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

		}}catch(e){
			var packetName = "Unknown";
			if(PacketsShit.fields[packetId] != null){
				packetName = PacketsShit.fields[packetId].name;
			}
			trace(e);
			Chat.OutputChatMessage("[Client] You had an error when receiving packet '" + '${packetName}' + "' with ID '" + '$packetId' + "' :");
			Chat.OutputChatMessage(e.message);
			var err = ('${e.stack}').split('\n');
			var _e = "";
			while ((_e = err.pop()) != null){
				Chat.OutputChatMessage('||${_e}');
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OnlineLobbyState(true));
		}

	}
	

	function SendScore()
	{
		if (TitleState.supported)
			Sender.SendPacket(Packets.SEND_CURRENT_INFO, [PlayState.songScore,PlayState.misses,Math.ceil(PlayState.accuracy * 100)], OnlinePlayMenuState.socket);
		else
			Sender.SendPacket(Packets.SEND_SCORE, [PlayState.songScore], OnlinePlayMenuState.socket);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(inPause)
			Conductor.songPosition = FlxG.sound.music.time / PlayState.songspeed;
		if (!ready)
		{
			Conductor.songPosition = -5000;
			Conductor.lastSongPos = -5000;
			songTime = 0;
			if (waitMusic.volume < 0.75)
				waitMusic.volume += 0.1 * elapsed;
		}
		if(FlxG.save.data.animDebug){
			Overlay.debugVar += '\nClient count:${clientCount}'
				+'\nLast Packet: ${lastPacketID};${lastPacket}';
		}

		canPause = (!Chat.chatField.hasFocus && !paused);
		ChatBGBox.visible = Chat.hidechat;
		if((!Chat.hidechat && FlxG.keys.justPressed.T) || (Chat.hidechat && FlxG.keys.justPressed.ESCAPE))
			Chat.toggleChat();
		if(FlxG.keys.justPressed.ESCAPE)
			Chat.chatField.hasFocus = false;
		if(FlxG.keys.justPressed.T)
			Chat.chatField.hasFocus = true;
		Chat.update(elapsed);
	}
/*
	override function addExtraCharacter(){ // i will come back to this later
		if(PlayState.SONG.multichar != null && PlayState.SONG.multichar != []){
			super.addExtraCharacter();
			return;
		}
		var offset = 250;
		var CurEXChar = 1;
		for (i in clients.keys()){
				LoadingScreen.loadingText = 'Loading Extra Character ${CurEXChar}/${onlinemod.OnlineLobbyState.clientCount}';
				if(CurEXChar > FlxG.save.data.OnlineEXCharLimit){
					LoadingScreen.loadingText = 'Limit reach on Extra Character';
					return;
				}
				var CharInfo:MoreChar = {
					char: "boyfriend",
					side: 0,
					offset: offset
				};
				if(CurEXChar <= onlinemod.OnlineLobbyState.ExChar.length)CharInfo = onlinemod.OnlineLobbyState.ExChar[CurEXChar - 1];
				var CharName = (if(TitleState.retChar(CharInfo.char) != "") CharInfo.char else "boyfriend");
				var Char = (if((PlayState.bfShow && FlxG.save.data.bfShow && CharInfo.side == 0) || (PlayState.dadShow && FlxG.save.data.dadShow && CharInfo.side == 1)) new Character(0, 100, CharName,CharInfo.side == 1 ? false : true,CharInfo.side) else new EmptyCharacter(0,100));
				Char.visible = false; // fuck you im spawning you invisible
				if(CharInfo.side == 1){
					Char.x = PlayState.dad.x + CharInfo.offset;
					PlayState.dadArray.push(Char);
				}
				else{
					Char.x = PlayState.boyfriend.x + CharInfo.offset;
					PlayState.boyfriendArray.push(Char);
				}
				PlayState.ShouldAIPress[CharInfo.side].push(true);
				CurEXChar++;
				clientCharacters[i] = [PlayState.boyfriendArray.length - 1,CharInfo.side];
				offset += 250;
		}
	}
 */
	override function destroy()
	{
		// This function is called when the State changes. For example, when exiting via the pause menu.
		FlxG.sound.music.onComplete = null;

		FlxG.save.data.frames = originalSafeFrames;
		Conductor.recalculateTimings();
		super.destroy();
	}
	override function testanimdebug(){
		return;
	}
}