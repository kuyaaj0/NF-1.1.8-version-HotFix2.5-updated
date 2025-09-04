package backend.state.freeplayState;

import sys.thread.Thread;
import sys.thread.FixedThreadPool;
import sys.thread.Mutex;

import thread.ThreadEvent;

import Lambda;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import sys.FileSystem;

typedef DataPrepare = {
    name:String,
    color:Array<Int>,
    icon:String,
    modPath:String
}

typedef RectData = {
    path:String,
    color:Array<Int>,
    modPath:String
}

//haxe用线程加载太不稳定了，所以我放弃了--狐月影
class PreThreadLoad {
    public var loadFinish:Bool = false;

    public var maxCount:Int = 0;
    public var count:Int = 0;

    ///////////////////////////////////////////////////////

    var loadRect:Array<RectData> = [];
    var loadIcon:Array<String> = [];

    var rectPool:FixedThreadPool;
    var iconPool:FixedThreadPool;
    
    var threadCount = 0;
    var countMutex:Mutex;

    public function new() {
        countMutex = new Mutex();
    }

    var rectPre:Map<String, RectData> = [];
    var iconPre:Array<String> = [];
    public function start(data:Array<DataPrepare>) {
        ThreadEvent.create(function() {
            for (mem in data) {
                if (mem.modPath != '') mem.modPath = mem.modPath + '/';

                var rd:RectData = pathCheck(mem);
                if (!rectPre.exists(rd.modPath + ' ' + rd.path + ' ' + rd.color))
                    rectPre.set(rd.modPath + ' ' + rd.path + ' ' + rd.color, rd);

                var id:String = iconCheck(mem);
                if (!iconPre.contains(id))
                    iconPre.push(id);
            }
            maxCount = Std.int(Lambda.count(rectPre) + iconPre.length);
            threadCount = CoolUtil.getCPUThreadsCount() - 1;

            for (key => value in rectPre) {
                loadRect.push(value);
            }
            loadIcon = iconPre;
        }, load);
    }

    function pathCheck(rect:DataPrepare):RectData {
        var filesLoad = 'data/' + rect.name + '/bg';
        if (!FileSystem.exists(Paths.mods(rect.modPath + filesLoad + '.png'))) 
            filesLoad = 'images/menuDesat';
            
        return {path:Paths.mods(rect.modPath + filesLoad), color:rect.color, modPath:rect.modPath};
    }

    function iconCheck(rect:DataPrepare):String {
        var name:String = 'images/icons/' + rect.icon;
        if (!FileSystem.exists(Paths.mods(rect.modPath + name + '.png'))) 
            name = 'images/icons/icon-' + rect.icon;
        if (!FileSystem.exists(Paths.mods(rect.modPath + name + '.png'))) 
            name = 'images/icons/icon-face';
        return Paths.mods(rect.modPath + name);
    }

    function load() {
        Sys.sleep(0.005); //先释放下线程

        lineShape = null;
        var light = new Rect(0, 0, 560, SongRect.fixHeight, SongRect.fixHeight / 2, SongRect.fixHeight / 2, FlxColor.WHITE, 1, 1, EngineSet.mainColor);
        drawLine(light.pixels);

        var rectThread:Int = Math.ceil(threadCount * 0.75);
        var iconThread:Int = Std.int(Math.max(1, threadCount - rectThread));

        rectPool = new FixedThreadPool(rectThread);
        iconPool = new FixedThreadPool(iconThread);

        for (i in 0...loadRect.length) {
            var rectData = loadRect[i];
            rectPool.run(() -> {
                var newGraphic:FlxGraphic = Paths.cacheImage(rectData.path, null, false, true);
                if (newGraphic == null) {

                    trace('load rect: ' + rectData.path + ' fail');
                    return;
                }
                
                var matrix:Matrix = new Matrix();
                var scale:Float = light.width / newGraphic.width;
                if (light.height / newGraphic.height > scale)
                    scale = light.height / newGraphic.height;
                matrix.scale(scale, scale);
                matrix.translate(-(newGraphic.width * scale - light.width) / 2, -(newGraphic.height * scale - light.height) / 2);
                

                var resizedBitmapData:BitmapData = new BitmapData(Std.int(light.width), Std.int(light.height), true, 0x00000000);
                resizedBitmapData.draw(newGraphic.bitmap, matrix);

                
                if (rectData.path.indexOf('menuDesat') != -1)
                {
                    var colorTransform:ColorTransform = new ColorTransform();
                    var color:FlxColor = FlxColor.fromRGB(rectData.color[0], rectData.color[1], rectData.color[2]);
                    colorTransform.redMultiplier = color.redFloat;
                    colorTransform.greenMultiplier = color.greenFloat;
                    colorTransform.blueMultiplier = color.blueFloat;
                    
                    resizedBitmapData.colorTransform(new Rectangle(0, 0, resizedBitmapData.width, resizedBitmapData.height), colorTransform);
                }
                
                drawLine(resizedBitmapData);
                
                resizedBitmapData.copyChannel(light.pixels, new Rectangle(0, 0, light.width, light.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);

                newGraphic = FlxGraphic.fromBitmapData(resizedBitmapData);
                
                
                countMutex.acquire();
                count++;
                if (count >= maxCount) {
                    loadFinish = true;
                }
                trace('load rect: ' + rectData.path + ' finish');
                countMutex.release();
            });
        }

        for (i in 0...loadIcon.length) {
            var iconPath = loadIcon[i];
            iconPool.run(() -> {
                Paths.cacheImage(iconPath, null, false, true);
                
                countMutex.acquire();
                count++;
                
                if (count >= maxCount) {
                    loadFinish = true;
                }
                trace('load icon: ' + iconPath + ' finish');
                countMutex.release();
            });
        }
    }

    static var lineShape:Shape = null;
    function drawLine(bitmap:BitmapData)
	{
        if (lineShape == null) {
            lineShape = new Shape();
            var lineSize:Int = 2;
            var round:Int = Std.int(bitmap.height / 2);
            lineShape.graphics.beginFill(EngineSet.mainColor);
            lineShape.graphics.lineStyle(1, EngineSet.mainColor, 1);
            lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, round, round);
            lineShape.graphics.lineStyle(0, 0, 0);
            lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, round - lineSize * 2, round - lineSize * 2);
            lineShape.graphics.endFill();
        }

		bitmap.draw(lineShape);
	}
}