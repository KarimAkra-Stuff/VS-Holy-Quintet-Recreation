package objects;

class HQMenuOption extends FlxSpriteGroup
{
    public var name:String;
    public var isSelected(default, set):Bool;
    public var locked(default, null):Bool = false;

    private var button:FlxSprite;
    private var highlight:FlxSprite;
    private var text:FlxText;
    private var highlighTween:FlxTween;

    public function new(name:String, locked:Bool = false)
    {
        super(0, 0);

        this.name = name;
        this.locked = locked;

        button = new FlxSprite();
        if (locked)
        {
            button.loadGraphic(Paths.image('interfaces/common/buttons/standard/buttonslocked'));
        }
        else
        {
            button.loadGraphic(Paths.image('interfaces/common/buttons/standard/buttons'), true, 356, 103);
            button.animation.add('selected', [0]);
            button.animation.add('idle', [1]);
            button.animation.play('idle');
        }
        button.updateHitbox();

        if (!locked)
        {
            highlight = new FlxSprite(0, 0);
            highlight.loadGraphic(Paths.image('interfaces/common/buttons/standard/buttonhightlight'));
        }

        text = new FlxText(0, 0, 0, name);
        text.setFormat(Paths.font('shingo.otf'), 40, FlxColor.WHITE, null, locked ? FlxTextBorderStyle.NONE : FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        if (!locked)
        {
            text.borderSize = 2.5;
            text.borderQuality = 5.0;
        }

        add(button);
        if (!locked)
            add(highlight);
        add(text);

        if (!locked)
            CoolUtil.centerObjectInsideObject(highlight, button);
        CoolUtil.centerTextInsideObject(text, button);
    }

    public function flash()
    {
        if (isSelected && !locked)
        {
            var flash:FlxSprite = new FlxSprite().loadGraphic(Paths.image('interfaces/main/buttons/buttonselected'));
            flash.x -= 10;
            flash.y += 2;
            // CoolUtil.centerObjectInsideObject(flash, button);
            add(flash);
            FlxTween.tween(flash, {"scale.x": 1.13, "scale.y": 1.13, "alpha": 0.0}, 1.6, {
                ease: FlxEase.circOut, 
                onComplete: (_) -> {
                    flash.destroy();
                    remove(flash);
                }
            });
        }
    }

    @:noCompletion
    private function set_isSelected(Value:Bool):Bool
    {
        if (locked)
        {
            if (Value == true)
                text.color = FlxColor.WHITE;
            else
                text.color = FlxColor.GRAY;

            return isSelected = Value;
        }

        if (highlighTween != null)
        {
            highlighTween.cancel();
            highlighTween.destroy();
            highlighTween = null;
        }

        highlight.scale.set(1, 1);
        highlight.alpha = 0.0;
        
        if (Value == true)
        {
            button.animation.play('selected');
            button.updateHitbox();
            button.color = FlxColor.fromInt(0x00FFFFFF);
            text.y -= 10;
            FlxTween.tween(text, {y: text.y + 10}, 0.2, {ease: FlxEase.sineOut});
            text.color = FlxColor.WHITE;

            highlighTween = FlxTween.tween(highlight, {"scale.x": 1.11, "scale.y": 1.11, "alpha": 0.0}, 0.8, {
                ease: FlxEase.circOut, 
                type: FlxTweenType.LOOPING,
                startDelay: 0.3,
                loopDelay: 0.8,
                onStart: (_) -> {
                    highlight.scale.set(1, 1);
                    highlight.alpha = 1.0;
                }
            });
        }
        else
        {
            button.animation.play('idle');
            button.updateHitbox();
            text.color = FlxColor.GRAY;
            button.color = FlxColor.GRAY;
        }

        return isSelected = Value;
    }

    override public function destroy()
    {
        if (!locked)
            FlxTween.cancelTweensOf(highlight);
        super.destroy();
    }
}