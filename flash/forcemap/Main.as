package
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.*;
	import flash.text.*;
	
	[SWF(backgroundColor="0")]
	public class Main extends Sprite
	{
		private const W:int = 100, H:int = 100, N:int = 100;
		private var particles:Vector.<Particle> = new Vector.<Particle>();
		private var forceMap:BitmapData = new BitmapData(W, H, false, 0), bmpData:BitmapData = new BitmapData(W, H, false, 0), displayBmpData:BitmapData = new BitmapData(W, H, false, 0);
		private var colorTransform:ColorTransform;
		private var blur:BlurFilter = new BlurFilter(4, 4, 1), blur2:BlurFilter = new BlurFilter(4, 4, 4);
		private var offset1v:Point, offset2v:Point, offset1:Point, offset2:Point;
		private var seed:Number;
		
		public function Main()
		{
			addEventListener(Event.ENTER_FRAME, function():void{
				if(stage.stageWidth > 0 && stage.stageHeight > 0){
					removeEventListener(Event.ENTER_FRAME, arguments.callee);
					stage.scaleMode = StageScaleMode.EXACT_FIT;
					resize();
					addChild(new Bitmap(displayBmpData));
					createForceMap();
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
					stage.addEventListener(MouseEvent.CLICK, createForceMap);
					stage.addEventListener(Event.RESIZE, resize);
				}
			});
		}
		
		private function resize(e:Event=null):void{
			scaleX = stage.stageWidth/W;
			scaleY = stage.stageHeight/H;
		}
		
		private function createForceMap(e:MouseEvent=null):void{
			seed = Math.random()*int.MAX_VALUE;
			particles = new Vector.<Particle>();
			offset1v = new Point(Math.random(), Math.random());
			offset2v = new Point(Math.random(), Math.random());
			offset1 = new Point();
			offset2 = new Point();
			var r:Number = Math.random()*0.15+0.85, g:Number = Math.random()*0.15+0.85, b:Number = Math.random()*0.05+0.95;
			colorTransform = new ColorTransform(r, g, b);
			for(var i:int = 0; i < N; i++){
				for(var j:int = 0; j < N; j++){
					var p:Particle = new Particle();
					p.x = W/N*j;
					p.y = H/N*i;
					p.vx = p.vy = p.ax = p.ay = 0;
					particles.push(p);
				}
			}
			
			forceMap.perlinNoise(W, H, 2, seed, false, true, BitmapDataChannel.BLUE | BitmapDataChannel.GREEN);
		}
		
		private function onEnterFrame(e:Event):void{
			displayBmpData.applyFilter(bmpData, bmpData.rect, bmpData.rect.topLeft,　blur2);
			bmpData.applyFilter(bmpData, bmpData.rect, bmpData.rect.topLeft,　blur);
			bmpData.colorTransform(bmpData.rect, colorTransform);
			
			var n:int = particles.length;
			bmpData.lock();
			while(n--){
				var p:Particle = particles[n];
				
				bmpData.setPixel(p.x, p.y, 0xFFFFFF);
				
				var c:uint = forceMap.getPixel(p.x, p.y);
				p.ax = ((c & 0xFF)-128)*0.002;
				p.ay = ((c>>8 & 0xFF)-128)*0.002;

				p.x += p.vx;
				p.y += p.vy;
				p.vx += p.ax;
				p.vy += p.ay;
				
				if(p.x < 0) p.x = W+p.x;
				else if(p.x >= W) p.x = p.x-W;
				if(p.y < 0) p.y = H+p.y;
				else if(p.y >= H) p.y = p.y-H;

				p.vx *= 0.95;
				p.vy *= 0.95;
			}
			bmpData.unlock();
			
			offset1 = offset1.add(offset1v);
			offset2 = offset2.add(offset2v);
			forceMap.perlinNoise(W, H, 2, seed, false, true, BitmapDataChannel.BLUE | BitmapDataChannel.GREEN, false, [offset1, offset2]);
		}
	}
}

class Particle{
	public var x:Number, y:Number, vx:Number, vy:Number, ax:Number, ay:Number;
}