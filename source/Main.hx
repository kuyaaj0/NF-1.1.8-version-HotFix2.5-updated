package;

import objects.screen.Graphics;
import objects.screen.FPS;
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.system.System;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.events.KeyboardEvent;
import lime.system.System as LimeSystem;
import lime.app.Application;
import states.TitleState;
import states.backend.InitState;
import states.backend.PassState;
import mobile.backend.Data;
import backend.extraKeys.ExtraKeysHandler;

import developer.console.TraceInterceptor;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end
#if desktop
import backend.device.ALSoftConfig;
import haxe.ui.Toolkit;
#end
#if hl
import hl.Api;
#end
#if linux
import lime.graphics.Image;

@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

import sys.Http;
import sys.thread.Thread;



class Main extends Sprite
{
	private static var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: #if mobile PassState #else InitState #end, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPS;
	public static var watermark:Watermark;

	#if mobile
	public static final platform:String = "Phones";
	#else
	public static final platform:String = "PCs";
	#end

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
	    TraceInterceptor.init();
		#if (cpp && windows)
		backend.device.Native.fixScaling();
		backend.device.Native.setWindowDarkMode(true, true);
		#end
		
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);

		//cpp.vm.Gc.enable(true);
		//cpp.vm.Gc.run(true);  
		#end
	}
	
	public function new()
	{
		super();
		#if android
		SUtil.doPermissionsShit();
		#end
		mobile.backend.CrashHandler.init();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
		#end
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		Toolkit.init();

		#if LUA_ALLOWED llua.Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();

		ExtraKeysHandler.instance = new ExtraKeysHandler();
		ClientPrefs.loadDefaultKeys();

		#if mobile
		#if android
		if (!FileSystem.exists(AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file')))
			FileSystem.createDirectory(AndroidEnvironment.getExternalStorageDirectory() + '/.' + Application.current.meta.get('file'));
		#end
		Sys.setCwd(SUtil.getStorageDirectory());
		#end
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		addChild(new FlxGame(#if (openfl >= "9.2.0") 1280, 720 #else game.width, game.height #end, game.initialState, #if (flixel < "5.0.0") game.zoom, #end
			game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		Achievements.load();

		fpsVar = new FPS(5, 5);
		addChild(fpsVar);
		if (fpsVar != null)
		{
			fpsVar.scaleX = fpsVar.scaleY = ClientPrefs.data.FPSScale;
			fpsVar.visible = ClientPrefs.data.showFPS;
		}

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		switch (ClientPrefs.data.gameQuality)
		{
			case 0:
				FlxG.game.stage.quality = openfl.display.StageQuality.LOW;
			case 1:
				FlxG.game.stage.quality = openfl.display.StageQuality.HIGH;
			case 2:
				FlxG.game.stage.quality = openfl.display.StageQuality.MEDIUM;
			case 3:
				FlxG.game.stage.quality = openfl.display.StageQuality.BEST;
		}

		#if mobile
		FlxG.fullscreen = true;
		#end

		var image:String = Paths.modFolders('images/menuExtend/Others/watermark.png');

		if (FileSystem.exists(image))
		{
			if (watermark != null)
				removeChild(watermark);
			watermark = new Watermark(5, Lib.current.stage.stageHeight - 5, 0.4);
			addChild(watermark);
			watermark.y -= watermark.bitmapData.height;
		}
		if (watermark != null)
		{
			watermark.scaleX = watermark.scaleY = ClientPrefs.data.WatermarkScale;
			watermark.y += (1 - ClientPrefs.data.WatermarkScale) * watermark.bitmapData.height;
			watermark.visible = ClientPrefs.data.showWatermark;
		}

		var effect = new MouseEffect();
		addChild(effect);

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if desktop FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, toggleFullScreen); #end

		#if android FlxG.android.preventDefaultKeys = [BACK]; #end

		#if mobile
		LimeSystem.allowScreenTimeout = ClientPrefs.data.screensaver;
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		#if mobile
		LimeSystem.allowScreenTimeout = ClientPrefs.data.screensaver;
		#end
		Data.setup();

		if (ClientPrefs.data.gcFreeZone)
			cpp.NativeGc.enterGCFreeZone;
		
		// shader coords fix
		FlxG.signals.gameResized.add(function(w, h)
		{
			if (FlxG.cameras != null)
			{
				for (cam in FlxG.cameras.list)
				{
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);
				}
			}

			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	function toggleFullScreen(event:KeyboardEvent)
	{
		if (Controls.instance.justReleased('fullscreen'))
			FlxG.fullscreen = !FlxG.fullscreen;
	}

	static public var type:Bool = ClientPrefs.data.gcFreeZone;
	static public function GcZoneChange()
	{
		if (type == true)
		{
			cpp.NativeGc.exitGCFreeZone;
			type = false;
		}
		else
		{
			cpp.NativeGc.enterGCFreeZone;
			type = true;
		}
	}
}
