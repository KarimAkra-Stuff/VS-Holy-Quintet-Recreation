package backend;

import flixel.util.FlxGradient;
import flixel.FlxSubState;

class CustomFadeTransition extends FlxSubState {
	public static var finishCallback:Void->Void;
	public static var kyubeyFrame:Int = 0;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	var kyubey:FlxSprite;
	var loadingText:FlxText;

	var duration:Float;
	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		kyubey = new FlxSprite();
		kyubey.frames = Paths.getSparrowAtlas('interfaces/common/KYUBEYRUN');
		kyubey.animation.addByPrefix('run', 'kyubey run instance 1', 24, true);
		kyubey.animation.play('run', true, false, kyubeyFrame);
		add(kyubey);
		
		loadingText = new FlxText();
		loadingText.text = 'Loading';
		loadingText.setFormat(Paths.font('shingo.otf'), 36, FlxTextBorderStyle.OUTLINE);
		loadingText.borderQuality = 5.0;
		add(loadingText);

		kyubey.setPosition(FlxG.width - kyubey.width - 40, FlxG.height);
		loadingText.setPosition(kyubey.x - loadingText.width - 30, FlxG.height);

		if(isTransIn)
		{
			transGradient.y = transBlack.y - transBlack.height;

			kyubey.y -= kyubey.height + 15;
			loadingText.y -= loadingText.height + 27;

			FlxTween.tween(kyubey, {x: FlxG.width + 10, alpha: 0}, 0.6, {ease: FlxEase.sineOut});
			FlxTween.tween(loadingText, {alpha: 0}, 0.6, {ease: FlxEase.sineOut});
		}
		else
		{
			transGradient.y = -transGradient.height;

			kyubey.alpha = 0.0;
			loadingText.alpha = 0.0;

			FlxTween.tween(kyubey, {y: kyubey.y - (kyubey.height + 15), alpha: 1}, 0.4, {ease: FlxEase.sineOut});
			FlxTween.tween(loadingText, {y: loadingText.y - (loadingText.height + 27), alpha: 1}, 0.4, {ease: FlxEase.sineOut});
		}

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
		if(duration > 0)
			transGradient.y += (height + targetPos) * elapsed / duration;
		else
			transGradient.y = (targetPos) * elapsed;

		if(isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;

		if(transGradient.y >= targetPos)
		{
			close();
		}
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
