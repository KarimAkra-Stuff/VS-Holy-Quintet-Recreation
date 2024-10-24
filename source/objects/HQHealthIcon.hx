package objects;

import openfl.Assets;
import haxe.Json;

class HQHealthIcon extends FlxSprite
{
    public var currentAnimation(default, null):String = 'normal';
    public var iconData(default, null):IconData;
    public var attacked(default, null):Bool = false;
    public var iconOffset:Array<Float> = [0, 0];
	private var isPlayer:Bool = false;
	private var char:String = '';
    private var isFreeplayIcon:Bool = false;

	public function new(char:String = 'gf', isFreeplayIcon:Bool = false, isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		this.isPlayer = isPlayer;
        this.isFreeplayIcon = isFreeplayIcon;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'interfaces/game/icons/animated/' + char;
            
			if(!Paths.fileExists('images/' + name + '.png', IMAGE))
                Sys.println('[WARNING] Couldn\'t find health icon ${'images/' + name + '.png'}');

            frames = Paths.getSparrowAtlas(name, allowGPU);

            iconData = Json.parse(Assets.getText(graphic.key.replace('png', 'json')));

            animation.addByIndices('#normal_win', 'ICON', iconData.normalToWinIndices, "", 24.0, false);
            animation.addByIndices('#normal_lose', 'ICON', iconData.normalToLoseIndices, "", 24.0, false);

            animation.addByIndices('#win_normal', 'ICON', iconData.winToNormalIndices, "", 24.0, false);
            animation.addByIndices('#lose_normal', 'ICON', iconData.loseToNormalIndices, "", 24.0, false);

            animation.addByIndices('normal-loop', 'ICON', iconData.normalLoopIndices, "", 24.0);
            animation.addByIndices('win-loop', 'ICON', iconData.winLoopIndices, "", 24.0);
            animation.addByIndices('lose-loop', 'ICON', iconData.loseLoopIndices, "", 24.0);

            if (iconData.attackedIndices != null)
                animation.addByIndices('attacked', 'ICON', iconData.attackedIndices, "", 24.0, false);

            offset.set(isFreeplayIcon ? iconData.freeplayOffset[0] : 0, isFreeplayIcon ? iconData.freeplayOffset[1] : 0);
            
            animation.finishCallback = (name:String) -> {
                if (name == 'attacked')
                {
                    attacked = false;
                    playAnimation(currentAnimation);
                }
                if (name != 'attacked' && !name.endsWith('-loop'))
                {
                    if (name.startsWith('#'))
                        name = name.split('_')[1];
                    animation.play('$name-loop', true);
                }
            };
			
            playAnimation('normal');

			this.char = char;

			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

    public function playAnimation(animation:String)
    {
        if (attacked)
        {
            currentAnimation = animation;
            return;
        }

        if (animation == 'attacked')
        {
            this.animation.play('attacked', true);
            attacked = true;
            return;
        }

        switch (currentAnimation)
        {
            case 'normal':
                switch (animation)
                {
                    case 'win':  this.animation.play('#normal_win', true);
                    case 'lose': this.animation.play('#normal_lose', true);
                    default: this.animation.play('normal-loop', true);
                }
            case 'lose':
                switch (animation)
                {
                    case 'win':  this.animation.play('win-loop', true);
                    case 'normal': this.animation.play('#lose_normal', true);
                    default: this.animation.play('lose-loop', true);
                }
            case 'win':
                switch (animation)
                {
                    case 'normal': this.animation.play('#win_normal', true);
                    case 'lose':  this.animation.play('lose-loop', true);
                    default: this.animation.play('win-loop', true);
                }
            default:
                this.animation.play('normal-loop', true);
        }

        currentAnimation = animation;
    }

	override function updateHitbox()
	{
		super.updateHitbox();
        offset.set(isFreeplayIcon ? iconData.freeplayOffset[0] : iconOffset[0], isFreeplayIcon ? iconData.freeplayOffset[1] : iconOffset[1]);
	}

	public function getCharacter():String {
		return char;
	}

	override function destroy()
	{
		super.destroy();
	}
}

typedef IconData =
{
    public var winToNormalIndices:Array<Int>;
    public var loseToNormalIndices:Array<Int>;
    
    public var normalToWinIndices:Array<Int>;
    public var normalToLoseIndices:Array<Int>;

    public var normalLoopIndices:Array<Int>;
    public var winLoopIndices:Array<Int>;
    public var loseLoopIndices:Array<Int>;
    
    public var freeplayOffset:Array<Float>;

    // Kyoko's icon has a attack animation & girlfriend has an attacked animation soo
    @:optional public var attackedIndices:Array<Int>;
}