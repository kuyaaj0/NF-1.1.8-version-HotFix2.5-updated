package objects.state.freeplayState.select;

class SearchButton extends FlxSpriteGroup {
    var bg:FlxSprite;
    
    public var onSearchChange:String->Void;

    public function new(x:Float, y:Float) {
        super(x, y);

        bg = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + 'searchButton'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);
        
       
    }

}
