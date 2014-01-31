package
{
    import caurina.transitions.Tweener;
    
    import flash.events.Event;
    
    import org.papervision3d.materials.special.Letter3DMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.typography.Text3D;
    import org.papervision3d.typography.fonts.HelveticaBold;
    import org.papervision3d.view.BasicView;

    [SWF(width="500", height="500", backgroundColor="0x000000", frameRate="40")]
    public class Main extends BasicView
    {
        private var rootNode:DisplayObject3D;
        
        //ひとつ前の時間を保持しておくための変数
        private var prev_second1:uint;
        private var prev_second2:uint;
        private var prev_minute1:uint;
        private var prev_minute2:uint;
        private var prev_hour1:uint;
        private var prev_hour2:uint;
        private var prev_second_text1:DisplayObject3D;
        private var prev_second_text2:DisplayObject3D;
        private var prev_minute_text1:DisplayObject3D;
        private var prev_minute_text2:DisplayObject3D;
        private var prev_hour_text1:DisplayObject3D;
        private var prev_hour_text2:DisplayObject3D;
        
        private var second1:Text3D;
        private var second2:Text3D;
        private var minute1:Text3D;
        private var minute2:Text3D;
        private var hour1:Text3D;
        private var hour2:Text3D;
        
        private var date:Date;

        private const zoom:Number=20;
        private const focus:Number=30;
        private const distance:Number=600;

        public function Main()
        {
            if(stage)
                init();
            else
                addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init():void{
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            startRendering();
            
            rootNode=this.scene.addChild(new DisplayObject3D("rootNode"));
            camera.target=DisplayObject3D.ZERO;
            camera.zoom=zoom;
            camera.focus=focus;
            
            //文字列マテリアルの設定
            var mat:Letter3DMaterial=new Letter3DMaterial();
            mat.fillColor=0xFFFFFF;
            mat.doubleSided=true;
            mat.doubleSided=mat.interactive=true;
            
            //文字列の生成
            second1=new Text3D("0123456789", new HelveticaBold(), mat);
            second2=new Text3D("012345", new HelveticaBold(), mat);
            minute1=new Text3D("0123456789", new HelveticaBold(), mat);
            minute2=new Text3D("012345", new HelveticaBold(), mat);
            hour1=new Text3D("01234567890", new HelveticaBold(), mat);
            hour2=new Text3D("012", new HelveticaBold(), mat);
            rootNode.addChild(second1);
            rootNode.addChild(second2);
            rootNode.addChild(minute1);
            rootNode.addChild(minute2);
            rootNode.addChild(hour1);
            rootNode.addChild(hour2);
            second1.scale=second2.scale=minute1.scale=minute2.scale=hour1.scale=hour2.scale=0.4;
            
            date = new Date();
            prev_second1 = date.seconds%10;
            prev_second2 = date.seconds/10;
            prev_minute1 = date.minutes%10;
            prev_minute2 = date.minutes/10;
            prev_hour1 = date.hours%10;
            prev_hour2 = date.hours/10;
            
            //文字列を分解し、飛び散らせる。
            prev_second_text1 = dispersionWords(second1, prev_second1, 350);
            prev_second_text2 = dispersionWords(second2, prev_second2, 250);
            prev_minute_text1 = dispersionWords(minute1, prev_minute1, 50);
            prev_minute_text2 = dispersionWords(minute2, prev_minute2, -50);
            prev_hour_text1 = dispersionWords(hour1, prev_hour1, -250);
            prev_hour_text2 = dispersionWords(hour2, prev_hour2, -350);
            
            addEventListener(Event.ENTER_FRAME, onFrame);
        }

        private function dispersionWords(words:Text3D, tt:uint, tx:Number):DisplayObject3D
        {
            var xx:Number;
            var yy:Number;
            var zz:Number;
            var ary:Array = words.letters;
            var target:DisplayObject3D;
            var prev_text:DisplayObject3D;
            
            for(var i:uint = 0; i < ary.length; i++)
            {
                target = ary[i];
                xx = Math.random()*2000-1000;
                yy = Math.random()*2000-1000;
                zz = Math.random()*2000-1000;
                target.x=target.y=target.z=target.scale=0;
                
                if(i == tt){
                    Tweener.addTween(target, {scale:1.5, x:tx, y:0, z:0, rotationX:0, rotationY:0, rotationZ:0, time:0.5});
                    prev_text = target;
                }else{
                    Tweener.addTween(target, {scale:1, x:xx, y:yy, z:zz, rotationX:Math.random() * 360, rotationY:Math.random() * 360, rotationZ:Math.random() * 360, time:3, delay:2 * Math.random() + 1});
                }
            }
            return prev_text;
        }
        
        //対象の文字を指定した場所へ移動
        private function moveWords(word:DisplayObject3D, x:Number, y:Number, z:Number, scale:Number, rX:Number, rY:Number, rZ:Number):void
        {
            Tweener.addTween(word, {x:x, y:y, z:z, rotationX:rX, rotationY:rY, rotationZ:rZ, scale:scale, time: 0.5, transition:"easeOutBounce"});
        }

        private function onFrame(e:Event):void
        {
            var obj:DisplayObject3D;
            date = new Date();
            
            //時間が経過していたら
            if(prev_second1 != date.seconds%10){
                //時刻更新
                prev_second1 = date.seconds%10;
                obj = prev_second_text1;
                prev_second_text1 = second1.letters[date.seconds%10];
                Tweener.removeTweens(obj);
                //中心からどこかへ飛ばす
                moveWords(obj, Math.random()*2000-1000, Math.random()*2000-1000, Math.random()*2000-1000, 1, Math.random() * 360, Math.random() * 360, Math.random() * 360);
                Tweener.removeTweens(prev_second_text1);
                //中心へ持ってくる
                moveWords(prev_second_text1, 350, 0, 0, 1.5, -rootNode.rotationX, 0, 0);
            }
            if(prev_second2 != Math.floor(date.seconds/10)){
                prev_second2 = date.seconds/10;
                obj = prev_second_text2;
                prev_second_text2 = second2.letters[Math.floor(date.seconds/10)];
                Tweener.removeTweens(obj);
                moveWords(obj, Math.random()*2000-1000, Math.random()*2000-1000, Math.random()*2000-1000, 1, Math.random() * 360, Math.random() * 360, Math.random() * 360);
                Tweener.removeTweens(prev_second_text2);
                moveWords(prev_second_text2, 250, 0, 0, 1.5, -rootNode.rotationX, 0, 0);
            }
            if(prev_minute1 != date.minutes%10){
                prev_minute1 = date.minutes%10;
                obj = prev_minute_text1;
                prev_minute_text1 = minute1.letters[date.minutes%10];
                Tweener.removeTweens(obj);
                moveWords(obj, Math.random()*2000-1000, Math.random()*2000-1000, Math.random()*2000-1000, 1, Math.random() * 360, Math.random() * 360, Math.random() * 360);
                Tweener.removeTweens(prev_minute_text1);
                moveWords(prev_minute_text1, 50, 0, 0, 1.5, -rootNode.rotationX, 0, 0);
            }
            if(prev_minute2 != Math.floor(date.minutes/10)){
                prev_minute2 = date.minutes/10;
                obj = prev_minute_text2;
                prev_minute_text2 = minute2.letters[Math.floor(date.minutes/10)];
                Tweener.removeTweens(obj);
                moveWords(obj, Math.random()*2000-1000, Math.random()*2000-1000, Math.random()*2000-1000, 1, Math.random() * 360, Math.random() * 360, Math.random() * 360);
                Tweener.removeTweens(prev_minute_text2);
                moveWords(prev_minute_text2, -50, 0, 0, 1.5, -rootNode.rotationX, 0, 0);
            }
            if(prev_hour1 != date.hours%10){
                prev_hour1 = date.hours%10;
                obj = prev_hour_text1;
                prev_hour_text1 = hour1.letters[date.hours%10];
                Tweener.removeTweens(obj);
                moveWords(obj, Math.random()*2000-1000, Math.random()*2000-1000, Math.random()*2000-1000, 1, Math.random() * 360, Math.random() * 360, Math.random() * 360);
                Tweener.removeTweens(prev_hour_text1);
                moveWords(prev_hour_text1, -250, 0, 0, 1.5, -rootNode.rotationX, 0, 0);
            }
            if(prev_hour2 != Math.floor(date.hours/10)){
                prev_hour2 = date.hours/10;
                obj = prev_hour_text2;
                prev_hour_text2 = hour2.letters[Math.floor(date.hours/10)];
                Tweener.removeTweens(obj);
                moveWords(obj, Math.random()*2000-1000, Math.random()*2000-1000, Math.random()*2000-1000, 1, Math.random() * 360, Math.random() * 360, Math.random() * 360);
                Tweener.removeTweens(prev_hour_text2);
                moveWords(prev_hour_text2, -350, 0, 0, 1.5, -rootNode.rotationX, 0, 0);
            }
            
            rootNode.rotationX++;
            prev_second_text1.rotationX = prev_second_text2.rotationX = prev_minute_text1.rotationX = prev_minute_text2.rotationX
            = prev_hour_text1.rotationX = prev_hour_text2.rotationX = -rootNode.rotationX;
        }
    }
}
