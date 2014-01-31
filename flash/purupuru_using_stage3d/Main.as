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

                

        // ���_�V�F�[�_

        private const VERTEX_SHADER:String =

            "m44 op, va0, vc0 \n" +        

            "mov v0, va1 \n";            //�s�N�Z���V�F�[�_��

        

        // �s�N�Z���V�F�[�_

        private const FRAGMENT_SHADER:String =

            //�e�N�X�`�����̏���

            "tex oc, v0, fs0<2d, linear>";    //�F���̎擾  v2:uv���W, fs0:�摜�f�[�^

        

        //���_�f�[�^

        private var indices:IndexBuffer3D;

        private var vertices:VertexBuffer3D;

        private var vertexData:Vector.<Number>;

        private var indexData:Vector.<uint>;

        

        //�΂˒萔

        private const k:Number = 1.2;

        //�����萔

        private const a:Number = 0.9;

        //���̒l���傫���قǁA���}�E�X�Ɉ����t������

        private const rep:Number = 50;

        //���_�̌�

        private var W:int = 30, H:int = 30;

        //��}�X�̑傫��

        private var MASSW:Number, MASSH:Number;

        //���_�̈ʒu���Ɖ�����Ă���͂��i�[����z��

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

            

            //���_�̍��W��uv���W�̐ݒ�

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

            

            //�e�O�p�`�ɃC���f�b�N�X������U��

            for(i = 0; i < H-1; i++){

                for(j = 0; j < W-1; j++){

                    indexData.push(j+i*(W), (j+1)+i*(W), j+(i+1)*(W));

                    indexData.push((j+1)+i*(W), j+(i+1)*(W), (j+1)+(i+1)*(W));

                }

            }

            

            // 5��(���_���W(x,y,z)�Auv���W(u,v))�̒l�������_�p�̒��_�o�b�t�@���쐬

            vertices = context3D.createVertexBuffer(W*H, 5);

            // ���_�f�[�^���A�b�v���[�h

            vertices.uploadFromVector(vertexData, 0, W*H);

            // �ŏ��̑����͍��W�̏��FFloat�^�̐��l��3�@����𑮐����W�X�^0�ɓ����

            context3D.setVertexBufferAt(0, vertices, 0, Context3DVertexBufferFormat.FLOAT_3);

            // uv��� Float�^��2�@����𑮐����W�X�^1�ɓ����

            context3D.setVertexBufferAt(1, vertices, 3, Context3DVertexBufferFormat.FLOAT_2);

            //�C���f�b�N�X�o�b�t�@���쐬

            indices = context3D.createIndexBuffer(indexData.length);

            //�C���f�b�N�X�����A�b�v���[�h

            indices.uploadFromVector(indexData, 0, indexData.length);

            

            var texture:Texture = context3D.createTexture(512, 512, Context3DTextureFormat.BGRA, false);

            

            var loader:Loader = imageArray.pop();

            var bmpd:BitmapData=new BitmapData(512, 512);

            

            bmpd.draw(loader, new Matrix(512/loader.width, 0,0,512/loader.height));

            texture.uploadFromBitmapData(bmpd);

            //fs0�ɐݒ�

            context3D.setTextureAt(0, texture);

            

            //���W�X�^�ɓo�^

            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, new Matrix3D());

            

            addEventListener(Event.ENTER_FRAME, onEnterFrame);

        }

        

        private function onContext3DCreate(event:Event):void

        {

            context3D = Stage3D(event.target).context3D;

            

            context3D.enableErrorChecking = true;

            context3D.configureBackBuffer(WIDTH, HEIGHT, 2, false);

            

            // ���_�V�F�[�_���R���p�C��;

            var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();

            vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);

            // �s�N�Z���V�F�[�_���R���p�C��;

            var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();

            fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);

            

            var programPair:Program3D;

            // Program3D�̃C���X�^���X���擾

            programPair = context3D.createProgram();

            // ���_�V�F�[�_�ƃs�N�Z���V�F�[�_�̃R�[�h��GPU�ɃA�b�v���[�h

            programPair.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);

            // �g�p����V�F�[�_�̃y�A���w��;

            context3D.setProgram(programPair);

            

//            initVertex();

            SequentialLoader.loadImages(["http://assets.wonderfl.net/images/related_images/3/36/3605/3605f29686918e48eefff9cc0a4f93002777b3de"], imageArray, initVertex);

        }

        

        private function onEnterFrame(e:Event):void{

            // drawTriangles()���ĂԑO�ɕK���o�b�t�@���N���A;

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

            

            // ���_�f�[�^���A�b�v���[�h

            vertices.uploadFromVector(vertexData, 0, W*H);

            

            // 3�p�`��S�ĕ`�悷��;

            context3D.drawTriangles(indices, 0, -1);

            //�r���[�|�[�g�ɕ\��;

            context3D.present();

        }

        

        //�w�肵�����W�𒆐S�Ƀv���v��������B

        public function doPuyo(xx:Number, yy:Number, strength:Number):void{

            for(var i:int = 0; i < H; i++){

                for(var j:int = 0; j < W; j++){

                    var x:Number = vertexData[(i*W+j)*5], y:Number = vertexData[(i*W+j)*5+1];

                    var d:Number = new Point(x-xx,y-yy).length*100;

                    //�}�E�X�̈ʒu�Ɉ����񂹂�

                    forces[(i*W+j)*2] += ((xx - x)/(d/strength) + (j*MASSW - x)/rep)/30;

                    forces[(i*W+j)*2+1] += ((yy - y)/(d/strength) + (i*MASSH - y)/rep)/30;

                }

            }

        }

    }

}
