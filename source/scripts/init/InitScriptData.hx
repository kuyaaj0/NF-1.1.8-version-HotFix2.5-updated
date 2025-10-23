package scripts.init;

import crowplexus.iris.Iris;

import scripts.lua.*;

class InitScriptData {
    public static function init() {
        Iris.proxyImports.set("psychlua.CallbackHandler", CallbackHandler);
        Iris.proxyImports.set("psychlua.CustomSubstate", CustomSubstate);
        Iris.proxyImports.set("psychlua.DebugLuaText", DebugLuaText);
        Iris.proxyImports.set("psychlua.DeprecatedFunctions", DeprecatedFunctions);
        Iris.proxyImports.set("psychlua.ExtraFunctions", ExtraFunctions);
        Iris.proxyImports.set("psychlua.FlxAnimateFunctions", FlxAnimateFunctions);
        Iris.proxyImports.set("psychlua.FunkinLua", FunkinLua);
        Iris.proxyImports.set("psychlua.LuaUtils", LuaUtils);
        Iris.proxyImports.set("psychlua.ModchartAnimateSprite", ModchartAnimateSprite);
        Iris.proxyImports.set("psychlua.ModchartSprite", ModchartSprite);
        Iris.proxyImports.set("psychlua.ReflectionFunctions", ReflectionFunctions);
        Iris.proxyImports.set("psychlua.ShaderFunctions", ShaderFunctions);
    }
}