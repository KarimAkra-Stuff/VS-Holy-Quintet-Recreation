package states;

import shaders.ColorSwap;
import flixel.graphics.FlxGraphic;
import openfl.Assets;
import haxe.Json;
import haxe.io.Path;
import backend.Song;
import backend.Highscore;
import backend.Difficulty;
import objects.FreeplaySongItem;
import flixel.addons.display.FlxBackdrop;

class FreeplayState extends MusicBeatState
{
    public static var curSong:Int = 0;
    public static var curDifficulty:Int = 1;
    
    var songsList:Array<{songName:String, composer:String, character:String}> = [];
    var backgrounds:FlxTypedGroup<FlxSprite>;
    var songsGroup:FlxTypedGroup<FreeplaySongItem>;
    var portraits:FlxTypedGroup<FlxSprite>;

    var colorSwap:ColorSwap = new ColorSwap();
    var portraitsBaseX:Array<Float> = [];
    var top:FlxBackdrop;
    var bottom:FlxBackdrop;
    var diffSpr:FlxSprite;
    var diffSprFlash:FlxSprite;

    var busy:Bool = false;

    override public function create():Void 
    {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
        
        persistentUpdate = persistentDraw = true;
        
        backgrounds = new FlxTypedGroup<FlxSprite>();
        add(backgrounds);

        songsGroup = new FlxTypedGroup<FreeplaySongItem>();
        add(songsGroup);

        top = new FlxBackdrop(Paths.image('interfaces/common/topbar'), X);
        bottom = new FlxBackdrop(Paths.image('interfaces/common/topbar'), X);
        bottom.y = FlxG.height - bottom.height;
        bottom.flipY = true;
        
        top.velocity.x = bottom.velocity.x = 10;

        add(top);

        portraits = new FlxTypedGroup<FlxSprite>();
        add(portraits);

        add(bottom);

        Difficulty.resetList();

        var graphic:FlxGraphic = Paths.image('interfaces/freeplay/diff');
        diffSpr = new FlxSprite().loadGraphic(graphic, true, graphic.width, Std.int(graphic.height / Difficulty.defaultList.length));
        diffSpr.animation.add('a', [for (i in 0...Difficulty.defaultList.length) i], 24, false);
        diffSpr.animation.play('a');
        diffSpr.setPosition(217, 23);
        add(diffSpr);

        graphic = Paths.image('interfaces/freeplay/diffadd');
        diffSprFlash = new FlxSprite().loadGraphic(graphic, true, graphic.width, Std.int(graphic.height / Difficulty.defaultList.length));
        diffSprFlash.animation.copyFrom(diffSpr.animation);
        diffSprFlash.animation.play('a');
        diffSprFlash.setPosition(diffSpr.x, diffSpr.y);
        diffSprFlash.alpha = 0.0001;
        diffSprFlash.offset.x = 50;
        diffSprFlash.blend = ADD;
        diffSprFlash.shader = colorSwap.shader;
        colorSwap.brightness = 2.0;
        add(diffSprFlash);

        getSongs();

        for (i => song in songsList)
        {
            var background:FlxSprite = new FlxSprite().loadGraphic(Paths.image('interfaces/freeplay/backgrounds/${song.songName}'));
            background.alpha = curSong == i ? 1 : 0;
            background.ID = i;
            background.screenCenter();
            
            var songItem = new FreeplaySongItem(0, 0, song.songName, song.composer, song.character);
            songItem.ID = i;

            var portrait = new FlxSprite().loadGraphic(Paths.image('interfaces/freeplay/portraits/${song.songName}'));
            portrait.scale.set(0.8, 0.8);
            portrait.updateHitbox();
            portrait.setPosition(FlxG.width - portrait.width, (FlxG.height - portrait.height - bottom.height));
            portrait.alpha = curSong == i ? 1 : 0;
            portrait.visible = curSong == i;
            portrait.ID = i;

            // note to self: uncomment this later
            // switch (i)
            // {
            //     case 0:
            //         portrait.x -= 26.8;
            //         portrait.y += 8;
            //     case 2:

                    portrait.x += 144;
                    portrait.x = Math.fround(portrait.x);
                    portrait.y += 1;
                    portrait.y = Math.ffloor(portrait.y);
            // }

            portraitsBaseX[i] = portrait.x;

            backgrounds.add(background);
            songsGroup.add(songItem);
            portraits.add(portrait);
        }

        changeSong(0);
        changeDifficulty(0);

        // note to self: replace this with LEFT_FULL later
        addVirtualPad('LEFT_RIGHT', 'A_B');

        super.create();
    }
    
