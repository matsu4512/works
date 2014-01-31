/*
   ���Z�b�g�{�^���ǉ�
   �����L���O�\���@�\�ǉ�
   Twitter�ɓ��e����Ă���_�����烉���L���O���v�Z

   ���ʂ̃u���b�N�����ł��B
   �ŏ����炠��{�[�����������GameOver�ł��B
   �����_�ڎw���Ċ撣���Ă��������B
   ���ʂ�Twitter�łԂ₯�܂��B

   �A�C�e��
   ��: ���^�̃{�[���ɂȂ�܂��B
   �n�[�g: ���˃o�[�̑傫���̕ύX
 */

package
{
    import __AS3__.vec.Vector;
    import com.adobe.serialization.json.JSON;
    import com.bit101.components.PushButton;
    import net.wonderfl.utils.SequentialLoader;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.*;
    import flash.system.Security;
    import flash.text.*;
    import flash.utils.escapeMultiByte;
    
    import org.si.sion.*;

    [SWF(backgroundColor=0x00f0f, width=465, height=465, frameRate=60)]
    public class Main extends Sprite
    {
        
        //�w�i�摜�ǂݍ��ݗp    
        private var imageArray:Array=[];
        private var imageUrl:String="http://assets.wonderfl.net/images/related_images/1/16/162f/162fabe272eae4e0e084575ac63ac9545f4e2bd2";
        //private var imageUrl:String="pic3.jpg";
        //private var imageLoader:Loader;

        //Twitter�p
        private var postUrl:String="http://twitter.com/home?status=";
        private var wonderflUrl:String="http://bit.ly/9xsPLp %23StardustBreakout";
        //��ԁ@0:�Q�[�����A1:Not Clear, 2:Clear
        public var status:int;

        public static const W:Number=388; // �Q�[���X�e�[�W�̕�
        public static const H:Number=465; // �Q�[���X�e�[�W�̍���
        public static const ITEM_PROBABILITY:Number=0.3; //�A�C�e���̏o��m��
        public static const STAR_PROBABILITY:Number=0.7;
        public static const HEART_PROBABILITY:Number=0.3;
        public static const FAIL:String="fail"; //FAIL�C�x���g
        public static const CLEAR:String="clear"; //clear�C�x���g
        public static const block_row:int=10; // �u���b�N�̍s��
        public static const block_column:int=10; // �u���b�N�̗�
        public static const block_width:Number=38.9; // �u���b�N�̕�
        public static const block_height:Number=15.5; //�u���b�N�̍���
        public static const bar_width:Number=62; //���˃o�[�̕�
        public static const bar_height:Number=15.5; //���˃o�[�̍���
        public static const ball_size:Number=4; //�{�[���̃T�C�Y
        private static const SPEED:Number=6; //���C���̋��̃X�s�[�h
        private static const BLOCK_COLOR:uint=0x0000ff; //�u���b�N�̐F

        private var score:int=0; //�X�R�A
        private var ball_bmp:Bitmap; // �\���pBitmap
        private var block_bmp:Bitmap; //Block��`��Bitmap
        private var block_bmpData:BitmapData;
        private var ball_bmpData:BitmapData; // canvas�̓��e���L�^���邽�߂�BitmapData
        private var counter:TextField; // �J�E���g�t�B�[���h
        private var message:TextField; // ���b�Z�[�W�t�B�[���h
        private var scoreTxt:TextField; //�X�R�A�t�B�[���h
        private var clickStart:TextField; //�N���b�N�X�^�[�g
        private var rankTxt:TextField;
        private var remainBall:int;
        private var block_count:int;
        public var ball_canvas:Sprite; // Ball�Ȃǂ�`�悷��Sprite
        public var block_canvas:Sprite; //Block��`��Sprite
        public var BlockList:Vector.<Block>; // �u���b�N�i�[�z��
        public var bar:Bar // �{�[�h

        public var ballNum:int;
        public var soundDriver:SiONDriver;
        //BGM
        private var data:SiONData;
        private var bgm:SoundChannel;
        //���ʉ�
        public var se:SiONData;


        //�L���L���̂��߂̂���
        private var glow_bmpData:BitmapData;
        private var glowMtx:Matrix;
        private var particle_bmpData:BitmapData;
        //�L���L���p�[�e�B�N�����i�[����z��
        public var particleList:Vector.<Particle>;

        //�����L���O�̎擾�p
        //���ݓǂݍ���ł���y�[�W��
        private var page:int=1;
        //�P�y�[�W�̗v�f��
        private var rpp:int=100;
        private var twitterLoader:URLLoader;
        private var rankUrl:String = "http://search.twitter.com/search.json?q=%23StardustBreakout";
        private var ary:Array=[];

        private var rank:int=0;
        private var userNum:int=0;

        private var resetBtn:PushButton;
        private var twitBtn:PushButton;
        public var expFlg:int=0;

        public function Main()
        {
            status=0;
            ballNum=0;
            soundDriver=new SiONDriver();

            //�R���p�C��
            data=soundDriver.compile("t80o7l8r10[g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b<g>b<f+>b<d>b<e>b<f+>b<e>b<d>b<e>b]10");
            se=soundDriver.compile("t300 l8 <<b<e");

            //�w�i�G��ݒ�
        //    imageLoader=new Loader();
        //    imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
        //    imageLoader.load(new URLRequest(imageUrl));
            SequentialLoader.loadImages([imageUrl], imageArray, onLoaded);
        }

        private function onLoaded():void
        {
                var loader:Loader=imageArray.pop();
                var backData:BitmapData = new BitmapData(W, H);
                backData.draw(loader);
                var back:Bitmap=new Bitmap(backData);
            //var back:Bitmap=event.target.content as Bitmap;
            back.width=W;
            back.height=H;
            addChild(back);
            // BitmapData�̍쐬
            ball_bmpData=new BitmapData(W, H, true, 0x0);
            // BitmapData�̓��e����Bitmap�𐶐�
            ball_bmp=new Bitmap(ball_bmpData);
            // Bitmap��\��
            addChild(ball_bmp);
            ball_canvas=new Sprite;

            // BitmapData�̍쐬
            block_bmpData=new BitmapData(W, H, true, 0x0);
            // BitmapData�̓��e����Bitmap�𐶐�
            block_bmp=new Bitmap(block_bmpData);
            // Bitmap��\��
            addChild(block_bmp);
            block_canvas=new Sprite;

            //�L���L���̏���
            particle_bmpData=new BitmapData(W, H, true, 0xFF000000);
            addChild(new Bitmap(particle_bmpData));
            glow_bmpData=new BitmapData(W / 4, H / 4, false, 0x0);
            var bm:Bitmap=addChild(new Bitmap(glow_bmpData, PixelSnapping.NEVER, true)) as Bitmap;
            bm.scaleX=bm.scaleY=4;
            bm.blendMode=BlendMode.ADD;
            glowMtx=new Matrix(0.25, 0, 0, 0.25);

            particleList=new Vector.<Particle>();

            // �o�[�̍쐬
            bar=new Bar(this, W / 2, H - 50, 0x0000FF, bar_width, bar_height);
            ball_canvas.addChild(bar);

            // �J�E���g�t�B�[���h�̍쐬
            counter=createField();
            counter.x=W;
            addChild(counter);

            // ���b�Z�[�W�t�B�[���h�쐬
            message=createField();

            rankTxt=createField();

            scoreTxt=createField();
            scoreTxt.x=W;
            scoreTxt.y=50;
            addChild(scoreTxt);

            clickStart=createField();
            
            addEventListener(FAIL, notClear);
            addEventListener(CLEAR, clear);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            create();
        }

        private function create():void
        {
            // �v�f�̌^��Block��Vector���쐬
            BlockList=new Vector.<Block>();

            // �u���b�N�쐬
            var color:uint=BLOCK_COLOR;
            var b:Block;
            var item:Item;
            var type:int; // �A�C�e���^�C�v
            var item_color:uint;
            var rand:Number; // �����i�[
            for (var i:int=0; i < block_row; i++)
            {
                color+=0xf;
                for (var j:int=0; j < block_column; j++)
                {
                    b=new Block(this, j * block_width, i * block_height, color, block_width, block_height);
                    // ball_canvas��ɕ\��(��ʏ�Ɍ����Ȃ�)
                    block_canvas.addChild(b);
                    // �z��ɒǉ�
                    BlockList.push(b);
                }
            }

            block_bmpData.draw(block_canvas);
            ball_bmpData.draw(ball_canvas);

            rankTxt.text="";
            scoreTxt.text="Score:\n0";
            clickStart.text="Click Start!!";
            clickStart.x=W / 2 - clickStart.width / 2;
            clickStart.y=H / 2 - clickStart.height / 2;
            addChild(clickStart);

            stage.addEventListener(MouseEvent.CLICK, start);
        }

        private function start(event:MouseEvent):void
        {
            if (event.target != stage)
                return;
            expFlg=0;
            status=0;
            var theta:Number=Math.random() * Math.PI;
            if (theta < Math.PI / 6)
                theta=Math.PI / 6;
            else if (theta > 5 * Math.PI / 6)
                theta=5 * Math.PI / 6;
            // �{�[���̍쐬
            var ball:Ball=new Ball(this, W / 2, H - 100, SPEED * Math.cos(theta), -SPEED * Math.sin(theta), 0.0, 0xFFFFFF, ball_size);
            ball_canvas.addChild(ball);

            stage.removeEventListener(MouseEvent.CLICK, start);
            removeChild(clickStart);

            //bgm���Đ�
            bgm=soundDriver.play(data);
            var st:SoundTransform=new SoundTransform();
            st.volume=0.2;
            bgm.soundTransform=st;
        }

        //�X�R�A�̉��Z
        public function addScore(value:int):void
        {
            if (status != 0)
                return;
            score+=value;
            scoreTxt.text="Score:\n" + score.toString();
        }

        // �e�L�X�g�t�B�[���h�쐬�֐�
        private function createField():TextField
        {
            var tf:TextField=new TextField;
            // �t�H���g�A�T�C�Y�A�F�����߂�
            tf.defaultTextFormat=new TextFormat("Swis721 BdRndBT", 20, 0xFFFFFF);
            tf.autoSize=TextFieldAutoSize.LEFT;
            return tf;
        }

        private function displayMessage(str:String):void
        {
            ball_bmpData.lock();
            ball_bmpData.fillRect(ball_bmpData.rect, 0x0);
            ball_bmpData.unlock();
            message.text=str;
            // �Q�[���X�e�[�W�̒����ɍ��킹��
            message.x=W / 2 - message.width / 2;
            message.y=H / 2 - message.height / 2;
            addChild(message);
        }

        //�N���A�o���Ȃ�����
        private function notClear(event:Event):void
        {
            remainBall=block_count;
            if (status != 0)
                return;
            status=1;
            displayMessage("Game Over!!");

            createButton();
        }

        //�N���A
        private function clear(event:Event):void
        {
            if (status != 0)
                return;
            status=2;
            ary=[];
            page=1;
            userNum=0;
            rank = 0;
            displayMessage("THANK YOU FOR PLAYING\nCONGRATULATION!!");
            twitterLoader = new URLLoader(new URLRequest(rankUrl + "&rpp="+rpp.toString()+"&page=" + page.toString()));
            twitterLoader.addEventListener(Event.COMPLETE, onLoadTwitter);
            twitterLoader.addEventListener(IOErrorEvent.IO_ERROR, error);
        }
        
        //�������ʂ̎擾
        private function onLoadTwitter(event:Event):void{
            var str:String = event.target.data;
            var obj:Object = JSON.decode(str);
            if((obj.results as Array).length == rpp){
                page++;
                twitterLoader.load(new URLRequest(rankUrl + "&rpp="+rpp.toString()+"&page=" + page.toString()));
                ary = ary.concat(obj.results as Array);
                return;
            }
            
            ary = ary.concat(obj.results as Array);
            
            var exp1:RegExp = /(\[�����u���b�N����\]|\[����u���b�N����\])Clear���߂łƂ��I ���Ȃ��̃X�R�A��[0-9]+�_�ł��B/;
            var exp2:RegExp = /[0-9]+/;
            var exp3:RegExp = /RT|QT/;
            var resultMap:Object = {};
            for(var i:int = 0; i < ary.length; i++){
                var tmp:String = ary[i].text;
                var user:String = ary[i].from_user;
                if(exp3.exec(tmp) != null) continue;
                tmp = exp1.exec(tmp);
                tmp = exp2.exec(tmp);
                if(resultMap[user] == undefined){
                    resultMap[user] = tmp;
                }
                else{
                    if(int(tmp) > int(resultMap[user])){
                        resultMap[user] = tmp;
                    }
                }
            }
            for each(i in resultMap){
                if(i < score) rank++;
                userNum++;
            }
            rank = userNum-rank+1;
            userNum++;
            rankTxt.text = userNum.toString() + "�l��" + rank.toString() + "��";
            rankTxt.x = W/2 - rankTxt.width/2;
            rankTxt.y = H/2 - rankTxt.height/2 + message.height;
            addChild(rankTxt);
            createButton();
        }

        private function error(event:IOErrorEvent):void
        {
            createButton();
        }

        private function createButton():void
        {
            twitBtn=new PushButton(this, W / 2, H / 2 + message.height + rankTxt.height, "Twitter", twitter);
            twitBtn.x-=twitBtn.width / 2;
            resetBtn=new PushButton(this, W / 2, twitBtn.y + twitBtn.height + 10, "Restart", reset);
            resetBtn.x-=resetBtn.width / 2;
        }



        private function reset(event:MouseEvent):void
        {
            score=0;
            ballNum=0;
            expFlg=1;
            removeChild(twitBtn);
            removeChild(resetBtn);
            removeChild(message);
            for (var i:int=0; i < BlockList.length; i++)
            {
                BlockList[i].explosion();
            }
            create();
        }

        //Twitter�ɓ��e
        private function twitter(event:MouseEvent):void
        {
            var url:String
            if (status == 2)
            {
                url=postUrl + escapeMultiByte("[�����u���b�N����]Clear���߂łƂ��I ���Ȃ��̃X�R�A��") + score.toString() + escapeMultiByte("�_�ł��B");
                if (rankTxt.text != "")
                    url+=escapeMultiByte(userNum.toString() + "�l��" + rank.toString() + "��")
            }
            else if (status == 1 && block_count == 0)
            {
                url=postUrl + escapeMultiByte("[�����u���b�N����]�u���b�N�S�������߂łƂ��I������Game Over����I�I");
            }
            else if (status == 1)
            {
                url=postUrl + escapeMultiByte("[�����u���b�N����]Game Over ���Ȃ��͎c��") + remainBall.toString() + escapeMultiByte("�̃u���b�N���c���ė͐s���܂����B");
            }
            url+=wonderflUrl;
            navigateToURL(new URLRequest(url));
        }

        private function onEnterFrame(event:Event):void
        {
            block_count=BlockList.length;
            counter.text="Block��:\n" + block_count;

            glow_bmpData.fillRect(glow_bmpData.rect, 0x0);
            particle_bmpData.fillRect(particle_bmpData.rect, 0x00000000);
            particle_bmpData.lock();

            //�L���L���p�[�e�B�N���𓮂�����
            var i:int=particleList.length;
            while (i--)
            {
                var p:Particle=particleList[i];
                particle_bmpData.setPixel32(p.x, p.y, p.color);
                p.update();
                if (p.y > H)
                {
                    particleList.splice(i, 1);
                }
            }

            //�`��
            particle_bmpData.unlock();
            glow_bmpData.draw(particle_bmpData, glowMtx);

            block_bmpData.fillRect(block_bmpData.rect, 0x0);
            block_bmpData.draw(block_canvas);

            ball_bmpData.draw(ball_canvas);
            ball_bmpData.colorTransform(ball_bmpData.rect, new ColorTransform(1.5, 1.0, 1.5, 0.85));
        }
    }
}

