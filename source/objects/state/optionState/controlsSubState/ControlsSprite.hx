package objects.state.optionState.controlsSubState;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;

import backend.InputFormatter;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.input.keyboard.FlxKey;

class ControlsSprite extends FlxSpriteGroup
{
    private var DEFAULT_COLOR:FlxColor = 0xFF5C5970;
    public static final PRESSED_COLOR:FlxColor = 0xFF908BB0;
    public static final CHOOSEN_COLOR:FlxColor = 0xFF7A75A0;
    public static final PADDING:Float = 10;

    public var mainX:Float;
	public var mainY:Float;
    public var heightset:Float = 0;

    private var CORNER_RADIUS:Float;
    
    private var background:FlxSprite;
    public var text:FlxText;
    public var noteSprite:ControlsNoteSprite;
    public var moveBGArray:Array<RabSprite> = [];

    public var noteArray:Array<FlxText>;
    public var label:String = "";
    
    private var currentColor:FlxColor;
    private var targetColor:FlxColor;
    private var colorLerpSpeed:Float = 0.2;

    public var optiontext:String = "";
    public var optionUpdateBool:Bool = false; // 识别然后更新newCSS的文字Bool

    public var reNote:Bool = false;

    public function new(x:Float = 0, y:Float = 0, width:Float = 180, height:Float = 40, CORNER_RADIUS:Float, DEFAULT_COLOR:FlxColor = 0xFF5C5970, label:String = "")
    {
        super();

        this.CORNER_RADIUS = CORNER_RADIUS;
        this.DEFAULT_COLOR = DEFAULT_COLOR;
        this.label = label;

        currentColor = DEFAULT_COLOR;
        targetColor = DEFAULT_COLOR;
        mainX = X;
		mainY = Y;
        heightset = height;

        background = new FlxSprite(x, y);
        background.makeGraphic(Std.int(width), Std.int(height), FlxColor.TRANSPARENT, true);
        FlxSpriteUtil.drawRoundRect(background, 0, 0, width, height, CORNER_RADIUS, CORNER_RADIUS, currentColor);
        add(background);
        
        if (label != "")
        {
            text = new FlxText(PADDING + x, PADDING + y - 5, width, label);
            text.autoSize = true;
            text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 16, FlxColor.WHITE, LEFT);
            text.fieldHeight = height;
            add(text);
        }
    }

    public function funReNote(labels:String)
    {
        reNote = true;
        background.visible = false;

        text = new FlxText(PADDING + background.x, PADDING + background.y - 5, 300, labels);
        text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 32, FlxColor.WHITE, CENTER);
        text.screenCenter(X);
        add(text);
    }

    public function centerTextX()
    {
        text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 16, FlxColor.WHITE, CENTER);
        text.screenCenter(X);
        centerSpriteX();
        background.y += text.height;
    }
    public function centerSpriteX()
    {
        background.screenCenter(X);
    }

    public var wwidth:Float = 0;
    var hheight = 0;
    
    public function createNoteArray(array:Array<String>)
    {
        wwidth = 120;
        hheight = 50;

        noteSprite = new ControlsNoteSprite(background.x, background.y + (background.height / 2 - hheight / 2), wwidth, background.height, array, 16);
        noteSprite.updateBackground(background.x, background.y, 1800, background.height);
        noteSprite.updateParent(this);
        add(noteSprite);

        var resetSprite:RabSprite = new RabSprite(background.x + (background.width / 2 + wwidth) - 1, background.y + hheight, wwidth, hheight, 0x8E00D9E0, "Reset");
        add(resetSprite);

        var backSprite:RabSprite = new RabSprite(background.x + (background.width / 2 + (wwidth * 2)) + 5 - 1, background.y + hheight, wwidth, hheight, 0x8A42FF8A, "Done");
        add(backSprite);

        resetSprite.sprite.alpha = 0.8;
        backSprite.sprite.alpha = 0.8;

        resetSprite.setScale("y", 0);
        backSprite.setScale("y", 0);

        moveBGArray.push(resetSprite);
        moveBGArray.push(backSprite);

        // 不知道为什么另一个class的图片偏移这么多 chh
    }

    public var scaleBool:Bool = false;

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (reNote)
        {
            reNoteFunction();
        }

        if (reNote || label == "") return;

        if (!NewControlsSubState.allowControlsMode) {
            if (CoolUtil.mouseOverlaps(background, NewControlsSubState.instance.camControls)) 
            {
                if (background.alpha != 1)
                    background.alpha = 1;
            }
            else {
                if (background.alpha != 0.8)
                    background.alpha = 0.8;
            }
        }
        else {
            if (scaleBool) {
                for (i in 0...2)
                {
                    var moveBG:FlxSprite = moveBGArray[i].sprite;

                    if (CoolUtil.mouseOverlaps(moveBG, NewControlsSubState.instance.camControls)) 
                    {
                        if (moveBG.alpha != 1)
                            moveBG.alpha = 1;

                        if (FlxG.mouse.justPressed)
                        {
                            switch (i)
                            {
                                case 0:
                                    resetindieNote(NewControlsSubState.instance.buttonNpos-1);
                                case 1:
                                    NewControlsSubState.instance.backAllowControlsMode();
                            }
                        }
                    }
                    else {
                        if (moveBG.alpha != 0.8)
                            moveBG.alpha = 0.8;
                    }
                }
            }
        }
    }

    public var changeHeighting:Bool = false;
    public var bgheight:Float = 30;

    var tween:FlxTween;
    var tweenY:FlxTween;

    public function moveBG(i:Int, optionsButtonArray:Array<ControlsSprite>)
    {
        var optionsButtonArray = NewControlsSubState.instance.optionsButtonArray;
        var setOptionText = NewControlsSubState.setOptionText;
        
        setOptionText.text = "Idle...";
        setOptionText.updateHitbox();
        add(setOptionText);
        
        bgheight = 50;

        if (tween != null)
        {
            tween.cancel();
            tweenY.cancel();
        }

        if (!changeHeighting) {
            changeHeighting = true;
            scaleBool = true;

            tween = FlxTween.tween(background.scale, { y: 2 }, 0.2, {
                onUpdate: function(tween:FlxTween)
                {
                    tweenUpdate();
                },
                onComplete: function(twn:FlxTween)
                {
                    tweenUpdate();
                }
            });
        }
        else {
            changeHeighting = false;
            scaleBool = false;

            tween = FlxTween.tween(background.scale, { y: 1 }, 0.2, {
                onUpdate: function(tween:FlxTween)
                {
                    tweenUpdate();
                },
                onComplete: function(twn:FlxTween)
                {
                    tweenUpdate();
                }
            });
            bgheight = 0;
        }

        tweenY = FlxTween.num(NewControlsSubState.instance.buttonYpos, bgheight, 0.2, tweenFunction.bind(NewControlsSubState.instance.buttonYpos));

        i++;

        NewControlsSubState.instance.buttonNpos = i;
        trace(i, NewControlsSubState.instance.buttonNpos);
    }

    function tweenUpdate(i:Bool = false)
    {
        var setOptionText = NewControlsSubState.setOptionText;

        setOptionText.x = background.x + 5;
        setOptionText.y = background.y + hheight - 5;

        for (i in 0...2){
            moveBGArray[i].setScale("y", background.scale.y - 1);
        }

        setOptionText.scale.y = background.scale.y - 1;

        setOptionText.updateHitbox();
        background.updateHitbox();
    }

    function tweenFunction(s:Float, v:Float)
    {
        NewControlsSubState.instance.buttonYpos = v;
    }

    public function resetindieNote(i:Int)
    {
        var optionsButtonArray = NewControlsSubState.instance.optionsButtonArray;
        var key = optionsButtonArray[i].noteSprite.strArray[1];

		if (NewControlsSubState.onKeyboardMode == true)
            if (ClientPrefs.defaultKeys.exists(key))
                ClientPrefs.keyBinds.set(key, ClientPrefs.defaultKeys.get(key).copy());

        updateNoteSpriteText(i, optionsButtonArray);
    }

    public function reNoteFunction()
    {
        if (CoolUtil.mouseOverlaps(text, NewControlsSubState.instance.camControls)) {
            if (text.alpha != 1)
                text.alpha = 1;

            if (!NewControlsSubState.allowControlsMode && FlxG.mouse.justPressed)
            {
                ClientPrefs.resetKeys(!NewControlsSubState.onKeyboardMode);
                ClientPrefs.reloadVolumeKeys();
                FlxG.sound.play(Paths.sound('cancelMenu'));

                var optionsButtonArray = NewControlsSubState.instance.optionsButtonArray;

                for (i in 0...optionsButtonArray.length)
                {
                    updateNoteSpriteText(i, optionsButtonArray);
                }
            }
        }
        else {
            if (text.alpha != 0.8)
                text.alpha = 0.8;
        }
    }
    
    public function updateNoteSpriteText(i:Int, optionsButtonArray:Array<ControlsSprite>)
    {
        for (n in 0...2) {
            var key:String = null;

            if (optionsButtonArray[i].wwidth != 0) { // 检测是不是有noteSprite(可以更改按键的)SpriteGroup
                var option:String = optionsButtonArray[i].noteSprite.strArray[1];

                if (NewControlsSubState.onKeyboardMode)
                {
                    var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option);
                    key = InputFormatter.getKeyName(savKey[n] != null ? savKey[n] : NONE);
                }
                else
                {
                    var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option);
                    key = InputFormatter.getGamepadName(savKey[n] != null ? savKey[n] : NONE);
                }

                optionsButtonArray[i].noteSprite.updateText(n, key);
            }
        }
    }

    public function createOptionText(text:String)
    {
        optionUpdateBool = true;
        optiontext = text;
    }

    public function updateOptionText()
    {
        if (NewControlsSubState.optionText.text != optiontext) {
            NewControlsSubState.updateOptionsText(optiontext);
        }
    }
    
    private function applyColor():Void
    {
        FlxSpriteUtil.drawRoundRect(background, 0, 0, background.width, background.height, CORNER_RADIUS, CORNER_RADIUS, currentColor);
    }
    
    public function setColor(color:FlxColor):Void
    {
        targetColor = color;
    }
    
    public function setText(newText:String):Void
    {
        text.text = newText;
    }
}

