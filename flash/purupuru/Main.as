/*
�Ȃ�ƂȂ�nengafl�ɓ��e���Ă݂��B
*/
package
{
    import flash.events.ErrorEvent;
    import flash.display.Loader;
    import flash.display.BitmapData;
    import __AS3__.vec.Vector;
    
    import flash.display.Bitmap;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Point;
    import net.wonderfl.utils.SequentialLoader;

    [SWF(backgroundColor="#000000")]
    public class Main extends Sprite
    {
            private var imageArray:Array=[];
            private var bmpData:BitmapData;
            
            /*
                    �摜�̕ς�����������Ȃ��Ƃ������������̂ŁA�菇�������Ă����܂��B
                        fork��A�^�C�g���̉E�ɂ���wedit title,tag�x���N���b�N
                        ��
                        +more���N���b�N
                        ��
                        upload���N���b�N���摜��I��
                        ��
                        �n�j���N���b�N
                        ��
                        �G�f�B�b�g��ʂ��甲���č�i�ɍēx�A�N�Z�X
                        ��
                        �y�[�W�̉��̕��ɕ\�����ꂽ�摜���E�N���b�N�˃v���p�e�B
                        ��
                        �\�����ꂽURL������url�ϐ��ɓ����΂n�j
            */
            //�摜��URL
            private var url:String = "http://assets.wonderfl.net/images/related_images/8/81/8142/8142a2b3567293a4831bf49d3772a70cceb73777";
            /*
                    �΂˒萔�ƌ����萔��ς���΂Ղ�Ղ����ς��܂��B
            */
            //�΂˒萔
            private const k:Number = 1.2;
            //�����萔
            private const a:Number = 0.9;
            //�}�E�X�Ɉ����t���锼�a
            private const r:Number = 100;
            //���̒l���傫���قǁA���}�E�X�Ɉ����t������
            private const rep:Number = 50;
            
        //���_���i�[����z��
        private var drugpAry:Array;
        //���_�̌�
        private const WN:int = 30, HN:int = 30;
        //�`�悷��傫��
        private const W:int = 465, H:int = 465;
        //��}�X�̑傫��
        private const MASSW:Number = W/WN, MASSH:Number = H/HN;
        //�摜��`�悷��Shape
            private var sp:Shape=new Shape();
            //���_�Auvt�A�g�p���钸�_���Ǘ�����z��
            private var vec:Vector.<Number>, uvtData:Vector.<Number>, indices:Vector.<int>;
            //���_�A�}�E�X�̈ʒu���i�[���邽�߂�Point
            private var p:Point = new Point(), mouseP:Point = new Point();
        
            public  function Main(){
                SequentialLoader.loadImages([url], imageArray, onLoaded);
            }
            
        private function onLoaded():void
        {
                 var loader:Loader=imageArray.pop();
             bmpData=new BitmapData(loader.width, loader.height);
             bmpData.draw(loader);
             
                stage.frameRate = 30;
            
               //������
            vec = new Vector.<Number>();
            uvtData=new Vector.<Number>();
            indices = new Vector.<int>();
            drugpAry = [];
            
            //���_�𓙊Ԋu�ɕ��ׂ�B
            for(var i:int = 0; i <= HN; i++){
                    drugpAry[i] = [];
                    for(var j:int = 0; j <= WN; j++){
                        vec.push(j*MASSW, i*MASSH);
                        uvtData.push(j/WN, i/HN);
                        drugpAry[i][j] = new SPoint(j*MASSW, i*MASSH);
                    }
            }
            
            //�g�p���钸�_�̊i�[�B��̎l�p�`���Q�̎O�p�`�ɕ����Ă���B
            for(i = 0; i < HN; i++){
                    for(j = 0; j < WN; j++){
                        indices.push(j+i*(WN+1), (j+1)+i*(WN+1), j+(i+1)*(WN+1));
                        indices.push((j+1)+i*(WN+1), j+(i+1)*(WN+1), (j+1)+(i+1)*(WN+1));
                    }
            }

            addChild(sp);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void{
            vec = Vector.<Number>([]);
            for(var i:int = 0; i <= HN; i++){
                for(var j:int = 0; j <= WN; j++){
                    p.x = drugpAry[i][j].x; 
                    p.y = drugpAry[i][j].y;
                    mouseP.x = mouseX;
                    mouseP.y = mouseY;
                    var d:Number = p.subtract(mouseP).length;
                    if(d < r){
                        //�}�E�X�̈ʒu�Ɉ����񂹂�
                        drugpAry[i][j].x += (mouseP.x - p.x)/(d*2) + (j*MASSW - p.x)/rep;
                        drugpAry[i][j].y += (mouseP.y - p.y)/(d*2) + (i*MASSH - p.y)/rep;
                    }
                    else{
                        //�΂˂̗͂̌v�Z
                        drugpAry[i][j].forceX = drugpAry[i][j].forceX*a + (j*MASSW - p.x)*k;
                        drugpAry[i][j].forceY = drugpAry[i][j].forceY*a + (i*MASSW - p.y)*k;
                        //���_�̈ړ�
                        drugpAry[i][j].x += drugpAry[i][j].forceX;
                        drugpAry[i][j].y += drugpAry[i][j].forceY;
                    }
                    vec.push(drugpAry[i][j].x, drugpAry[i][j].y);
                    }
            }
            
                sp.graphics.clear();
                sp.graphics.beginBitmapFill(bmpData);
            sp.graphics.drawTriangles(vec, indices, uvtData);
            sp.graphics.endFill();
        }
    }
}
    import flash.geom.Point;
    
class SPoint extends Point{
    public var forceX:Number, forceY:Number;
    public function SPoint(x:int, y:int):void{
        super(x, y);
        forceX = 0;
        forceY = 0;
    }
}