import __AS3__.vec.Vector;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.GlowFilter;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.display.Sprite;
import flash.geom.Point;

class Obj extends Shape
{
    protected var field:BreakBlock;
    protected var color:uint;

    public function Obj(field:BreakBlock)
    {
        this.field=field;
    }

    protected function enterFrame(event:Event):void
    {
        if (field.expFlg)
            explosion();
        update();
    }

    //��ʏォ�����
    public function deleteObj():void
    {
        removeEventListener(Event.ENTER_FRAME, enterFrame);
        parent.removeChild(this);
    }

    protected function update():void
    {
    }

    protected function draw():void
    {
    }

    public function explosion():void
    {
        var num:int=width * height / 10;
        //�L���L���p�[�e�B�N���̔���
        for (var i:int=0; i < num; i++)
        {
            var p:Particle=new Particle(x + width / 2, y + height / 2, Math.random() * 10 - 5, Math.random() * 10 - 5, color);
            field.particleList.push(p as Particle);
        }
        deleteObj();
    }
}

//�ʏ�̃{�[���N���X
class Ball extends Obj
{
    //Block�̎Q��
    protected var blocks:Vector.<Block>;
    //Bar�̎Q��
    private var bar:Bar;
    protected var value:int; //��b�_
    protected var vx:Number; // x�����̈ړ���
    protected var vy:Number; // y�����̈ړ���
    protected var vz:Number;
    protected var va:Number; // alpha�̕ω���
    protected var r:Number; // ���a
    protected var heaven:int; //�ђʃ��[�h�t���O
    protected var judgeLine1:Number; //�u���b�N�Ƃ̔��肪�K�v�ɂȂ鋫�E��
    protected var judgeLine2:Number; //�o�[�Ƃ̔��肪�K�v�ɂȂ鋫�E��

