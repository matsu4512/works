package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    
    import idv.cjcat.stardust.common.actions.*;
    import idv.cjcat.stardust.common.actions.triggers.DeathTrigger;
    import idv.cjcat.stardust.common.clocks.SteadyClock;
    import idv.cjcat.stardust.common.initializers.*;
    import idv.cjcat.stardust.common.math.UniformRandom;
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
        
        private var emitter:Emitter2D;
        private var point:SinglePoint;
        
        public function Main()
        {
            graphics.beginFill(0); graphics.drawRect(0,0,465,465); graphics.endFill();
            colorTrans=new ColorTransform(0.8, 0.95, 0.99, 0.9);
            
            canvas = new Sprite();
            bmpData=new BitmapData(465, 465, true, 0xFF00000);
            bmp=new Bitmap(bmpData);
            addChild(bmp);
            
            emitter = new Emitter2D(new SteadyClock(0.5));
            emitter.particleHandler = new DisplayObjectHandler(canvas);
            
            //壁にぶつかった後に生成されるパーティクルの設定
            var spawn:Spawn = new Spawn(new UniformRandom(5, 0));
            spawn.addInitializer(new Mask(2));
            spawn.addInitializer(new DisplayObjectClass(Star, [new GlowFilter(0, 1.0, 8, 8)]));
            spawn.addInitializer(new Life(new UniformRandom(20, 0)));
            spawn.addInitializer(new Velocity(new CircleZone(0, 0, 10)));
            spawn.addInitializer(new Scale(new UniformRandom(0.5, 0)));
            spawn.addInitializer(new Omega(new UniformRandom(5, 5)));
            var deathTrigger:DeathTrigger = new DeathTrigger();
            deathTrigger.addAction(spawn);
            
            //始めに生成されるパーティクルの設定
            point = new SinglePoint();
            emitter.addInitializer(new Position(point));
            emitter.addInitializer(new DisplayObjectClass(Star, [new GlowFilter(0, 1.0, 8, 8)]));
            emitter.addInitializer(new Velocity(new CircleZone(0, 0, 5)));
            emitter.addInitializer(new Omega(new UniformRandom(5, 5)));
            
            //共通のアクション
            var commonActions:CompositeAction = new CompositeAction();
            var gravity:Gravity = new Gravity();
            gravity.addField(new UniformField(0.15, 0.2));
            commonActions.mask = 1 | 2;
            commonActions.addAction(gravity);
            commonActions.addAction(new Move());
            commonActions.addAction(new Spin());
            emitter.addAction(commonActions);
            
            var age:Age = new Age();
            age.mask = 2;
            var death:DeathLife = new DeathLife();
            death.mask = 2;
            emitter.addAction(age);
            emitter.addAction(death);
            
            var curve:ScaleCurve = new ScaleCurve(0, 20);
            curve.inScale = 1;
            curve.outScale = 0;
            curve.mask = 2;
            emitter.addAction(curve);
            //パーティクル消滅後に小さいパーティクルを生成すつように設定
            emitter.addAction(deathTrigger);
            //消滅する領域の設定
            emitter.addAction(new DeathZone(new RectZone(0, 0, 400, 400), true));
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void
        {
            point.x = mouseX;
            point.y = mouseY;
            emitter.step();
            
            bmpData.draw(canvas);
            bmpData.colorTransform(bmpData.rect, colorTrans);
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
