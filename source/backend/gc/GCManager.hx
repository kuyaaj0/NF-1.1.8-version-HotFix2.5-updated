package backend.gc;

extern class GCManager {
      @:native("__hxcpp_gc_tick") extern static function gc_tick(frameTimeLeftUs:Float, usedBytesThreshold:Int, minorEveryN:Int):Void;
}