    public function Ball(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, va:Number, c:uint, r:Number)
    {
        super(field);
        field.ballNum++;
        value=100;
        this.field=field;
        this.blocks=field.BlockList;
        this.bar=field.bar;
        this.heaven=0;
        this.color=c;
        this.x=x;
        this.y=y;
        this.vx=vx;
        this.vy=vy;
        this.va=va;
        this.vz=0;
        this.r=r;
        draw();
        filter();
        judgeLine1=BreakBlock.block_height * BreakBlock.block_row + height / 2;
        judgeLine2=field.bar.y - height / 2 - field.bar.height / 2;
        addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    //�`��
    override protected function draw():void
    {
        //(0,0)�𒆐S�ɉ~��`��
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, r);
        graphics.endFill();
    }

    protected function filter():void
    {
        if (heaven)
        {
            filters=[new GlowFilter(0xFF0000, 1, 16, 16, 4)];
        }
        else
        {
            filters=[new GlowFilter(0xFF0000, 1, 8, 8, 2)];
        }
    }

    override protected function update():void
    {
        if (field.status == 2)
        {
            vz=-10;
            field.addScore(2000);
        }
        if (heaven)
        {
            x+=vx * 1.5;
            y+=vy * 1.5;
            z+=vz * 1.5;
        }
        else
        {
            x+=vx;
            y+=vy;
            z+=vz;
        }

        if (y + vy < judgeLine1)
            checkBlockCollision();
        if (y + vy > judgeLine2)
            checkBarCollision();
        checkStageCollision();
        checkInField();
    }

