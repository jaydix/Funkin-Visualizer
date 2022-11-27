package tools;

import flixel.util.typeLimit.OneOfTwo;
import openfl.Assets;
import haxe.Json;

using StringTools;

typedef CleanedNote = {
	var strumTime:Float;
	var note:Int;
	var length:Float;
	var bfSing:Bool;
};

typedef CleanedSection = {
	var notes:Array<CleanedNote>;
	var focusOnBf:Bool;
	var beginTime:Float;
};

typedef CleanedChart = {
	var name:String;
	var bpm:Float;
	var notes:Array<CleanedSection>;
	var crochet:Float;
};

typedef UncleanedNote = Array<OneOfTwo<Float, Int>>;

typedef UncleanedSection = {
	var sectionNotes:Array<UncleanedNote>;
	var mustHitSection:Bool;
	var lengthInSteps:Int;
};

typedef UncleanedChart = {
	var player1:String;
	var player2:String;
	var player3:Null<String>;
	var events:Null<Array<Any>>;
	var gfVersion:String;
	var notes:Array<UncleanedSection>;
	var song:String;
	var bpm:Float;
	var speed:Float;
};

typedef UncleanedFile = { // not needed!!
	var song:UncleanedChart;
};

/**
 * cleans charts
 * @author 8Bit
 */
class ChartBroom {
	public static function clean(song:String):CleanedChart {
		var file:Dynamic = Json.parse(Assets.getText("assets/data/charts/" + song.toLowerCase() + ".json"));
		var uncleanedChart:Null<UncleanedChart> = file.song;
		if(uncleanedChart == null){
			trace('song is already cleaned!!');
			return file;
		}
		trace('got uncleaned chart!!');
		var chart:CleanedChart = {
			name: uncleanedChart.song,
			bpm: uncleanedChart.bpm,
			notes: [],
			crochet: ((uncleanedChart.bpm / 60) * 1000)
		};
		trace('cleaning chart starts now');
		var i:Int = 0;
		for (s in uncleanedChart.notes) {
			var section:CleanedSection = {
				notes: [],
				focusOnBf: s.mustHitSection,
				beginTime: i * (s.lengthInSteps * chart.crochet)
			};
			for (n in s.sectionNotes) {
				var note:CleanedNote = {
					strumTime: n[0],
					note: Std.int(n[1]),
					length: n[2],
					bfSing: false,
				};
				if (section.focusOnBf) {
					if (note.note < 4) {
						note.bfSing = true;
					}
				} else {
					if (note.note >= 4) {
						note.bfSing = true;
					}
				}
				note.note = note.note % 4;
				section.notes.push(note);
				// trace('${section.notes.length} notes');
			}
			chart.notes.push(section);
			// trace('${chart.notes} sections');
			i++;
		}
		trace('done!');
		return chart;
	}
}
