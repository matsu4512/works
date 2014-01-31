package 

{

    import com.adobe.utils.AGALMiniAssembler;

    import com.adobe.utils.PerspectiveMatrix3D;

    

    import flash.display.*;

    import flash.display3D.*;

    import flash.display3D.textures.Texture;

    import flash.events.Event;

    import flash.events.MouseEvent;

    import flash.geom.*;

    import flash.net.URLRequest;

    import net.wonderfl.utils.SequentialLoader;

    

    [SWF(width="500", height="500", frameRate="60")]

    public class Main extends Sprite

    {

        private const WIDTH:Number = 465;

        private const HEIGHT:Number = 465;

        

        private var stage3D:Stage3D;

        private var context3D:Context3D;

                

        // 頂点シェーダ

        private const VERTEX_SHADER:String =

            "m44 op, va0, vc0 \n" +        

            "mov v0, va1 \n";            //ピクセルシェーダへ

        

        // ピクセルシェーダ

        private const FRAGMENT_SHADER:String =

            //テクスチャ情報の処理

            "tex oc, v0, fs0<2d, linear>";    //色情報の取得  v2:uv座標, fs0:画像データ

        

        //頂点データ

        private var indices:IndexBuffer3D;

        private var vertices:VertexBuffer3D;

        private var vertexData:Vector.<Number>;

        private var indexData:Vector.<uint>;

        

        //ばね定数

        private const k:Number = 1.2;

        //減衰定数

        private const a:Number = 0.9;

        //この値が大きいほど、よりマウスに引き付けられる

        private const rep:Number = 50;

        //頂点の個数

        private var W:int = 30, H:int = 30;

        //一マスの大きさ

        private var MASSW:Number, MASSH:Number;

        //頂点の位置情報と加わっている力を格納する配列

        private var forces:Vector.<Number>;

        

        private var imageArray:Array = [];

        

        public function Main()

        {

            stage.scaleMode = StageScaleMode.NO_SCALE;

            stage.align = StageAlign.TOP_LEFT;

            

            stage3D = this.stage.stage3Ds[0];

            

            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);

            stage3D.requestContext3D(Context3DRenderMode.AUTO);

        }

        

        private function initVertex(e:Event=null):void{

            MASSH = 2.0/(W-1);

            MASSW = 2.0/(H-1);

            

            forces = new Vector.<Number>();

            vertexData = new Vector.<Number>();

            indexData = new Vector.<uint>();

            

            //頂点の座標とuv座標の設定

            for(var i:int = 0; i < H; i++){

                for(var j:int = 0; j < W; j++){

                    vertexData.push(

                        j/(W-1)*2.0-1.0,    //x

                        -(i/(H-1)*2.0-1.0),    //y

                        0.0,                //z

                        j/(W-1),            //u

                        i/(H-1)                //v

                    );

                    forces.push(0, 0);

                }

            }

            

            //各三角形にインデックスを割り振る

            for(i = 0; i < H-1; i++){

                for(j = 0; j < W-1; j++){

                    indexData.push(j+i*(W), (j+1)+i*(W), j+(i+1)*(W));

                    indexData.push((j+1)+i*(W), j+(i+1)*(W), (j+1)+(i+1)*(W));

                }

            }

            

            // 5個(頂点座標(x,y,z)、uv座標(u,v))の値を持つ頂点用の頂点バッファを作成

            vertices = context3D.createVertexBuffer(W*H, 5);

            // 頂点データをアップロード

            vertices.uploadFromVector(vertexData, 0, W*H);

            // 最初の属性は座標の情報：Float型の数値が3つ　これを属性レジスタ0に入れる

            context3D.setVertexBufferAt(0, vertices, 0, Context3DVertexBufferFormat.FLOAT_3);

            // uv情報 Float型が2つ　これを属性レジスタ1に入れる

            context3D.setVertexBufferAt(1, vertices, 3, Context3DVertexBufferFormat.FLOAT_2);

            //インデックスバッファを作成

            indices = context3D.createIndexBuffer(indexData.length);

            //インデックス情報をアップロード

            indices.uploadFromVector(indexData, 0, indexData.length);

            

            var texture:Texture = context3D.createTexture(512, 512, Context3DTextureFormat.BGRA, false);

            

            var loader:Loader = imageArray.pop();

            var bmpd:BitmapData=new BitmapData(512, 512);

            

            bmpd.draw(loader, new Matrix(512/loader.width, 0,0,512/loader.height));

            texture.uploadFromBitmapData(bmpd);

            //fs0に設定

            context3D.setTextureAt(0, texture);

            

            //レジスタに登録

            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, new Matrix3D());

            

            addEventListener(Event.ENTER_FRAME, onEnterFrame);

        }

        

        private function onContext3DCreate(event:Event):void

        {

            context3D = Stage3D(event.target).context3D;

            

            context3D.enableErrorChecking = true;

            context3D.configureBackBuffer(WIDTH, HEIGHT, 2, false);

            

            // 頂点シェーダをコンパイル;

            var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();

            vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);

            // ピクセルシェーダをコンパイル;

            var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();

            fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);

            

            var programPair:Program3D;

            // Program3Dのインスタンスを取得

            programPair = context3D.createProgram();

            // 頂点シェーダとピクセルシェーダのコードをGPUにアップロード

            programPair.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);

            // 使用するシェーダのペアを指定;

            context3D.setProgram(programPair);

            

//            initVertex();

            SequentialLoader.loadImages(["http://assets.wonderfl.net/images/related_images/3/36/3605/3605f29686918e48eefff9cc0a4f93002777b3de"], imageArray, initVertex);

        }

        

        private function onEnterFrame(e:Event):void{

            // drawTriangles()を呼ぶ前に必ずバッファをクリア;

            context3D.clear(0, 0, 0);

            

            doPuyo(mouseX/stage.stageWidth*2.0-1.0, -(mouseY/stage.stageHeight*2.0-1.0), 300.0);

            for(var i:int = 0; i < H; i++){

                for(var j:int = 0; j < W; j++){

                    var x:Number = vertexData[(i*W+j)*5], y:Number = vertexData[(i*W+j)*5+1];

                    var fx:Number = forces[(i*W+j)*2], fy:Number = forces[(i*W+j)*2+1];

                    fx = fx*a + (j*MASSW-1.0-x)*k;

                    fy = fy*a + (-(i*MASSH-1.0)-y)*k;

                    x += fx/10;

                    y += fy/10;

                    

                    vertexData[(i*W+j)*5] = x;

                    vertexData[(i*W+j)*5+1] = y;

                    forces[(i*W+j)*2] = fx;

                    forces[(i*W+j)*2+1] = fy;

                }

            }

            

            // 頂点データをアップロード

            vertices.uploadFromVector(vertexData, 0, W*H);

            

            // 3角形を全て描画する;

            context3D.drawTriangles(indices, 0, -1);

            //ビューポートに表示;

            context3D.present();

        }

        

        //指定した座標を中心にプルプルさせる。

        public function doPuyo(xx:Number, yy:Number, strength:Number):void{

            for(var i:int = 0; i < H; i++){

                for(var j:int = 0; j < W; j++){

                    var x:Number = vertexData[(i*W+j)*5], y:Number = vertexData[(i*W+j)*5+1];

                    var d:Number = new Point(x-xx,y-yy).length*100;

                    //マウスの位置に引き寄せる

                    forces[(i*W+j)*2] += ((xx - x)/(d/strength) + (j*MASSW - x)/rep)/30;

                    forces[(i*W+j)*2+1] += ((yy - y)/(d/strength) + (i*MASSH - y)/rep)/30;

                }

            }

        }

    }

}