    //��ʊO�ɏo�Ă��Ȃ����ǂ���
    protected function checkInField():void
    {
        if (y > BreakBlock.H)
        {
            removeEventListener(Event.ENTER_FRAME, enterFrame);
            parent.removeChild(this);
            //FAIL�C�x���g�̔���
            field.dispatchEvent(new Event(BreakBlock.FAIL));
            field.ballNum--;
        }
    }

    //Block�Փ˔���
    protected function checkBlockCollision():void
    {
        var i:int=blocks.length;
        while (i--)
        {
            var block:Block=blocks[i];
            if (block.hitTestObject(this))
            {
                if (!heaven)
                {
                    if ((y - r) <= (block.y + block.height) || block.y <= (y + r))
                    {
                        vy*=-1;
                        y+=vy;
                    }
                    else if ((x + r) >= block.x || (block.x + block.width) >= (x - r))
                    {
                        vx*=-1;
                        x+=vx;
                    }
                }
                //�u���b�N�Ƀ_���[�W
                addScore();
                block.deleteBlock();
                blocks.splice(i, 1);
                if (blocks.length == 0)
                {
                    field.dispatchEvent(new Event(BreakBlock.CLEAR));
                }
            }
        }
    }

    //Bar�Փ˔���
    protected function checkBarCollision():void
    {
        // �o�[�ƃ{�[���̓����蔻��
        if (this.hitTestObject(bar))
        {
            if ((bar.y - bar.height / 2) <= (y + r))
            {
                vy*=-1;
                // �o�[�Ƀ{�[�����߂荞�ނ̂�h��
                y-=bar.height / 2 + r;
                var radian:Number=Math.atan2(y - bar.y, x - bar.x);

                var point:Point=new Point(vx, vy);
                vx=Math.cos(radian) * point.length;
                vy=Math.sin(radian) * point.length;
            }
            if (radian < -Math.PI / 2 + 0.1 && radian > -Math.PI / 2 - 0.1)
            {
                heaven=1;
                filter();
            }
            else if (heaven)
            {
                heaven=0;
                filter();
            }
        }
    }

