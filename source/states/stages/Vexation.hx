package states.stages;

import objects.Bar;
import objects.StrumNote;
import flxanimate.FlxAnimate;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
import hxvlc.flixel.FlxVideoSprite;
import states.stages.objects.Cutin;

class Vexation extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	// Stage variables
	public var background:FlxSprite;

	public var sayaka:FlxAnimate;
	public var mami:FlxAnimate;
	public var madoka:FlxAnimate;

	public var glow:FlxSprite;
	public var sun:FlxSprite;
	public var lightAdd:FlxSprite;
	public var lightMult:FlxSprite;
	public var lightRays:FlxSprite;
	public var darkness:FlxSprite;

	public var pipes:FlxSprite;

	// Dodge Mechanic variables
	public var warning:FlxSprite;
	public var warningGlow:FlxSprite;

	public var dodge:FlxSprite;
	public var dodgeGlow:FlxSprite;

	public var canDodge:Bool = false;
	public var dodged:Bool = false;
	public var underCooldown:Bool = false;
	public var curStatus(default, set):Int = 0;
	public var statusSpr:FlxSprite;
	public var attacksSustained:Int = 0;
	public var defaultHealthGain:Float = 1.0;
	public var dodgeCooldown:FlxTimer = new FlxTimer();
	public var cooldownBar:Bar;
	public var cooldownTxt:FlxText;
	public var dodgeAnimations:Array<String> = ['singLEFTdodge', 'singDOWNdodge', 'singDOWNdodge', 'singRIGHTdodge'];

	var statusY:Float = 0;
	var statusX:Float = 0;

	// Miscs variabls
	public var first:FlxSprite;
	public var fire:FlxVideoSprite;

	// Cutin variabls
	public var cutinBg:FlxSprite;
	public var gfCutin:Cutin;
	public var kyokoCutin:Cutin;
	public var allowedCutinAnimations:Array<String> = [
		'idle',
		'singLEFT',
		'singDOWN',
		'singUP',
		'singRIGHTMiss',
		'singLEFTMiss',
		'singDOWNMiss',
		'singUPMiss',
		'singRIGHTMiss'
	];

	override function create()
	{
		// Spawn your stage sprites here.
		// Characters are not ready yet on this function, so you can't add things above them yet.
		// Use characterPost() if that's what you want to do.

		ClientPrefs.data.extraButtons = 'SINGLE';
		cacheStuff();

		FlxG.console.registerObject('stage', this);

		game.camZooming = true;
		game.hudZooming = true;
		game.hideOppNotes = true;
		FlxG.camera.alpha = 0.00001;

		background = new FlxSprite().loadGraphic(Paths.image('vexation/background'));
		background.scale.set(1.2, 1.2);
		background.setPosition(-262, -40);
		add(background);

		sayaka = new FlxAnimate(1440, 340);
		sayaka.loadAtlas(Paths.getAtlasPath('atlases/vexation/sayaka', 'images', 'shared'));
		sayaka.anim.addBySymbol('bop', 'sayaka_kyokobg', 24, false);
		sayaka.anim.play('bop');
		add(sayaka);

		mami = new FlxAnimate(1870, 365);
		mami.loadAtlas(Paths.getAtlasPath('atlases/vexation/mami', 'images', 'shared'));
		mami.anim.addBySymbol('bop', 'mami_kyokobg', 24, false);
		mami.anim.play('bop');
		add(mami);

		madoka = new FlxAnimate(1750, 935);
		madoka.loadAtlas(Paths.getAtlasPath('atlases/vexation/madoka', 'images', 'shared'));
		madoka.anim.addBySymbol('bop', 'madoka_kyokobg', 24, false);
		madoka.anim.play('bop');
		add(madoka);

		kyokoCutin = new Cutin(178, 'cutinBLUE', 'kyoko-cutin', false, FlxG.cameras.list.indexOf(game.camHUD));
		kyokoCutin.character.x = kyokoCutin.characterBaseX = 205;
		kyokoCutin.jumpOut(true);
		add(kyokoCutin);

		gfCutin = new Cutin(378, 'cutinRED', 'gf-cutin', true, FlxG.cameras.list.indexOf(game.camHUD));
		gfCutin.character.x = gfCutin.characterBaseX = 491;
		gfCutin.jumpOut(true);
		add(gfCutin);
	}

	override function characterPost()
	{
		// Use this function to layer things above characters!

		// these alphas are kinda off but that's the best that i managed to assume (i hope this layering is correct aswel :sob:)

		sun = new FlxSprite().loadGraphic(Paths.image('vexation/sun'));
		sun.scale.set(1.2, 1.2);
		sun.setPosition(-362, -40);
		sun.blend = ADD;
		sun.alpha = 0.2;
		add(sun);

		lightRays = new FlxSprite().loadGraphic(Paths.image('vexation/backgroundlightrays'));
		lightRays.scale.set(1.2, 1.2);
		lightRays.scrollFactor.x = 1.5;
		lightRays.setPosition(-262, -40);
		lightRays.blend = ADD;
		lightRays.alpha = 0.35;
		add(lightRays);

		glow = new FlxSprite().loadGraphic(Paths.image('vexation/glow'));
		glow.scale.set(1.2, 1.2);
		glow.setPosition(-262, -40);
		glow.blend = ADD;
		glow.alpha = 0.6;
		add(glow);

		lightAdd = new FlxSprite().loadGraphic(Paths.image('vexation/backgroundadd'));
		lightAdd.scale.set(1.2, 1.2);
		lightAdd.setPosition(-262, -40);
		lightAdd.blend = ADD;
		lightAdd.alpha = 0.4;
		add(lightAdd);

		lightMult = new FlxSprite().loadGraphic(Paths.image('vexation/backgroundmulti'));
		lightMult.scale.set(1.2, 1.2);
		lightMult.setPosition(-262, -40);
		lightMult.blend = MULTIPLY;
		lightMult.alpha = 0.3;
		add(lightMult);

		pipes = new FlxSprite().loadGraphic(Paths.image('vexation/pipes'));
		pipes.scale.set(1.35, 1.35);
		pipes.scrollFactor.x = 1.2;
		pipes.setPosition(-80, 45);
		add(pipes);

		darkness = new FlxSprite().loadGraphic(Paths.image('vexation/darkness'));
		darkness.scale.set(1.25, 1.25);
		darkness.setPosition(790, 335);
		darkness.blend = MULTIPLY;
		darkness.alpha = 0.1;
		add(darkness);

		boombox.setPosition(880, 610);
	}

	override function createPost()
	{
		// called at the end of create()

		defaultHealthGain = game.healthGain;

		cutinBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		cutinBg.alpha = 0.00001;
		cutinBg.scrollFactor.set();
		cutinBg.scale.set(3, 3);
		add(cutinBg);

		game.healthDisplay = false;
		game.opponentStrums.forEachAlive((sturm) -> sturm.alpha = 0.00001);

		warning = new FlxSprite().loadGraphic(Paths.image('vexation/mechanic/warning'));
		warningGlow = new FlxSprite().loadGraphic(Paths.image('vexation/mechanic/warningglow'));

		warning.screenCenter();
		warningGlow.screenCenter();

		warning.color = FlxColor.YELLOW;
		warningGlow.color = FlxColor.YELLOW;

		warning.alpha = 0.00001;
		warningGlow.alpha = 0.00001;

		warning.cameras = [camHUD];
		warningGlow.cameras = [camHUD];

		add(warning);
		add(warningGlow);

		dodge = new FlxSprite().loadGraphic(Paths.image('vexation/mechanic/dodge'));
		dodgeGlow = new FlxSprite().loadGraphic(Paths.image('vexation/mechanic/dodgeglow'));

		dodge.screenCenter();
		dodgeGlow.screenCenter();

		dodge.color = FlxColor.RED;
		dodgeGlow.color = FlxColor.RED;

		dodge.alpha = 0.00001;
		dodgeGlow.alpha = 0.00001;

		dodge.cameras = [camHUD];
		dodgeGlow.cameras = [camHUD];

		add(dodge);
		add(dodgeGlow);

		var downScroll:Bool = ClientPrefs.data.downScroll;
		var imgName:String = downScroll ? 'gofirstdown' : 'gofirst';
		var firstStrumNote:StrumNote = game.playerStrums.members[0];

		first = new FlxSprite().loadGraphic(Paths.image('interfaces/game/$imgName', 'shared'));
		first.x = ((((firstStrumNote.width * 4) + 15 * 3) - first.width) / 2) + firstStrumNote.x;
		first.x -= 20;
		first.y = downScroll ? (firstStrumNote.y - firstStrumNote.height) - 10 : (firstStrumNote.y + firstStrumNote.height) + 10;
		first.cameras = [camHUD];
		insert(game.members.indexOf(game.noteGroup) - 1, first);
		FlxTween.tween(first, {y: downScroll ? first.y - 8 : first.y + 8}, 0.8, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

		fire = new FlxVideoSprite();
		fire.autoPause = false;
		fire.load(Paths.videoBytes('fire'), ['input-repeat=65545']);
		fire.scale.set(2.15, 2.15);
		fire.setPosition(258, -40);
		fire.alpha = 0.00001;
		fire.blend = ADD;
		add(fire);

		FlxG.signals.focusLost.add(pauseFire);
		FlxG.signals.focusGained.add(resumeFire);

		cooldownBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'interfaces/game/dodgeBar', () -> return dodgeCooldown.progress,
			0, 1);
		cooldownBar.y += ClientPrefs.data.downScroll ? 16 : -16;
		cooldownBar.x = FlxG.width - (cooldownBar.width + 30);
		cooldownBar.leftBar.color = FlxColor.WHITE;
		cooldownBar.rightBar.color = FlxColor.BLACK;
		cooldownBar.barHeight = 10;
		cooldownBar.barWidth = 210;
		cooldownBar.barOffset.set(27, 21);
		cooldownBar.alpha = 0.00001;
		game.uiGroup.insert(game.uiGroup.members.indexOf(game.healthBar), cooldownBar);

		cooldownTxt = new FlxText(cooldownBar.x + 110, cooldownBar.y + 14.2, '0.0');
		cooldownTxt.setFormat(Paths.font("shingo.otf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		cooldownTxt.scale.x = 0.9;
		cooldownTxt.alpha = 0.00001;
		game.uiGroup.insert(game.uiGroup.members.indexOf(cooldownBar) + 1, cooldownTxt);

		var graphic = Paths.image('interfaces/game/statuses');
		statusSpr = new FlxSprite().loadGraphic(graphic, true, Std.int(graphic.width / 4), graphic.height);
		statusSpr.animation.add('status', [0, 1, 2, 3], false);
		statusSpr.animation.play('status');
		statusSpr.visible = false;
		game.uiGroup.insert(game.uiGroup.members.indexOf(game.iconP1) + 1, statusSpr);
	}

	override function update(elapsed:Float)
	{
		// Code here

		if (((FlxG.keys.justPressed.SPACE
			|| MusicBeatState.instance.mobileControls != null
			&& MusicBeatState.instance.mobileControls.current.buttonExtra.justPressed)
			&& !underCooldown)
			|| (game.cpuControlled && canDodge))
		{
			underCooldown = true;
			FlxTween.cancelTweensOf(cooldownBar);
			FlxTween.cancelTweensOf(cooldownTxt);

			if (game.healthDisplay)
			{
				cooldownBar.rightBar.color = FlxColor.BLACK;
				FlxTween.tween(cooldownBar, {alpha: 1}, 0.3, {ease: FlxEase.sineIn});
				FlxTween.tween(cooldownTxt, {alpha: 1}, 0.3, {ease: FlxEase.sineIn});
			}

			dodgeCooldown.start(1.5, (_) ->
			{
				underCooldown = false;
				cooldownBar.rightBar.color = FlxColor.WHITE;
				FlxTween.tween(cooldownBar, {alpha: 0}, 0.3, {ease: FlxEase.sineOut});
				FlxTween.tween(cooldownTxt, {alpha: 0}, 0.3, {ease: FlxEase.sineOut});
			});

			boyfriend.playAnim(FlxG.random.getObject(dodgeAnimations), true);
			boyfriend.specialAnim = true;
			FlxG.sound.play(Paths.sound('mechanics/dodge_base', 'shared'));

			if (canDodge)
			{
				dodged = true;
				canDodge = false;
			}
		}

		if (underCooldown)
		{
			var time:String = '${CoolUtil.floorDecimal(dodgeCooldown.time * (1.0 - dodgeCooldown.progress), 1)}';
			if (!time.contains('.'))
				time += '.0';
			cooldownTxt.text = time;
		}

		game.iconP1.iconOffset = [game.healthBar.offset.x, game.healthBar.offset.y];
		game.iconP2.iconOffset = [game.healthBar.offset.x, game.healthBar.offset.y];

		statusSpr.offset.set(game.iconP1.offset.x, game.iconP1.offset.y);
		statusSpr.setPosition(game.iconP1.x + 90, game.iconP1.y + -75);
		statusSpr.scale.set(game.iconP1.scale.x + 0.05, game.iconP1.scale.y + 0.05);

		kyokoCutin.cam.zoom = game.camHUD.zoom;
		gfCutin.cam.zoom = game.camHUD.zoom;
	}

	override function countdownTick(count:Countdown, num:Int)
	{
		switch (count)
		{
			case THREE: // num 0
			case TWO: // num 1
			case ONE: // num 2
			case GO: // num 3
			case START: // num 4
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

		sayaka.anim.play('bop');
		mami.anim.play('bop');
		madoka.anim.play('bop');
	}

	override function sectionHit()
	{
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if (paused)
		{
			// timer.active = true;
			// tween.active = true;

			if (!FlxG.signals.focusLost.has(pauseFire))
				FlxG.signals.focusLost.add(pauseFire);
			if (!FlxG.signals.focusGained.has(resumeFire))
				FlxG.signals.focusGained.add(resumeFire);

			resumeFire();
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if (paused)
		{
			// timer.active = false;
			// tween.active = false;

			if (FlxG.signals.focusLost.has(pauseFire))
				FlxG.signals.focusLost.remove(pauseFire);
			if (FlxG.signals.focusGained.has(resumeFire))
				FlxG.signals.focusGained.remove(resumeFire);

			pauseFire();
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch (eventName)
		{
			case "Song Event":
				switch (value1)
				{
					case 'fire':
						if (value2 == 'on')
						{
							fire.play();
							fire.scale.set(2.15, 2.15);
							fire.setPosition(258, -40);
							FlxTween.tween(fire, {alpha: 1.0}, 0.8, {ease: FlxEase.circOut});
						}
					case 'cutin':
						if (value2 == 'in')
						{
							kyokoCutin.jumpIn();
							gfCutin.jumpIn();
							FlxTween.tween(cutinBg, {alpha: 0.75}, 0.5, {ease: FlxEase.quartOut});
						}
						else
						{
							kyokoCutin.jumpOut();
							gfCutin.jumpOut();
							FlxTween.tween(cutinBg, {alpha: 0.0}, 0.2, {ease: FlxEase.quartOut});
						}
				}
			case "Stage Event":
				switch (value1)
				{
					case 'Show Opp Strums':
						if (ClientPrefs.data.opponentStrums) game.opponentStrums.forEachAlive((sturm) -> FlxTween.tween(sturm,
							{alpha: ClientPrefs.data.middleScroll ? 0.35 : 1.0}, 0.3, {ease: FlxEase.circOut}));
					case 'Hide First':
						FlxTween.tween(first, {alpha: 0}, 0.4, {
							ease: FlxEase.sineOut,
							onComplete: (_) ->
							{
								FlxTween.cancelTweensOf(first);
								first.destroy();
								remove(first);
							}
						});
					case 'warning':
						var warningSound = FlxG.sound.load(Paths.sound('mechanics/kyoko_warning', 'shared'), 1.0, false, null, true);
						warningSound.pitch = flValue2 ?? 1.0;
						warningSound.play();
						glowWarning();

						if (ClientPrefs.data.camZooms)
						{
							if (game.camZooming)
								camGame.zoom += 0.035;
							if (game.hudZooming)
								camHUD.zoom += 0.04;
						}
					case 'dodge':
						var dodgeSound = FlxG.sound.load(Paths.sound('mechanics/kyoko_warning', 'shared'), 1.0, false, null, true);
						dodgeSound.pitch = flValue2 ?? 1.0;
						dodgeSound.play();
						glowDodge();

						if (ClientPrefs.data.camZooms)
						{
							if (game.camZooming)
								camGame.zoom += 0.04;
							if (game.hudZooming)
								camHUD.zoom += 0.045;
						}

						if (!game.cpuControlled) canDodge = true;
					case 'attack':
						if (!game.cpuControlled)
							canDodge = false;
						else
							canDodge = true;

						pupUpDodgeStatus();
						dad.playAnim('attack', true);
						dad.specialAnim = true;
						FlxG.sound.play(Paths.sound('mechanics/kyoko_spearhit', 'shared'));
						if (!dodged && !game.cpuControlled)
						{
							boyfriend.playAnim('hit', true);
							boyfriend.specialAnim = true;
							gf.playAnim('sad', true);
							gf.specialAnim = true;
							FlxG.sound.play(Paths.sound('gf/gfvo_hit_${FlxG.random.int(1, 3)}', 'shared'));
							FlxG.sound.play(Paths.sound('mechanics/damage', 'shared'));
							FlxTween.shake(game.healthBar, 0.1, 0.44, XY);
							game.iconP1.playAnimation('attacked');
							game.iconP2.playAnimation('attacked');
							attacksSustained++;
							curStatus++;
							new FlxTimer().start(40.0, (_) -> curStatus -= 1);
							if (!game.cpuControlled)
								game.health -= 0.8;
						}
						else
						{
							gf.playAnim('hey', true);
							gf.specialAnim = true;
							FlxG.sound.play(Paths.sound('gf/gfvo_dodge_${FlxG.random.int(1, 7)}', 'shared'));
						}

						if (attacksSustained > 0)
						{
							game.extraScoreTxt[0] = ' • Attacks Sustained: $attacksSustained';
							game.updateScore(false);
						}

						if (ClientPrefs.data.camZooms)
						{
							if (game.camZooming)
								camGame.zoom += 0.045;
							if (game.hudZooming)
								camHUD.zoom += 0.05;
						}
						dodged = false;
				}
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch (event.event)
		{
			case "My Event":
				// precacheImage('myImage') //preloads images/myImage.png
				// precacheSound('mySound') //preloads sounds/mySound.ogg
				// precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}

	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch (event.event)
		{
			case "My Event":
				switch (event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						// precacheImage('myImageOne') //preloads images/myImageOne.png
						// precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						// precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

						// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						// precacheImage('myImageTwo') //preloads images/myImageTwo.png
						// precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						// precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg

						// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						// precacheImage('myImageThree') //preloads images/myImageThree.png
						// precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						// precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}

	private function glowWarning()
	{
		FlxTween.cancelTweensOf(warning);
		FlxTween.cancelTweensOf(warningGlow);

		warning.alpha = 1.0;
		warningGlow.alpha = 1.0;

		warning.scale.set(1, 1);
		warningGlow.scale.set(1, 1);

		FlxTween.tween(warning, {alpha: 0, 'scale.x': 1.1, 'scale.y': 1.1}, 0.24, {ease: FlxEase.sineOut});
		FlxTween.tween(warningGlow, {alpha: 0, 'scale.x': 1.1, 'scale.y': 1.1}, 0.23, {ease: FlxEase.sineOut});
	}

	private function glowDodge()
	{
		FlxTween.cancelTweensOf(dodge);
		FlxTween.cancelTweensOf(dodgeGlow);

		dodge.alpha = 1.0;
		dodgeGlow.alpha = 1.0;

		dodge.scale.set(1, 1);
		dodgeGlow.scale.set(1, 1);

		FlxTween.tween(dodge, {alpha: 0, 'scale.x': 1.1, 'scale.y': 1.1}, 0.24, {ease: FlxEase.sineOut});
		FlxTween.tween(dodgeGlow, {alpha: 0, 'scale.x': 1.1, 'scale.y': 1.1}, 0.23, {ease: FlxEase.sineOut});
	}

	private function pupUpDodgeStatus()
	{
		var graphic:FlxGraphic = Paths.image('interfaces/game/combos/judgements', 'shared');
		var status:FlxSprite = new FlxSprite().loadGraphic(graphic, true, graphic.width, Std.int(graphic.height / 9));
		status.animation.add('dodged', [4]);
		status.animation.add('early', [5]);
		status.animation.add('late', [6]);
		status.animation.play('dodged');

		if (!dodged && underCooldown)
			status.animation.play('early');
		else if (!dodged && !underCooldown)
			status.animation.play('late');

		game.comboGroup.add(status);

		status.screenCenter();
		status.x = FlxG.width * 0.4 - 40;
		status.y -= 60;
		status.acceleration.y = 550 * game.playbackRate * game.playbackRate;
		status.velocity.y -= FlxG.random.int(140, 175) * game.playbackRate;
		status.velocity.x -= FlxG.random.int(0, 10) * game.playbackRate;
		status.visible = !ClientPrefs.data.hideHud;
		status.x += ClientPrefs.data.comboOffset[0];
		status.y -= ClientPrefs.data.comboOffset[1];
		status.setGraphicSize(Std.int(status.width * 0.7));
		status.updateHitbox();

		FlxTween.tween(status, {alpha: 0}, 0.2 / game.playbackRate, {
			startDelay: Conductor.crochet * 0.001 / game.playbackRate,
			onComplete: (_) ->
			{
				game.comboGroup.remove(status);
				status = FlxDestroyUtil.destroy(status);
			}
		});
	}

	override function destroy()
	{
		ClientPrefs.data.extraButtons = 'NONE';
		FlxG.console.removeByAlias('stage');
		super.destroy();
	}

	private function pauseFire()
	{
		if (fire != null)
			fire.pause();
	}

	private function resumeFire()
	{
		if (fire != null)
			fire.resume();
	}

	private function cacheStuff()
	{
		Paths.sound('mechanics/dodge_base', 'shared');
		Paths.sound('mechanics/kyoko_warning', 'shared');
		Paths.sound('mechanics/kyoko_spearhit', 'shared');
		Paths.sound('mechanics/damage', 'shared');

		for (i in 1...8)
			Paths.sound('gf/gfvo_dodge_$i');

		for (i in 1...4)
			Paths.sound('gf/gfvo_hit_$i', 'shared');
	}

	private function set_curStatus(Value:Int)
	{
		if (Value > 4)
		{
			game.healthGain = 0;
			return curStatus = Value;
		}

		if (Value < 1)
		{
			game.healthGain = defaultHealthGain;
			statusSpr.visible = false;
			return curStatus = Value;
		}

		statusSpr.visible = true;
		statusSpr.animation.curAnim.curFrame = Value - 1;
		game.healthGain = defaultHealthGain - ((Value * 2) / 10);
		if (game.healthGain < 0)
			game.healthGain = 0;

		return curStatus = Value;
	}
}
