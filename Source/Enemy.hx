import flash.display.Sprite;
import openfl.Assets;
import flash.display.Bitmap;
import motion.easing.Linear;
import motion.Actuate;

class Enemy extends Sprite {
	public var enemy:flash.display.Sprite;
	public var etype:String;
	public var fire_cooldown:Int = 0;
	public var fire_rate:Int = 40;
	public var velocity:Float =-2;
	public var weapon:String;
	
	public function new(etype:String, startx:Int, starty:Int) {
		super();
		this.etype=etype;
		var eta:Int = 10;
		if(this.etype=="xf") {
			eta = 10;
			var bit = new Bitmap(Assets.getBitmapData("assets/cross-fighter.png"));
			this.enemy = new flash.display.Sprite();
			this.enemy.addChild(bit);
			this.weapon = "bullet";
		}
		else if(this.etype=="wd") {
			eta = 12;
			var bit = new Bitmap(Assets.getBitmapData("assets/wedge.png"));
			this.enemy = new flash.display.Sprite();
			this.enemy.addChild(bit);
			this.weapon = "missle";
		}
		this.enemy.x = startx;
		this.enemy.y = starty;
		flash.Lib.current.addChild(this.enemy);
		Actuate.tween(this.enemy, eta, {x: -1}).ease(Linear.easeNone);
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