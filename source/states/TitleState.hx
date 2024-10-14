package states;

import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import shaders.ColorSwap;

class TitleState extends MusicBeatState
{
    public static final ASSETS_PATH:String = 'interfaces/title/';

    var sky:FlxSprite;
    var fog:FlxSprite;
    
    var cuties:FlxSprite;
    var cutiesFlash:FlxSprite;

    var dustOverlay:FlxBackdrop;
    
    var logo:FlxSprite;

    var pressBackdrop:FlxBackdrop;
    var press:FlxSprite;

    var blackOverlay:FlxSprite;

    var star:FlxSprite;
    var starGlow:FlxSprite;

    var flash:FlxSprite;

    var colorSwap:ColorSwap = new ColorSwap();
    var introTimer:FlxTimer = null;
    var finishedIntro:Bool = false;
    var transitioning:Bool = false;
    
    override public function create():Void
    {
        // FlxG.camera.filters = [new ShaderFilter(colorSwap.shader)];
        if (FlxG.sound.music != null && FlxG.sound.music.playing)
            FlxG.sound.music.stop();
        
        FlxG.sound.play(Paths.sound('ui/spaceambient'), 1.0, true);

        sky = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'sky'));
        sky.screenCenter();
        sky.shader = colorSwap.shader;
        add(sky);

        fog = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'fog'));
        fog.screenCenter();
        fog.shader = colorSwap.shader;
        add(fog);

        cuties = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'charas'));
        cuties.screenCenter();
        cuties.shader = colorSwap.shader;
        add(cuties);

        cuties.y -= 20;
        FlxTween.tween(cuties, {y: cuties.y + 20}, 6, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

        cutiesFlash = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'charasglow'));
        cutiesFlash.screenCenter();
        cutiesFlash.alpha = 0.0001;
        cutiesFlash.shader = colorSwap.shader;
        add(cutiesFlash);

        dustOverlay = new FlxBackdrop(Paths.image(ASSETS_PATH + 'dust'));
        dustOverlay.velocity.set(-120, 125);
        dustOverlay.shader = colorSwap.shader;
        add(dustOverlay);

        logo = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'logo'));
        logo.y = 30;
        logo.shader = colorSwap.shader;
        add(logo);

        logo.y -= 20;
        FlxTween.tween(logo, {y: logo.y + 20}, 5, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

        pressBackdrop = new FlxBackdrop(Paths.image(ASSETS_PATH + 'scrolltext'), X);
        pressBackdrop.velocity.set(30, 0);
        pressBackdrop.y = FlxG.height - 190;
        pressBackdrop.alpha = 0.5;
        pressBackdrop.blend = ADD;
        add(pressBackdrop);

        press = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'starttext'));
        press.screenCenter(X);
        press.x += 4;
        press.y = FlxG.height - 186;
        var pressColorSwap = new ColorSwap();
        pressColorSwap.brightness = 0.2;
        press.shader = pressColorSwap.shader;
        add(press);

        blackOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(blackOverlay);

        star = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'intro/star'));
        star.alpha = 0.0;
        star.shader = colorSwap.shader;
        add(star);

        starGlow = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'intro/starglow'));
        starGlow.alpha = 0.0;
        starGlow.scale.set(0.8, 0.8);
        starGlow.shader = colorSwap.shader;
        add(starGlow);

        star.screenCenter();
        starGlow.screenCenter();

        flash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
        flash.blend = ADD;
        flash.alpha = 0.0;
        add(flash);

        FlxTween.tween(star, {alpha: 1}, 0.3, {
            startDelay: 0.3,
            ease: FlxEase.sineOut,
            onComplete: function(_) {
                FlxG.sound.play(Paths.sound('ui/start-1'));

                FlxTween.tween(starGlow, {alpha: 1.0}, 0.9, {ease: FlxEase.sineOut, startDelay: 0.2});
                FlxTween.tween(starGlow, {'scale.x': 1.8, 'scale.y': 1.8}, 2.4, {ease: FlxEase.expoInOut, startDelay: 0.2});
                introTimer = new FlxTimer().start(1.43, function(_) {
                    FlxTween.tween(flash, {alpha: 1}, 0.8, {ease: FlxEase.expoInOut});
                    FlxTween.tween(colorSwap, {brightness: 3.5}, 0.8, {
                        ease: FlxEase.expoInOut,
                        onComplete: introCallback
                    });
                });
            }
        });

        super.create();
    }
    
    override public function update(elapsed:Float):Void
    {
        cutiesFlash.setPosition(cuties.x, cuties.y);
        if((controls.ACCEPT || (FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justPressed)) && !transitioning)
        {
            if (finishedIntro)
            {
                transitioning = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                flashCuties(1.1);
                colorSwap.brightness = 1.0;
                FlxTween.tween(colorSwap, {brightness: 0}, 1.1, {ease: FlxEase.sineOut});
                FlxG.camera.zoom += 0.08;
                FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.08}, 0.4, {
                    ease: FlxEase.sineOut,
                    onComplete: (_) -> {
                        FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.45}, 1.3, {ease: FlxEase.sineInOut, startDelay: 0.2});
                        FlxTween.tween(blackOverlay, {alpha: 1}, 1.1, {ease: FlxEase.expoInOut, startDelay: 0.2, onComplete: (_) -> MusicBeatState.switchState(new states.MainMenuState())});
                    }
                });
            }
            else
            {
                introCallback(null);
            }
        }

        super.update(elapsed);
    }

    function flashCuties(duration:Float = 0.5):Void
    {
        FlxTween.cancelTweensOf(cutiesFlash);
        cutiesFlash.alpha = 1.0;
        FlxTween.tween(cutiesFlash, {alpha: 0}, duration, {ease: FlxEase.sineOut});
    }

    function introCallback(_)
    {
        FlxG.sound.play(Paths.sound('ui/start-2'));
        FlxG.sound.playMusic(Paths.music('freakyMenu'));
        FlxTween.cancelTweensOf(star);
        FlxTween.cancelTweensOf(starGlow);
        FlxTween.cancelTweensOf(flash);
        FlxTween.cancelTweensOf(colorSwap);
        star.destroy();
        starGlow.destroy();
        // blackOverlay.destroy();
        remove(star);
        remove(starGlow);
        // remove(blackOverlay);
        blackOverlay.alpha = 0;
        FlxG.camera.zoom += 0.35;
        FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.35}, 0.6, {ease: FlxEase.expoOut});
        FlxTween.tween(colorSwap, {brightness: 0.0}, 0.75, {ease: FlxEase.quintOut});
        FlxTween.tween(flash, {alpha: 0.0}, 0.6, {ease: FlxEase.quintOut, onComplete: (_) -> flash.destroy()});
        flashCuties(0.9);
        if (introTimer != null)
            introTimer.cancel();
        finishedIntro = true;
    }
}