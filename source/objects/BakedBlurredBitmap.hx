package objects;

import openfl.filters.BitmapFilter;
import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.filters.BlurFilter;
import lime.math.Rectangle as LimeRect;

class BakedBlurredBitmap
{
	public static function fromBitmapData(bitmap:BitmapData, blurX:Float = 4, blurY:Float = 4, blurQuality:Int = 1):BitmapData
	{
		var blurFilter:BlurFilter = new BlurFilter(blurX * 1.5, blurY * 1.5, blurQuality);
		var rect = new Rectangle(0, 0, bitmap.width, bitmap.height);
		var point = new Point(0, 0);

		bitmap.applyFilter(bitmap, rect, point, blurFilter);
		// var bakedBitmap = BitmapData.fromBytes(bitmap.encode(rect, new PNGEncoderOptions()));
		// bitmap.dispose();
		return bitmap;
	}

	public static function getGameWindowBlur(blurX:Float = 4, blurY:Float = 4, blurQuality:Int = 1, applyFilters:Bool = true):BitmapData
	{
		var fpsVisibility:Bool = true;

		if (Main.fpsVar != null)
		{
			fpsVisibility = Main.fpsVar.visible;
			Main.fpsVar.visible = false;
            Main.fpsVar.invalidate();
		}

        FlxG.stage.invalidate();
        
		var bitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0);
		var bitmapDataImage = BitmapData.fromImage(FlxG.stage.window.readPixels(new LimeRect(FlxG.game.x, FlxG.game.y, FlxG.game.width, FlxG.game.height)));
        var rect = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
		var point = new Point(0, 0);
		bitmapData.draw(bitmapDataImage);
		bitmapDataImage.dispose();
        
        // kinda shit but idk any better way
        // one of the falws of this is that it won't capture the shaders that are applied onto FlxSprite manually
        var filters:Array<BitmapFilter> = [];
        // if (applyFilters)
        // {
        //     for (camera in FlxG.cameras.list)
        //         if (camera.filtersEnabled && camera.filters != null)
        //             for (filter in camera.filters)
        //                 filters.push(filter);

		//     if (FlxG.game.filtersEnabled)
        //         filters = filters.concat(FlxG.game.filters);            
        // }

        filters.push(new BlurFilter(blurX * 1.5, blurY * 1.5, blurQuality));

        for (filter in filters)
        {
            bitmapData.applyFilter(bitmapData, rect, point, filter);
        }
        

		// File.saveBytes('bitmap blur.png', bitmapData.encode(bitmapData.rect, new PNGEncoderOptions()));

		if (Main.fpsVar != null)
			Main.fpsVar.visible = fpsVisibility;

		return bitmapData;
	}
}
