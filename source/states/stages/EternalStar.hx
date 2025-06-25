package states.stages;

import states.stages.objects.*;

class EternalStar extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	
	public var bg:FlxSprite;
	public var bgBlack:FlxSprite;

	public var objects1:FlxSprite;
	public var objects1Black:FlxSprite;

	public var objects2:FlxSprite;
	public var objects2Black:FlxSprite;

	public var pills:FlxSprite;

	public var floor:FlxSprite;

	public var sayaka:FlxSprite;
	public var mami:FlxSprite;
	public var flashing:Bool = false;

	public var blackBg:FlxSprite;
	public var spotlight:FlxSprite;
	public var pillsFront:FlxSprite;

	public var flash:FlxSprite;

	override function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('eternal_star/background'));
		bg.setPosition(-260, -20);
		bg.scale.set(1.2, 1.2);
		add(bg);

		bgBlack = new FlxSprite().loadGraphicFromSprite(bg);
		bgBlack.setPosition(bg.x, bg.y);
		bgBlack.scale.copyFrom(bg.scale);
		bgBlack.alpha = 0.6;
		bgBlack.blend = MULTIPLY;
		bgBlack.color = FlxColor.BLACK;
		add(bgBlack);

		objects1 = new FlxSprite().loadGraphic(Paths.image('eternal_star/objects1'));
		objects1.setPosition(-260, -30);
		objects1.scale.set(1.2, 1.2);
		add(objects1);

		objects1Black = new FlxSprite().loadGraphicFromSprite(objects1);
		objects1Black.setPosition(objects1.x, objects1.y);
		objects1Black.scale.copyFrom(objects1.scale);
		objects1Black.alpha = 0.6;
		objects1Black.blend = MULTIPLY;
		objects1Black.color = FlxColor.BLACK;
		add(objects1Black);

		objects2 = new FlxSprite().loadGraphic(Paths.image('eternal_star/objects2'));
		objects2.setPosition(-255, -30);
		objects2.scale.set(1.2, 1.2);
		add(objects2);

		objects2Black = new FlxSprite().loadGraphicFromSprite(objects2);
		objects2Black.setPosition(objects2.x, objects2.y);
		objects2Black.scale.copyFrom(objects2.scale);
		objects2Black.alpha = 0.6;
		objects2Black.blend = MULTIPLY;
		objects2Black.color = FlxColor.BLACK;
		add(objects2Black);

		pills = new FlxSprite(0, -550).loadGraphic(Paths.image('eternal_star/pills'));
		pills.scrollFactor.set(1.1, 1.1);
		pills.scale.set(1.2, 1.2);
		add(pills);

		floor = new FlxSprite().loadGraphic(Paths.image('eternal_star/floor'));
		floor.setPosition(-290, -60);
		floor.scale.set(1.2, 1.2);
		add(floor);

		sayaka = new FlxSprite();
		sayaka.frames = Paths.getSparrowAtlas('eternal_star/vibe_sayaka');
		sayaka.animation.addByPrefix('bop', 'sayaka cheer', 24, false);
		sayaka.animation.addByPrefix('bop-alt', 'sayaka ALTcheer', 24, false);
		sayaka.animation.play('bop', true);
		sayaka.scale.set(0.8, 0.8);
		sayaka.setPosition(-145, 315);
		add(sayaka);
		
		mami = new FlxSprite();
		mami.frames = Paths.getSparrowAtlas('eternal_star/vibe_mami');
		mami.animation.addByPrefix('bop', 'mami cheer', 24, false);
		mami.animation.addByIndices('bop-right', 'mami ALTcheer', [for (i in 0...14) i], '', 24, false);
		mami.animation.addByIndices('bop-left', 'mami ALTcheer', [for (i in 14...29) i], '', 24, false);
		mami.animation.play('bop', true);
		mami.scale.set(0.8, 0.8);
		mami.setPosition(1165, 205);
		add(mami);
	}

	override function characterPost()
	{
		boombox.setPosition(330, 507);

		blackBg = new FlxSprite(-200, 0).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackBg.alpha = 0.0001;
		addBehindDad(blackBg);
	}
	
	override function createPost()
	{
		// Use this function to layer things above characters!

		spotlight = new FlxSprite(0, 275).loadGraphic(Paths.image('eternal_star/light'));
		spotlight.blend = ADD;
		spotlight.alpha = 0.0001;
		spotlight.scale.set(1.4, 1.4);
		add(spotlight);

		pillsFront = new FlxSprite(0, -650).loadGraphic(Paths.image('eternal_star/pillsfront'));
		pillsFront.scrollFactor.set(1.1, 1.1);
		pillsFront.scale.set(1.2, 1.2);
		add(pillsFront);

		flash = new FlxSprite().loadGraphic(Paths.image('eternal_star/vignette'));
		flash.setGraphicSize(FlxG.width, FlxG.height);
		flash.cameras = [game.camOther];
		flash.alpha = 0.0001;
		flash.blend = ADD;
		add(flash);
	}

	override function update(elapsed:Float)
	{
		// Code here
	}

	
	override function countdownTick(count:Countdown, num:Int)
	{
		switch(count)
		{
			case THREE: //num 0
			game.dad.playAnim("danceLeft", true);
			case TWO: //num 1
			game.dad.playAnim("danceRight", true);
			case ONE: //num 2
			game.dad.playAnim("danceLeft", true);
			case GO: //num 3
			game.dad.playAnim("danceRight", true);
			case START: //num 4
		}
	}

	// Steps, Beats and Sections:
	//    curStep, curDecStep
	//    curBeat, curDecBeat
	//    curSection
	override function stepHit()
	{
		// Code here
	}
	override function beatHit()
	{
		// Code here

		final beatDiff:Int = game.gfSpeed == 2 ? 4 : 2;
		if (curBeat % beatDiff == 0)
		{
			if (flashing)
			{
				FlxTween.cancelTweensOf(flash);
				flash.alpha = 1.0;
				FlxTween.tween(flash, {alpha: 0}, 1 + ((Conductor.crochet / 1000) * beatDiff) * game.gfSpeed, {ease: FlxEase.quintOut});
				sayaka.animation.play(flashing ? 'bop-alt' : 'bop', true);

				if (mami.animation.curAnim != null && mami.animation.curAnim.name == 'bop-left')
					mami.animation.play('bop-right', true);
				else
					mami.animation.play('bop-left', true);

				sayaka.offset.set(50, 175);
			}
			else
			{
				sayaka.animation.play('bop', true);
				mami.animation.play('bop', true);
				sayaka.offset.set(0, 0);
			}
		}
	}
	override function sectionHit()
	{
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			//timer.active = true;
			//tween.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			//timer.active = false;
			//tween.active = false;
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Stage Event":
				switch(value1)
				{
					case "outbeginning":
						game.manualCamZooming = true;
						game.camZooming = false;
						FlxTween.tween(game.camGame, {zoom: 0.6}, 6.72, {ease: FlxEase.quadIn});
					case "cancelbeginning":
						game.defaultCamZoom = 0.8;
						game.camZooming = true;
						game.manualCamZooming = false;
						new FlxTimer().start(1.12, (_) -> {
							FlxTween.tween(game, {defaultCamZoom: 0.70}, 0.2, {ease: FlxEase.quintOut});
						});
					case "spotlight":
						game.defaultCamZoom = 1.0;
						FlxTween.tween(blackBg, {alpha: 0.5}, 0.85, {ease: FlxEase.sineOut});
						FlxTween.tween(spotlight, {alpha: 0.45}, 0.85, {ease: FlxEase.sineOut});
						FlxTween.tween(pills, {y: 900}, 23.5, {ease: FlxEase.quadOut});
						FlxTween.tween(pillsFront, {y: 1400}, 25, {ease: FlxEase.quadOut});
					case "movethelight":
						FlxTween.tween(spotlight, {x: 875}, 1.1, {ease: FlxEase.cubeInOut});
					case "unspotlight":
						FlxTween.tween(blackBg, {alpha: 0.0}, 0.85, {ease: FlxEase.sineOut});
						FlxTween.tween(spotlight, {alpha: 0.0}, 0.85, {ease: FlxEase.sineOut});
						game.manualCamZooming = true;
						game.camZooming = false;
						FlxTween.tween(game.camGame, {zoom: 0.7}, 3.5, {ease: FlxEase.quartIn, onComplete: function(_) {
							game.defaultCamZoom = 0.7;
							game.manualCamZooming = false;
							game.camZooming = true;
						}});
					case "pink overlay":
						flashing = true;

				}
		}
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "My Event":
				//precacheImage('myImage') //preloads images/myImage.png
				//precacheSound('mySound') //preloads sounds/mySound.ogg
				//precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}
	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch(event.event)
		{
			case "My Event":
				switch(event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						//precacheImage('myImageOne') //preloads images/myImageOne.png
						//precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						//precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

					// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						//precacheImage('myImageTwo') //preloads images/myImageTwo.png
						//precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						//precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg
					
					// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						//precacheImage('myImageThree') //preloads images/myImageThree.png
						//precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						//precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}
}