package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;

class PlayState extends FlxState
{
	public var inputList:Array<{key:String, amount:Int}> = [];
	public var inputSprites:FlxTypedGroup<FlxSprite>;

	var inputlisttext:FlxText;

	public var player:FlxSprite = new FlxSprite();
	public var key:FlxSprite = new FlxSprite();
	public var door:FlxSprite = new FlxSprite();

	var lastDir:String = '';
	var key_linked:Bool = false;

	public var inputCode:String = '';

	public static var leveljsonPath:String = 'tutorial';

	public var level:LevelData;

	override public function create()
	{
		level = Json.parse(Assets.getText('assets/$leveljsonPath.json'));

		if (level == null)
			inputCode = level.code;

		if (inputCode == null || inputCode == '')
			parseInputCode('l.2-d.0-u.0-r.4');
		else
			parseInputCode(inputCode);

		inputSprites = new FlxTypedGroup<FlxSprite>();
		// add(inputSprites);

		var width = Std.int(FlxG.width / 64);
		var height = Std.int(FlxG.height / 64);

		var w = 0;
		var h = 0;

		#if (gridOutlineDisplay)
		while (h < height + 1)
		{
			while (w < width)
			{
				var grid = new FlxSprite();
				grid.loadGraphic('assets/gridOutline.png', true, 64, 64);
				grid.animation.add('idle', [0, 1, 2, 3], 16);
				grid.animation.play('idle');
				add(grid);
				grid.alpha = .5;
				grid.x = w * 64;
				grid.y = h * 64;

				var id = new FlxText();
				id.text = '[$w,$h]';
				id.setPosition(grid.x, grid.y);
				add(id);

				w++;
			}
			w = 0;
			h++;
		}
		#end

		inputlisttext = new FlxText();
		inputlisttext.size = 16;

		super.create();

		key.makeGraphic(64, 64, FlxColor.YELLOW);
		key.screenCenter();
		key.x -= key.width * 2;
		add(key);

		player.makeGraphic(64, 64, FlxColor.RED);
		player.screenCenter();
		add(player);

		door.makeGraphic(64, 64, FlxColor.GRAY);
		door.screenCenter();
		door.x += door.width * 2;
		add(door);

		if (level != null)
		{
			key.setPosition(level.keyPosition[0] * 64, level.keyPosition[1] * 64);
			player.setPosition(level.playerPosition[0] * 64, level.playerPosition[1] * 64);
			door.setPosition(level.doorPosition[0] * 64, level.doorPosition[1] * 64);
		}

		add(inputlisttext);
	}

	function parseInputCode(inputCode:String)
	{
		trace('Parsing ${inputCode}');
		inputList = [];
		for (key in inputCode.toLowerCase().split('-'))
		{
			var values = key.split('.');
			var input = '';

			switch (values[0])
			{
				case 'l':
					input = 'left';
				case 'd':
					input = 'down';
				case 'u':
					input = 'up';
				case 'r':
					input = 'right';
			}

			addInput(input, Std.parseInt(values[1]));
		}
		trace('Parsed ${inputCode}: ${inputList}');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		inputlisttext.text = '';
		inputCode = '';
		for (input in inputList)
		{
			inputlisttext.text += '${input.key.toLowerCase()} - ${input.amount}\n';

			inputCode += '${input.key.charAt(0).toLowerCase()}.${input.amount}-';

			if ((input.amount > 0 && FlxG.keys.justReleased.ANY))
			{
				switch (input.key.toLowerCase())
				{
					case 'left':
						if (FlxG.keys.anyJustReleased([LEFT, A]))
						{
							input.amount -= 1;
							player.x -= player.width;
							lastDir = 'l';
						}
					case 'right':
						if (FlxG.keys.anyJustReleased([RIGHT, D]))
						{
							input.amount -= 1;
							player.x += player.width;
							lastDir = 'r';
						}
					case 'down':
						if (FlxG.keys.anyJustReleased([DOWN, S]))
						{
							input.amount -= 1;
							player.y += player.height;
							lastDir = 'd';
						}
					case 'up':
						if (FlxG.keys.anyJustReleased([UP, W]))
						{
							input.amount -= 1;
							player.y -= player.height;
							lastDir = 'u';
						}
				}
			}
		}
		inputCode = inputCode.substring(0, inputCode.length - 1);
		FlxG.watch.addQuick('InputCode', inputCode);

		var zeros:Int = 0;
		for (key in inputCode.toLowerCase().split('-'))
		{
			var values = key.split('.');

			if (values[1] == '0')
				zeros++;
		}

		if (zeros == inputCode.toLowerCase().split('-').length)
			FlxG.switchState(() -> new NoControlsState());

		if (!key_linked)
		{
			if (player.overlaps(key))
				key_linked = true;
		}
		else if (key_linked)
		{
			if (player.overlaps(door) || FlxG.keys.justReleased.F5)
			{
				if (level.nextLevelPath != null)
				{
					PlayState.leveljsonPath = level.nextLevelPath;
					FlxG.switchState(() -> new PlayState());
				}
				else
				{
					FlxG.switchState(() -> new EndState());
				}
			}

			key.setPosition(player.x, player.y);

			switch (lastDir)
			{
				case 'l':
					key.x += player.width;
				case 'r':
					key.x -= player.width;

				case 'u':
					key.y += player.height;
				case 'd':
					key.y -= player.height;
			}
		}
	}

	public function addInput(key:String, amount:Int)
	{
		inputList.push({
			key: key,
			amount: amount,
		});
	}
}
