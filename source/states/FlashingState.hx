package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		blurOnSubstate = true;
		controls.isInSubstate = false; // qhar I hate it

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('interfaces/title/disclaimer'));
		add(bg);

		var text:FlxSprite = new FlxSprite().loadGraphic(Paths.image('interfaces/title/disclaimer_text'));
		text.screenCenter();
		text.y -= 15;
		add(text);

		// addVirtualPad('NONE', 'A_B');
	}

	override function update(elapsed:Float)
	{
		if((controls.ACCEPT || FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justPressed) && !leftState)
		{
			openSubState(new objects.HQDialog('Confirm Disclaimer', "By selecting 'Yes'. You've read the\ndisclaimer.\nDo you wish to continue?",
				{name: 'No', onSelect: function(substate) {
					FlxG.sound.play(Paths.sound('ui/window_close'));
					substate.close();
				}},

				{name: 'Yes', onSelect: (substate) -> {
					var overlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					overlay.alpha = 0;
					add(overlay);
					FlxG.save.data.agreedDisclaimer = leftState = true;
					FlxG.save.flush();
					substate.close();
					blurOnSubstate = false;
					FlxTween.tween(overlay, {alpha: 1}, {ease: FlxEase.sineInOut, startDelay: (FlxG.sound.play(Paths.sound('confirmMenu')).length / 1000) * 0.8, onComplete: (_) -> MusicBeatState.switchState(new states.InitState())});
				}}
		));
	}

	super.update(elapsed);
	}
}
