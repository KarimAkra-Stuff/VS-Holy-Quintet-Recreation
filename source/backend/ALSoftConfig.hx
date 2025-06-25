package backend;

import lime.system.System;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;

/**
 * A class that simply points OpenALSoft to a custom configuration file when the game starts up.
 * The config overrides a few global OpenALSoft settings with the aim of improving audio quality on desktop targets.
 * Originally from this PR on Funkin https://github.com/FunkinCrew/Funkin/pull/3318 with few tweaks
 */
#if (!macro && (lime_openal && !ios))
@:build(backend.ALSoftConfig.setupConfig())
#end
class ALSoftConfig
{
	#if (lime_openal && !ios)
	private static final OPENAL_CONFIG:String = '';

	public static function init():Void
	{
		var origin:String = #if android System.applicationStorageDirectory #elseif hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));
		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#elseif android
		configPath = origin + 'openal/alsoft.conf';
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		FileSystem.createDirectory(Path.directory(configPath));
		File.saveContent(configPath, OPENAL_CONFIG);

		#if (android && !macro)
		lime.system.JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'nativeSetenv', '(Ljava/lang/String;Ljava/lang/String;)V')("ALSOFT_CONF", configPath);
		#else
		Sys.putEnv("ALSOFT_CONF", configPath);
		#end
	}
	#end

	#if macro
	public static function setupConfig()
	{
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();

		if (!FileSystem.exists('alsoft.txt'))
			return fields;

		var newFields = fields.copy();
		for (i => field in fields)
		{
			if (field.name == 'OPENAL_CONFIG')
			{
				newFields[i] = {
					name: 'OPENAL_CONFIG',
					access: [APrivate, AStatic, AFinal],
					kind: FVar(macro :String, macro $v{File.getContent('alsoft.txt')}),
					pos: pos,
				};
			}
		}

		return newFields;
	}
	#end
}
