package objects;

import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import shaders.ColorSwap;
import backend.Rating;

class ComboWindow extends FlxSpriteGroup
{
	public var ratings:Map<String, WindowRating> = new Map();
	public var background:FlxSprite;
	public var milestoneDash:FlxSprite;
	public var milestoneStars:FlxEmitter;
	public var seperator:FlxSprite;
	public var combo:WindowCombo;
	public var msDelay:FlxText;
	public var bgColor:FlxColor;
	public var broken:Bool = false;
	public var comboBreak:WindowRating;
	public var closeTimer:FlxTimer = new FlxTimer();
	public var colorSwap:ColorSwap = new ColorSwap();
	public var showOnFirstAdd:Bool = true;

	public function new(x:Float = 0.0, y:Float = 0.0, color:FlxColor = FlxColor.WHITE, ratingData:Array<Rating>)
	{
		super(x, y);

		bgColor = color;
		background = new FlxSprite().loadGraphic(Paths.image('interfaces/game/combos/background', 'shared'));
		background.color = color;
		background.alpha = 0.8;
		background.scale.x = 0.9;
		background.x -= 20;
		background.shader = colorSwap.shader;
		add(background);

		milestoneDash = new FlxSprite().loadGraphic(Paths.image('interfaces/game/combos/backgroundshine', 'shared'));
		milestoneDash.color = FlxColor.WHITE;
		milestoneDash.scale.x = 0.9;
		milestoneDash.x -= milestoneDash.width;
		milestoneDash.shader = colorSwap.shader;
		add(milestoneDash);

		for (rating in ratingData)
		{
			var windowRating = new WindowRating(-55, -43, rating);
			windowRating.alpha = 0.0001;
			windowRating.scale.set(0.65, 0.65);
			ratings.set(windowRating.ratingName, windowRating);
			if (rating.name != 'sick')
				windowRating.shader = colorSwap.shader;
			add(windowRating);
		}

		comboBreak = new WindowRating(-55, -43, 'break');
		comboBreak.alpha = 0.0001;
		comboBreak.scale.set(0.65, 0.65);
		add(comboBreak);

		seperator = new FlxSprite().loadGraphic(Paths.image('interfaces/game/combos/divider', 'shared'));
		seperator.shader = colorSwap.shader;
		add(seperator);

		combo = new WindowCombo(0.55, -12);
		combo.y += 3.5;
		combo.x -= 2;
		combo.forEachAlive((m) -> m.shader = colorSwap.shader);
		add(combo);

		msDelay = new FlxText();
		msDelay.setFormat(Paths.font('shingo.otf'), 24, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msDelay.scale.x = 1.1;
		msDelay.borderSize = 2;
		msDelay.borderQuality = 5.0;
		msDelay.alpha = 0.85;
		msDelay.y += 104;
		msDelay.x += 30;
		add(msDelay);

		milestoneStars = new FlxEmitter(x - 40, y, 10);
		milestoneStars.launchMode = FlxEmitterMode.SQUARE;
		milestoneStars.velocity.set(120, 0, 145, 0);
		milestoneStars.angle.set(0, 0, 0, 0);
		milestoneStars.alpha.set(1, 1, 0, 0);
		milestoneStars.lifespan.set(0.9, 1.8);
		milestoneStars.width = background.width;
		milestoneStars.height = background.height;
		milestoneStars.emitting = true;
		milestoneStars.loadParticles(Paths.image('interfaces/game/combos/magicalsparkle', 'shared'), 10, 0);
		// add(emitterSprite);

		visible = false;
	}

	public function addRating(ratingName:String, delay:Float)
	{
		open();
		broken = false;
		comboBreak.alpha = 0.0001;
		background.color = bgColor;
		for (rating in ratings.iterator())
			rating.alpha = 0.0001;
		ratings.get(ratingName).popIn();

		msDelay.text = '${CoolUtil.floorDecimal(delay, 2)}ms';
		msDelay.scale.set(1.25, 1.15);

		combo.curCombo++;
		if (combo.curCombo % 100 == 0 || combo.curCombo == 50)
		{
			milestoneEffect();
		}
	}

	public function breakCombo()
	{
		if (broken)
			return;
		open(true);
		for (rating in ratings.iterator())
			rating.alpha = 0.0001;
		comboBreak.popIn();
		combo.curCombo = 0;
		msDelay.text = '';
		background.color = 0x37354F;
		broken = true;
	}

	public function open(broken:Bool = false)
	{
		if (showOnFirstAdd)
		{
			showOnFirstAdd = false;
			visible = true;
		}

		for (rating in ratings.iterator())
		{
			FlxTween.cancelTweensOf(rating);
			rating.active = true;
			rating.scale.set(0.65, 0.65);
		}

		FlxTween.cancelTweensOf(combo);
		combo.active = true;
		combo.scale.set(1, 1);
		combo.alpha = 1;

		FlxTween.cancelTweensOf(seperator);
		seperator.active = true;
		seperator.scale.set(1, 1);
		seperator.alpha = 1;

		FlxTween.cancelTweensOf(msDelay);
		msDelay.active = true;
		msDelay.scale.set(1.1, 1);
		msDelay.alpha = 0.9;

		FlxTween.cancelTweensOf(background);
		background.active = true;
		background.scale.set(0.9, 1.0);
		background.alpha = 0.8;

		FlxTween.cancelTweensOf(comboBreak);
		comboBreak.active = true;
		comboBreak.scale.set(0.65, 0.65);

		if (!broken)
			closeTimer.cancel();
		closeTimer.start(0.8, close);
	}

	// i want to die.
	public function close(timer:FlxTimer)
	{
		var tweenDuration:Float = 0.2;
		var easeFunction:EaseFunction = FlxEase.circOut;

		var objects:Array<WindowRating> = [for (rating in ratings.iterator()) rating];
		objects.push(comboBreak);

		for (rating in objects)
		{
			rating.active = false;
			FlxTween.cancelTweensOf(rating);
			FlxTween.tween(rating, {'scale.x': 2 * 0.6, 'scale.y': 0 * 0.6, 'alpha': 0}, tweenDuration, {ease: easeFunction});
		}

		seperator.active = false;
		FlxTween.cancelTweensOf(seperator);
		FlxTween.tween(seperator, {'scale.x': 2, 'scale.y': 0, 'alpha': 0}, tweenDuration, {ease: easeFunction});

		background.active = false;
		FlxTween.cancelTweensOf(background);
		FlxTween.tween(background, {'scale.x': 2 * 0.9, 'scale.y': 0, 'alpha': 0}, tweenDuration, {ease: easeFunction});

		combo.active = false;
		FlxTween.cancelTweensOf(combo);
		FlxTween.tween(combo, {'scale.x': 2 * combo.windowScale, 'scale.y': 0, 'alpha': 0}, tweenDuration, {ease: easeFunction});

		msDelay.active = false;
		FlxTween.cancelTweensOf(msDelay);
		FlxTween.tween(msDelay, {'scale.x': 2 * 1.1, 'scale.y': 0, 'alpha': 0}, tweenDuration, {ease: easeFunction});
	}

	public function milestoneEffect()
	{
		FlxG.sound.play(Paths.sound('ui/combomilestone', 'shared'));
		FlxTween.cancelTweensOf(colorSwap);
		FlxTween.cancelTweensOf(milestoneDash);
		for (i in 0...10)
			milestoneStars.emitParticle();
		milestoneDash.x = x - milestoneDash.width / 1.5;
		milestoneDash.alpha = 1;
		colorSwap.brightness = 10;

		FlxTween.tween(colorSwap, {brightness: 0}, 0.8, {ease: FlxEase.expoOut});
		FlxTween.tween(milestoneDash, {x: x + 30, alpha: 0}, 0.5, {ease: FlxEase.sineOut, startDelay: 0.35});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		msDelay.scale.y = FlxMath.lerp(msDelay.scale.y, 1, Math.exp(-elapsed * 89.3));
		msDelay.scale.x = FlxMath.lerp(msDelay.scale.x, 1.1, Math.exp(-elapsed * 89.3));
		milestoneStars.update(elapsed);
		milestoneStars.cameras = cameras;
	}

	override function draw()
	{
		super.draw();
		milestoneStars.draw();
	}

	override function destroy()
	{
		milestoneStars.destroy();
		super.destroy();
	}
}

@:allow(objects.ComboWindow)
class WindowRating extends FlxSprite
{
	public static final ratingsFrame:Map<String, Int> = ['sick' => 0, 'good' => 1, 'bad' => 2, 'shit' => 3, 'combo' => 7, 'break' => 8];
	public static final popAngles:Array<Float> = [-1.6, -1.45, -1.2, -1, -0.5, 0.5, 1.1, 1.4, 2.0];

