package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    
    import idv.cjcat.stardust.common.actions.*;
    import idv.cjcat.stardust.common.actions.triggers.DeathTrigger;
    import idv.cjcat.stardust.common.clocks.SteadyClock;
    import idv.cjcat.stardust.common.initializers.*;
    import idv.cjcat.stardust.common.math.*;
    import idv.cjcat.stardust.threeD.actions.*;
    import idv.cjcat.stardust.threeD.emitters.Emitter3D;
    import idv.cjcat.stardust.threeD.fields.UniformField3D;
    import idv.cjcat.stardust.threeD.handlers.DisplayObjectHandler3D;
    import idv.cjcat.stardust.threeD.initializers.*;
    import idv.cjcat.stardust.threeD.zones.*;
    import idv.cjcat.stardust.twoD.actions.*;
    import idv.cjcat.stardust.twoD.emitters.Emitter2D;
    import idv.cjcat.stardust.twoD.fields.UniformField;
    import idv.cjcat.stardust.twoD.handlers.DisplayObjectHandler;
    import idv.cjcat.stardust.twoD.initializers.*;
    import idv.cjcat.stardust.twoD.zones.*;
    
    [SWF(width=465, height=465, frameRate=60)]
    public class Main extends Sprite
    {
        private var colorTrans:ColorTransform;
        private var canvas:Sprite;
        private var bmp:Bitmap;
        private var bmpData:BitmapData;
        private var matrix:Matrix;
        
        private var currentX:Number=0, currentY:Number=0;
        
        private var emitter:Emitter3D;
        private var point:SinglePoint;
        
        public function Main()
        {
            graphics.beginFill(0); graphics.drawRect(0,0,465,465); graphics.endFill();
            colorTrans=new ColorTransform(0.8, 0.95, 0.99, 0.9);
            matrix = new Matrix(1,0,0,1,stage.stageWidth/2, stage.stageHeight/2);
            canvas = new Sprite();
            bmpData=new BitmapData(465, 465, true, 0xFF00000);
            bmp=new Bitmap(bmpData);
            addChild(bmp);
            emitter = new Emitter3D(new SteadyClock(0.7));
            emitter.particleHandler = new DisplayObjectHandler3D(canvas);
            
            //壁にぶつかった後に生成されるパーティクルの設定
            var spawn:Spawn3D = new Spawn3D(new UniformRandom(5, 0));
            spawn.addInitializer(new Mask(2));
            spawn.addInitializer(new DisplayObjectClass3D(Star, [new GlowFilter(0, 1.0, 8, 8)]));
            spawn.addInitializer(new Life(new UniformRandom(30, 0)));
            spawn.addInitializer(new Velocity3D(new SphereZone(0, 0, 0, 7)));
            spawn.addInitializer(new Scale(new UniformRandom(0.7, 0)));
            spawn.addInitializer(new Omega3D(new UniformRandom(5, 5), new UniformRandom(5, 5), new UniformRandom(5, 5)));
            var deathTrigger:DeathTrigger = new DeathTrigger();
            deathTrigger.addAction(spawn);
            
            //始めに生成されるパーティクルの設定
            emitter.addInitializer(new Position3D(new SinglePoint3D()));
            emitter.addInitializer(new DisplayObjectClass3D(Star, [new GlowFilter(0, 1.0, 8, 8)]));
            emitter.addInitializer(new Velocity3D(new SphereZone(0, 0, 0, 20)));
            emitter.addInitializer(new Omega3D(new UniformRandom(5, 5), new UniformRandom(5, 5), new UniformRandom(5, 5)));
            
            //共通のアクション
            var commonActions:CompositeAction = new CompositeAction();
            commonActions.mask = 1 | 2;
            commonActions.addAction(new Move3D());
            commonActions.addAction(new Spin3D());
            emitter.addAction(commonActions);
            
            var age:Age = new Age();
            age.mask = 2;
            var death:DeathLife = new DeathLife();
            death.mask = 2;
            emitter.addAction(age);
            emitter.addAction(death);
            emitter.addAction(new Accelerate3D(0.01));
            
            var curve:ScaleCurve = new ScaleCurve(0, 30);
            curve.inScale = 1;
            curve.outScale = 0;
            curve.mask = 2;
            emitter.addAction(curve);
            //パーティクル消滅後に小さいパーティクルを生成すつように設定
            emitter.addAction(deathTrigger);
            //消滅する領域の設定
            emitter.addAction(new DeathZone3D(new SphereZone(0, 0, 0, 400), true));
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void
        {
            currentX += (mouseX - currentX)*0.02;
            currentY += (mouseY - currentY)*0.02;
            
            mouseRotate();
            emitter.step();
            
            bmpData.draw(canvas, matrix);
            bmpData.colorTransform(bmpData.rect, colorTrans);
        }
        
        //カメラを回転(Stardustのexampleから頂きました。)
        protected function mouseRotate():void {
            var theta:Number = 0.55 * (currentX - stage.stageWidth/2) * StardustMath.DEGREE_TO_RADIAN;
            var phy:Number = 0.35 * (currentY - stage.stageHeight/2) * StardustMath.DEGREE_TO_RADIAN;
            phy = StardustMath.clamp(phy, -0.45 * Math.PI, 0.45 * Math.PI);
            var r:Number = 400;
            var x:Number = r * Math.sin(theta) * Math.cos(phy);
            var y:Number = r * Math.sin(phy);
            var z:Number = -r * Math.cos(theta) * Math.cos(phy);
            (emitter.particleHandler as DisplayObjectHandler3D).camera.position.x = x;
            (emitter.particleHandler as DisplayObjectHandler3D).camera.position.y = y;
            (emitter.particleHandler as DisplayObjectHandler3D).camera.position.z = z;
            (emitter.particleHandler as DisplayObjectHandler3D).camera.direction.set( -x, -y, -z);
        }
    }
}
import flash.display.Sprite;
import flash.filters.GlowFilter;

class Star extends Sprite
{
    public function Star(glow:GlowFilter)
    {
        glow.color = Math.random() * 0xffffff;
        filters = [glow];
        
        var r:Number = Math.random() * 8 + 5;
        var p:int = 5;
        var r2:Number=r / 2;
        var angle:Number=-90;
        var addtion:Number=360 / (p * 2);
        graphics.beginFill(0xffffff);
        graphics.moveTo(0, -r);
        for (var i:int=0; i < p * 2; i++)
        {
            angle+=addtion;
            var to_x:Number;
            var to_y:Number;
            var radian:Number=angle * Math.PI / 180;
            if (i % 2)
            {
                to_x=r * Math.cos(radian);
                to_y=r * Math.sin(radian);
            }
            else
            {
                to_x=r2 * Math.cos(radian);
                to_y=r2 * Math.sin(radian);
            }
            graphics.lineTo(to_x, to_y);
        }
        graphics.endFill();
    }
}
