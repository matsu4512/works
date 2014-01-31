package {
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    
    import frocessing.color.ColorHSV;

    [SWF(width=465, height=465, backgroundColor=0x0, frameRate=30)]

    public class Main extends Sprite {
        
        private var cvs:BitmapData;
        private var glow_bmpData:BitmapData;
        private var glowMtx:Matrix;
        private var particles:Array;
        private var pixel_particles:Array;
        private var w:Number, h:Number, hw:Number, hh:Number;
        private var hsvc:ColorHSV = new ColorHSV(0,0.5,0.5);
        private var color:uint = 0;
        private var sp:Sprite = new Sprite();
        private var glowf:GlowFilter = new GlowFilter();
        
        public function Main() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            w = stage.stageWidth;
            h = stage.stageHeight;
            
            this.cvs = new BitmapData(465, 465, false, 0x0);
            addChild(new Bitmap(cvs)) as  Bitmap;
            glow_bmpData = new BitmapData(465 / 4, 465 / 4, false, 0x0);
            var bm:Bitmap = addChild(new Bitmap(glow_bmpData, PixelSnapping.NEVER, true)) as Bitmap;
            bm.scaleX = bm.scaleY = 4;
            bm.blendMode = BlendMode.ADD;
            glowMtx = new Matrix(0.25, 0, 0, 0.25);
            particles = [];
            pixel_particles = [];

            addEventListener(Event.ENTER_FRAME, update);
        }
        
        public function createParticle(xx:Number, yy:Number, c:int, vx:Number, vy:Number, size:Number):void {
            var p:Particle = new Particle();
            p.x = xx;
            p.y = yy;
            p.vx = vx;
            p.vy = vy;
            p.c = c;
            var g:Graphics = p.graphics;
            g.beginFill(0xffffff);
            g.drawCircle(0,0,size);
            g.endFill();
            glowf.color = c;
            glowf.alpha = 1;
            glowf.blurX = 8;
            glowf.blurY = 8;
            glowf.strength = 6;
            glowf.quality = 6;
            p.filters = [glowf];
            sp.addChild(p);
            particles.push(p);
        }
        
        public function createPixelParticle(xx:Number, yy:Number, c:int, vx:Number, vy:Number):void{
            var p:pixelParticle = new pixelParticle();
            p.x = xx;
            p.y = yy;
            p.vx = vx;
            p.vy = vy;
            p.c = c;
            p.life = 20;
            pixel_particles.push(p);
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
                createPixelParticle(p.x, p.y, p.c, -p.vx/2.0,-p.vy/2.0);
                if (p.y < 0 || p.y > h || p.x < 0|| p.x > w) {
                    particles.splice(n, 1);
                    sp.removeChild(p);
                }
            }
            cvs.draw(sp);
            
            n = pixel_particles.length;
            while (n--) {
                var pp:pixelParticle = pixel_particles[n];
                pp.x += pp.vx;
                pp.y += pp.vy;
                pp.life--;
                cvs.setPixel32(pp.x, pp.y, pp.c);
                if (pp.life <= 0) {
                    pixel_particles.splice(n, 1);
                }
            }
            cvs.unlock();
            glow_bmpData.draw(cvs, glowMtx);
            
            hsvc.h += 3;
            var c:uint = (hsvc.toRGB().value);
            createParticle(mouseX, mouseY, c, Math.random()*14-7, Math.random()*14-7, Math.random()*3+1);
        }
    }
}
    import flash.display.Shape;
    

class Particle extends Shape{
    public var vx:Number;
    public var vy:Number;
    public var c:uint;
}

class pixelParticle {
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var c:uint;
    public var life:int;
}