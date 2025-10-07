#if LUA_ALLOWED
package scripts.lua;

import openfl.Lib;
import openfl.utils.Assets;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end
import objects.Character;
import scripts.LuaUtils;
import scripts.LuaUtils.LuaTweenOptions;
#if SScript
import scripts.HScript;
#end
import states.LoadingState;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import haxe.Json;

class ProloadLua
{
	public var lua:State = null;
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var modFolder:String = null;
	public var closed:Bool = false;

	#if HSCRIPT_ALLOWED
	public var hscript:HScript = null;
	public var hscriptBase:HScriptBase = null;
	#end

	public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();

	public static var customFunctions:Map<String, Dynamic> = new Map<String, Dynamic>();

	public function new(scriptName:String)
	{
		#if LUA_ALLOWED
		var times:Float = Date.now().getTime();
		lua = LuaL.newstate();
		LuaL.openlibs(lua);

		this.scriptName = scriptName.trim();
		LoadingState.luaArray.push(this);

		var myFolder:Array<String> = this.scriptName.split('/');
		#if MODS_ALLOWED
		if (myFolder[0] + '/' == Paths.mods()
			&& (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
			this.modFolder = myFolder[1];
		#end

		set("addLuaScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false)
		{ // would be dope asf.
			var foundScript:String = findScript(luaFile);
			if (foundScript != null)
			{
				if (!ignoreAlreadyRunning)
					for (luaInstance in LoadingState.luaArray)
						if (luaInstance.scriptName == foundScript)
						{
							luaTrace('addLuaScript: The script "' + foundScript + '" is already running!');
							return;
						}

				LoadingState.startScriptNamed(foundScript);
				return;
			}
			luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
		});
		/*
			set("addHScript", function(luaFile:String, ?ignoreAlreadyRunning:Bool = false) {
				#if HSCRIPT_ALLOWED
				var foundScript:String = findScript(luaFile, '.hx');
				if(foundScript != null)
				{
					if(!ignoreAlreadyRunning)
						for (script in LoadingState.hscriptArray)
							if(script.origin == foundScript)
							{
								luaTrace('addHScript: The script "' + foundScript + '" is already running!');
								return;
							}

					PlayState.instance.initHScript(foundScript);
					return;
				}
				luaTrace("addHScript: Script doesn't exist!", false, false, FlxColor.RED);
				#else
				luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
				#end
			});
		 */

		set("loadGraphic", function(variable:String, image:String, ?gridX:Int = 0, ?gridY:Int = 0)
		{
			var split:Array<String> = variable.split('.');
			var spr:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			var animated = gridX != 0 || gridY != 0;

			LoadingState.imagesToPrepare.push(image);
		});

		set("addCharacterToList", function(name:String, type:String)
		{
			var charType:Int = 0;
			switch (type.toLowerCase())
			{
				case 'dad':
					charType = 1;
				case 'gf' | 'girlfriend':
					charType = 2;
			}
			LoadingState.preloadCharacter(name);
		});
		set("precacheImage", function(name:String, ?allowGPU:Bool = true)
		{
			LoadingState.imagesToPrepare.push(name);
		});
		set("precacheSound", Paths.sound);
		set("precacheMusic", Paths.music);

		/*
			set("triggerEvent", function(name:String, arg1:Dynamic, arg2:Dynamic) {
				var value1:String = arg1;
				var value2:String = arg2;
				LoadingState.triggerEvent(name, value1, value2, Conductor.songPosition);
				//trace('Triggered event: ' + name + ', ' + value1 + ', ' + value2);
				return true;
			});
		 */

		set("makeLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0)
		{
			tag = tag.replace('.', '');
			LoadingState.imagesToPrepare.push(image);
		});
		set("makeAnimatedLuaSprite", function(tag:String, ?image:String = null, ?x:Float = 0, ?y:Float = 0, ?spriteType:String = "sparrow")
		{
			tag = tag.replace('.', '');
			LoadingState.imagesToPrepare.push(image);
		});

		set("playMusic", function(sound:String, volume:Float = 1, loop:Bool = false)
		{
			LoadingState.musicToPrepare.push(sound);
		});
		set("playSound", function(sound:String, volume:Float = 1, ?tag:String = null)
		{
			LoadingState.soundsToPrepare.push(sound);
		});
		/*
			#if DISCORD_ALLOWED DiscordClient.addLuaCallbacks(this); #end
			#if HSCRIPT_ALLOWED 
				HScript.implement(this); 
				HScriptBase.implement(this);
			#end
		 */

		try
		{
			var isString:Bool = !FileSystem.exists(scriptName);
			var result:Dynamic = null;
			if (!isString)
				result = LuaL.dofile(lua, scriptName);
			else
				result = LuaL.dostring(lua, scriptName);

			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0)
			{
				trace(resultStr);
				#if (windows || mobile || js || wasm)
				SUtil.showPopUp(resultStr, 'Error on lua script!');
				#else
				luaTrace('$scriptName\n$resultStr', true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
			if (isString)
				scriptName = 'unknown';
		}
		catch (e:Dynamic)
		{
			trace(e);
			return;
		}
		call('onCreate', []);
		trace('lua file loaded succesfully: $scriptName (${Std.int(Date.now().getTime() - times)}ms)');
		#end
	}

	// main
	public var lastCalledFunction:String = '';

	public static var lastCalledScript:ProloadLua = null;

	public function call(func:String, args:Array<Dynamic>):Dynamic
	{
		if (closed)
			return LuaUtils.Function_Continue;

		lastCalledFunction = func;
		lastCalledScript = this;
		try
		{
			if (lua == null)
				return LuaUtils.Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.LUA_TFUNCTION)
			{
				if (type > Lua.LUA_TNIL)
					luaTrace("ERROR (" + func + "): attempt to call a " + LuaUtils.typeToString(type) + " value", false, false, FlxColor.RED);

				Lua.pop(lua, 1);
				return LuaUtils.Function_Continue;
			}

			for (arg in args)
				Convert.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.LUA_OK)
			{
				var error:String = getErrorMessage(status);
				luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
				return LuaUtils.Function_Continue;
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast Convert.fromLua(lua, -1);
			if (result == null)
				result = LuaUtils.Function_Continue;

			Lua.pop(lua, 1);
			if (closed)
				stop();
			return result;
		}
		catch (e:Dynamic)
		{
			trace(e);
		}
		return LuaUtils.Function_Continue;
	}

	public function set(variable:String, data:Dynamic)
	{
	#if LUA_ALLOWED
	if (lua == null)
		return;

	if (Type.typeof(data) == TFunction)
	{
		Lua_helper.add_callback(lua, variable, data);
		return;
	}

	Convert.toLua(lua, data);
	Lua.setglobal(lua, variable);
	} public function stop()

	{
		closed = true;

		if (lua == null)
		{
			return;
		}
		Lua.close(lua);
		lua = null;
	#end
		#if HSCRIPT_ALLOWED
		if (hscript != null)
		{
			hscript.destroy();
			hscript = null;
		}

		if (hscriptBase != null)
			hscriptBase.interp = null;
		hscriptBase = null;
		#end
	}

	public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE)
	{
		if (ignoreCheck || getBool('luaDebugMode'))
		{
			if (deprecated && !getBool('luaDeprecatedWarnings'))
			{
				return;
			}
			PlayState.instance.addTextToDebug(text, color);
		}
	}

	public static function getBool(variable:String)
	{
		if (lastCalledScript == null)
			return false;

		var lua:State = lastCalledScript.lua;
		if (lua == null)
			return false;

		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return false;
		}
		return (result == 'true');
	}

	function findScript(scriptFile:String, ext:String = '.lua')
	{
		if (!scriptFile.endsWith(ext))
			scriptFile += ext;
		var preloadPath:String = Paths.getSharedPath(scriptFile);
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(scriptFile);
		if (FileSystem.exists(scriptFile))
			return scriptFile;
		else if (FileSystem.exists(path))
			return path;

		if (FileSystem.exists(preloadPath))
		#else
		if (Assets.exists(preloadPath))
		#end
		{
			return preloadPath;
		}
		return null;
	}

	public function getErrorMessage(status:Int):String
	{
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null)
			v = v.trim();
		if (v == null || v == "")
		{
			switch (status)
			{
				case Lua.LUA_ERRRUN:
					return "Runtime Error";
				case Lua.LUA_ERRMEM:
					return "Memory Allocation Error";
				case Lua.LUA_ERRERR:
					return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		return null;
	}

	public function addLocalCallback(name:String, myFunction:Dynamic)
	{
		callbacks.set(name, myFunction);
		Lua_helper.add_callback(lua, name, null); // just so that it gets called
	}
}
#end
