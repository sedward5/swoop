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
	
	// Texts
	static var title_text:Texter;
	static var subtitle_text:Texter;
	static var level_text:Texter;
	static var score_text:Texter;

	// Play stats
	static var fire_rate:Int = 20;
	
	public function new () {
		super ();
		swoopclosed = new Bitmap(Assets.getBitmapData("assets/swoop.png"));
		swoopopen = new Bitmap(Assets.getBitmapData("assets/swoop_open.png"));
		
		var fieldbit = new Bitmap(Assets.getBitmapData("assets/starfield.png"));
		var field  = new flash.display.Sprite();
		field.addChild(fieldbit);
		flash.Lib.current.addChild(field);
		
		swoop = new flash.display.Sprite();
		swoop.addChild(swoopclosed);
		swoop.x = 10;
		swoop.y = 205;
		flash.Lib.current.addChild(swoop);
		
		title_text = new Texter(110, 205, 75, 0xFFFFFF, "Swooper", true, 0xaa00aa);
		subtitle_text = new Texter(200, 270, 24, 0xFFFFFF, "Press S to Begin", true, 0xaa00aa);
		level_text = new Texter(5, 5, 16, 0xFFFFFF, "Level: 1", false, 0xaa00aa);
		score_text = new Texter(525, 5, 16, 0xFFFFFF, "Score: 0", false, 0xaa00aa);
		
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
				title_text.hideText();
				subtitle_text.hideText();
				game_state = "running";
			}		
		} 
		else if(game_state == "next level") {
			if(s_pressed) {
				title_text.hideText();
				subtitle_text.hideText();
				game_state = "running";
			}	
		}
		else if(game_state == "running") {
			level_clock++;
			
			
			//
			// Here be the level layouts
			//
			if(level == 1) {		
				if(level_clock == 5) {
					enemies.push(new Enemy("xf",sw, 100));
					enemies.push(new Enemy("xf",sw, 425));
				} 
				else if(level_clock == 35) {
					enemies.push(new Enemy("xf",sw, 120));
					enemies.push(new Enemy("xf",sw, 405));
				} 
				else if(level_clock == 65) {
					enemies.push(new Enemy("xf",sw, 140));
					enemies.push(new Enemy("xf",sw, 385));
				} 
				else if(level_clock == 95) {
					enemies.push(new Enemy("xf",sw, 160));
					enemies.push(new Enemy("xf",sw, 365));
				}
				else if(level_clock == 125) {
					enemies.push(new Enemy("xf",sw, 180));
					enemies.push(new Enemy("xf",sw, 345));
				}
				else if(level_clock == 155) {
					enemies.push(new Enemy("xf",sw, 200));
					enemies.push(new Enemy("xf",sw, 325));
				} 
				else if(level_clock == 185) {
					enemies.push(new Enemy("wd",sw, 262));
				}
				else if(level_clock == 520) {
					level++;
					level_text.updateText("Level: "+level);
					title_text.updateText("Level: "+level);
					title_text.showText();
					subtitle_text.showText();
					level_clock = 0;
					game_state = "next level";
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
						bullets.push(new Projectile(enemies[i].weapon, enemies[i].enemy.x, enemies[i].enemy.y+20, 180));
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
