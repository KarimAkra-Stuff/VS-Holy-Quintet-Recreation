package states;

import backend.Rating;
import openfl.filters.BlurFilter;
import objects.VideoSprite;
import backend.Highscore;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import states.StoryMenuState;
import states.MainMenuState;
import haxe.Int64;
import objects.ComboWindow;

class InitState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	public var playingVideo:Bool = false;
	public var video:VideoSprite;

	override public function create()
	{
		FlxTransitionableState.skipNextTransIn = true;
		super.create();

		// Paths.clearStoredMemory();

		if (!initialized)
		{
			Main.BLUR_SHADER = new BlurFilter(4.7, 4.7);

			#if MODS_ALLOWED
			Mods.pushGlobalMods();
			Mods.loadTopMod();
			#end

			FlxG.fixedTimestep = false;
			FlxG.game.focusLostFramerate = 60;
			FlxG.keys.preventDefaultKeys = [TAB];

			FlxG.save.bind('funkin', CoolUtil.getSavePath());

			ClientPrefs.loadPrefs();

			Highscore.load();

			if (FlxG.save.data != null && FlxG.save.data.fullscreen)
				FlxG.fullscreen = FlxG.save.data.fullscreen;
			persistentUpdate = true;
			persistentDraw = true;
			FlxG.mouse.load(Paths.image('interfaces/common/cursor-gf').bitmap);
			MobileData.init();

			if (FlxG.save.data.weekCompleted != null)
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

			FlxG.mouse.visible = false;

			flixel.FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

			controls.isInSubstate = false;

			initialized = true;
		}

		#if STAY_ON_INIT
		createState();
		#else
		#if FREEPLAY
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		MusicBeatState.switchState(new states.FreeplayState());
		#elseif MAIN_MENU
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		MusicBeatState.switchState(new states.MainMenuState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if (FlxG.save.data.agreedDisclaimer == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			video = new VideoSprite(Paths.video('intro'), false, true, false, Paths.videoBytes('intro'));
			video.finishCallback = function()
			{
				playingVideo = false;
				remove(video);
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new states.TitleState());
			};
			video.onSkip = function()
			{
				playingVideo = false;
				remove(video);
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new states.TitleState());
			};
			add(video);

			FlxG.sound.playMusic(Paths.music('vidintro'));
			video.videoSprite.play();

			playingVideo = true;
		}
		#end
		#end
	}

	override function update(elapsed:Float)
	{
		if (playingVideo)
		{
			if (video.videoSprite.bitmap != null
				&& video.videoSprite.bitmap.position < 0.9
				&& (video.videoSprite.bitmap.time > Int64.fromFloat(FlxG.sound.music.time + 200)
					|| video.videoSprite.bitmap.time < Int64.fromFloat(FlxG.sound.music.time - 200)))
				video.videoSprite.bitmap.time = Int64.fromFloat(FlxG.sound.music.time);
		}
		#if STAY_ON_INIT
		stateUpdate(elapsed);
		#end
		super.update(elapsed);
	}

	#if STAY_ON_INIT
	private function createState()
	{
	}

	function stateUpdate(elapsed:Float)
	{
	}
	#end
}
