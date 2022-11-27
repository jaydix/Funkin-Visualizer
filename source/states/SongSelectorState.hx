package states;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;
import objects.Transition;
import flixel.util.FlxColor;
import objects.Alphabet;
import flixel.system.FlxSound;
import openfl.utils.Assets;

using StringTools;

class SongSelectorState extends FlxState {
	var trans:Transition;
	var selected:Int = 0;
	var songs:Array<String> = [];
	var isTransitioning:Bool = false;

	var alphabetGroup:FlxTypedGroup<Alphabet>;

	override public function create():Void {
		alphabetGroup = new FlxTypedGroup<Alphabet>();
		bgColor = FlxColor.fromString('ffffff');
		if(Assets.exists('assets/data/songList.txt')){
			songs = textToList('assets/data/songList.txt');
		} else {
			songs = ['No Songs Loaded'];
		}
		add(alphabetGroup);
		trans = new Transition();
		var i:Int = 0;
		for (s in songs) {
			var a:Alphabet = new Alphabet(0, (70 * i) + 30, s);
			a.isMenuItem = true;
			a.targetY = i - 1;
			i++;
			alphabetGroup.add(a);
		}
		changeSelection();
		// trans.switchState(new PlayState());
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		for (s in alphabetGroup.members) {
			s.screenCenter(X);
		}
		if (!isTransitioning) {
			var upP = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
			var downP = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S;
			var accepted = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER;

			if (upP) {
				changeSelection(-1);
			}
			if (downP) {
				changeSelection(1);
			}

			if (accepted) {
				var song:String = songs[selected].toLowerCase().replace('\n', '');
				trace(song + 'lol');
				PlayState.song = song;
				trans.switchState(new PlayState());
				isTransitioning = true;
			}
		}
	}

	function changeSelection(change:Int = 0) {
		if (change != 0)
			new FlxSound().loadEmbedded('assets/sounds/scrollMenu.${Main.EXT}').play(0.4);

		selected += change;

		if (selected < 0)
			selected = songs.length - 1;
		if (selected >= songs.length)
			selected = 0;

		var bullShit:Int = 0;
		for (item in alphabetGroup.members) {
			item.targetY = bullShit - selected;
			item.targetY -= 1;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY + 1 == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function textToList(path:String):Array<String> {
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length) {
			daList[i] = daList[i].trim();
		}

		return daList;
	}
}
