package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;

class Transition {
	var trans1:FlxSprite = new FlxSprite(0, 0).makeGraphic(Math.ceil(FlxG.width / 2), FlxG.height, 0xFF000000);
	var trans2:FlxSprite = new FlxSprite(0, 0).makeGraphic(Math.ceil(FlxG.width / 2), FlxG.height, 0xFF000000);
	public var tweenSpeed:Float = 0.655;

	public function new() {
		trans1.x = -FlxG.width / 2;
		trans2.x = FlxG.width;
		FlxG.state.add(trans1);
		FlxG.state.add(trans2);
		//trace('part 1 added');
		//trace('part 2 added');
		trans1.x = 0;
		trans2.x = FlxG.width / 2;
		FlxTween.tween(trans1, {x: -FlxG.width / 2}, tweenSpeed, {
			ease: FlxEase.circOut
		});
		FlxTween.tween(trans2, {x: FlxG.width}, tweenSpeed, {
			ease: FlxEase.circOut
		});
	}

	public function switchState(state:FlxState, ?callback) {
		trans1.x = -FlxG.width / 2;
		trans2.x = FlxG.width;

		FlxG.state.add(trans1);
		//trace('part 1 added');

		FlxG.state.add(trans2);
		//trace('part 2 added');

		FlxTween.tween(trans1, {x: 0}, tweenSpeed, {
			ease: FlxEase.circOut,
			onComplete: function(t) {
				new FlxTimer().start(1, function(tmr) {
					if(callback != null) callback();
					FlxG.switchState(state);
				});
			}
		});
		FlxTween.tween(trans2, {x: FlxG.width / 2}, tweenSpeed, {
			ease: FlxEase.circOut
		});

		return true;
	}
}