	public var colorSwap:Null<ColorSwap>;
	public var ratingName:String;
	public var rating:Rating;

	private var intendedAngle:Float = 0;

	public function new(x:Float = 0, y:Float = 0, ?rating:Rating, ?ratingName:String)
	{
		super(x, y);

		this.rating = rating;
		this.ratingName = rating == null ? ratingName : rating.name;

		var graphic = Paths.image('interfaces/game/combos/judgements', 'shared');
		loadGraphic(graphic, true, graphic.width, Std.int(graphic.height / 9));
		animation.add('rating', [ratingsFrame.get(this.ratingName)]);
		animation.play('rating');

		if (this.ratingName == 'sick')
		{
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
		}
	}

	public function popIn()
	{
		if (colorSwap != null)
			colorSwap.brightness = 1.5;
		if (ratingName != 'break')
		{
			angle = 0;
			intendedAngle = FlxG.random.getObject(popAngles);
		}
		else
		{
			FlxTween.cancelTweensOf(this);
			FlxTween.shake(this, 0.05, 0.4, XY);
		}
		alpha = 1;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (colorSwap != null)
			colorSwap.brightness = FlxMath.lerp(colorSwap.brightness, 0, Math.exp(-elapsed * 68.0));

		if (ratingName != 'break')
			angle = FlxMath.lerp(angle, intendedAngle, Math.exp(-elapsed * 62.6));
	}
}

@:allow(objects.ComboWindow)
class WindowCombo extends FlxSpriteGroup
{
	public var curCombo(default, set):Int;
	public var windowScale(default, null):Float = 1;

