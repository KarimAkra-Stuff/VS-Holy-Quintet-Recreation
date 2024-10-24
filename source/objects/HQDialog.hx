package objects;

import flixel.FlxObject;
import openfl.filters.BlurFilter;
import shaders.ColorSwap;

class HQDialog extends MusicBeatSubstate
{
    private var box:FlxSprite;
    private var notice:FlxSprite;
    private var title:FlxText;
    private var message:FlxText;
    private var option1:DialogOption;
    private var option2:DialogOption;
    private var cam = new FlxCamera();
    private var colorSwap = new ColorSwap();
    private var flashSpr:FlxSprite;


    public function new(Title:String, Message:String, Option1:OptionArgs, Option2:OptionArgs)
    {
        super();
        
        FlxG.sound.play(Paths.sound('ui/window_open'));
        cam.bgColor.alpha = 0;
        FlxG.cameras.add(cam, false);
        cameras = [cam];

        // for(i in 0...FlxG.cameras.list.length - 2)
        //     FlxG.cameras.list[i].filters = [Main.BLUR_SHADER];

        var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.scrollFactor.set();
        bg.alpha = 0.76;
        add(bg);

        box = new FlxSprite();
        box.loadGraphic(Paths.image('interfaces/common/window/confirmation'));
        box.updateHitbox();
        box.screenCenter();
        add(box);

        notice = new FlxSprite();
        notice.loadGraphic(Paths.image('interfaces/common/window/warning'));
        notice.alpha = 0.0;
        notice.shader = colorSwap.shader;
        add(notice);

        title = new FlxText(0, 0, 0, Title);
        title.setFormat(Paths.font('shingo.otf'), 34);
        add(title);

        message = new FlxText(0, 0, 0, Message);
        message.setFormat(Paths.font('shingo.otf'), 33, FlxColor.BLACK, FlxTextAlign.CENTER);
        add(message);
        
        option1 = new DialogOption(Option1.name, Option1.onSelect);
        add(option1);

        option2 = new DialogOption(Option2.name, Option2.onSelect);
        add(option2);

        notice.setPosition(box.x + 30, box.y - 5 - 20);

        CoolUtil.centerObjectInsideObject(title, box, X);
        title.y = box.y + 20;

        CoolUtil.centerObjectInsideObject(message, box);

        option1.setPosition(box.x + 23, ((box.y + box.height) - 55.5) - option1.height);
        option1.isSelected = true;
        
        option2.setPosition(box.x + (box.width - option2.width) - 37, ((box.y + box.height) - 55.5) - option2.height);
        option2.isSelected = false;

        cam.alpha = 0.0;
        cam.y += 40;

        FlxTween.tween(cam, {y: cam.y - 40, alpha: 1}, 0.3, {
            ease: FlxEase.expoOut,
            onComplete: (_) -> {
                FlxTween.tween(notice, {alpha: 1}, 0.4, {ease: FlxEase.sineOut});

                FlxTween.tween(notice, {y: notice.y + 20}, 0.8, {
                    ease: FlxEase.elasticOut,
                    onComplete: (_) -> {

                        colorSwap.brightness = 0.9;

                        FlxTween.tween(colorSwap, {brightness: 0}, 1.0, {ease: FlxEase.cubeOut});

                        flashSpr = new FlxSprite().loadGraphicFromSprite(notice);
                        flashSpr.setPosition(notice.x, notice.y);
                        add(flashSpr);

                        FlxTween.tween(flashSpr, {"scale.x": 1.6, "scale.y": 1.6, "alpha": 0.0}, 1.2, {
                            ease: FlxEase.circOut, 
                            startDelay: 0.2,
                            onComplete: (_) -> {
                                FlxTween.cancelTweensOf(flashSpr);
                                flashSpr.destroy();
                            },
                            onUpdate: (_) -> {
                                // CoolUtil.centerObjectInsideObject(flashSpr, notice);
                            }
                        });
                    }
                });
            }
        });
    }

    override public function update(elapsed:Float)
    {
        for(option in [option1, option2])
        {
            if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
                option.isSelected = !option.isSelected;

            if (controls.ACCEPT && option.isSelected && option.onSelect != null)
                option.onSelect(this);
        }

        if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
    		FlxG.sound.play(Paths.sound('scrollMenu'));

        addVirtualPad('LEFT_RIGHT', 'A');
        virtualPad.cameras = [cam];

        super.update(elapsed);
    }

    override public function destroy():Void
    {
        // for(i in 0...FlxG.cameras.list.length)
        //     FlxG.cameras.list[i].filters = [];
        FlxTween.cancelTweensOf(cam);
        FlxTween.cancelTweensOf(colorSwap);
        if (notice != null)
        FlxTween.cancelTweensOf(notice);
        if (flashSpr != null)
            FlxTween.cancelTweensOf(flashSpr);
        super.destroy();
    }
}

class DialogOption extends FlxSpriteGroup
{
    public var name:String;
    public var isSelected(default, set):Bool;
    public var onSelect:HQDialog->Void;

    private var button:FlxSprite;
    private var highlight:FlxSprite;
    private var text:FlxText;
    private var highlighTween:FlxTween;

    public function new(name:String, ?onSelect:HQDialog->Void)
    {
        super(0, 0);

        this.name = name;
        this.onSelect = onSelect;

        button = new FlxSprite();
        button.loadGraphic(Paths.image('interfaces/common/buttons/standard/buttons'), true, 356, 103);
		button.animation.add('selected', [0]);
		button.animation.add('idle', [1]);
        button.animation.play('idle');
        button.updateHitbox();

        highlight = new FlxSprite(0, 0);
        highlight.loadGraphic(Paths.image('interfaces/common/buttons/standard/buttonhightlight'));

        text = new FlxText(0, 0, 0, name);
        text.setFormat(Paths.font('shingo.otf'), 40, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.borderSize = 2.5;
        text.borderQuality = 5.0;

        add(button);
        add(highlight);
        add(text);

        CoolUtil.centerObjectInsideObject(highlight, button);
        CoolUtil.centerTextInsideObject(text, button);
    }

    @:noCompletion
    private function set_isSelected(Value:Bool):Bool
    {
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
            text.color = FlxColor.WHITE;
            button.color = FlxColor.fromInt(0x00FFFFFF);

            highlighTween = FlxTween.tween(highlight, {"scale.x": 1.11, "scale.y": 1.11, "alpha": 0.0}, 0.8, {
                ease: FlxEase.circOut, 
                type: FlxTweenType.LOOPING,
                startDelay: 0.3,
                loopDelay: 0.8,
                onStart: (_) -> {
                    highlight.scale.set(1, 1);
                    highlight.alpha = 1.0;
                },
                onUpdate: (_) -> {
                    // CoolUtil.centerObjectInsideObject(highlight, button);
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
        FlxTween.cancelTweensOf(highlight);
        super.destroy();
    }
}

typedef OptionArgs =
{
    public var name:String;   
    @:optional public var onSelect:HQDialog->Void; 
}