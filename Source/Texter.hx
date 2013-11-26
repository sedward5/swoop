import flash.display.Sprite;
import openfl.Assets;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.filters.GlowFilter;

class Texter {
	public var textObj:TextField;

	public function new(x:Int, y:Int, size:Int, color:Int, text:String, glow:Bool, glowColor:Int) {
		this.textObj = new TextField();
		this.textObj.x = x;
		this.textObj.y = y;
		var font = Assets.getFont("assets/space age.ttf");
		this.textObj.defaultTextFormat =  new TextFormat(font.fontName, size, color);
		this.textObj.embedFonts = true; 
		this.textObj.text = text;
		this.textObj.width = 640;
		if(glow) {
			this.textObj.filters = [ new  GlowFilter(glowColor, 1.0, 6, 6, 6, 6, false, false) ];
		}
		flash.Lib.current.addChild(this.textObj);
	}

	public function updateText(text:String) {
		this.textObj.text = text;
	}

	public function hideText() {
		flash.Lib.current.removeChild(this.textObj);
	}
	public function showText() {
		flash.Lib.current.addChild(this.textObj);
	}
}