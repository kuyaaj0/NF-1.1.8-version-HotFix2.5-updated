package objects.state.freeplayState.down;

class FuncButton extends FlxSpriteGroup {
    var rect:FlxSprite;
    var light:FlxSprite;

    var text:FlxText;

    var event:Dynamic -> Void = null;

    public function new(x:Float, y:Float, name:String, color:FlxColor = 0xffffff, onClick:Dynamic -> Void = null) {
        super(x, y);
        this.event = onClick;

        rect = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + 'funcButton'));
        rect.color = 0x24232C;
        rect.antialiasing = ClientPrefs.data.antialiasing;
        add(rect);

        light = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + 'funcLight'));
        light.color = color;
        light.alpha = 0.8;
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);

        text = new FlxText(0, 0, 0, name, Std.int(rect.height * 0.25));
		text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), Std.int(rect.height * 0.25), 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF);
        text.borderStyle = NONE;
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.x = rect.width / 2 - text.width / 2;
		text.y = rect.height / 3 * 2 - text.height / 2;
		add(text);
    }
}