class ControlsNoteSprite extends FlxSpriteGroup
{
    private var DEFAULT_COLOR:FlxColor;
    public static final PRESSED_COLOR:FlxColor = 0xFF908BB0;
    public static final CHOOSEN_COLOR:FlxColor = 0xFF7A75A0;
    public static final PADDING:Float = 10;

    private var CORNER_RADIUS:Float;

    private var finalWidth:Float;

    public var strArray:Array<String> = [];

    public var textArray:Array<FlxText> = [];
    public var backgroundArray:Array<FlxSprite> = [];

    public var parent:ControlsSprite;

    public function new(x:Float, y:Float, width:Float, height:Float, array:Array<String>, CORNER_RADIUS:Float, DEFAULT_COLOR:FlxColor = 0xFF908BB0, label:String = "111")
    {
        super();

        this.CORNER_RADIUS = CORNER_RADIUS;
        this.DEFAULT_COLOR = DEFAULT_COLOR;

        strArray = array;
        finalWidth = width;

        //var keyArray:Array<String> = NewControlsSubState.returnStr(strArray);

        var xPos;

        for (i in 0...2)
        {
            var e = (strArray.length - 1) - i;
            xPos = (e * (width + 5));

            var key:String = returnKey(i);

            var text:FlxText = new FlxText(PADDING + x - xPos, PADDING + y);
            text.text = key;
            //text.autoSize = true;
            text.setFormat(Paths.font(Language.get('fontName', 'ma') + '.ttf'), 16, FlxColor.WHITE, CENTER);
            //text.fieldHeight = height;
            text.updateHitbox();

            //trace(text.width);

            var bgWidth:Float = text.width;

            if (text.width < width)
            {
                bgWidth = width;
            }

            bgWidth = width;

            var background:FlxSprite = new FlxSprite(x - xPos + bgWidth + 5, y);
            background.makeGraphic(Std.int(bgWidth), Std.int(height), FlxColor.TRANSPARENT, true);
            FlxSpriteUtil.drawRoundRectComplex(background, 0, 0, bgWidth, height, CORNER_RADIUS, CORNER_RADIUS, 0, 0, DEFAULT_COLOR); // 同步宽度 -- chh
            background.alpha = 0.8;
            background.updateHitbox();

            add(background);
            add(text);

            centerSprite(text, background);

            backgroundArray.push(background);
            textArray.push(text);
        }
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!NewControlsSubState.allowControlsMode || NewControlsSubState.allowControlsMode && parent.scaleBool) {
            for (i in 0...2) {
                if (CoolUtil.mouseOverlaps(backgroundArray[i], NewControlsSubState.instance.camControls)) {
                    if (backgroundArray[i].alpha != 1) {
                        backgroundArray[i].alpha = 1;
                    }

                    if (FlxG.mouse.justPressed)
                    {
                        var key:String = returnKey(i);

                        NewControlsSubState.instance.updateNoteMode(key, strArray, i, parent);
                    }
                }
                else {
                    if (backgroundArray[i].alpha != 0.8) {
                        backgroundArray[i].alpha = 0.8;
                    }
                }
            }
        }
    }

    public var bgInt:Int = 0;

    public function updateBackground(x:Float, y:Float, width:Float, height:Float)
    {
        var py:Int = 36; // 偏移量

        for (i in 0...2)
        {
            var bg;
            var text;

            if (bgInt < 1) {

                bg = backgroundArray[i + 1];
                text = textArray[i + 1];

                bg.x = x + (width / 2) - bg.width - py;
            }
            else {
                bg = backgroundArray[i - 1];
                text = textArray[i - 1];
                
                bg.x = backgroundArray[i].x - bg.width - 5;
            }

            centerSprite(text, bg);

            bgInt++;
            if (bgInt > 1) bgInt = 0;
        }
    }

    public function updateText(i:Int, newText:String):Void
    {
        textArray[i].text = newText;
        textArray[i].updateHitbox();
        centerSprite(textArray[i], backgroundArray[i]);
    }

    public function updateParent(sprite:ControlsSprite)
    {
        parent = sprite;
    }

    public function returnKey(i:Int):String
    {
        var key:String = null;
        if (NewControlsSubState.onKeyboardMode)
        {
            var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(strArray[1]);
            key = InputFormatter.getKeyName((savKey[i] != null) ? savKey[i] : NONE);
        }
        else
        {
            var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(strArray[1]);
            key = InputFormatter.getGamepadName((savKey[i] != null) ? savKey[i] : NONE);
        }
        return key;
    }

    public function centerSprite(yourSprite:Dynamic, Sprite:Dynamic):Void
    {
        var x = Sprite.x + (Sprite.width / 2) - (yourSprite.width / 2);
        var y = Sprite.y + (Sprite.height / 2) - (yourSprite.height / 2);

        yourSprite.setPosition(x, y);
    }
}