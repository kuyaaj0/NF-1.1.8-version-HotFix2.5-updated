package developer.display;

class Watermark extends Bitmap
{
	public function new(x:Float = 10, y:Float = 10, Alpha:Float = 0.5)
	{
		super();

		var image:String = Paths.modFolders('images/menuExtend/Others/watermark.png');

		bitmapData = BitmapData.fromFile(image);

		this.x = x;
		this.y = y;
		this.alpha = Alpha;
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		this.x = 5;
		this.y = Lib.current.stage.stageHeight - 5 - ClientPrefs.data.WatermarkScale * bitmapData.height;
	}
}

class FPSBG extends Bitmap
{
	public function new(Width:Int = 140, Height:Int = 50, Alpha:Float = 0.3)
	{
		super();

		var color:FlxColor = FlxColor.fromRGB(124, 118, 146, 255);

		var shape:Shape = new Shape();
		shape.graphics.beginFill(color);
		shape.graphics.drawRoundRect(0, 0, Width, Height, 10, 10);
		shape.graphics.endFill();

		var BitmapData:BitmapData = new BitmapData(Width, Height, 0x00FFFFFF);
		BitmapData.draw(shape);

		this.bitmapData = BitmapData;
		this.alpha = Alpha;
	} // 说真的，haxe怎么写个贴图在flxgame层这么麻烦
}