    protected function checkStageCollision():void
    {
        //�X�e�[�W�S�̂ƃ{�[���̓����蔻��
        if (x < r || x > BreakBlock.W - r)
        {
            vx*=-1;
            // �X�e�[�W�ɂ߂荞�ނ̂�h��
            x+=vx;
        }
        else if (y < r)
        {
            vy*=-1;
            // �X�e�[�W�ɂ߂荞�ނ̂�h��
            y+=vy;
        }
    }

    protected function addScore():void
    {
        var score:int=value;
        score+=(field.ballNum - 1) * 50;
        if (heaven)
            score*=2;
        score*=1.0 / field.bar.scaleX;
        field.addScore(score);
    }
}

//���^�̃{�[���N���X
class StarBall extends Ball
{
    public var rv:Number;

    public function StarBall(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, va:Number, c:uint, r:Number, rv:Number)
    {
        super(field, x, y, vx, vy, va, c, r);
        this.rv=rv;
        value=200;
    }

    override protected function draw():void
    {
        var r2:Number=r / 2;
        var angle:Number=-90;
        var addtion:Number=360 / 10;
        graphics.beginFill(0xffffff);
        graphics.moveTo(0, -r);
        for (var i:int=0; i < 10; i++)
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

    override protected function filter():void
    {
        if (heaven)
        {
            filters=[new GlowFilter(0xFF0000, 1, 16, 16, 4)];
        }
        else
        {
            filters=[new GlowFilter(color, 1, 8, 8, 2)];
        }
    }

    //��ʊO�ɏo�Ă��Ȃ����ǂ���
    override protected function checkInField():void
    {
        if (y > BreakBlock.H)
        {
            removeEventListener(Event.ENTER_FRAME, enterFrame);
            parent.removeChild(this);
            field.ballNum--;
        }
    }

    override protected function update():void
    {
        rotation+=rv;
        super.update();
    }
}

//�u���b�N�N���X
class Block extends Obj
{
    public function Block(field:BreakBlock, x:Number, y:Number, c:uint, w:Number, h:Number)
    {
        super(field);
        this.field=field;
        this.x=x;
        this.y=y;
        this.color=c;
        // (1,1)���n�_�ɒ����`��`��
        graphics.beginFill(color);
        graphics.drawRect(1, 1, w - 1, h - 1);
        graphics.endFill();
    }

