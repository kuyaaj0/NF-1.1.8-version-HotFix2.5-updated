package objects.state.freeplayState.select;

class DiffSelect extends FlxSpriteGroup {

    static public var filePath:String = 'diff/';

    var bg:FlxSprite;
    var light:FlxSprite;
    
    public var onSelectChange:String->Void;

    public function new(x:Float, y:Float) {
        super(x, y);

        bg = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + filePath + 'bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);
        
        light = new FlxSprite(75, 0).loadGraphic(Paths.image(FreeplayState.filePath + filePath + 'light'));
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);
    }
}