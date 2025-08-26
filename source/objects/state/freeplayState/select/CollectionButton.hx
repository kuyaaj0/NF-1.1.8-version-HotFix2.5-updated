package objects.state.freeplayState.select;

class CollectionButton extends FlxSpriteGroup {
    static public var filePath:String = 'selectChange/';
    var bg:FlxSprite;
    var light:FlxSprite;
    
    public var onSelectChange:String->Void;

    public function new(x:Float, y:Float) {
        super(x, y);

        bg = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + filePath + 'bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.color = 0x21272F;
        add(bg);
        
        light = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + filePath + 'light'));
        light.antialiasing = ClientPrefs.data.antialiasing;
        light.color = 0x374248;
        add(light);
    }
}