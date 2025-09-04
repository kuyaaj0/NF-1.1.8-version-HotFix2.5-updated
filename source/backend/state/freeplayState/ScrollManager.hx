package backend.state.freeplayState;

class ScrollManager {

    var target:Array<SongRect>;
	public function new(tar:Array<SongRect>) { 
        this.target = tar;
    }

    var scrollFix:Int = 0;
    public function check(state:String) {
        scrollFix = Math.ceil(FreeplayState.instance.songPosiStart / SongRect.fixHeight) + 2;
        if (state == "up" || state == "down") {
            moveElementToPosition();
        }
    }

    var count:Int = 0;
    var _count:Int = -9999;
    public function moveElementToPosition() {
        if (FreeplayState.instance.songsMove.target > FreeplayState.instance.songPosiStart + SongRect.fixHeight * 0.95 * (target.length)) {
            FreeplayState.songPosiData = FreeplayState.instance.songsMove.target = FreeplayState.instance.songsMove.target - SongRect.fixHeight * 0.95 * (target.length);
        }
        if (FreeplayState.instance.songsMove.target < FreeplayState.instance.songPosiStart - SongRect.fixHeight * 0.95 * (target.length)) {
            FreeplayState.songPosiData = FreeplayState.instance.songsMove.target = FreeplayState.instance.songsMove.target + SongRect.fixHeight * 0.95 * (target.length);
        }

        count = Math.floor((FreeplayState.instance.songsMove.target - FreeplayState.instance.songPosiStart) / (SongRect.fixHeight * 0.95));

        if (count == _count) return;
        _count = count;

        var flipData:Int = target.length-1 - count - scrollFix;

        if (target.length < 0) return;

        for (i in 0...target.length) {
            if (i <= flipData) {
                target[i].currect = i;
            } else {
                target[i].currect = i - target.length;
            }
        }

        for (i in 0...target.length) {
            if (flipData < 0) {
                for (i in 0...Std.int(Math.abs(flipData))) {
                    target[target.length-1 - i].currect = target[0].currect-1 - i;
                }
            }
            if (flipData - target.length-1 - scrollFix >= 0) {
                for (i in 0...Std.int(flipData - target.length-1 - scrollFix)) {
                    target[i].currect = target[target.length-1].currect+1 + i;
                }
            }
        }
    }
}