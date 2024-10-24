package objects;

import flixel.graphics.FlxGraphic;
import objects.HQHealthIcon;
import flixel.math.FlxMath;

class FreeplaySongItem extends FlxSpriteGroup
{
    public var songName:String;
    public var composerName:String;
    public var intendedPosition:FlxPoint;
    public var intendedAlpha:Float = 1;
    public var lerp:Bool = true;

    public var handle:FlxSprite;
    public var icon:HQHealthIcon;

    var songText:FlxText;
    var composerText:FlxText;
    var scoreText:FlxText;
    var accuracyText:FlxText;

    public function new(x:Float = 0, y:Float = 0, song:String, composer:String, Icon:String)
    {
        super(x, y);

        songName = song;
        composerName = composer;
        intendedPosition = FlxPoint.get(x, y);

        handle = new FlxSprite();
        var graphic:FlxGraphic = Paths.image('interfaces/freeplay/song_borders');
        handle.loadGraphic(graphic, true, graphic.width, Std.int(graphic.height / 5));
        handle.animation.add('clear', [0]);
        handle.animation.add('SDCB', [1]);
        handle.animation.add('FC', [2]);
        handle.animation.add('GFC', [3]);
        handle.animation.add('MFC', [4]);
        handle.animation.play('clear');
        // that's to make positioning the thing easier
        handle.offset.y += 2;
        handle.height -= 2;
        add(handle);

        icon = new HQHealthIcon(Icon, true);
        icon.playAnimation('win');
        add(icon);

        // -42, -301.5
        songText = new FlxText(0, 0, 0, songName);
        songText.setFormat(Paths.font('shingo.otf'), 38, FlxColor.BLACK);
        songText.scale.x = 0.9;
        songText.updateHitbox();
        songText.setPosition(158.5, 13.5);
        add(songText);

        composerText = new FlxText(0, 0, 0, 'Composed by: $composer');
        composerText.setFormat(Paths.font('shingo.otf'), 24, FlxColor.BLACK);
        composerText.scale.x = 0.8;
        composerText.updateHitbox();
        composerText.setPosition(Math.fround(songText.x), (songText.y + songText.height) - 7);
        add(composerText);
    }

    override public function update(elapsed:Float):Void
    {
        if (lerp)
        {
            x = FlxMath.lerp(x, intendedPosition.x, Math.exp(-elapsed * 88.8));
            y = FlxMath.lerp(y, intendedPosition.y, Math.exp(-elapsed * 88.8));
            alpha = FlxMath.lerp(alpha, intendedAlpha, Math.exp(-elapsed * 68.0));
        }

        super.update(elapsed);
    }

    override public function destroy():Void
    {
        lerp = false;
        intendedPosition.put();
        super.destroy();
    }
}