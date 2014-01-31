/*
なんとなくnengaflに投稿してみた。
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
                    画像の変え方が分からないという方がいたので、手順を書いておきます。
                        fork後、タイトルの右にある『edit title,tag』をクリック
                        ↓
                        +moreをクリック
                        ↓
                        uploadをクリックし画像を選択
                        ↓
                        ＯＫをクリック
                        ↓
                        エディット画面から抜けて作品に再度アクセス
                        ↓
                        ページの下の方に表示された画像を右クリック⇒プロパティ
                        ↓
                        表示されたURLを下のurl変数に入れればＯＫ
            */
            //画像のURL
            private var url:String = "http://assets.wonderfl.net/images/related_images/8/81/8142/8142a2b3567293a4831bf49d3772a70cceb73777";
            /*
                    ばね定数と減衰定数を変えればぷるぷる具合も変わります。
            */
            //ばね定数
            private const k:Number = 1.2;
            //減衰定数
            private const a:Number = 0.9;
            //マウスに引き付ける半径
            private const r:Number = 100;
            //この値が大きいほど、よりマウスに引き付けられる
            private const rep:Number = 50;
            
        //頂点を格納する配列
        private var drugpAry:Array;
        //頂点の個数
        private const WN:int = 30, HN:int = 30;
        //描画する大きさ
        private const W:int = 465, H:int = 465;
        //一マスの大きさ
        private const MASSW:Number = W/WN, MASSH:Number = H/HN;
        //画像を描画するShape
            private var sp:Shape=new Shape();
            //頂点、uvt、使用する頂点を管理する配列
            private var vec:Vector.<Number>, uvtData:Vector.<Number>, indices:Vector.<int>;
            //頂点、マウスの位置を格納するためのPoint
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
            
               //初期化
            vec = new Vector.<Number>();
            uvtData=new Vector.<Number>();
            indices = new Vector.<int>();
            drugpAry = [];
            
            //頂点を等間隔に並べる。
            for(var i:int = 0; i <= HN; i++){
                    drugpAry[i] = [];
                    for(var j:int = 0; j <= WN; j++){
                        vec.push(j*MASSW, i*MASSH);
                        uvtData.push(j/WN, i/HN);
                        drugpAry[i][j] = new SPoint(j*MASSW, i*MASSH);
                    }
            }
            
            //使用する頂点の格納。一つの四角形を２つの三角形に分けている。
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
                        //マウスの位置に引き寄せる
                        drugpAry[i][j].x += (mouseP.x - p.x)/(d*2) + (j*MASSW - p.x)/rep;
                        drugpAry[i][j].y += (mouseP.y - p.y)/(d*2) + (i*MASSH - p.y)/rep;
                    }
                    else{
                        //ばねの力の計算
                        drugpAry[i][j].forceX = drugpAry[i][j].forceX*a + (j*MASSW - p.x)*k;
                        drugpAry[i][j].forceY = drugpAry[i][j].forceY*a + (i*MASSW - p.y)*k;
                        //頂点の移動
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