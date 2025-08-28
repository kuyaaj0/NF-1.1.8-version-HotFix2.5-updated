package backend;

import backend.extraKeys.ExtraKeysHandler.EKNoteColor;
import flixel.util.FlxSave;
import openfl.utils.Assets;
import flixel.FlxBasic;
import flixel.FlxObject;

#if cpp
@:cppFileCode('#include <thread>')
#end

class CoolUtil
{
	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		var formatted:Array<String> = path.split(':'); // prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length - 1];
		if (FileSystem.exists(path))
			daList = File.getContent(path);
		#else
		if (Assets.exists(path))
			daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if (color.startsWith('0x'))
			color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null)
			colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	inline public static function getComboColor(sprite:flixel.FlxSprite):Int
	{
		var maxSaturation:Float = 0;
		var maxSaturationColor:Int = 0xFFFFFFFF;
		var blackPixelCount:Int = 0;
		var totalPixelCount:Int = 0;
		
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					totalPixelCount++;
					
					if (colorOfThisPixel == FlxColor.BLACK)
					{
						blackPixelCount++;
						continue;
					}
					
					// 计算饱和度
					var flxColor = FlxColor.fromInt(colorOfThisPixel);
					var r = flxColor.red / 255.0;
					var g = flxColor.green / 255.0;
					var b = flxColor.blue / 255.0;
					
					var max = Math.max(Math.max(r, g), b);
					var min = Math.min(Math.min(r, g), b);
					var saturation = max == 0 ? 0 : (max - min) / max;
					
					// 找到饱和度最高的颜色
					if (saturation > maxSaturation)
					{
						maxSaturation = saturation;
						maxSaturationColor = colorOfThisPixel;
					}
				}
			}
		}
		
		// 如果黑色像素占50%以上，返回黑色，目前不用了这个功能
		//if (blackPixelCount >= totalPixelCount * 0.5)
			//return 0xFF000000;
		
		return maxSaturationColor;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
			dumbArray.push(i);

		return dumbArray;
	}

	inline public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/**
	 * 递归读取指定目录及其子目录中的所有文件路径
	 * @param directory 要搜索的目录路径
	 * @return Array<String> 包含所有文件路径的数组
	 */
	public static function readDirectoryRecursive(directory:String, stayRoot:Bool = false):Array<String>
	{
		var filePaths:Array<String> = [];
		#if sys
		if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
		{
			for (file in FileSystem.readDirectory(directory))
			{
				var path:String = haxe.io.Path.addTrailingSlash(directory) + file;
				if (FileSystem.isDirectory(path))
				{
					// 递归处理子文件夹
					filePaths = filePaths.concat(readDirectoryRecursive(path));
				}
				else
				{
					// 添加文件路径
					filePaths.push(path);
				}
			}
		}
		#end
		return filePaths;
	}

	inline public static function openFolder(folder:String, absolute:Bool = false)
	{
		#if sys
		if (!absolute)
			folder = Sys.getCwd() + '$folder';

		folder = folder.replace('/', '\\');
		if (folder.endsWith('/'))
			folder.substr(0, folder.length - 1);

		#if linux
		var command:String = '/usr/bin/xdg-open';
		#else
		var command:String = 'explorer.exe';
		#end
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.log.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String
	{
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}

	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch (border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}

	public static function getArrowRGB(path:String = 'arrowRGB.json', defaultArrowRGB:Array<EKNoteColor>):ArrowRGBSavedData
	{
		var result:ArrowRGBSavedData;
		var content:String = '';
		#if sys
		if (FileSystem.exists(path))
			content = File.getContent(path);
		else
		{
			// create a default ArrowRGBSavedData
			var colorsToUse = [];
			for (color in defaultArrowRGB)
			{
				colorsToUse.push(color);
			}

			var defaultSaveARGB:ArrowRGBSavedData = new ArrowRGBSavedData(colorsToUse);

			// write it
			var writer = new json2object.JsonWriter<ArrowRGBSavedData>();
			content = writer.write(defaultSaveARGB, '    ');
			File.saveContent(path, content);

			trace(path + ' (Color save) didn\'t exist. Written.');
		}
		#else
		if (Assets.exists(path))
			content = Assets.getText(path);
		#end

		var parser = new json2object.JsonParser<ArrowRGBSavedData>();
		parser.fromJson(content);
		result = parser.value;

		// automatically (?) sets colors of notes that have no colors
		for (i in 0...ExtraKeysHandler.instance.data.maxKeys + 1)
		{
			// colors dont exist

			// cannot take the previous approach since
			// this is indexed and not per mania
			if (result.colors[i] == null)
			{
				result.colors[i] = defaultArrowRGB[i];
			}
		}

		return result;
	}

	/**
	 * Replacement for `FlxG.mouse.overlaps` because it's currently broken when using a camera with a different position or size.
	 * It will be fixed eventually by HaxeFlixel v5.4.0.
	 * 
	 * @param 	objectOrGroup The object or group being tested.
	 * @param 	camera Specify which game camera you want. If null getScreenPosition() will just grab the first global camera.
	 * @return 	Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	inline public static function mouseOverlaps(objectOrGroup:FlxBasic, ?camera:FlxCamera):Bool
	{
		var result:Bool = false;

		final group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null)
		{
			group.forEachExists(function(basic:FlxBasic)
			{
				if (mouseOverlaps(basic, camera))
				{
					result = true;
					return;
				}
			});
		}
		else
		{
			final point = FlxG.mouse.getWorldPosition(camera, FlxPoint.weak());
			final object:FlxObject = cast objectOrGroup;
			result = object.overlapsPoint(point, true, camera);
		}

		return result;
	}

	#if cpp
    @:functionCode('
        return std::thread::hardware_concurrency();
    ')
	#end
    public static function getCPUThreadsCount():Int
    {
        return 1;
    }
}

class ArrowRGBSavedData {
	public var colors:Array<EKNoteColor>;

	public function new(colors){
		this.colors = colors;
	}
}

