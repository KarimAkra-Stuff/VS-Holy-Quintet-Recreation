package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System as OpenFlSystem;
import lime.system.System as LimeSystem;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if (!windows && cpp)
@:headerInclude('sys/utsname.h')
#elseif (windows && cpp)
@:cppFileCode('#include <windows.h>')
#end
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Float;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	public var os:String = '';

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		if (LimeSystem.platformName == LimeSystem.platformVersion || LimeSystem.platformVersion == null)
			os = '\nOS: ${LimeSystem.platformName}' #if (cpp && !ios) + ' ${getArch()}' #end;
		else
			os = '\nOS: ${LimeSystem.platformName}' #if (cpp && !ios) + ' ${getArch()}' #end + ' - ${LimeSystem.platformVersion}';

		positionFPS(x, y);

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		width = FlxG.width;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		// prevents the overlay from updating every frame, why would you need to anyways
		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		// final now:Float = haxe.Timer.stamp() * 1000;
		// times.push(now);
		// while (times[0] < now - 1000) times.shift();

		final fps:Float = CoolUtil.floorDecimal(1.0 / deltaTime, 2);
		if (Math.abs(fps - FlxG.updateFramerate) > 5)
			currentFPS = fps < FlxG.updateFramerate ? fps : FlxG.updateFramerate;
		updateText();
		deltaTimeout += deltaTime;
	}

	public dynamic function updateText():Void // so people can override it in hscript
	{
		var _fps = '$currentFPS';
		if (!_fps.contains('.'))
			_fps += '.00';
		text = 
		'FPS: $_fps' + 
		'\nMemory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}' +
		os;

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			textColor = 0xFFFF0000;
	}

	inline function get_memoryMegas():Float
		return cast(OpenFlSystem.totalMemory, UInt);

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}

	#if cpp
	#if windows
	@:functionCode('
		SYSTEM_INFO osInfo;

		GetSystemInfo(&osInfo);

		switch(osInfo.wProcessorArchitecture)
		{
			case 9:
				return ::String("x86_64");
			case 5:
				return ::String("ARM");
			case 12:
				return ::String("ARM64");
			case 6:
				return ::String("IA-64");
			case 0:
				return ::String("x86");
			default:
				return ::String("Unknown");
		}
	')
	#else
	@:functionCode('
		struct utsname osInfo{};
		uname(&osInfo);
		return ::String(osInfo.machine);
	')
	#end
	@:noCompletion
	private function getArch():String
	{
		return null;
	}
        #end
}
