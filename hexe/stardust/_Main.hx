package ;

import createjs.easeljs.Shadow;
import createjs.easeljs.Shape;
import createjs.easeljs.Ticker;
import createjs.easeljs.Stage;
import createjs.easeljs.Graphics;
import js.Browser;
import js.CanvasRenderingContext2D;
import js.Lib;
import matsu3d.Vector2D;
import matsu3d.Vector3D;

/**
 * ...
 * @author matsu4512
 */

class Main 
{
	private var stage:Stage;
	private var stars:Array<Star>;
	private var context:Dynamic;
	
	private var W:Int = 465;
	private var H:Int = 465;
	
	public static function main():Void
	{
		new Main();
	}
 
	public function new()
	{
		Browser.window.onload = initHandler;
	}
 
	private function initHandler(_):Void
	{
		Ticker.useRAF = true;
		Ticker.setFPS(60);
		Ticker.addListener(tickHandler);
 
		stars = new Array<Star>();
		
		stage = new Stage(cast Browser.document.getElementById("canvas"));
		stage.autoClear = false;
		context = stage.canvas.getContext("2d");
	}
 
	private function tickHandler():Void
	{
		context.globalCompositeOperation = "source-over";
		context.setTransform(1, 0, 0, 1, 0, 0);
		context.fillStyle = "rgba(0, 0, 0, 0.25)";
		context.fillRect(0, 0, W, H);
		context.globalCompositeOperation = "lighter";
		stars.push(cast(stage.addChild(new Star(stage.mouseX, stage.mouseY)), Star));
		
		var i:Int = stars.length;
		while (i-- > 0) {
			var star:Star = stars[i];
			star.update();
			
			if (star.x > W + 30 || star.y > H + 30) {
				stars.splice(i, 1);
				stage.removeChild(star);
			}
		}
		
		stage.update();
	}
}

class Star extends createjs.easeljs.Shape {
	private var position:Vector3D;
	private var velocity:Vector3D;
	private var radius:Float;
	private var rv:Float;
	private var color:String;
	
	
	public function new(x:Float, y:Float) {
		super();
		this.x = x;
		this.y = y;
		this.position = new Vector3D(x, y, 0.0);
		this.velocity = new Vector3D(Math.random() * 8.0 - 4.0, Math.random() * 8.0 - 4.0, -Math.random() * 4+1);
		this.color = Graphics.getRGB(Std.int(Math.random() * 255), Std.int(Math.random() * 255), Std.int(Math.random() * 255));
		this.radius = Math.random() * 8 + 5;
		this.rv = Math.random()*10+3;
		
		var p:Int = 5;
        var r2:Float = radius / 2;
        var angle:Float = -90;
        var addtion:Float = 360 / (p * 2);
        graphics.beginFill(Graphics.getRGB(255,255,255));
        graphics.moveTo(0, -radius);
        for (i in 0...p * 2)
        {
            angle+=addtion;
            var to_x:Float;
            var to_y:Float;
            var radian:Float=angle * Math.PI / 180;
            if (i % 2 == 1)
            {
                to_x=radius * Math.cos(radian);
                to_y=radius * Math.sin(radian);
            }
            else
            {
                to_x=r2 * Math.cos(radian);
                to_y=r2 * Math.sin(radian);
            }
            graphics.lineTo(to_x, to_y);
        }
        graphics.endFill();
		shadow = new Shadow(color, 0, 0, 30);
	}
	
	public function update():Void {
		position = position.add(velocity);
		velocity.x += 0.1;
		velocity.y += 0.14;
		rotation += rv;
		scaleX = scaleY = 150 / (position.z + 150);
		
		var vec2:Vector2D = position.getPerspective(150);
		x = vec2.x;
		y = vec2.y;
	}
}