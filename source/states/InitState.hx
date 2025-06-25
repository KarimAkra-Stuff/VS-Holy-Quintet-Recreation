package states;

import lime.app.Application;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import backend.Rating;
import openfl.filters.BlurFilter;
#if VIDEOS_ALLOWED
import objects.VideoSprite;
#end
import backend.Highscore;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import states.StoryMenuState;
import states.MainMenuState;
import haxe.Int64;
import objects.ComboWindow;

@:access(flixel.FlxCamera)
class InitState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	public var playingVideo:Bool = false;
	#if VIDEOS_ALLOWED
	public var video:VideoSprite;
	#end

	override public function create()
	{
		super.create();

		FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;

		if (!initialized)
		{
			ClientPrefs.loadPrefs();

			if (FlxG.save.data != null && FlxG.save.data.fullscreen)
				FlxG.fullscreen = FlxG.save.data.fullscreen;

			if (FlxG.save.data.weekCompleted != null)
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

			FlxG.fixedTimestep = false;
			FlxG.mouse.visible = false;
			FlxG.game.focusLostFramerate = 60;
			FlxG.keys.preventDefaultKeys = [TAB];
			FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
			FlxG.save.bind('funkin', CoolUtil.getSavePath());
			FlxG.mouse.load(Paths.image('interfaces/common/cursor-gf').bitmap);

			Main.BLUR_SHADER = new BlurFilter(4.7, 4.7);

			#if MODS_ALLOWED
			Mods.pushGlobalMods();
			Mods.loadTopMod();
			#end

			Highscore.load();

			MobileData.init();

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
			#if VIDEOS_ALLOWED
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
			#else
			MusicBeatState.switchState(new states.TitleState());
			#end
		}
		#end
		#end
	}

	override function update(elapsed:Float)
	{
		#if VIDEOS_ALLOWED
		if (playingVideo)
		{
			if (video.videoSprite.bitmap != null
				&& video.videoSprite.bitmap.position < 0.9
				&& (video.videoSprite.bitmap.time > Int64.fromFloat(FlxG.sound.music.time + 30)
					|| video.videoSprite.bitmap.time < Int64.fromFloat(FlxG.sound.music.time - 30)))
				video.videoSprite.bitmap.time = Int64.fromFloat(FlxG.sound.music.time);
		}
		#end
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