    override public function explosion():void
    {
        var num:int=width * height / 10;
        //�L���L���p�[�e�B�N���̔���
        for (var i:int=0; i < num; i++)
        {
            var p:Particle=new Particle(x + width / 2, y + height / 2, Math.random() * 10 - 5, Math.random() * 10 - 5, x / BreakBlock.W * 0xffffff);
            field.particleList.push(p as Particle);
        }
        deleteObj();
    }

    override public function deleteObj():void
    {
        parent.removeChild(this);
    }

    public function deleteBlock():void
    {
        var tween:ITween=BetweenAS3.to(this, {alpha: 0}, 0.3);
        tween.onComplete=function(... onCompleteParams):void
        {
            parent.removeChild(onCompleteParams[0])
        };
        tween.onCompleteParams=[this];
        tween.play();

        //���ʉ�
        field.soundDriver.sequenceOn(field.se);

        var num:int=width * height / 10;
        //�L���L���p�[�e�B�N���̔���
        for (var i:int=0; i < num; i++)
        {
            var p:Particle=new Particle(x + width / 2, y + height / 2, Math.random() * 10 - 5, Math.random() * 10 - 5, Math.random() * 0xffffff);
            field.particleList.push(p as Particle);
        }

        // �A�C�e���쐬
        if (Math.random() < BreakBlock.ITEM_PROBABILITY)
        {
            var item:Item;
            if (Math.random() < BreakBlock.STAR_PROBABILITY)
            {
                item=new StarItem(field, x + width / 2, y + height / 2, 0, 4, Math.random() * 0xffffff, 5.4 * Math.random() + 4);
                field.block_canvas.addChild(item as StarItem);
            }
            else
            {
                item=new HeartItem(field, x + width / 2, y + height / 2, 0, 4, Math.round(Math.random()) * 0xffffff, 15.5);
                field.block_canvas.addChild(item as HeartItem);
            }
        }
    }
}

//���˃o�[�N���X
class Bar extends Obj
{
    private var w:Number;
    private var h:Number;

