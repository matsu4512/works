package{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Cubic;
    import org.libspark.betweenas3.tweens.ITween;
    
    [SWF(width=465, height=465, frameRate=60)]
    public class Main extends Sprite{
        private var numberList:Vector.<TextSprite> = new Vector.<TextSprite>;
        private var W:Number = 465, H:Number = 465, prev_s:int = -1;
        
        public function Main(){
            graphics.beginFill(0); graphics.drawRect(0,0,W,H); graphics.endFill();
            
            for(var i:int = 0; i < 50; i++)
                numberList.push(addChild(new TextSprite((i%10).toString(), Math.random()*W, Math.random()*H, Math.random()*6-3, Math.random()*6-3, Math.random()/2, Math.random()/2, Math.random()/2)));
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(e:Event):void{
            var date:Date = new Date();
            if(prev_s != date.seconds){
                prev_s = date.seconds;
                date.setMilliseconds(date.milliseconds+2000);
                var time:String = date.toTimeString().split(" ")[0].replace(":", "").replace(":", "");
                var tx:Number = Math.random()*(W-240)+30, ty:Number = Math.random()*(H-60)+30, tweenAry:Array = [];
                for(var i:int = 0; i < time.length; i++){
                    var sp:TextSprite = addChild(new TextSprite(time.charAt(i))) as TextSprite;
                    sp.alpha = 0;
                    sp.rotationZ = Math.random()*360;
                    sp.rotationY = Math.random()*360;
                    sp.rotationX = Math.random()*360;
                    var num:Number = Math.random();
                    if(num < 0.5){
                        if(num < 0.25) sp.x = -30-Math.random()*200;
                        else sp.x = W+30+Math.random()*200;
                        sp.y = Math.random()*H;
                    }
                    else{
                        if(num < 0.75) sp.y = -30-Math.random()*200;
                        else sp.y = H+30+Math.random()*200;
                        sp.x = Math.random()*W;
                    }
                    var it:ITween = BetweenAS3.to(sp, {x:tx+i*30+int(i/2)*15, y:ty, rotationX:0, rotationY:0, rotationZ:0, alpha:0.7}, 3.0);
                    it.onComplete = tweenComp;
                    it.onCompleteParams = [sp];
                    tweenAry.push(it);
                }
                BetweenAS3.parallelTweens(tweenAry).play();
            }
            
            i = numberList.length;
            while(i--){
                sp = numberList[i];
                sp.update();
                if(sp.x < -30 || sp.y < -30 || sp.x > W+30 || sp.y > H+30){
                    if(sp.x < -30) sp.x = W+30;
                    if(sp.y < -30) sp.y = H+30;
                    if(sp.x > W+30) sp.x = -30;
                    if(sp.y > H+30) sp.y = -30;
                    sp.alpha = 0.7;
                }
            }
        }
        
        private function tweenComp(sp:TextSprite):void{
            sp.filters = [new GlowFilter(0xFFFFFF, 1.0, 4, 4, 4, 4)];
            sp.tf.textColor = 0;
            var t:ITween = BetweenAS3.to(sp, {scaleX:2.5, scaleY:2.5, alpha:0}, 0.5, Cubic.easeOut);
            t.onComplete = removeChild;
            t.onCompleteParams = [sp];
            t.play();
        }
    }
}
import flash.display.Sprite;
import flash.text.*;

class TextSprite extends Sprite{
    public var rx:Number, ry:Number, rz:Number, vx:Number, vy:Number, tf:TextField = new TextField();
    
    public function TextSprite(text:String, x:Number=0, y:Number=0, vx:Number=0, vy:Number=0, rx:Number=0, ry:Number=0, rz:Number=0){
        this.x = x; this.y = y; this.vx = vx; this.vy = vy; this.rx = rx; this.ry = ry; this.rz = rz;
        alpha = 0.7;
        tf.textColor = 0xFFFFFF;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.defaultTextFormat = new TextFormat(null, 35);
        tf.text = text;
        tf.x = -tf.width/2;
        tf.y = -tf.height/2;
        addChild(tf);
        mouseEnabled = tf.mouseEnabled = false;
    }
    
    public function update():void{
        x += vx;
        y += vy;
        rotationX += rx;
        rotationY += ry;
        rotationZ += rz;
        alpha -= 0.0025;
    }
}