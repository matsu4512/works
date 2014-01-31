package {
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Matrix;
    
    import frocessing.color.ColorHSV;

    [SWF(width=465, height=465, backgroundColor=0x0, frameRate=30)]

    public class Main extends Sprite {
        
        private var cvs:BitmapData;
        private var glow_bmpData:BitmapData;
        private var glowMtx:Matrix;
        private var particles:Array;
        private var hsvc:ColorHSV = new ColorHSV(0,0.6,0.6);
        private var color:uint = 0;
        
        public function Main(){
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            this.cvs = new BitmapData(465, 465, false, 0x0);
            addChild(new Bitmap(cvs)) as  Bitmap;
            glow_bmpData = new BitmapData(465 / 5, 465 / 5, false, 0x0);
            var bm:Bitmap = addChild(new Bitmap(glow_bmpData, PixelSnapping.NEVER, true)) as Bitmap;
            bm.scaleX = bm.scaleY = 5;
            bm.blendMode = BlendMode.ADD;
            glowMtx = new Matrix(0.2, 0, 0, 0.2);
            particles = [];

            addEventListener(Event.ENTER_FRAME, update);
        }
        
        public function createParticle(xx:Number, yy:Number, c:int, vx:Number, vy:Number):void {
            var p:Particle = new Particle();
            p.x = xx;
            p.y = yy;
            p.vx = vx;
            p.vy = vy;
            p.c = c;
            particles.push(p);
        }
        
        public function update(e:Event):void {
            cvs.lock();
            cvs.fillRect(cvs.rect, 0);
            var n:int = particles.length;
            while (n--) {
                var p:Particle = particles[n];
                p.vx *= 1.01;
                p.vy *= 1.01;
                p.x += p.vx;
                p.y += p.vy;
                cvs.setPixel(p.x, p.y, p.c);
                if (p.y < 0 || p.y > stage.stageHeight || p.x < 0|| p.x > stage.stageWidth) {
                    particles.splice(n, 1);
                }
            }
            cvs.unlock();
            glow_bmpData.draw(cvs, glowMtx);
            
            n = 10;
            hsvc.h += 3;
            var c:uint = (hsvc.toRGB().value);;
            while (n--) {
                createParticle(mouseX, mouseY, c, Math.random()*10-5, Math.random()*10-5);
            }
        }
    }
}

class Particle{
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var c:uint;
}

