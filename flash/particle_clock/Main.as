package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	[SWF(width="500", height="500", backgroundColor="0", frameRate="60")]
	public class Main extends Sprite
	{
		private const W:int = 250, H:int = 250, N:int = 30;
		
		private var particles:Vector.<Particle> = new Vector.<Particle>();
		
		private var bmpData:BitmapData;
		
		private var tf:TextField = new TextField();
		
		private var colorTransform:ColorTransform = 
			new ColorTransform(0.95, 0.95, 0.99);

		private var blur:BlurFilter = new BlurFilter(2, 2, 1);
		
		private var timeBmpData:BitmapData;
		
		public function Main()
		{
			scaleX = scaleY = 2.0;
			
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.textColor = 0xFFFFFF;
			tf.defaultTextFormat = new TextFormat(null, 60);
			
			bmpData = new BitmapData(W, H, false, 0);
			addChild(new Bitmap(bmpData));
			
			timeBmpData = new BitmapData(W, H, false, 0);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void{
			tf.text = new Date().toString().match(/\d\d:\d\d:\d\d/)[0];
			timeBmpData.fillRect(timeBmpData.rect, 0);
			timeBmpData.draw(tf, 
				new Matrix(1, 0, 0, 1, W/2-tf.width/2, H/2-tf.height/2));
			
			for(var i:int = 0; i < N; i++){
				var p:Particle = new Particle();
				p.x = Math.random()*W;
				p.y = p.vx = p.vy = p.ax = 0;
				p.ay = Math.random()/5+0.02;
				particles.push(p);
			}
			
			bmpData.applyFilter(bmpData, bmpData.rect, bmpData.rect.topLeft,
				blur);
			bmpData.colorTransform(bmpData.rect, colorTransform);
			
			var n:int = particles.length;
			bmpData.lock();
			while(n--){
				p = particles[n];
				
				p.x += p.vx;
				p.y += p.vy;
				p.vx += p.ax;
				p.vy += p.ay;
				
				if(p.y >= H) particles.splice(n,1);
				
				if(timeBmpData.getPixel(p.x, p.y) != 0){
					if(p.vy > 0.3) p.vy = 0.3;
					bmpData.setPixel(p.x, p.y, 0xFFFFFF);
				}
				else bmpData.setPixel(p.x, p.y, 0xCCCCFF);
			}
			bmpData.unlock();
		}
	}
}

class Particle{
	public var x:Number, y:Number, vx:Number, vy:Number, ax:Number, ay:Number;
}