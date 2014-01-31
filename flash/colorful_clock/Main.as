/*
Full Screenで見た方が綺麗だと思われます。

スクリーンセーバー化もしてみたので欲しい方はこちらからどうぞ
http://d.hatena.ne.jp/matsu4512/20100330
*/

package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.*;
    import flash.geom.*;
    
    import frocessing.color.*;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.events.TweenEvent;
    import org.libspark.betweenas3.tweens.*;
    import org.osmf.metadata.TemporalFacet;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.cameras.SpringCamera3D;
    import org.papervision3d.core.effects.view.ReflectionView;
    import org.papervision3d.core.geom.renderables.*;
    import org.papervision3d.core.math.Number3D;
    import org.papervision3d.materials.ColorMaterial;
    import org.papervision3d.materials.special.Letter3DMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.Plane;
    import org.papervision3d.objects.special.ParticleField;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.typography.*;
    import org.papervision3d.typography.fonts.HelveticaBold;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.Viewport3D;
    public class Main extends ReflectionView
    {
        private var timeNums:Text3D;
        private var nums:Text3D;
        private var timeNumsList:Vector.<VectorLetter3D>;
        private var cnt:Number = 0;
        private var timeStr:String;
        private var numsScene:DisplayObject3D;
        private var hourNum:Vector.<Text3D>;
        private var hourNumsScene:DisplayObject3D;
        
        private var longHand:Sprite;
        private var shortHand:Sprite;
        
        private var Ratio:Number;
        private var OutRadius:Number=700, InRadius:Number=350;
        private var LongHandLength:Number=280, ShortHandLength:Number=160, LongBallSize:Number=4, ShortBallSize:Number=6;
        
        
        public function Main()
        {
            Ratio = stage.stageHeight/645;
            graphics.beginFill(0);
            graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight);
            graphics.endFill();
            OutRadius*=Ratio; InRadius*=Ratio; LongHandLength*=Ratio; ShortHandLength*=Ratio; LongBallSize*=Ratio; ShortBallSize*=Ratio;
            var currentTime:Array = new Date().toTimeString().split(" ")[0].split(":");
            //長針の生成
            longHand = createHand(LongHandLength, LongBallSize, 13*Ratio, 7*Ratio, 7*Ratio, 0xFFFFFF, 0xFF0000);
            viewport.containerSprite.addChild(longHand);
            //短針の生成
            shortHand = createHand(ShortHandLength, ShortBallSize, 26*Ratio, 7*Ratio, 13*Ratio, 0xFFFFFF, 0x0000FF);
            viewport.containerSprite.addChild(shortHand);
            
            //一秒間隔で動く数字を格納する空間
            numsScene = new DisplayObject3D();
            //時を表す数字を格納する空間
            hourNumsScene = new DisplayObject3D();
            scene.addChild(numsScene);
            scene.addChild(hourNumsScene);
            //addChild(new Stats);
            
            var delayTweens:Array = [];
            shortHand.alpha = longHand.alpha = 0;
            delayTweens.push(BetweenAS3.tween(longHand, {scaleX:1, scaleY:1, alpha:1}, {scaleX:0, scaleY:0, alpha:0}, 3));
            delayTweens.push(BetweenAS3.tween(shortHand, {scaleX:1, scaleY:1, alpha:1}, {scaleX:0, scaleY:0, alpha:0}, 3));
            
            timeStr = "xx:xx:xx";
            //中央にくる数字の位置を取得するためのText3D
            timeNums = new Text3D("00:00:00", new HelveticaBold, new Letter3DMaterial(0xFFFFFF));
            //":"だけは固定なので表示させておく
            scene.addChild(timeNums.letters[2]);
            scene.addChild(timeNums.letters[5]);
            
            hourNum = new Vector.<Text3D>();
            
            var tweens:Array = [];
            
            var hsv:ColorHSV = new ColorHSV();
            //1～12までの数字の生成
            for(var i:int = 1; i <= 12; i++){
                hsv.h = 360/12*(i-1);
                var txt:Text3D = new Text3D(i.toString(), new HelveticaBold(), new Letter3DMaterial(hsv.toRGB().value, 0));
                var angle:Number = -2*Math.PI / 12 * i + Math.PI/2;
                txt.x = OutRadius*Math.cos(angle);
                txt.y = OutRadius*Math.sin(angle);
                txt.filters = [new GlowFilter(0xFFFFFF, 1,0,0,2)];
                hourNum.push(txt);
                hourNumsScene.addChild(txt);
                txt.scale*=Ratio;
                tweens.push(BetweenAS3.to(txt.material, {fillAlpha:1}, 4));
            }
            hourNumsScene.scale = 0;
            tweens.push(BetweenAS3.to(hourNumsScene, {rotationZ:360, scale:1}, 4, Back.easeOut));
            
            //周りの数字
            nums = new Text3D("0123456789", new HelveticaBold, new Letter3DMaterial(0xFFFFFF));
            
            timeNumsList = new Vector.<VectorLetter3D>();
            for(i = 0; i < timeStr.length; i++){
                timeNumsList.push(new VectorLetter3D(timeStr.charAt(i), new Letter3DMaterial(0xFFFFFF), new HelveticaBold));
            }
            
            //0～9の数字の色の設定と配置
            for(i = 0; i < nums.letters.length; i++){
                var char:VectorLetter3D = nums.letters[i];
                hsv.h = 360/10*i;
                char.material = new Letter3DMaterial(hsv.toRGB().value);
                angle = 2*Math.PI / 10 * i + Math.PI/2;
                char.x = Math.cos(angle)*InRadius;
                char.y = Math.sin(angle)*InRadius;
                char.scale *= 0.8*Ratio;
                char.rotationZ = hsv.h;
                char.filters = [new GlowFilter(0xFFFFFF, 1, 0, 0,1)];
            }
            numsScene.addChild(nums);

            //鏡面の設定
            viewportReflection.filters = [new BlurFilter()];
            viewportReflection.alpha = 0.7;
            surfaceHeight = -160*Ratio;
            
            addEventListener(Event.ENTER_FRAME, onFrame);
            
            BetweenAS3.serial(BetweenAS3.parallelTweens(tweens), BetweenAS3.parallelTweens(delayTweens)).play();
            
        }
        
        
        private function onFrame(event:Event):void{
            //時間の文字列の取得
            var str:String = new Date().toTimeString().split(" ")[0];
            for(var i:int = 0; i < str.length; i++){
                //前フレームと比べて変わっている部分があるかどうか
                if(str.charAt(i) == timeStr.charAt(i))continue;
                var time:Array = str.split(":");
                //変動した部分の数字を取得
                var index:int = int(str.charAt(i));
                //移動する数字の生成
                var char:VectorLetter3D = new VectorLetter3D(index.toString(), new Letter3DMaterial(), new HelveticaBold());
                //周りに並んでいる数字の取得
                var numChar:VectorLetter3D = nums.letters[index];
                //色、位置を同じにする
                char.material.fillColor = numChar.material.fillColor;
                char.x = numChar.sceneX;
                char.y = numChar.sceneY;
                char.z = numChar.sceneZ;
                
                //角度計算
                var angle:Number = Math.atan2(numChar.sceneX, numChar.sceneY)/(2*Math.PI)*360;
                char.rotationZ = -angle;
                char.scale *= 0.8*Ratio;
                scene.addChild(char);
                
                //中央へ
                var cChar:VectorLetter3D = timeNums.letters[i];
                var tweens:Array = [];
                var rgb:ColorRGB = new ColorRGB();
                rgb.value = char.material.fillColor;
                var hsv:ColorHSV = rgb.toHSV();
                
                //numsを回転
                if(i == 7){
                    tweens.push(BetweenAS3.to(numsScene, {rotationZ:numsScene.rotationZ-6}, 0.7, Back.easeOut));
                }
                else if(i == 4){
                    if(time[1] == 0) longHand.rotationZ -= 360;
                    tweens.push(BetweenAS3.to(longHand, {rotationZ:time[1]*6}, 0.7, Back.easeOut));
                    hsv.h = time[1]*6;
                    if(time[0] == 0 && time[1] == 0) longHand.rotationZ -= 360;
                    tweens.push(BetweenAS3.to(shortHand, {rotationZ:time[0]%12*30+time[1]*0.5}, 0.7));
                    hsv.h = time[0]%12*30+time[1]*0.5;
                    numChar.useOwnContainer = true;
                    tweens.push(BetweenAS3.to(numChar.filters[0], {blurX:16, blurY:16}, 1, Back.easeOut));
                }
                //徐々に色を白に
                var tween1:ITween = BetweenAS3.to(hsv, {s:0}, 0.7);
                tween1.onUpdate = function(c:VectorLetter3D, hsv:ColorHSV):void{ c.material.fillColor = hsv.toRGB().value };
                tween1.onUpdateParams = [char, hsv];
                tweens.push(tween1);
                //位置の移動
                tweens.push(BetweenAS3.to(char, {x:cChar.x, y:cChar.y, z:cChar.z, rotationZ:cChar.rotationZ, scale:1}, 0.7));
                
                if(timeNumsList[i].char == "x"){
                    timeNumsList[i] = char;
                }
                else{
                    if(i == 4){
                        var tween:ITween = BetweenAS3.to(nums.letters[int(timeStr.charAt(i))].filters[0], {blurX:0, blurY:0}, 1);
                        tween.onComplete = function(c:VectorLetter3D):void{ c.useOwnContainer = false; };
                        tween.onCompleteParams = [nums.letters[int(timeStr.charAt(i))]];
                        tweens.push(tween);
                    }
                    var num:int = int(timeNumsList[i].char);
                    //外側へ
                    var oChar:VectorLetter3D = nums.letters[num];
                    rgb.value = oChar.material.fillColor;
                    hsv = new ColorHSV(rgb.toHSV().h,0,1);
                    //色の変化
                    var tween2:ITween = BetweenAS3.to(hsv, {s:1}, 0.7);
                    tween2.onUpdate = function(c:VectorLetter3D, color:ColorHSV):void{ c.material.fillColor = color.toRGB().value; };
                    tween2.onUpdateParams = [timeNumsList[i], hsv];
                    tweens.push(tween2);
                    
                    //角度計算
                    angle = Math.atan2(oChar.sceneX, oChar.sceneY)/(2*Math.PI)*360+6;
                    var nextPos:Number3D = new Number3D(Math.cos(-angle/360*2*Math.PI+Math.PI/2)*InRadius, Math.sin(-angle/360*2*Math.PI+Math.PI/2)*InRadius);
                    //位置の変化
                    var tween3:ITween = BetweenAS3.to(timeNumsList[i], {x:nextPos.x, y:nextPos.y, z:oChar.sceneZ, rotationZ:-angle, scale:0.8*Ratio}, 0.7);
                    tween3.onComplete = function(ii:int, c:VectorLetter3D):void{scene.removeChild(timeNumsList[ii]); timeNumsList[ii] = c;};
                    tween3.onCompleteParams = [i, char];
                    tweens.push(tween3);
                }
                BetweenAS3.parallelTweens(tweens).play();
            }
            timeStr = str;
            singleRender();
        }
        
        private function createHand(length:Number, ballSize:Number, glow:Number, ballBlur:Number, lightBlur:Number, lightColor:uint, ballColor:uint):Sprite{
            var hand:Sprite = new Sprite();
            var light:Shape = new Shape();
            var g:Graphics = light.graphics;
            //光っぽいところの生成
            g.beginFill(lightColor);
            g.lineTo(-ballSize, -length);
            g.lineTo(ballSize, -length);
            g.lineTo(0,0);
            g.endFill();
            light.filters = [new BlurFilter(lightBlur, lightBlur, 4)];
            light.alpha = 0.7;
            hand.addChild(light);
            //先端の玉の生成
            var ball:Shape = new Shape();
            g = ball.graphics;
            g.beginFill(0xFFFFFF);
            g.drawCircle(0,0,ballSize);
            g.endFill();
            ball.filters = [new BlurFilter(ballBlur,ballBlur,1), new GlowFilter(ballColor, 1,glow,glow,3)];
            ball.y = -length;
            ball.x = 0;
            hand.addChild(ball);
            return hand;
        }
    }
}