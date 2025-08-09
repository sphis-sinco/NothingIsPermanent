package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class EndState extends FlxState
{
	override function create()
	{
		super.create();

		var text = new FlxText();
		text.size = 16;
		text.alignment = 'center';
		text.text = 'You\'re done.\n\n\nHope you had fun\n\nIf you press anything the game will reset';
		text.screenCenter();
		add(text);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justReleased.ANY)
		{
			PlayState.leveljsonPath = 'tutorial';
			FlxG.switchState(() -> new PlayState());
		}
	}
}
