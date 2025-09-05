package objects.state.freeplayState.song;

class DiffRect extends FlxSpriteGroup {
    public var light:Rect;
    private var bg:FlxSprite;
    public var diffRectArray:Array<DiffRect> = [];
    private var icon:HealthIcon;
	private var songName:FlxText;
	private var musican:FlxText;

    /////////////////////////////////////////////////////////////////////

    static public var fixHeight:Int = #if mobile 40 #else 30 #end;
    private var filePath:String = 'song/';

    public var id:Int = 0;
    public var currect:Int = 0;
    
    public var onSelectChange:String->Void;
    public function new(songNameSt:String, songChar:String, songMusican:String, songCharter:Array<String>, songColor:Array<Int>) {
        super(x, y);

        light = new Rect(0, 0, 560, 60, 20, 20, FlxColor.WHITE, 1, 1, EngineSet.mainColor);
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);

        var extraLoad:Bool = false;
        var filesLoad = 'data/' + songNameSt + '/bg';
        if (FileSystem.exists(Paths.modFolders(filesLoad + '.png'))) {
            extraLoad = true;
        } else {
            filesLoad = 'menuDesat';
            extraLoad = false;
        }
        if (Cache.currentTrackedFrames.get('freeplay-song-' + Mods.currentModDirectory + '-' + filesLoad + 'color: r:' + songColor[0] + ' g:' + songColor[1] + ' b:' + songColor[2]) == null) addBGCache(filesLoad, extraLoad, songColor);

        bg = new FlxSprite();
        bg.frames = Cache.currentTrackedFrames.get('freeplay-song-' + Mods.currentModDirectory + '-' + filesLoad + 'color: r:' + songColor[0] + ' g:' + songColor[1] + ' b:' + songColor[2]);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        icon = new HealthIcon(songChar, false, false);
		icon.setGraphicSize(Std.int(bg.height * 0.8));
		icon.x += bg.height / 2 - icon.height / 2;
		icon.y += bg.height / 2 - icon.height / 2;
		icon.updateHitbox();
		add(icon);

        songName = new FlxText(0, 0, 0, songNameSt, 20);
		songName.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(light.height * 0.3), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        songName.borderStyle = NONE;
		songName.antialiasing = ClientPrefs.data.antialiasing;
		songName.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		//songName.y = light.height * 0.05;
		add(songName);

        musican = new FlxText(0, 0, 0, songMusican, 20);
		musican.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(light.height * 0.2), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        musican.borderStyle = NONE;
		musican.antialiasing = ClientPrefs.data.antialiasing;
		musican.x += bg.height / 2 - icon.height / 2 + icon.width * 1.1;
		musican.y += songName.textField.textHeight;
		add(musican);
    }

    function addBGCache(filesLoad:String, extraLoad:Bool, songColor:Array<Int>) {
		var spr = new FlxSprite(0, 0).loadGraphic(Paths.image(filesLoad, null, false, extraLoad));

        var matrix:Matrix = new Matrix();
        var scale:Float = light.width / spr.width;
        if (light.height / spr.height > scale)
            scale = light.height / spr.height;
        matrix.scale(scale, scale);
        matrix.translate(-(spr.width * scale - light.width) / 2, -(spr.height * scale - light.height) / 2);

        var resizedBitmapData:BitmapData = new BitmapData(Std.int(light.width), Std.int(light.height), true, 0x00000000);
        resizedBitmapData.draw(spr.pixels, matrix);
        
        if (!extraLoad)
        {
            var colorTransform:ColorTransform = new ColorTransform();
            var color:FlxColor = FlxColor.fromRGB(songColor[0], songColor[1], songColor[2]);
            colorTransform.redMultiplier = color.redFloat;
            colorTransform.greenMultiplier = color.greenFloat;
            colorTransform.blueMultiplier = color.blueFloat;
            
            resizedBitmapData.colorTransform(new Rectangle(0, 0, resizedBitmapData.width, resizedBitmapData.height), colorTransform);
        }

        drawLine(resizedBitmapData);
        
        resizedBitmapData.copyChannel(light.pixels, new Rectangle(0, 0, light.width, light.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

        spr.loadGraphic(resizedBitmapData);

        Cache.currentTrackedFrames.set('freeplay-song-' + Mods.currentModDirectory + '-' + filesLoad + 'color: r:' + songColor[0] + ' g:' + songColor[1] + ' b:' + songColor[2], spr.frames);

        var mainBGcache = new FlxSprite(0, 0).loadGraphic(Paths.image(filesLoad, null, false, extraLoad));
        Cache.currentTrackedFrames.set('freeplay-bg-' + Mods.currentModDirectory + '-' + filesLoad, mainBGcache.frames);//预加载大界面的图像
	}

    static var lineShape:Shape = null;
    function drawLine(bitmap:BitmapData)
	{
        if (lineShape == null) {
            lineShape = new Shape();
            var lineSize:Int = 1;
            lineShape.graphics.beginFill(EngineSet.mainColor);
            lineShape.graphics.lineStyle(1, EngineSet.mainColor, 1);
            lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, 20, 20);
            lineShape.graphics.lineStyle(0, 0, 0);
            lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, 20, 20);
            lineShape.graphics.endFill();
        }

		bitmap.draw(lineShape);
	}

    public var onFocus(default, set):Bool = true;
    override function update(elapsed:Float)
	{
		super.update(elapsed);

        calcX();

        
	}

    private function set_onFocus(value:Bool):Bool
	{
		if (onFocus == value)
			return onFocus;
		onFocus = value;
		if (onFocus)
		{
			addDiffRect();
		} else {
			
		}
		return value;
	}

    public function addDiffRect() {
        
    }

    ///////////////////////////////////////////////////////////////////////

    public var moveX:Float = 0;
    public var chooseX:Float = 0;
    public var diffX:Float = 0;
    public function calcX() {
        moveX = Math.pow(Math.abs(this.y + this.light.height / 2 - FlxG.height / 2) / (FlxG.height / 2) * 10, 1.9);
        this.x = FlxG.width - this.light.width + 70 + moveX + chooseX + diffX;
    }

    public var moveY:Float = 0;
    public var diffY:Float = 0;
}