	public function new(scale:Float = 1, spacing:Float = 0)
	{
		super();

		windowScale = scale;
		var graphic = Paths.image('interfaces/game/combos/numbers', 'shared');
		var graphicWidth:Int = Std.int(graphic.width / 10);
		for (i in 0...4)
		{
			var number:FlxSprite = new FlxSprite();
			number.loadGraphic(graphic, true, graphicWidth, graphic.height);
			number.animation.add('num', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 24, false);
			number.animation.play('num');
			number.animation.curAnim.stop();
			number.color = FlxColor.GRAY;
			number.x += (graphicWidth * i * windowScale) + (spacing * i);
			number.scale.scale(windowScale, windowScale);
			add(number);
		}
		curCombo = 0;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		forEachAlive((member) -> member.scale.x = member.scale.y = FlxMath.lerp(member.scale.x, 1 * windowScale, Math.exp(-elapsed * 89.3)));
	}

	@:noCompletion
	private function set_curCombo(Value:Int)
	{
		forEachAlive((member) ->
		{
			if (Value == 0)
				member.animation.curAnim.curFrame = 0;
			else
				member.scale.set(1.13 * windowScale, 1.13 * windowScale);
			if (Value < 9999)
				member.color = FlxColor.GRAY;
		});

		if (Value == 0)
			return curCombo = Value;

		if (Value > 9999)
		{
			trace('sir dis numba is too big');
			return curCombo;
		}
		else if (Value < 0)
		{
			trace('sir dis numba is too smol');
			return curCombo;
		}

		var numberString = Std.string(Value);
		for (i => s in numberString.split(''))
		{
			var curNumber = Std.parseInt(s);
			var member = members[i + (members.length - numberString.length)];

			if (member.animation.curAnim.curFrame != curNumber)
				member.scale.set(1.18 * windowScale, 1.18 * windowScale);

			member.color = FlxColor.fromInt(0x00FFFFFF);
			member.animation.curAnim.curFrame = curNumber;
		}

		for (i in 0...(members.length - numberString.length))
		{
			var member = members[i];
			if (member.animation.curAnim.curFrame != 0)
				member.scale.set(1.18 * windowScale, 1.18 * windowScale);

			member.animation.curAnim.curFrame = 0;
		}

		return curCombo = Value;
	}
}
