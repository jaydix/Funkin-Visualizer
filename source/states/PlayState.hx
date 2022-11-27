package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import objects.Transition;
import flixel.util.FlxColor;
import tools.ChartBroom;
import objects.Guy;
import flixel.system.FlxSound;
import states.SongSelectorState;
#if desktop
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
#end

class PlayState extends FlxState {
	var voices:FlxSound = new FlxSound();
	var chart:CleanedChart;
	var dad:Guy;
	var bf:Guy;

	public static var song:String = 'bopeebo';

	var crochet:Float;
	var trans:Transition;

	override public function create():Void {
		bgColor = FlxColor.fromString('ffffff');
		super.create();

		chart = ChartBroom.clean(song);
		crochet = chart.crochet;
		trace(crochet);
		// trace();
		dad = new Guy(0, 0);
		dad.screenCenter();
		dad.y += 25;
		dad.x -= 100;
		bf = new Guy(0, 0, true);
		bf.screenCenter();
		bf.y += 25;
		bf.x += 100;
		add(dad);
		add(bf);

		// dad.animation.play('left');

		playMusic(song);
		trans = new Transition();
	}

	private function playMusic(song:String):Void {
		voices.loadEmbedded('assets/music/$song/Voices.${Main.EXT}');
		FlxG.sound.playMusic('assets/music/$song/Inst.${Main.EXT}', 1, false);
		voices.play(false, FlxG.sound.music.time);
	}

	override public function onFocusLost():Void {
		super.onFocusLost();
		voices.pause();
	}

	override public function onFocus():Void {
		super.onFocus();
		voices.resume();
		voices.time = FlxG.sound.music.time;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		voices.volume = FlxG.sound.music.volume; // WHY DOESNT IT JUST DJUST AUTOMATICALLY GRRR I FUKCING HAT  HAXFLXIEL

		for (s in chart.notes) {
			for (n in s.notes) {
				var offset:Float = 0.05 * 1000;
				if ((n.strumTime - offset < FlxG.sound.music.time) && (FlxG.sound.music.time < n.strumTime + (offset + n.length))) {
					var a:String = ['left', 'down', 'up', 'right'][n.note];
					// trace(n.bfSing);
					if (!n.bfSing) {
						dad.playAnim(a, (n.length > 0));
					} else {
						bf.playAnim(a, (n.length > 0));
					}
					// trace(n);
				}
			}
		}
		if (FlxG.sound.music.time % crochet < 0.05 * 1000) {
			if ((dad.animation.curAnim.finished) || (dad.animation.curAnim.name == 'idle')) {
				dad.playAnim('idle', true);
			}
			if ((bf.animation.curAnim.finished) || (bf.animation.curAnim.name == 'idle')) {
				bf.playAnim('idle', true);
			}
		}
		if (dad.animation.curAnim.finished && dad.animation.curAnim.name != 'idle') {
			dad.playAnim('idle');
		}
		if (bf.animation.curAnim.finished && bf.animation.curAnim.name != 'idle') {
			bf.playAnim('idle');
		}

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE || (FlxG.sound.music.time >= FlxG.sound.music.length - 1)) {
			trans.switchState(new SongSelectorState(), function() {
				FlxG.sound.music.stop();
				voices.stop();
			});
		}

		#if desktop
		if(FlxG.keys.justPressed.SEVEN){
			FlxG.sound.music.stop();
			voices.stop();

			var newPath:String = './assets/data/charts/$song.json';
			File.copy(newPath, newPath + '.bak');
			File.saveContent(newPath, Json.stringify(chart));

			trans.switchState(new PlayState());
		}
		if(FlxG.keys.justPressed.EIGHT){
			FlxG.sound.music.stop();
			voices.stop();

			var oldPath:String = './assets/data/charts/$song.json.bak';
			FileSystem.deleteFile('./assets/data/charts/$song.json');
			FileSystem.rename(oldPath, './assets/data/charts/$song.json');

			trans.switchState(new PlayState());
		}
		#end
	}
}
