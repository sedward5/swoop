package;

import flash.display.Sprite;
import openfl.Assets;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.filters.GlowFilter;
import flash.display.LoaderInfo;
import flash.display.Loader;
import flash.display.Bitmap;
import flash.net.URLRequest;
import flash.system.Security;
import flash.media.SoundTransform;
import motion.easing.Linear;
import motion.Actuate;

class Main extends Sprite {
	
	static var swoop: flash.display.Sprite;
	static var moveY: Float = 0;
	static var firing: Bool = false;
	static var begin_firing:Bool = false;
	static var stop_firing:Bool = false;
	static var bullets:Array<Projectile> = new Array();
	static var enemies:Array<Enemy> = new Array();
	static var fire_cooldown:Int = 0;
	static var level_clock:Int = 0;
	static var game_state:String = "welcome";
	static var s_pressed:Bool = false;
	static var level:Int = 1;
	static var sw = flash.Lib.current.stage.stageWidth;
	static var sh = flash.Lib.current.stage.stageHeight;
	static var swoopclosed:Bitmap;
	static var swoopopen:Bitmap;
	
	// Play stats
	static var fire_rate:Int = 20;
	
	public function new () {
		super ();
		swoopclosed = new Bitmap(Assets.getBitmapData("assets/swoop.png"));
		swoopopen = new Bitmap(Assets.getBitmapData("assets/swoop_open.png"));
		var field  = new flash.display.Shape();
		field.graphics.beginBitmapFill(Assets.getBitmapData("assets/starfield.png"));
		field.graphics.drawRect ( 0, 0, 700, 550);
		field.graphics.endFill ();
		flash.Lib.current.addChild(field);
		
		swoop = new flash.display.Sprite();
		swoop.addChild(swoopclosed);
		swoop.x = 10;
		flash.Lib.current.addChild(swoop);
		
		
		//Start event handlers
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME,function(_) Main.onEnterFrame());
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, key_down);
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, key_up);
	}
	
	static function key_down(event:flash.events.KeyboardEvent)
	{
		if (event.keyCode == 38) { // up arrow
			moveY = -5;
		}
		else if (event.keyCode == 40) { // down arrow
			moveY = 5;
		}
		else if (event.keyCode == 32) { // down arrow
			firing = true;
			begin_firing = true;
		}
		else if (event.keyCode == 83) { // down arrow
			s_pressed = true;
		}

	}
   
	static function key_up(event:flash.events.KeyboardEvent)
	{
		if (event.keyCode == 38 && moveY == -5) // up arrow
		moveY = 0;
		else if (event.keyCode == 40 && moveY == 5) // down arrow
		moveY = 0;
		else if (event.keyCode == 32) { // down arrow
			firing = false;
			stop_firing = true;
		}
		else if (event.keyCode == 83) { // down arrow
			s_pressed = false;
		}
	}
	
	static function onEnterFrame()
	{
		if(game_state == "welcome") {
			if(s_pressed) {
				game_state = "running";
			}		
		} 
		else if(game_state == "running") {
			level_clock++;
			haxe.Log.clear();
			trace(level_clock);
			trace("Fire_Cooldown: "+fire_cooldown);
			trace("Firing: "+firing);
			trace("Begin_firing: "+begin_firing);
			trace("Stop_firing: "+stop_firing);
			
			if(level == 1) {		
				if(level_clock == 5) {
					enemies.push(new Enemy("box",sw, 100));
					enemies.push(new Enemy("box",sw, 425));
				} 
				else if(level_clock == 35) {
					enemies.push(new Enemy("box",sw, 120));
					enemies.push(new Enemy("box",sw, 405));
				} 
				else if(level_clock == 65) {
					enemies.push(new Enemy("box",sw, 140));
					enemies.push(new Enemy("box",sw, 385));
				} 
				else if(level_clock == 95) {
					enemies.push(new Enemy("box",sw, 160));
					enemies.push(new Enemy("box",sw, 365));
				}
				else if(level_clock == 125) {
					enemies.push(new Enemy("box",sw, 180));
					enemies.push(new Enemy("box",sw, 345));
				}
			}
			// GAME STATE
			// Action
			swoop.y += moveY;
		
			if( swoop.y > sh - swoop.height -1)
			swoop.y = sw - swoop.height -1;
			else if( swoop.y <    0 )
			swoop.y = 0;
		
			if(begin_firing) {
				begin_firing = false;
				swoop.removeChild(swoopclosed);
				swoop.addChild(swoopopen);
			}
			if(stop_firing) {
				stop_firing = false;
				swoop.removeChild(swoopopen);
				swoop.addChild(swoopclosed);
				
			}
			if(firing && fire_cooldown == 0) {
				fire_cooldown = fire_rate;
				bullets.push(new Projectile("laser", swoop.x+100, swoop.y+25, 0));
				bullets.push(new Projectile("laser", swoop.x+100, swoop.y+25, 30));
				bullets.push(new Projectile("laser", swoop.x+100, swoop.y+25, -30));
			}
			if(fire_cooldown>0) {
				fire_cooldown--;
			}

			if(bullets.length > 0) {
				for(i in 0...bullets.length) {
					bullets[i].updateProj();
					if(bullets[i].cleanProj()) {
						bullets.splice(i, 1);
					}
				}
			}
			if(enemies.length > 0) {
				for(i in 0...enemies.length) {
					if(enemies[i].canFire()) {
						bullets.push(new Projectile("bullet", enemies[i].enemy.x, enemies[i].enemy.y+20, 180));
					}
					enemies[i].updateEnemy();
					if(enemies[i].cleanEnemy()) {
						enemies.splice(i, 1);
					}
				}
			}
		}
	}
	
}

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