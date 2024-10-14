package objects;

import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;

class BalloonsBG extends FlxBackdrop
{
    public function new()
    {
        super(Paths.image('interfaces/main/menuCircles'));
    }

    override public function update(elapsed:Float):Void
    {
        // TODO: improve this
        if(FlxG.mouse.justMoved)
        {
            var deltaScreen:FlxPoint = FlxPoint.get(FlxG.mouse.deltaScreenX, FlxG.mouse.deltaScreenY);
            var changeX:Bool = (deltaScreen.x > 5 || deltaScreen.x < -5);
            var changeY:Bool = (deltaScreen.y > 5 || deltaScreen.y < -5);
            if (changeX || changeY)
            {
                if (changeX)
                    velocity.x = FlxMath.bound(deltaScreen.x, -45, 45);
                if (changeY)
                    velocity.y = FlxMath.bound(deltaScreen.y, 10, 60);
            }
            deltaScreen.put();
        }

        // FlxG.watch.addQuick('velocity X', velocity.x);
        // FlxG.watch.addQuick('velocity y', velocity.y);
        // FlxG.watch.addQuick('delta X', FlxG.mouse.deltaScreenX);
        // FlxG.watch.addQuick('delta Y', FlxG.mouse.deltaScreenY);

        super.update(elapsed);
    }
}