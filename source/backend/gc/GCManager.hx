package backend.gc;

import openfl.Lib;

class GCManager  {
    
    private var initMemory:Float = 0;

    public function new() {
        Lib.current.stage.addEventListener(Event.ENTER_FRAME, onUpdate);
    }
    
    private function onUpdate(e:Event):Void
    {
        
	}


}