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
        // particleを保管するための配列
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
            // 配列の初期化
            arrays = new Vector.<particle>();
            // イベントの追加
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
            addEventListener(Event.ENTER_FRAME, onFrame);
        }


        private function onFrame(e:Event):void
        {
            // 配列の長さを獲得
            var i:int=arrays.length;
            // 配列の長さの分だけループ
            while(i)
            {
                i--;
                // 配列から要素を取りだす
                var p:particle = arrays[i] as particle;
                p.x+=p.vx;
                p.y+=p.vy;
                p.z+=p.vz;
                p.rotationX += 5;
                p.rotationY += 3;
                //vyの更新
                p.vx+=0.8;

                // 画面外に出たら削除
                if (p.x >= stage.stageWidth)
                {
                    // 画面から削除
                    removeChild(p);
                    // 配列からも削除
                    arrays.splice(i, 1);
                    // ヌルを代入
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

            // 配列に格納
            arrays.push(p);
        }
    }
}

    import flash.display.Sprite;
    import flash.filters.BlurFilter;

    // クラス「Particle」
    // Spriteを継承したクラスを作成する
class particle extends Sprite
{
    // x方向とy方向とz方向の移動量
    public var vx:Number;
    public var vy:Number;
    public var vz:Number;
        // コンストラクタ
    public function particle(x:Number, y:Number, z:Number, vx:Number, vy:Number, vz:Number, color:uint)
    {
        // 変数の初期化
        this.x=x;
        this.y=y;
        this.z=z;
        this.vx=vx;
        this.vy=vy;
        this.vz=vz;
        // 円を書く
        graphics.beginFill(color, 1);
        graphics.drawCircle(0, 0, 15 * Math.random() + 3);
        graphics.endFill();
    }
}
