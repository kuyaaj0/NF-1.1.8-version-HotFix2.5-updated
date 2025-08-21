package objects.state.freeplayState.select;

import haxe.ui.components.TextField;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;

class SearchButton extends FlxSpriteGroup {
    var bg:FlxSprite;
    var searchInput:TextField;
    var uiContainer:Box;
    
    public var onSearchChange:String->Void;

    public function new(x:Float, y:Float) {
        super(x, y);

        bg = new FlxSprite().loadGraphic(Paths.image(FreeplayState.filePath + 'searchButton'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);
        
        // 创建HaxeUI容器
        uiContainer = new Box();
        uiContainer.width = bg.width * 0.8;
        uiContainer.height = bg.height * 0.6;
        uiContainer.left = bg.x + (bg.width - uiContainer.width) / 2;
        uiContainer.top = bg.y + (bg.height - uiContainer.height) / 2;
        
        // 创建输入框
        searchInput = new TextField();
        searchInput.width = uiContainer.width;
        searchInput.height = uiContainer.height;
        searchInput.placeholder = "搜索歌曲...";
        searchInput.backgroundColor = 0x00000000;
        searchInput.customStyle.fontSize = 16;
        // 也可以添加onChange作为备用
        searchInput.onChange = function(e:UIEvent) {
            if (onSearchChange != null) {
                onSearchChange(searchInput.text);
            }
        };
        
        // 将输入框添加到容器
        uiContainer.addComponent(searchInput);
        
        // 将容器添加到屏幕
        add(uiContainer);
    }
    
    override function destroy() {
        // 清理HaxeUI组件
        if (uiContainer != null) {
            remove(uiContainer);
            uiContainer = null;
        }
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
