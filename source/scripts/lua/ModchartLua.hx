package scripts.lua;

#if LUA_ALLOWED
import modchart.Manager;
import flixel.tweens.FlxEase;
import flixel.FlxG;

class ModchartLua {
    public static function implement(lua:Dynamic):Void {
        if (lua == null) {
            FlxG.log.warn("[ModchartLua] Skipped — Lua instance is null!");
            return;
        }

        // Ensure Manager singleton exists
        if (Manager.instance == null)
            Manager.instance = new Manager();

        try {
            // --- BASIC MODIFIERS ---

            lua.addLocalCallback('addMod', function(name:String, ?field:Int = -1) {
                Manager.instance.addModifier(name, field);
            });

            lua.addLocalCallback('setMod', function(name:String, value:Float, ?player:Int = -1, ?field:Int = -1) {
                Manager.instance.setPercent(name, value, player, field);
            });

            lua.addLocalCallback('getMod', function(name:String, ?player:Int = 0, ?field:Int = 0):Float {
                return Manager.instance.getPercent(name, player, field);
            });

            lua.addLocalCallback('resetMod', function(name:String) {
                Manager.instance.setPercent(name, 0);
            });

            // --- EVENTS / EASING ---

            lua.addLocalCallback('setModAtBeat', function(name:String, beat:Float, value:Float, ?player:Int = -1, ?field:Int = -1) {
                Manager.instance.set(name, beat, value, player, field);
            });

            lua.addLocalCallback('easeMod', function(name:String, beat:Float, length:Float, value:Float, ease:String = "linear", ?player:Int = -1, ?field:Int = -1) {
                var easeFunc = Reflect.field(FlxEase, ease);
                if (easeFunc == null) easeFunc = FlxEase.linear;
                Manager.instance.ease(name, beat, length, value, easeFunc, player, field);
            });

            lua.addLocalCallback('addEaseMod', function(name:String, beat:Float, length:Float, value:Float, ease:String = "linear", ?player:Int = -1, ?field:Int = -1) {
                var easeFunc = Reflect.field(FlxEase, ease);
                if (easeFunc == null) easeFunc = FlxEase.linear;
                Manager.instance.add(name, beat, length, value, easeFunc, player, field);
            });

            // --- CALLBACKS / REPEATERS ---

            lua.addLocalCallback('callbackMod', function(beat:Float, funcName:String, ?field:Int = -1) {
                Manager.instance.callback(beat, function(e) {
                    if (lua != null && lua.functions != null && lua.functions.exists(funcName)) {
                        lua.call(funcName, []);
                    } else {
                        FlxG.log.warn("[ModchartLua] Tried to call missing Lua function: " + funcName);
                    }
                }, field);
            });

            lua.addLocalCallback('repeaterMod', function(beat:Float, length:Float, funcName:String, ?field:Int = -1) {
                Manager.instance.repeater(beat, length, function(e) {
                    if (lua != null && lua.functions != null && lua.functions.exists(funcName)) {
                        lua.call(funcName, []);
                    } else {
                        FlxG.log.warn("[ModchartLua] Tried to call missing Lua function: " + funcName);
                    }
                }, field);
            });

            // --- PLAYFIELD UTILITY ---
            lua.addLocalCallback('addPlayfield', function() {
                Manager.instance.addPlayfield();
            });

            FlxG.log.add("[ModchartLua] ✅ Fully registered Modchart functions successfully!");
        } catch (e:Dynamic) {
            FlxG.log.error("[ModchartLua] ❌ Error while registering Modchart functions: " + e);
        }
    }
}
#end
