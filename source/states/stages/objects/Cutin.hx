package states.stages.objects;

import states.PlayState;
import flixel.FlxCamera;
import objects.Character;
import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;

// this might look weird but it just seemed alot more convinient doing this like that
@:access(flixel.FlxCamera)
class Cutin extends FlxGroup
{
	public var bg:FlxBackdrop;
	public var character:Character;
	public var cam:FlxCamera;
	public var isPlayer(default, null):Bool = false;
	public var characterBaseX:Float = 0;

	private var animationsOffset:Map<String, Array<Float>> = new Map<String, Array<Float>>();

	public function new(y:Int, bgName:String, characterName:String, isPlayer:Bool = false, cameraPos:Int)
	{
		cam = new FlxCamera(0, y, FlxG.width, 200);
		FlxG.game.addChildAt(cam.flashSprite, FlxG.game.getChildIndex(FlxG.cameras.list[cameraPos + 1].flashSprite) - 1);

		FlxG.cameras.list.insert(cameraPos - 1, cam);

		cam.bgColor.alpha = 0;
		cam.ID = FlxG.cameras.list.indexOf(cam);

		this.isPlayer = isPlayer;

		super();

		var graphic:FlxGraphic = Paths.image('interfaces/game/$bgName', 'shared');
		bg = new FlxBackdrop(null, flixel.util.FlxAxes.X);
		bg.loadGraphic(graphic, true, graphic.width, Std.int(graphic.height / 3), false);
		bg.y = 22;
		bg.velocity.set();
		bg.scale.y = 0.95;
		bg.animation.add('loop', [0, 1, 2], 24, true);
		bg.animation.play('loop', true);
		bg.cameras = [cam];
		add(bg);

		character = new Character(0, 0, characterName, isPlayer);
		character.scale.set(0.95, 0.95);
		character.y = 22;
		character.cameras = [cam];
		if (Std.isOfType(FlxG.state, PlayState))
		{
			if (isPlayer)
				PlayState.instance.players.push(character);
			else
				PlayState.instance.opponents.push(character);
		}
		add(character);
	}

	public function jumpIn(?force:Bool = false, ?reset:Bool = true)
	{
		if (force)
		{
			cam.alpha = 1.0;
			cam.flashSprite.height = 152;
			character.x = characterBaseX;
			return;
		}

		if (reset)
		{
			cam.alpha = 0.00001;
			cam.flashSprite.height = 5;
			character.x = isPlayer ? -120 : FlxG.width;
		}

		character.x = characterBaseX + (isPlayer ? 120 : -120);
		cam.flashSprite.height = 5;

		FlxTween.tween(cam, {alpha: 1}, 0.2, {ease: FlxEase.cubeOut});
		FlxTween.tween(cam.flashSprite, {height: cam._scrollRect.height}, 0.25, {ease: FlxEase.cubeOut});
		FlxTween.tween(character, {x: characterBaseX}, 0.3, {ease: FlxEase.quintOut});
	}

	public function jumpOut(?force:Bool = false, ?reset:Bool = true)
	{
		if (force)
		{
			cam.alpha = 0.00001;
			cam.flashSprite.height = 5;
			character.x = isPlayer ? -120 : FlxG.width;
			return;
		}

		if (reset)
		{
			cam.alpha = 1.0;
			cam.flashSprite.height = cam._scrollRect.height;
			character.x = characterBaseX;
		}

		FlxTween.tween(cam, {alpha: 0.00001}, 0.25, {ease: FlxEase.cubeOut, startDelay: 0.13});
		FlxTween.tween(cam.flashSprite, {height: 5}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0.1});
		FlxTween.tween(character, {x: isPlayer ? -120 : FlxG.width}, 0.3, {ease: FlxEase.quintOut});
	}

	override function destroy()
	{
		if (Std.isOfType(FlxG.state, PlayState) && PlayState.instance != null)
		{
			if (isPlayer && PlayState.instance.players != null)
				PlayState.instance.players.remove(character);

			if (!isPlayer && PlayState.instance.opponents != null)
				PlayState.instance.opponents.remove(character);
		}
		FlxG.cameras.remove(cam, false);
		cam = FlxDestroyUtil.destroy(cam);
		super.destroy();
	}
}
