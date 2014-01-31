package {

    import com.adobe.utils.AGALMiniAssembler;

    import flash.display.*;

    import flash.display3D.*;

    import flash.display3D.textures.*;

    import flash.events.*;

    import flash.geom.*;

    import flash.net.URLRequest;

    

    [SWF(width="500", height="500", frameRate="60")]

    public class Main extends Sprite {

        

        private var ctx:Context3D;

        private var WIDTH:Number = 500;

        private var HEIGHT:Number = 500;

        

        private var vertexParticle:VertexBuffer3D;

        private var indexParticle:IndexBuffer3D;

        private var textureParticle:Texture;

        private var transformVec:Vector.<Number>;

        private var colorVec:Vector.<Number>;

        private var particles:Vector.<Particle>=new Vector.<Particle>();

        private var balls:Vector.<FireBall> = new Vector.<FireBall>();

        

        // 頂点シェーダ

        private const VERTEX_SHADER:String =

            "mov　vt0, va0 \n"+                

            "mul vt0.xy, vt0, vc4.ww \n"+    //サイズを乗算して拡大

            "add vt0.xy, vt0, vc4.xy \n"+    //位置を移動

            "m44 op, vt0, vc0 \n"+            //座標を表示範囲に正規化

            "mov v0, va1";

        

        // ピクセルシェーダ

        private const PIXEL_SHADER:String =

            "tex ft0, v0, fs0<2d,linear> \n"+    

            "mul oc, ft0, fc0";                

        

        

        public function Main(){

            stage.scaleMode = StageScaleMode.NO_SCALE;

            stage.align = StageAlign.TOP_LEFT;

            var stage3d:Stage3D = stage.stage3Ds[0];

            stage3d.addEventListener(Event.CONTEXT3D_CREATE, context3DCreateHandler);

            stage3d.requestContext3D();

        }

        

        private function context3DCreateHandler(e:Event):void {

            ctx = Stage3D(e.target).context3D;

            ctx.configureBackBuffer(WIDTH, HEIGHT, 2, false);

            

            //頂点データ・インデックスデータ

            var vertices:Vector.<Number> = new <Number>[

                -0.5,  0.5, 0, 0,

                0.5,  0.5, 0, 1,

                0.5, -0.5, 1, 1,

                -0.5, -0.5, 0, 1];

            var indices:Vector.<uint> = new <uint>[0,1,2, 2,3,0];

            

            vertexParticle = ctx.createVertexBuffer(4, 4);

            vertexParticle.uploadFromVector(vertices, 0, 4);

            

            indexParticle = ctx.createIndexBuffer(6);

            indexParticle.uploadFromVector(indices, 0, 6);

            

            var screenMat:Matrix3D = new Matrix3D();

            screenMat.appendScale(1/(WIDTH/2), 1/(HEIGHT/2), 1);

            ctx.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, screenMat, true);

            

            transformVec = new <Number>[0, 0, 0, 1];

            colorVec = new <Number>[1, 1, 1, 1];

            

            //テクスチャ生成

            var sp:Sprite = new Sprite();

            var m:Matrix = new Matrix();

            m.createGradientBox(64, 64, 0, -32, -32);

            sp.graphics.beginGradientFill(GradientType.RADIAL, [0xFF8888, 0xFF8888], [0.5, 0], [0, 255], m);

            sp.graphics.drawCircle(0,0,64);

            sp.graphics.endFill();

            var bmpd:BitmapData = new BitmapData(64, 64, true, 0);

            bmpd.draw(sp, new Matrix(1,0,0,1,32,32));

            textureParticle = ctx.createTexture(64, 64, Context3DTextureFormat.BGRA, false);

            textureParticle.uploadFromBitmapData(bmpd);

            

            // 頂点シェーダをコンパイル;

            var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();

            vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);

            // ピクセルシェーダをコンパイル;

            var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();

            fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, PIXEL_SHADER);

            

            var programPair:Program3D;

            // Program3Dのインスタンスを取得

            programPair = ctx.createProgram();

            // 頂点シェーダとピクセルシェーダのコードをGPUにアップロード

            programPair.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);

            // 使用するシェーダのペアを指定;

            ctx.setProgram(programPair);

            

            ctx.setVertexBufferAt(0, vertexParticle, 0, Context3DVertexBufferFormat.FLOAT_2);

            ctx.setVertexBufferAt(1, vertexParticle, 2, Context3DVertexBufferFormat.FLOAT_2);

            ctx.setTextureAt(0, textureParticle);

            

            ctx.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);

            stage.addEventListener(MouseEvent.CLICK, createBall);

            addEventListener(Event.ENTER_FRAME, onEnterFrame);

        }

        

        private function onEnterFrame(e:Event):void {

            i = balls.length;

            while(i--){

                var ball:FireBall = balls[i];

                createParticles(ball);

                ball.x += ball.vx;

                ball.y += ball.vy;

                ball.vy += 0.1;

                if(ball.x < 0){

                    ball.x = 0;

                    ball.vx *= -1;

                }

                if(ball.x > WIDTH){

                    ball.x = WIDTH;

                    ball.vx *= -1;

                }

                if(ball.y > HEIGHT+50) balls.splice(i,1);

            }

            

            var i:int = particles.length;

            while(i--){

                var p:Particle = particles[i];

                p.x += -p.vx;

                p.y += -p.vy;

                p.vx += p.ax;

                p.vy += p.ay;

                p.size -= 2;

                if(p.size <= 0){

                    particles.splice(i,1);

                }

            }

           
           

            ctx.clear();

            

            for (i = 0; i<particles.length; i++){

                p = particles[i];

                transformVec[0] = p.x;

                transformVec[1] = p.y;

                transformVec[3] = p.size;

                colorVec[0]     = p.r;

                colorVec[1]     = p.g;

                colorVec[2]     = p.b;

                ctx.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, transformVec);

                ctx.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorVec);

                ctx.drawTriangles(indexParticle);

            }

            

            ctx.present();

        }

        

        private function createBall(e:MouseEvent):void{

            balls.push(new FireBall(mouseX, mouseY, Math.random()*20-10, Math.random()*10-10, Math.random()*Math.random()*50+5));

        }

        

        private function createParticles(ball:FireBall):void {

            for (var i:int = 0; i<ball.N; i++){

                particles.push(new Particle(ball.x-WIDTH/2, -(ball.y-HEIGHT/2), Math.random()*10-5, Math.random()*10-5, 0, -Math.random()));

            }

        }

    }

}



class FireBall{

    public var x:Number, y:Number;

    public var vx:Number, vy:Number;

    public var N:int;

    

    public function FireBall(x:Number, y:Number, vx:Number, vy:Number, N:Number):void{

        this.x = x; this.y = y;

        this.vx = vx; this.vy = vy;

        this.N = N;

    }

}



class Particle{

    public var x:Number, y:Number;

    public var vx:Number, vy:Number;

    public var ax:Number, ay:Number;

    public var size:Number;

    public var r:Number, g:Number, b:Number;

    

    public function Particle(x:Number, y:Number, vx:Number, vy:Number, ax:Number, ay:Number){

        this.x = x; this.y = y;

        this.vx = vx; this.vy = vy;

        this.ax = ax; this.ay = ay;

        size = 50*Math.random()+20;

        r = Math.random();

        g = Math.random()*0.5;

        b = Math.random()*0.5;

    }

}