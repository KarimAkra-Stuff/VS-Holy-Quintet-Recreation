package objects;

import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class BalloonsBG extends FlxBackdrop
{
    var finishedTween:Bool = true;
    var defaultVelocityY:Float = 40.0;

    public function new(defaultVelocityY:Float = 40.0)
    {
        super(Paths.image('interfaces/main/menuCircles'));
        this.defaultVelocityY = defaultVelocityY;
        velocity.set(0, defaultVelocityY);
        // FlxTween.tween(velocity, {x: 0}, 1.8, {ease: FlxEase.sineInOut, onComplete: (_) -> finishedTween = true});
    }

    override public function update(elapsed:Float):Void
    {
        #if desktop
        // this is no where near how the one in the mod works but i have no idea how to make it better i tried man i swear :sob:
        if(FlxG.mouse.justMoved && finishedTween)
        {
            // var deltaScreen:FlxPoint = FlxPoint.get(FlxG.mouse.deltaScreenX, FlxG.mouse.deltaScreenY);

            // velocity.x += deltaScreen.x;
            // velocity.x = FlxMath.bound(velocity.x, -45, 45);

            // if (deltaScreen.y > 5 || deltaScreen.y < -5)
            // {
            //     velocity.y += deltaScreen.y;
            //     velocity.y = FlxMath.bound(velocity.y, 5, 60);
            // }

            // deltaScreen.put();

            velocity.x = (FlxG.mouse.screenX - (FlxG.width / 2)) * 0.30;
            velocity.y = (FlxG.mouse.screenY - 6 - (FlxG.height / 2)) * 0.20;
            
            FlxTween.cancelTweensOf(velocity);
            FlxTween.tween(velocity, {x: 0}, 1.8, {ease: FlxEase.quadOut, startDelay: 1.1});
            FlxTween.tween(velocity, {y: defaultVelocityY}, 1.1, {ease: FlxEase.quadOut, startDelay: 1.1});
        }
        #end

        super.update(elapsed);
    }
}