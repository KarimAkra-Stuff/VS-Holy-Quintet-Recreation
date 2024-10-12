package mobile.flixel.input;

import flixel.system.macros.FlxMacroUtil;

/**
 * A high-level list of unique values for mobile input buttons.
 * Maps enum values and strings to unique integer codes
 * @author Karim Akra & Lily(mcagabe19)
 */
@:runtimeValue
enum abstract FlxMobileInputID(Int) from Int to Int {
	public static var fromStringMap(default, null):Map<String, FlxMobileInputID> = FlxMacroUtil.buildMap("mobile.flixel.input.FlxMobileInputID");
	public static var toStringMap(default, null):Map<FlxMobileInputID, String> = FlxMacroUtil.buildMap("mobile.flixel.input.FlxMobileInputID", true);
	// Nothing & Anything
	var ANY = -2;
	var NONE = -1;
	// Buttons
	var A = 1;
	var B = 2;
	var C = 3;
	var D = 4;
	var E = 5;
	var F = 6;
	var G = 7;
	var H = 8;
	var I = 9;
	var J = 10;
	var K = 11;
	var L = 12;
	var M = 13;
	var N = 14;
	var O = 15;
	var P = 16;
	var Q = 17;
	var R = 18;
	var S = 19;
	var T = 20;
	var U = 21;
	var V = 22;
	var W = 23;
	var X = 24;
	var Y = 25;
	var Z = 26;
	var ZERO = 27;
	var ONE = 28;
	var TWO = 29;
	var THREE = 30;
	var FOUR = 31;
	var FIVE = 32;
	var SIX = 33;
	var SEVEN = 34;
	var EIGHT = 35;
	var NINE = 36;
	// VPAD Buttons
	var UP = 37;
	var UP2 = 38;
	var DOWN = 39;
	var DOWN2 = 40;
	var LEFT = 41;
	var LEFT2 = 42;
	var RIGHT = 43;
	var RIGHT2 = 44;
	// HITBOX
	var hitboxUP = 45;
	var hitboxDOWN = 46;
	var hitboxLEFT = 47;
	var hitboxRIGHT = 48;
	// PlayState Releated
	var noteUP = 49;
	var noteDOWN = 50;
	var noteLEFT = 51;
	var noteRIGHT = 52;

	@:from
	public static inline function fromString(s:String) {
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}

	@:to
	public inline function toString():String {
		return toStringMap.get(this);
	}
}
