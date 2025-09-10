package objects.state.freeplayState.song;

class DiffRect extends FlxSpriteGroup {
    public var light:Rect;
    private var bg:FlxSprite;
	private var diffName:FlxText;
	private var charter:FlxText;

    /////////////////////////////////////////////////////////////////////

    static public var fixHeight:Int = #if mobile 40 #else 30 #end;
    private var filePath:String = 'song/';

    public var id:Int = 0;
    public var currect:Int = 0;
    
    public var onSelectChange:String->Void;
    public function new(songNameSt:String, songChar:String, songMusican:String, songCharter:Array<String>, songColor:Array<Int>) {
        super(x, y);
    }
}