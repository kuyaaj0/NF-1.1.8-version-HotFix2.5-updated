package shapeEx;

class Rect extends FlxSprite
{
	public var mainRound:Float;
	public function new(X:Float = 0, Y:Float = 0, width:Float = 0, height:Float = 0, roundWidth:Float = 0, roundHeight:Float = 0,
			Color:FlxColor = FlxColor.WHITE, ?Alpha:Float = 1, ?lineStyle:Int = 0, ?lineColor:FlxColor = FlxColor.WHITE)
	{
		super(X, Y);

		this.mainRound = roundWidth;

		if (Cache.currentTrackedFrames.get('rect-w'+width+'-h:'+height+'-rw:'+roundWidth+'-rh:'+roundHeight) == null) addCache(width, height, roundWidth, roundHeight, lineStyle, lineColor);
		frames = Cache.currentTrackedFrames.get('rect-w'+width+'-h:'+height+'-rw:'+roundWidth+'-rh:'+roundHeight);
		antialiasing = ClientPrefs.data.antialiasing;
		color = Color;
		alpha = Alpha;
	}

	function drawRect(width:Float = 0, height:Float = 0, roundWidth:Float = 0, roundHeight:Float = 0, lineStyle:Int, lineColor:FlxColor):BitmapData
	{
		var shape:Shape = new Shape();

		shape.graphics.beginFill(0xFFFFFF);
		shape.graphics.drawRoundRect(0, 0, Std.int(width), Std.int(height), roundWidth, roundHeight);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Std.int(width), Std.int(height), true, 0);
		bitmap.draw(shape);
		if (lineStyle > 0) drawLine(bitmap, lineStyle, lineColor);
		return bitmap;
	}

	function addCache(width:Float = 0, height:Float = 0, roundWidth:Float = 0, roundHeight:Float = 0, lineStyle:Int, lineColor:FlxColor) {
		var spr:FlxSprite = new FlxSprite();
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(drawRect(width, height, roundWidth, roundHeight, lineStyle, lineColor));
		spr.loadGraphic(newGraphic);

		Cache.currentTrackedFrames.set('rect-w'+width+'-h:'+height+'-rw:'+roundWidth+'-rh:'+roundHeight, spr.frames);
	}

	static var lineShape:Shape = null;
    function drawLine(bitmap:BitmapData, lineStyle:Int, lineColor:FlxColor)
	{
        if (lineShape == null) {
            lineShape = new Shape();
            var lineSize:Int = lineStyle;
            lineShape.graphics.beginFill(lineColor);
            lineShape.graphics.lineStyle(1, lineColor, 1);
            lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, 20, 20);
            lineShape.graphics.lineStyle(0, 0, 0);
            lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, 20, 20);
            lineShape.graphics.endFill();
        }

		bitmap.draw(lineShape);
	}
}
