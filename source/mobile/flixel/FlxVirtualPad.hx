package mobile.flixel;

import haxe.io.Path;
import flixel.graphics.frames.FlxTileFrames;
import mobile.flixel.input.FlxMobileInputManager;
import mobile.flixel.FlxButton;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.display.BitmapData;

/**
 * A gamepad.
 * It's easy to customize the layout.
 *
 * @author Ka Wing Chin, Mihai Alexandru, Karim Akra & Lily (mcagabe19)
 */
class FlxVirtualPad extends FlxMobileInputManager {
	public var buttonLeft:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.LEFT, FlxMobileInputID.noteLEFT]);
	public var buttonUp:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.UP, FlxMobileInputID.noteUP]);
	public var buttonRight:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.RIGHT, FlxMobileInputID.noteRIGHT]);
	public var buttonDown:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.DOWN, FlxMobileInputID.noteDOWN]);
	public var buttonLeft2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.LEFT2, FlxMobileInputID.noteLEFT]);
	public var buttonUp2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.UP2, FlxMobileInputID.noteUP]);
	public var buttonRight2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.RIGHT2, FlxMobileInputID.noteRIGHT]);
	public var buttonDown2:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.DOWN2, FlxMobileInputID.noteDOWN]);
	public var buttonZero:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.ZERO]);
	public var buttonOne:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.ONE]);
	public var buttonTwo:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.TWO]);
	public var buttonThree:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.THREE]);
	public var buttonFour:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.FOUR]);
	public var buttonFive:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.FIVE]);
	public var buttonSix:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.SIX]);
	public var buttonSeven:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.SEVEN]);
	public var buttonEight:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.EIGHT]);
	public var buttonNine:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.NINE]);
	public var buttonA:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.A]);
	public var buttonB:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.B]);
	public var buttonC:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.C]);
	public var buttonD:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.D]);
	public var buttonE:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.E]);
	public var buttonF:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.F]);
	public var buttonG:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.G]);
	public var buttonH:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.H]);
	public var buttonI:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.I]);
	public var buttonJ:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.J]);
	public var buttonK:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.K]);
	public var buttonL:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.L]);
	public var buttonM:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.M]);
	public var buttonN:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.N]);
	public var buttonO:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.O]);
	public var buttonP:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.P]);
	public var buttonQ:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.Q]);
	public var buttonR:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.R]);
	public var buttonS:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.S]);
	public var buttonT:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.T]);
	public var buttonU:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.U]);
	public var buttonV:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.V]);
	public var buttonW:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.W]);
	public var buttonX:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.X]);
	public var buttonY:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.Y]);
	public var buttonZ:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.Z]);
	public var buttonExtra:FlxButton = new FlxButton(0, 0);
	public var buttonExtra2:FlxButton = new FlxButton(0, 0);

	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(DPad:String, Action:String, ?Extra:ExtraActions = NONE) {
		super();

		if (DPad != "NONE") {
			if (!MobileData.dpadModes.exists(DPad))
				throw 'The virtualPad dpadMode "$DPad" doesn\'t exists.';
			for (buttonData in MobileData.dpadModes.get(DPad).buttons) {
				Reflect.setField(this, buttonData.button,
					createButton(buttonData.x, buttonData.y, buttonData.width, buttonData.height, buttonData.graphic,
						CoolUtil.colorFromString(buttonData.color), Reflect.getProperty(this, buttonData.button).IDs));
				add(Reflect.field(this, buttonData.button));
			}
		}

		if (Action != "NONE") {
			if (!MobileData.actionModes.exists(Action))
				throw 'The virtualPad actionMode "$Action" doesn\'t exists.';
			for (buttonData in MobileData.actionModes.get(Action).buttons) {
				Reflect.setField(this, buttonData.button,
					createButton(buttonData.x, buttonData.y, buttonData.width, buttonData.height, buttonData.graphic,
						CoolUtil.colorFromString(buttonData.color), Reflect.getProperty(this, buttonData.button).IDs));
				add(Reflect.field(this, buttonData.button));
			}
		}

		switch (Extra) {
			case SINGLE:
				add(buttonExtra = createButton(0, FlxG.height - 137, 132, 125, 's', 0xFF0066FF));
				setExtrasPos();
			case DOUBLE:
				add(buttonExtra = createButton(0, FlxG.height - 137, 132, 125, 's', 0xFF0066FF));
				add(buttonExtra2 = createButton(FlxG.width - 132, FlxG.height - 137, 132, 125, 'g', 0xA6FF00));
				setExtrasPos();
			case NONE: // nothing
		}

		scrollFactor.set();
		updateTrackedButtons();
	}

	override function update(elapsed:Float)
	{
		forEachAlive((button:FlxButton) -> {
			if(!button.isOnScreen(button.camera))
			{
				if(button.x < 0)
					button.x = 0;
				if(button.y < 0)
					button.y = 0;
				if(button.x > FlxG.width - button.frameWidth)
					button.x = FlxG.width - button.frameWidth;
				if(button.y > FlxG.height - button.frameHeight)
					button.y = FlxG.height - button.frameHeight;
			}
		});
		super.update(elapsed);
	}

	override public function destroy() {
		super.destroy();

		for (field in Reflect.fields(this))
			if (Std.isOfType(Reflect.field(this, field), FlxButton))
				Reflect.setField(this, field, FlxDestroyUtil.destroy(Reflect.field(this, field)));
	}

	public function setExtrasDefaultPos() {
		var int:Int = 0;

		if (MobileControls.save.data.extraData == null)
			MobileControls.save.data.extraData = new Array();

		for (button in Reflect.fields(this)) {
			if (button.toLowerCase().contains('extra') && Std.isOfType(Reflect.field(this, button), FlxButton)) {
				var daButton = Reflect.field(this, button);
				if (MobileControls.save.data.extraData[int] == null)
					MobileControls.save.data.extraData.push(FlxPoint.get(daButton.x, daButton.y));
				else
					MobileControls.save.data.extraData[int] = FlxPoint.get(daButton.x, daButton.y);
				++int;
			}
		}
		MobileControls.save.flush();
	}

	public function setExtrasPos() {
		var int:Int = 0;
		if (MobileControls.save.data.extraData == null)
			return;

		for (button in Reflect.fields(this)) {
			if (button.toLowerCase().contains('extra') && Std.isOfType(Reflect.field(this, button), FlxButton)) {
				var daButton = Reflect.field(this, button);
				daButton.x = MobileControls.save.data.extraData[int].x;
				daButton.y = MobileControls.save.data.extraData[int].y;
				int++;
			}
		}
	}

	private function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, ?Color:Int = 0xFFFFFF, ?IDs:Array<FlxMobileInputID>):FlxButton {
		var button = new FlxButton(X, Y, IDs);
		button.frames = FlxTileFrames.fromFrame(getSparrowAtlas('mobile/images/virtualpad').getByName(Graphic), FlxPoint.get(Width, Height));
		button.bounds.makeGraphic(Std.int(button.frameWidth - 50), Std.int(button.frameHeight - 50), FlxColor.TRANSPARENT);
		button.centerBounds();
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.moves = false;
		button.scrollFactor.set();
		button.color = Color;
		button.antialiasing = ClientPrefs.data.antialiasing;
		button.tag = Graphic.toUpperCase();
		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end
		return button;
	}

	function getSparrowAtlas(key:String):FlxAtlasFrames {
		var file:String = '';
		var bitmap:BitmapData = null;
		#if MODS_ALLOWED
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			file = haxe.io.Path.join([Mods.currentModDirectory, key]);
		if (Paths.currentTrackedAssets.exists(file)) {
			Paths.localTrackedAssets.push(file);
			bitmap = Paths.currentTrackedAssets.get(file).bitmap;
		} else if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end
		{
			file = Paths.getSharedPath(key + '.png');
			if (Paths.currentTrackedAssets.exists(file)) {
				Paths.localTrackedAssets.push(file);
				bitmap = Paths.currentTrackedAssets.get(file).bitmap;
			} else if (Assets.exists(file, IMAGE))
				bitmap = Assets.getBitmapData(file);
		}

		var imageLoaded:FlxGraphic = Paths.cacheBitmap(file, bitmap, false);
		#if MODS_ALLOWED
		var xml:String = '';
		if (FileSystem.exists(Paths.modsXml(key)))
			xml = Paths.modsXml(key);
		else if (FileSystem.exists(Path.withoutExtension(file) + '.xml'))
			xml = Path.withoutExtension(file) + '.xml';

		return FlxAtlasFrames.fromSparrow(imageLoaded, File.getContent(xml));
		#else
		return FlxAtlasFrames.fromSparrow(imageLoaded, Paths.getPath('$key.xml'));
		#end
	}
}
