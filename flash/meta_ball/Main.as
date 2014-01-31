package{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    [SWF(width=465, height=465)]
    public class Main extends Sprite{
        private var dotsSp:Sprite = new Sprite();
        private var metaBallBmp:Bitmap;
        private var metaBallBmpData:BitmapData;
        private var baseSp:Sprite = new Sprite();
        
        private var metaBlur:BlurFilter = new BlurFilter(50, 50); 
        private var balls:Vector.<Ball>;
        private var rect:Rectangle;
        private var destPt:Point;
        
        public function Main(){
            
            dotsSp.graphics.lineStyle(0, 0, 0);
            dotsSp.graphics.beginFill(0xFFFFFF);
            dotsSp.graphics.drawRect(0, 0, 465, 465);
            dotsSp.graphics.endFill();
            dotsSp.alpha = 0;
            
            metaBallBmpData = new BitmapData(465, 465, false, 0xFFFFFF);
            metaBallBmp = new Bitmap(metaBallBmpData);
            metaBallBmp.filters = [new BlurFilter(16, 16, BitmapFilterQuality.LOW)];
            
            baseSp.addChild(metaBallBmp);
            baseSp.addChild(dotsSp);
            addChild(baseSp);
            
            for(var i:int = 0; i < 30; i++){
                var sp:Sprite = new Sprite();
                sp.graphics.beginFill(0xFFFFFF*Math.random());
                sp.graphics.drawCircle(0,0,10);
                sp.graphics.endFill();
                sp.x = Math.random()*465;
                sp.y = Math.random()*465;
                dotsSp.addChild(sp);
            }
            
            dotsSp.filters = [metaBlur];
            
            rect = new Rectangle(0, 0, metaBallBmpData.width, metaBallBmpData.height);
            destPt = new Point(0,0);
            
            balls = new Vector.<Ball>();
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void{
            var b:Ball = new Ball(mouseX, mouseY, Math.random()*10-5, Math.random()*10-5, 0x0, Math.random()*10+10);
            dotsSp.addChild(b);
            balls.push(b);
            
            var i:int = balls.length;
            while(i--){
                b = balls[i];
                b.update();
                
                if(b.x < 0){
                    b.x = 0;
                    b.vx *= -1;
                }
                
                if(b.x > 465){
                    b.x = 465;
                    b.vx *= -1;
                }
                
                if(b.y > 465){
                    b.y = 465;
                    b.vy = 0;
                }
                else b.vy += 0.1;
                
                if(b.y == 465 && (b.x > 220 && b.x < 250)){
                    balls.splice(i,1);
                    dotsSp.removeChild(b);
                    b = null;
                }
            }
            
            metaBallBmpData.draw(dotsSp);
            var threshold:uint =  0x00999999; 
            var color:uint = 0x0000FF00;
            var maskColor:uint = 0x00FFFFFF;
            metaBallBmpData.threshold(metaBallBmpData, rect, destPt, "<", threshold, color, maskColor, false);
        }
    }
}
import flash.display.Shape;

class Ball extends Shape{
    public var vx:Number, vy:Number, color:uint;
    public function Ball(x:Number, y:Number, vx:Number, vy:Number, c:uint, s:Number){
        this.x = x; this.y = y; this.vx = vx; this.vy = vy; color = c;
        graphics.beginFill(color);
        graphics.drawCircle(0,0,s);
        graphics.endFill();
    }
    
    public function update():void{
        x += vx;
        y += vy;
    }
}
