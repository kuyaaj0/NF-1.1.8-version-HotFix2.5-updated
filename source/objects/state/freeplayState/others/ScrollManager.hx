package objects.state.freeplayState.others;

import objects.state.freeplayState.song.SongRect;

class ScrollManager {

    public var index:Int = 0;

    var virtualIndex:Int = 0;

    var target:Array<SongRect>;
	public function new(tar:Array<SongRect>) { 
        this.target = tar;
    }

    public function init(){
        moveElementToPosition(true);
        index = virtualIndex = 0;
    }

    public function check(state:String) {
        if (state == "up") {
            if (target[0].y + target[0].light.height < FlxG.height * 0.5 - Math.floor(target.length * 0.8) * target[0].light.height)
                moveElementToPosition(true);
        } else if (state == "down") {
            if (target[target.length - 1].y > FlxG.height * 0.5 + Math.floor(target.length * 0.8) * target[0].light.height)
                moveElementToPosition(false);
        }
    }

    function moveElementToPosition(isUp:Bool) {
        var moveCount:Int = 0;
        
        for (member in 0...target.length) {
            if (isUp) {
                if (target[member].y + target[member].light.height < FlxG.height * 0.5 - Math.floor(target.length * 0.8) * target[0].light.height)
                    moveCount++;
                else break;
            } else {
                if (target[target.length - 1 - member].y > FlxG.height * 0.5 + Math.floor(target.length * 0.8) * target[0].light.height)
                    moveCount++;
                else break;
            }
        }

        var removed = target.splice(isUp ? 0 : target.length - 1 - moveCount, moveCount);
        
        if (isUp) {
            for (i in 0...removed.length)
                target.push(removed[i]);
            virtualIndex += moveCount;
        } else {
            for (i in 0...removed.length)
                target.insert(0, removed[removed.length - 1 - i]);
            virtualIndex -= moveCount;
        }

        //if (virtualIndex > target.length) virtualIndex -= target.length;
        //if (virtualIndex < target.length * -1) virtualIndex += target.length;

        index = virtualIndex;
        trace("index: " + index);
    }

}