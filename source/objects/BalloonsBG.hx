package objects;

import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;

class BalloonsBG extends FlxBackdrop
{
    var finishedTween:Bool = false;

    public function new()
    {
        super(Paths.image('interfaces/main/menuCircles'));
        velocity.set(100, 40);
        FlxTween.tween(velocity, {x: 0}, 1.8, {ease: FlxEase.sineInOut, onComplete: (_) -> finishedTween = true});
    }

    override public function update(elapsed:Float):Void
    {
        if(FlxG.mouse.justMoved && finishedTween)
        {
            var deltaScreen:FlxPoint = FlxPoint.get(FlxG.mouse.deltaScreenX, FlxG.mouse.deltaScreenY);

            velocity.x += deltaScreen.x;
            velocity.x = FlxMath.bound(velocity.x, -45, 45);

            if (deltaScreen.y > 5 || deltaScreen.y < -5)
            {
                velocity.y += deltaScreen.y;
                velocity.y = FlxMath.bound(velocity.y, 5, 60);
            }

            deltaScreen.put();
        }

        super.update(elapsed);
    }
}