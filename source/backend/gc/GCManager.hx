package backend.gc;

import developer.display.DataGet;

class GCManager {
    static var listener:GCManager = null;

    /////////////////////////////////////////////////////////////////////////

    public static function addListener() {
        if (listener != null)
            return;

        listener = new GCManager();
    }

    public static function removeListener() {
        if (listener != null)
            listener = null;
        cpp.vm.Gc.enable(true);
        enableGC = true;
        trace("GCManager close");
    }

    private function new() {
        initMemory = DataGet.memory;
        cpp.vm.Gc.enable(false);
        trace("GCManager init");
    }

    //////////////////////////////////////////////////////////////////////////

    private var initMemory:Float = 0; //初始化内存
    static var enableGC:Bool = false; //是否开启了GC

    private var mem:Float = 0;

    private var avgIncrease:Float = 0;
    
    public static function updateData(curMem:Float) {
        if (listener == null) 
            return;


    }

    //////////////////////////////////////////////////////////////////////////
}