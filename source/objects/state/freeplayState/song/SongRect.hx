package objects.state.freeplayState.song;

import objects.HealthIcon;

class CollectionButton extends FlxSpriteGroup {
    static public var filePath:String = 'song/';
    var light:FlxSprite;
    var mask:FlxSprite;
    var bg:FlxSprite;

    var icon:HealthIcon;
	var songName:FlxText;
	var musican:FlxText;
    
    public var onSelectChange:String->Void;

    public function new(songNameSt:String, songChar:String, songmusican:String, songColor:Array<Int>) {
        super(x, y);

        if (Cache.currentTrackedFrames.get('freeplay-song-Light') == null) addLightCache();
        light = new FlxSprite();
        light.frames = Cache.currentTrackedFrames.get('freeplay-song-Light');
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);

        if (Cache.currentTrackedFrames.get('freeplay-song-Mask') == null) addMaskCache();   
        mask = new FlxSprite();
        mask.frames = Cache.currentTrackedFrames.get('freeplay-song-Mask');

        var extraLoad:Bool = false;
        var filesLoad = 'data/' + songNameSt + '/bg';
        if (FileSystem.exists(Paths.modFolders(filesLoad + '.png'))) {
            extraLoad = true;
        } else {
            filesLoad = 'menuDesat';
            extraLoad = false;
        }

        if (Cache.currentTrackedFrames.get('freeplay-song-' + Mods.currentModDirectory + '-' + filesLoad) == null) {
            var spr = new FlxSprite(0, 0).loadGraphic(Paths.image(filesLoad, null, false, extraLoad));

            var matrix:Matrix = new Matrix();
            var scale:Float = mask.width / spr.width;
            if (mask.height / spr.height > scale)
                scale = mask.height / spr.height;
            matrix.scale(scale, scale);
            matrix.translate(-(spr.width * data - mask.width) / 2, -(spr.height * data - mask.height) / 2);

            var resizedBitmapData:BitmapData = new BitmapData(Std.int(mask.width), Std.int(mask.height), true, 0x00000000);
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
            
            resizedBitmapData.copyChannel(mask.pixels, new Rectangle(0, 0, mask.width, mask.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

            spr.loadGraphic(resizedBitmapData);

            Cache.currentTrackedFrames.set('freeplay-song-' + Mods.currentModDirectory + '-' + filesLoad, spr.frame);

            var mainBGcache = new FlxSprite(0, 0).loadGraphic(Paths.image(filesLoad, null, false, extraLoad));
            Cache.currentTrackedFrames.set('freeplay-bg-' + Mods.currentModDirectory + '-' + filesLoad, mainBGcache.frame);//预加载大界面的图像
        }

        bg = new FlxSprite();
        bg.frame = Cache.currentTrackedFrames.get('freeplay-song-' + Mods.currentModDirectory + '-' + filesLoad);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        icon = new HealthIcon(songChar, false, false);
		icon.setGraphicSize(Std.int(bg.height * 0.8));
		icon.x += 60 - icon.width / 2;
		icon.y += bg.height / 2 - icon.height / 2;
		icon.updateHitbox();
		add(icon);
    }

    function addMaskCache() {
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + filePath + 'mask'));
		spr.loadGraphic(newGraphic);

		Cache.currentTrackedFrames.set('freeplay-song-Mask', spr.frames);
	}

    function addLightCache() {
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + filePath + 'light'));
		spr.loadGraphic(newGraphic);

		Cache.currentTrackedFrames.set('freeplay-song-Light', spr.frames);
	}
}