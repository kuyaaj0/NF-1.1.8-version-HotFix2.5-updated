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
    
    override function destroy() {
        super.destroy();
    }
    
    public function getText():String {
        return searchInput != null ? searchInput.text : "";
    }
    
    public function setText(value:String):Void {
        if (searchInput != null) {
            searchInput.text = value;
        }
    }
}
