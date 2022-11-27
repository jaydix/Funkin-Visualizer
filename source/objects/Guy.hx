package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;

/**
 * the man himself
 *
 * @author 8Bit
 */
class Guy extends FlxSprite {
	public var isPlayer:Bool = false;

	override public function new(x:Float = 0, y:Float = 0, isPlayer:Bool = false) {
		super(x, y);
		this.scale.set(.5, .5);
		this.flipX = this.isPlayer = isPlayer;
		this.frames = FlxAtlasFrames.fromSparrow('assets/images/guy.png', 'assets/images/guy.xml');
		animation.addByIndices('idle', 'anims', framesFrom(0, 5), "", 24, false);
		if (!this.isPlayer) {
			animation.addByIndices('left', 'anims', framesFrom(6, 9), "", 24, false);
			animation.addByIndices('right', 'anims', framesFrom(19, 23), "", 24, false);
		} else {
			animation.addByIndices('left', 'anims', framesFrom(19, 23), "", 24, false);
			animation.addByIndices('right', 'anims', framesFrom(6, 9), "", 24, false);
		}
		animation.addByIndices('down', 'anims', framesFrom(10, 13), "", 24, false);
		animation.addByIndices('up', 'anims', framesFrom(15, 18), "", 24, false);

		playAnim('idle');
	}

	public function playAnim(name:String, forceRestart:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		switch (name) {
			case 'right':
				this.color = 0xFFd46666;

			case 'left':
				this.color = 0xff9266d4;

			case 'up':
				this.color = 0xFF61cf61;

			case 'down':
				this.color = 0xFF61cfcf;

			default:
				this.color = FlxColor.WHITE;
		}
		animation.play(name, forceRestart, reversed, frame);
	}

	private function framesFrom(min:Int, max:Int):Array<Int> {
		var frames:Array<Int> = [];
		for (i in min...max) {
			frames.push(i);
		}
		for (i in 0...5) {
			frames.push(max);
		}
		return frames;
	}
}
