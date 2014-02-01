package ;

import createjs.easeljs.Shadow;
import createjs.easeljs.Shape;
import createjs.easeljs.Ticker;
import createjs.easeljs.Stage;
import createjs.easeljs.Graphics;
import js.Browser;
import js.CanvasRenderingContext2D;
import js.Lib;
import matsu3d.Camera3D;
import matsu3d.Matrix3D;
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
	private var buffer:Array<Star>;
	
	private var context:Dynamic;
	private var camera:Camera3D;
	
	private var radX:Float = 0.0;
	private var emitNum:Int = 3;
	
	private static inline var W:Int = 465;
	private static inline var H:Int = 465;
	
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
		
		camera = new Camera3D();
		
		stars = new Array<Star>();
		
		buffer = new Array<Star>();
		
		stage = new Stage(cast Browser.document.getElementById("canvas"));
		stage.autoClear = false;
		context = stage.canvas.getContext("2d");
		
		for ( i in 0...300) {
			var star:Star = new Star();
			star.visible = false;
			buffer.push(star);
			stage.addChild(star);
		}
	}
 
	private function tickHandler():Void
	{
		camera.set_x(200.0*Math.cos(radX));
        camera.set_z(200.0*Math.sin(radX));
		var M:Matrix3D = camera.getViewingTransformMatrix();
		
		context.globalCompositeOperation = "source-over";
		context.setTransform(1, 0, 0, 1, 0, 0);
		context.fillStyle = "rgba(0, 0, 0, 0.25)";
		context.fillRect(0, 0, W, H);
		context.globalCompositeOperation = "lighter";
		
		for (i in 0...emitNum) {
			var star:Star = buffer.pop();
			star.init(0, -300, 0);
			star.visible = true;
			stars.push(star);
		}
		
		var i:Int = stars.length;
		while (i-- > 0) {
			var star:Star = stars[i];
			star.update(camera, M);
			star.x += W / 2;
			star.y += H / 2;
			if (star.y > H+30) {
				stars.splice(i, 1);
				star.visible = false;
				buffer.push(star);
			}
		}
		
		stage.update();
		
		radX += 0.02;
	}
}

class Star extends createjs.easeljs.Shape {
	private var position:Vector3D;
	private var velocity:Vector3D;
	private var acceleration:Vector3D;
	private var radius:Float;
	private var rv:Float;
	private var color:String;
	
	public function new() {
		super();
	}
	
	public function init(x:Float, y:Float, z:Float):Void {
		this.x = x;
		this.y = y;
		this.position = new Vector3D(x, y, z);
		this.velocity = new Vector3D(Math.random() * 8.0 - 4.0, Math.random() * 8.0 - 4.0, Math.random() * 8.0 - 4.0);
		this.color = Graphics.getRGB(Std.int(Math.random() * 255), Std.int(Math.random() * 255), Std.int(Math.random() * 255));
		this.radius = Math.random() * 8 + 5;
		this.rv = Math.random()*10+3;
		this.scaleX = this.scaleY = 1;
		this.alpha = 1;
		
		var p:Int = 5;
        var r2:Float = radius / 2;
        var angle:Float = -90;
        var addtion:Float = 360 / (p * 2);
		
		this.graphics.clear();
        this.graphics.beginFill(Graphics.getRGB(255,255,255));
        this.graphics.moveTo(0, -radius);
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
            this.graphics.lineTo(to_x, to_y);
        }
        this.graphics.endFill();
		var r:Int = Std.int(Math.random() * 256);
		var g:Int = Std.int(Math.random() * 256);
		var b:Int = Std.int(Math.random() * 256);
		this.graphics.beginRadialGradientFill([Graphics.getRGB(r, g, b, 0.2), Graphics.getRGB(r, g, b, 0)], [0, 1], 0, 0, 0, 0, 0, radius * 3).drawCircle(0, 0, radius * 3).endFill();
        this.cache( -radius * 3, -radius * 3, radius * 6, -radius * 6);
	}
	
	public function update(camera:Camera3D, M:Matrix3D):Void {
		position = position.add(velocity);
		velocity.y += 0.3;
		rotation += rv;
		
		var vec2:Vector2D = M.multiplyVector(position).getPerspective(150);
		
		var dist:Float = camera.eye.sub(position).norm();
		scaleX = scaleY = 300 / (dist + 300);
		this.alpha -= 0.005;
		x = vec2.x;
		y = vec2.y;
	}
}