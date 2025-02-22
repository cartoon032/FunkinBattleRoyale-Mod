package;
import Sys.sleep;
import discord_rpc.DiscordRpc;
import flixel.FlxG;

using StringTools;

class DiscordClient
{
	static var TurnOn:Bool = true;
	public function new()
	{
		TurnOn = FlxG.save.data.DiscordRPC;
		if(!TurnOn)return;
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "983726933164572693",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: null,
			state: "Start up",
			largeImageKey: 'icon',
			largeImageText: "FNF : SE-T"
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		if(!TurnOn)return;
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, ?largeImageKey:String = "icon", ?smallImageText:String)
	{
		if(!TurnOn)return;
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: largeImageKey,
			largeImageText: "FNF : SE-T " + MainMenuState.modver,
			smallImageKey: smallImageKey,
			smallImageText: smallImageText,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
            endTimestamp: Std.int(endTimestamp / 1000)
			// partyID: "AAAAAAAAAAA", // brain size tiny
			// joinSecret: "AAAAAAAAAAAAAA"
		});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
}