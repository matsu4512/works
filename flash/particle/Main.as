package
{
    import __AS3__.vec.Vector;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Point;

    [SWF(backgroundColor=0x000000, width=512, height=512)]

    public class Main extends Sprite
    {
        // particle��ۊǂ��邽�߂̔z��
        private var arrays:Vector.<particle>;
        private var bmpData:BitmapData;
        private var cMtx:ColorMatrixFilter;
        private var bf:BlurFilter;
        
        
        public function Main()
        {
            stage.scaleMode=StageScaleMode.NO_SCALE;
            stage.align=StageAlign.TOP_LEFT;
            stage.frameRate=40;
            
            bmpData = new BitmapData(stage.stageWidth, stage.stageWidth, true, 0x000000);
            var bmp:Bitmap = new Bitmap(bmpData);
            addChild(bmp);
            
            cMtx= new ColorMatrixFilter([0.95,    0,    0,    0, 1,
                                             0, 0.95,    0,    0, 1,
                                            0,    0, 0.95,    0, 1,
                                             0,    0,    0, 0.95, 1]);
            bf = new BlurFilter(8, 8, 1);
            // �z��̏�����
            arrays = new Vector.<particle>();
            // �C�x���g�̒ǉ�
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
            addEventListener(Event.ENTER_FRAME, onFrame);
        }


        private function onFrame(e:Event):void
        {
            // �z��̒������l��
            var i:int=arrays.length;
            // �z��̒����̕��������[�v
            while(i)
            {
                i--;
                // �z�񂩂�v�f����肾��
                var p:particle = arrays[i] as particle;
                p.x+=p.vx;
                p.y+=p.vy;
                p.z+=p.vz;
                p.rotationX += 5;
                p.rotationY += 3;
                //vy�̍X�V
                p.vx+=0.8;

                // ��ʊO�ɏo����폜
                if (p.x >= stage.stageWidth)
                {
                    // ��ʂ���폜
                    removeChild(p);
                    // �z�񂩂���폜
                    arrays.splice(i, 1);
                    // �k������
                    p=null;
                }
            }
            
            bmpData.draw(this);
            bmpData.applyFilter(bmpData, bmpData.rect, new Point(0, 0), cMtx);
            bmpData.applyFilter(bmpData, bmpData.rect, new Point(0, 0), bf); 
        }

        private function onMove(e:MouseEvent):void
        {
            var p:particle=new particle(mouseX, mouseY, 0, 6 * Math.random() - 3, 6 * Math.random() - 3, -20 * Math.random(),
                                             0xffffff * Math.random());
            addChild(p);

            p.blendMode=BlendMode.ADD;

            // �z��Ɋi�[
            arrays.push(p);
        }
    }
}

    import flash.display.Sprite;
    import flash.filters.BlurFilter;

    // �N���X�uParticle�v
    // Sprite���p�������N���X���쐬����
class particle extends Sprite
{
    // x������y������z�����̈ړ���
    public var vx:Number;
    public var vy:Number;
    public var vz:Number;
        // �R���X�g���N�^
    public function particle(x:Number, y:Number, z:Number, vx:Number, vy:Number, vz:Number, color:uint)
    {
        // �ϐ��̏�����
        this.x=x;
        this.y=y;
        this.z=z;
        this.vx=vx;
        this.vy=vy;
        this.vz=vz;
        // �~������
        graphics.beginFill(color, 1);
        graphics.drawCircle(0, 0, 15 * Math.random() + 3);
        graphics.endFill();
    }
}
