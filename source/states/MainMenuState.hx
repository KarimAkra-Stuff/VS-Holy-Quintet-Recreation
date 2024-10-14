package states;

import objects.BalloonsBG;
import objects.HQMenuOption;
import openfl.utils.Assets;
import states.TitleState;
import states.CreditsState;
import options.OptionsState;

@:access(objects.HQMenuOption)
class MainMenuState extends MusicBeatState
{
    public static final ASSETS_PATH:String = 'interfaces/main/';
    public static final menuOptions:Array<String> = ['Story', 'Freeplay', 'Achievements', 'Credits', 'Settings'];
    public static final optionsLock:Array<Bool> = [true, false, true, false, false];
    public static var curSelected:Int = 0;
    
    var bg:FlxSprite;
    var balloons:BalloonsBG;
    
    var optionsBG:FlxSprite;
    var logo:FlxSprite;
    
    var menuItems:FlxTypedGroup<HQMenuOption>;
    var itemsScreen:Array<FlxAnimate> = [];

    final atlasesSymbolData:Map<String, {name:String, x:Float, y:Float, ?scale:Float, fps:Int, indicesIntro:Array<Int>, indicesLoop:Array<Int>, ?underneathOptionsBG:Bool, ?addInOne:Bool}> = [];
    var busy:Bool = false;

    override public function create():Void
    {
        persistentUpdate = persistentDraw = true;

        bg = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'menuBG'));
        bg.screenCenter();
        add(bg);

        balloons = new BalloonsBG();
        add(balloons);

        optionsBG = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'bg'));
        optionsBG.x = FlxG.width - optionsBG.width;
        add(optionsBG);

        logo = new FlxSprite().loadGraphic(Paths.image(ASSETS_PATH + 'logosmaller'));
        logo.scale.set(0.47, 0.47);
        logo.setPosition(optionsBG.x + 86.5, 6);
        logo.updateHitbox();
        add(logo);

        menuItems = new FlxTypedGroup<HQMenuOption>();
        add(menuItems);
        
        var lastOptionPoint:FlxPoint = FlxPoint.get();
        for (i => optionName in menuOptions)
        {
            trace('creating option $optionName (id: $i)');
            var name:String = optionName.toLowerCase();
            var option:HQMenuOption = new HQMenuOption(optionName, optionsLock[i]);
            option.isSelected = false;
            menuItems.add(option);

            if (i == 0)
            {
                option.setPosition(optionsBG.x + 115, logo.y + logo.height);
            }
            else
            {
                option.setPosition(lastOptionPoint.x + -15, lastOptionPoint.y + option.height + 2);
            }

            // hardcoding this cuz i'm a lazy mf
            if (i == 2)
            {
                option.text.scale.x = 0.85;
                option.text.x -= 36;
            }

            var atlasFolder:String = Paths.getAtlasPath('atlases/menu/animations/$name', 'images');

            if (Assets.exists(atlasFolder + '/data.json'))
            {
                // trace('adding animation data for $optionName');
                atlasesSymbolData.set(optionName, haxe.Json.parse(Assets.getText(atlasFolder + '/data.json')));
            }

            if (atlasesSymbolData.exists(optionName))
            {
                var symbolData = atlasesSymbolData.get(optionName);
                // trace(symbolData);
                var screen:FlxAnimate = new FlxAnimate(symbolData.x, symbolData.y);
                screen.loadAtlas(atlasFolder);
                if (symbolData.scale != null)
                    screen.scale.set(symbolData.scale, symbolData.scale);
                if (symbolData.addInOne == true)
                {
                    screen.anim.addBySymbol('intro', symbolData.name, symbolData.fps, false);
                }
                else
                {
                    screen.anim.addBySymbolIndices('intro', symbolData.name, [for (i in symbolData.indicesIntro[0]...symbolData.indicesIntro[1]) i], symbolData.fps, false);
                    screen.anim.addBySymbolIndices('loop', symbolData.name, [for (i in symbolData.indicesLoop[0]...symbolData.indicesLoop[1]) i], symbolData.fps);
                    screen.anim.onComplete.add(() -> {
                        if (screen.anim.curSymbol.name == 'intro')
                            screen.anim.play('loop', true);
                    });
                }
                if (symbolData.underneathOptionsBG == true)
                    insert(members.indexOf(optionsBG), screen);
                else
                    insert(members.indexOf(logo) + 1, screen);
                    // add(screen);
                itemsScreen.push(screen);
            }

            lastOptionPoint.set(option.x, option.y);
        }

        lastOptionPoint.put();

        changeItem(0);

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        if (!busy)
        {
            if (controls.UI_UP_P)
                changeItem(-1);
            if (controls.UI_DOWN_P)
                changeItem(1);

            if (controls.BACK)
                MusicBeatState.switchState(new TitleState());
            
            if (controls.ACCEPT)
            {
               if (menuItems.members[curSelected].isSelected)
                {
                    if (menuItems.members[curSelected].locked)
                    {
                        FlxG.sound.play(Paths.sound('lockedMenu'));
                    }
                    else
                    {
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                        menuItems.members[curSelected].flash();
                    
                        switch (menuOptions[curSelected])
                        {
                            // case 'Story': MusicBeatState.switchState(new states.StoryMenuState());
                            case 'Freeplay': MusicBeatState.switchState(new FreeplayState());
                            // case 'Achievements': MusicBeatState.switchState(new states.AchievementsMenuState());
                            case 'Credits': MusicBeatState.switchState(new CreditsState());
                            case 'Settings': MusicBeatState.switchState(new OptionsState());
                        }
                    }
                }
            }
        }
        super.update(elapsed);
    }

    function changeItem(change:Int)
    {
        curSelected += change;

        if (curSelected > menuOptions.length - 1)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = menuOptions.length - 1;

        for (i => member in menuItems.members)
            member.isSelected = i == curSelected;

        for (i => member in itemsScreen)
        {
            if (i == curSelected)
            {
                if (atlasesSymbolData.exists(menuOptions[curSelected]))
                {
                    member.anim.play('intro', true);
                    member.visible = true;
                }
            }
            else
            {
                member.visible = false;
            }
        }

        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}