    override public function update(elapsed):Void
    {
        if (controls.ACCEPT && !busy)
        {
            busy = true;
			var songLowercase:String = Paths.formatToSongPath(songsList[curSong].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[lime.utils.Assets] ERROR:')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart

                Sys.println('ERROR WHILE LOADING CHART:\n$errorStr');
				FlxG.sound.play(Paths.sound('cancelMenu'));

                updateBackgrounds(elapsed);
                updateDifficulties(elapsed);
                busy = false;
				super.update(elapsed);
				return;
			}

			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
			#if !LOADING_SCREEN_ALLOWED FlxG.sound.music.stop(); #end
        }

        if (controls.BACK && !busy)
        {
            busy = true;
            persistentUpdate = false;
            MusicBeatState.switchState(new states.MainMenuState());
        }

        if (!busy)
        {
            if (controls.UI_UP_P)
                changeSong(-1);
            else if (controls.UI_DOWN_P)
                changeSong(1);

            if (controls.UI_LEFT_P)
                changeDifficulty(-1);
            else if (controls.UI_RIGHT_P)
                changeDifficulty(1);
        }

        updateBackgrounds(elapsed);
        updateDifficulties(elapsed);
        super.update(elapsed);
    }

    function changeSong(change:Int = 0)
    {
        curSong += change;

        if (curSong > songsList.length - 1)
            curSong = 0;
        if (curSong < 0)
            curSong = songsList.length - 1;

        for (i => song in songsGroup)
        {
            // i += 1;
            var indexOffset = i - curSong;

            song.intendedPosition.x = 42 + (Math.abs(indexOffset) * -75);
            song.intendedPosition.y = 301.5 + (indexOffset * 110);
            song.intendedAlpha = FlxMath.bound(1.0 - (Math.abs(indexOffset) * 0.6), 0.05, 1);

            if (indexOffset == 0)
            {
                song.icon.playAnimation('win');
            }
            else
            {
                song.icon.playAnimation('normal');
            }
        }

        setPortrait(change);

        if (change != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    function changeDifficulty(change:Int = 0)
    {
        curDifficulty += change;

        if (curDifficulty > Difficulty.defaultList.length - 1)
            curDifficulty = 0;
        if (curDifficulty < 0)
            curDifficulty = Difficulty.defaultList.length - 1;

        diffSpr.animation.curAnim.curFrame = diffSprFlash.animation.curAnim.curFrame = curDifficulty;
        if (change != 0)
        {
            diffSprFlash.scale.x = 1.0;
            diffSprFlash.alpha = 1.0;

            diffSpr.x += curDifficulty == 1 ? -20 : 20;
            FlxG.sound.play(Paths.sound(curDifficulty == 1 ? 'ui/diff_hard' : 'ui/diff_easy'));
        }
    }

    function updateDifficulties(elapsed:Float)
    {
        diffSpr.x = FlxMath.lerp(diffSpr.x, 217, Math.exp(-elapsed * (curDifficulty == 1 ? 106.0 : 124.0)));
        diffSprFlash.x = diffSpr.x;
        diffSprFlash.alpha = FlxMath.lerp(diffSprFlash.alpha, 0.0001, Math.exp(-elapsed * 152.0));
        diffSprFlash.scale.x = FlxMath.lerp(diffSprFlash.scale.x, 1.18, Math.exp(-elapsed * 152.0));
    }

    function updateBackgrounds(elapsed:Float)
    {
        backgrounds.forEachAlive(function(background) {
            background.alpha = FlxMath.lerp(background.alpha, background.ID == curSong ? 1 : 0, Math.exp(-elapsed * 160.0));
        });
    }

    function setPortrait(portrait:Int)
    {
        portraits.forEachAlive(function(portrait) {
            FlxTween.cancelTweensOf(portrait);
            portrait.visible = false;
            portrait.alpha = 0.0;
            portrait.x = portraitsBaseX[portrait.ID];

            if (portrait.ID == curSong)
            {
                portrait.visible = true;
                portrait.x += 50;

                FlxTween.tween(portrait, {alpha: 1}, 0.2, {ease: FlxEase.sineOut});
                FlxTween.tween(portrait, {x: portrait.x - 50}, 0.4, {ease: FlxEase.backOut});
            }
        });
    }

    function getSongs():Void
    {
        songsList = [];
        var list:Array<String> = CoolUtil.listFromString(Assets.getText(Paths.getAssetWithLibrary('assets/shared/songs/list.txt')));
        for (songPath in Paths.readDirectory('assets/shared/songs'))
        {
            if (Path.extension(songPath) != 'json') continue;
            var name:String = Path.withoutDirectory(Path.withoutExtension(songPath));
            var songJson:Dynamic = Json.parse(Assets.getText(songPath));
            songsList[list.indexOf(name)] = {songName: name, composer: songJson.composer, character: songJson.character};
        }
    }
}