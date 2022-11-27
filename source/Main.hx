package;

import states.SongSelectorState;
import states.PlayState;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
// crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

typedef Log = {
	var content:Dynamic;
	var file:String;
	var line:Int;
	var time:String;
}

class Main extends Sprite {
	var gameWidth:Int = 480; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 360; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = SongSelectorState; // The FlxState the game starts with.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets.

	public static var EXT:String = "ogg"; // The extension of the audio files.

	public static var logs:Array<Log> = [];

	var game_name:String = 'FUNKIN\' VISUALIZER';
	var sep:String = '/';

	public function new() {
		super();
		#if html5
		skipSplash = false;
		framerate = Std.int(framerate / 2);
		EXT = "mp3";
		#end
		replaceTrace(game_name, sep);

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));
		// replaceTrace('FUNKIN\' VISUALIZER','/');
		// haxe.Log.trace = oldTrace;
	}

	function replaceTrace(game:String, sep:String = '-'):Dynamic {
		var oldTrace = haxe.Log.trace; // store old function
		haxe.Log.trace = function(v, ?infos) {
			// handle trace
			var fn:String = infos.fileName.replace('source/', ''); // here in the countryside we hate source/ 🤠
			var r:String = '[$game $sep '; // begin cool thingy!!
			if (infos != null) { // its never null anyways so idk why this is here
				r += fn + ':' + infos.lineNumber + ' $sep '; // add file and line number (like Main.hx:69420)
			}
			var d = Date.now(); // get current time!!
			r += Std.string(d) + '] '; // add time to cool thingy!!
			r += Std.string(v); // add the actual trace
			logs.push({ // add to debug logs array...
				content: v, // the actual trace
				file: fn, // the file it was traced from
				line: infos.lineNumber, // the line trace() was called on
				time: Std.string(d) // time
			});
			oldTrace(r);
		}

		// ⬇ uncomment this for testing, obviously
		// trace('test');
		return haxe.Log.trace;
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		path = "./crash.txt";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		var crashLog:String = '';
		for (log in logs) {
			crashLog += log.file + ':' + log.line + ' ' + log.time + ' ' + log.content + '\n';
		}

		errMsg += "\nUncaught Error: \n" + e.error;

		File.saveContent(path, errMsg + "\n");
		File.saveContent('./logs.txt', crashLog);

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		Sys.println("Logs saved in " + Path.normalize("./logs.txt"));

		Application.current.window.alert(errMsg, "Error!");
		Sys.exit(1);
	}
	#end
}
