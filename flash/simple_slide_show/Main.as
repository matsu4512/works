package
{
    import com.bit101.components.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.system.*;
    
    import org.libspark.betweenas3.*;
    import org.libspark.betweenas3.tweens.*;
    
    [SWF(width=465, height=465, frameRate=60)]
    public class Main extends Sprite
    {
        private var loader:ImageLoader;
        private const row:int = 15, col:int = 15, W:int=30, H:int=30;
        private var tileList:Vector.<Vector.<Vector.<Sprite>>>, order:Vector.<Point>;
        private var imgIndex:int = 0, orderIndex:int = 0, pattern:int = 0;
        private var loadTxt:Label;
        
        public function Main()
        {
            Security.loadPolicyFile("http://api.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm1.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm2.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm3.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm4.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm5.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm6.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm7.static.flickr.com/crossdomain.xml");
            Security.loadPolicyFile("http://farm8.static.flickr.com/crossdomain.xml");
            
            loader = new ImageLoader();
            loader.addEventListener(Event.COMPLETE, onComplete);
            Style.fontSize = 20;
            loadTxt = new Label(this, 0, 0, "Now Loading...\n0/20");
            loadTxt.x = 465/2-loadTxt.width/2;
            loadTxt.y = 465/2-loadTxt.height/2;
            addEventListener(Event.ENTER_FRAME, onLoad);
            tileList = new Vector.<Vector.<Vector.<Sprite>>>;
            //âÊëúÇÃì«Ç›çûÇ›
            loader.load("kamakura");
        }
        
        private function onLoad(e:Event):void{
            loadTxt.text = "Now Loading...\n" + loader.count + "/20";
        }
        
        private function onComplete(e:Event):void{
            removeChild(loadTxt);
            for(var i:int = 0; i < loader.imageList.length; i++) tileList[i] = sliceBmp(loader.imageList[i]);
            
            //ÉpÉ^Å[ÉìÇÃê∂ê¨
            order = new Vector.<Point>;
            for(var l:int = 2; l <= row+col; l++){
                for(i = 1; i < l; i++){
                    var j:int =l-i;
                    if(i<=row && j<=col) order.push(new Point(i-1, j-1));
                }
            }
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(e:Event=null):void{
            for(var i:int = 0; i < 3; i++){
                if(pattern==0)show(imgIndex, order[orderIndex].y, order[orderIndex].x);
                else if(pattern==1)show(imgIndex, order[orderIndex].y, col-1-order[orderIndex].x);
                else if(pattern==2)show(imgIndex, row-1-order[orderIndex].y, col-1-order[orderIndex].x);
                else show(imgIndex, row-1-order[orderIndex].y, order[orderIndex].x);
                orderIndex++;
                if(orderIndex == order.length){
                    orderIndex = 0;
                    imgIndex = (imgIndex+1)%20;
                    pattern = (pattern+1)%4;
                }
            }
        }
        
        private function show(i:int, j:int, k:int):void{
            var target:Sprite = tileList[i][j][k];
            var t:ITween = BetweenAS3.tween(target, {scaleX:1, scaleY:1}, {scaleX:0, scaleY:0}, 0.5);
            target.visible = true;
            tileList[i-3<0?19+i-3:i-3][j][k].visible = false;
            setChildIndex(target, col*row*20-1);
            t.play();
        }
        
        //âÊëúÇÃï™äÑ
        private function sliceBmp(bmp:Bitmap):Vector.<Vector.<Sprite>>{
            var vec:Vector.<Vector.<Sprite>> = new Vector.<Vector.<Sprite>>;
            var w:Number = bmp.width/col, h:Number = bmp.height/row;
            var rect:Rectangle = new Rectangle(0, 0, w, h);
            for(var i:int = 0; i < row; i++){
                vec[i] = new Vector.<Sprite>;
                for(var j:int = 0; j < col; j++){
                    var bmpd:BitmapData = new BitmapData(w, h);
                    rect.x = j*w; rect.y = i*h;
                    bmpd.copyPixels(bmp.bitmapData, rect, new Point());
                    var b:Bitmap = new Bitmap(bmpd);
                    b.width = W; b.height = H;
                    b.x = -b.width/2; b.y = -b.height/2;
                    var sp:Sprite = new Sprite();
                    sp.addChild(b);
                    sp.x = j*W; sp.y = i*H;
                    addChild(sp);
                    sp.visible = false;
                    sp.scaleX = sp.scaleY = 0;
                    vec[i][j] = sp;
                }
            }
            return vec;
        }
    }
}
import flash.system.LoaderContext;

import flash.display.*;
import flash.events.*;
import flash.net.*;

class ImageLoader extends EventDispatcher{
    private var feed:String = "http://api.flickr.com/services/feeds/photos_public.gne?format=rss_200&tags=";
    private var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");
    public var count:int = 0;
    private var $images:Array, $urls:Array;
    
    public var imageList:Vector.<Bitmap> = new Vector.<Bitmap>;
    
    public function load(tag:String):void{
        var ldr:URLLoader = new URLLoader;
        ldr.addEventListener(Event.COMPLETE, function _load(e:Event):void {
            ldr.removeEventListener(Event.COMPLETE, _load);
            $images = XML(ldr.data)..media::content.@url.toXMLString().split('\n');
            imageLoad();
        });
        ldr.load(new URLRequest(feed+tag));
    }
    
    private function imageLoad():void{
        for(var i:int = 0; i < $images.length; i++){
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
            loader.load(new URLRequest($images[i]), new LoaderContext(true));
        }
    }
    
    private function onComplete(e:Event):void{
        imageList.push(e.target.content as Bitmap);
        count++;
        if($images.length == count) dispatchEvent(new Event(Event.COMPLETE));
    }
}