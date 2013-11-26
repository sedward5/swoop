import flash.display.Sprite;
import openfl.Assets;
import motion.easing.Linear;
import motion.Actuate;

class Projectile extends Sprite {
	public var proj:flash.display.Shape;
	public var velocity:Int;
	public var trajectory:Float;
	public var dir_neg:Bool = false;
	public var xtraj:Float;
	public var ytraj:Float;
	static var sw = flash.Lib.current.stage.stageWidth;
	static var sh = flash.Lib.current.stage.stageHeight;
	public function new(ptype:String, startx:Float, starty:Float, direction:Float) {
		super();
		this.trajectory = direction * Math.PI / 180;
		var finalx:Float;
		var finaly:Float;
		if(direction > -90 && direction < 90) {
			// forward
			finalx = sw+1;
			finaly = (Math.tan(this.trajectory)*(finalx-startx))+starty;
		}
		else {
			// backward
			finalx = -1;
			finaly = (Math.tan(this.trajectory)*(startx))+starty;
			
		}
		if(ptype == "bullet") {
			this.velocity = 150;
			this.proj = new flash.display.Shape();
			this.proj.graphics.beginFill ( 0xffffff );
			this.proj.graphics.drawRect ( 0, 0, 6, 6);
			this.proj.graphics.endFill ();
			flash.Lib.current.addChild(this.proj);
		}
		else if(ptype == "laser") {
			this.velocity = 150;
			this.proj = new flash.display.Shape();
			this.proj.graphics.beginFill ( 0x5Dd9dF );
			this.proj.graphics.drawRect ( 0, 0, 12, 3);
			this.proj.graphics.endFill ();
			this.proj.rotation = direction;
			flash.Lib.current.addChild(this.proj);
		}
		this.proj.x = startx;
		this.proj.y = starty;
		var distance = Math.sqrt(Math.pow(finalx-startx, 2)+Math.pow(finaly-starty,2));
		var eta = distance/this.velocity;
		Actuate.tween(this.proj, eta, {x: finalx, y: finaly}).ease(Linear.easeNone);
		//this.xtraj = (this.velocity*Math.cos(this.trajectory));
		//this.ytraj = (this.velocity*Math.sin(this.trajectory));
	
	}
	
	public function updateProj() {
		//this.proj.x += this.xtraj;
		//this.proj.y += this.ytraj;
	}
	
	public function cleanProj() {
		if( this.proj.x > flash.Lib.current.stage.stageWidth -1) {
			flash.Lib.current.removeChild(this.proj);
			return true;
		}
		else if( this.proj.x <    0 ) {
			flash.Lib.current.removeChild(this.proj);
			return true;
		}
		else if( this.proj.y > flash.Lib.current.stage.stageHeight -1) {
			flash.Lib.current.removeChild(this.proj);
			return true;
		}
		else if( this.proj.y <    0 ) {
			flash.Lib.current.removeChild(this.proj);
			return true;
		}
		else {
			return false;
		}
	}
}