    public function Bar(field:BreakBlock, x:Number, y:Number, c:uint, w:Number=50, h:Number=20)
    {
        super(field);
        this.field=field;
        this.x=x;
        this.y=y;
        this.w=w;
        this.h=h;
        draw();

        addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    override protected function draw():void
    {
        // (0,0)�𒆐S�Ƃ��钷���`��`��
        var matrix:Matrix=new Matrix();
        matrix.createGradientBox(w, h, 5);
        graphics.beginGradientFill("linear", [0x0000FF, 0x00FFFF], [1.0, 1.0], [0, 255], matrix);
        graphics.drawRect(-w / 2, -h / 2, w, h);
        graphics.endFill();
    }

    override public function explosion():void
    {
        BetweenAS3.to(this, {scaleX: 1}, 0.5).play();
    }

    override public function deleteObj():void
    {
    }

    override protected function update():void
    {
        x+=(field.mouseX - x) / 8;
        if (x + width / 2 > BreakBlock.W)
            x=BreakBlock.W - width / 2;
        else if (x - width / 2 < 0)
            x=width / 2;
    }
}

//�A�C�e���N���X
class Item extends Obj
{
    protected var vx:Number;
    protected var vy:Number;
    protected var vz:Number;
    protected var size:Number;
    protected var judgeLine:Number;

    public function Item(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, color:uint, r:Number)
    {
        super(field);
        this.x=x;
        this.y=y;
        this.vx=vx;
        this.vy=vy;
        this.vz=vx;
        this.color=color;
        this.size=r;
        this.field=field;
        draw();
        this.judgeLine=0;
        addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    override protected function update():void
    {
        if (field.status == 2)
            vz=-10;

        x+=vx;
        y+=vy;
        z+=vz;

        checkInField();
        if (y > judgeLine)
            checkBarCollision();
    }

    //��ʊO�ɏo�Ă��Ȃ����ǂ���
    protected function checkInField():void
    {
        if (y > BreakBlock.H)
        {
            deleteObj();
        }
    }

    //�o�[�Ƃ̐ڐG����
    protected function checkBarCollision():void
    {
        if (this.hitTestObject(field.bar))
        {
            deleteObj();
        }
    }
}

//���^�̃A�C�e���N���X
class StarItem extends Item
{
    public function StarItem(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, color:uint, r:Number)
    {
        super(field, x, y, vx, vy, color, r);
    }

