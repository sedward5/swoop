import flash.display.Sprite;
import openfl.Assets;
import flash.display.Bitmap;
import motion.easing.Linear;
import motion.Actuate;

class Enemy extends Sprite {
	public var enemy:flash.display.Shape;
	public var etype:String;
	public var fire_cooldown:Int = 0;
	public var fire_rate:Int = 40;
	public var velocity:Float =-2;
	
	public function new(type:String, startx:Int, starty:Int) {
		super();
		this.enemy = new flash.display.Shape();
		this.enemy.graphics.beginFill ( 0xaa0000 );
		this.enemy.graphics.drawRect ( 0, 0, 40, 40);
		this.enemy.graphics.endFill ();
		this.enemy.x = startx;
		this.enemy.y = starty;
		flash.Lib.current.addChild(this.enemy);
		Actuate.tween(this.enemy, 10, {x: -1}).ease(Linear.easeNone);
	}
	
	public function updateEnemy() {
		this.fire_cooldown--;
		//this.enemy.x += this.velocity;
	}
	
	public function cleanEnemy() {
		if( this.enemy.x <    0 ) {
			flash.Lib.current.removeChild(this.enemy);
			return true;
		}
		else {
			return false;
		}
	}
	
	public function canFire() {
		if(this.fire_cooldown == 0) {
			this.fire_cooldown=this.fire_rate;
			return true;
		}
		else {
			return false;
		}
	}
}