    override protected function draw():void
    {
        this.filters=[new GlowFilter(color, 1, 8, 8, 2)];
        var r2:Number=size / 2;
        var angle:Number=-90;
        var addtion:Number=360 / 10;
        graphics.beginFill(0xffffff);
        graphics.moveTo(0, -size);
        for (var i:int=0; i < 10; i++)
        {
            angle+=addtion;
            var to_x:Number;
            var to_y:Number;
            var radian:Number=angle * Math.PI / 180;
            if (i % 2)
            {
                to_x=size * Math.cos(radian);
                to_y=size * Math.sin(radian);
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

    override protected function checkBarCollision():void
    {
        if (this.hitTestObject(field.bar))
        {
            deleteObj();
            createBall();
        }
    }

    //�{�[���̐���
    private function createBall():void
    {
        var newBall:StarBall=new StarBall(field, x, y - field.bar.height, Math.random() * 15 - 7.5, -Math.random() * 5 - 2, 0.0, color, size, Math.random() * 5 + 5);
        field.ball_canvas.addChild(newBall);
    }
}

//�o�[�̑傫����ς���A�C�e��
class HeartItem extends Item
{
    public function HeartItem(field:BreakBlock, x:Number, y:Number, vx:Number, vy:Number, color:uint, r:Number)
    {
        super(field, x, y, vx, vy, color, r);
    }

    //�o�[�Ƃ̏Փ˔���
    override protected function checkBarCollision():void
    {
        if (this.hitTestObject(field.bar))
        {
            var tween:ITween;
            var toScale:Number;
            vy=0;
            //�o�[�̏k���g��B�F�ɂ���Č��ʂ��Ⴄ
            if (color)
            {
                if (field.bar.scaleX < 1)
                    toScale=1;
                else
                {
                    toScale=field.bar.scaleX + 1;
                    if (toScale > 3)
                        toScale=3;
                }
                tween=BetweenAS3.to(field.bar, {scaleX: toScale}, 0.5);
            }
            else
            {
                toScale=field.bar.scaleX / 2;
                if (toScale < 0.25)
                    toScale=0.25;
                tween=BetweenAS3.to(field.bar, {scaleX: toScale}, 0.5);
            }
            tween.play();
            removeEventListener(Event.ENTER_FRAME, enterFrame);
            tween=BetweenAS3.to(this, {alpha: 0, scaleX: 3, scaleY: 3}, 0.5);
            tween.onComplete=deleteObj;
            tween.play();
        }
    }

    override protected function draw():void
    {
        var a:Number=1;
        var b:Number=2;
        var c:Number=0.7;
        var d:Number=1;
        var df:Number=0.01;
        var fmin:Number=-Math.PI / 2;
        var fmax:Number=3 * Math.PI / 2;
        var xx:Vector.<Number>=new Vector.<Number>;
        var yy:Vector.<Number>=new Vector.<Number>;
        var value:Number;
        var max_v:Number=0;
        var min_v:Number=1000000;

        for (var f:Number=fmin; f <= fmax; f+=df)
        {
            var t:Number=b * Math.sqrt(f + Math.PI / 2) - b * Math.sqrt(3 * Math.PI / 2 - f) + (1 - b * Math.sqrt(2 / Math.PI)) * f + b * Math.sqrt(Math.PI / 2);
            var r:Number=a * (1 - Math.sin(t));
            xx.push(size * r * (1 + c * Math.sin(f)) * Math.cos(f));
            value=size * d * r * (1 + c * Math.sin(f)) * Math.sin(f);
            yy.push(value);
            if (value > max_v)
                max_v=value;
            if (value < min_v)
                min_v=value;
        }

        var center:Number=(max_v + min_v) / 2;
        var i:int=xx.length;
        graphics.beginFill(color);
        graphics.moveTo(xx[0], yy[0] - center);
        while (i--)
        {
            graphics.lineTo(xx[i], yy[i] - center);
        }
        graphics.endFill();

        this.rotation+=180;
        this.filters=[new GlowFilter(0xff69b4, 1, 16, 16, 2)];
    }
}

//�L���L���̗��q�N���X
class Particle
{
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var color:uint;
    public var field:BreakBlock;

    public function Particle(x:Number, y:Number, vx:Number, vy:Number, color:uint)
    {
        this.x=x;
        this.y=y;
        this.vx=vx;
        this.vy=vy;
        this.color=color | 0xFF000000;
    }

    public function update():void
    {
        x+=vx;
        y+=vy;
        vy+=0.2;
    }
}
