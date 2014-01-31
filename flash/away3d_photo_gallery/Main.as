package



{



    import away3d.containers.*;



    import away3d.entities.Mesh;



    import away3d.errors.AbstractMethodError;



    import away3d.events.MouseEvent3D;



    import away3d.materials.TextureMaterial;



    import away3d.primitives.*;



    import away3d.textures.BitmapTexture;



    



    import flash.display.*;



    import flash.display3D.Context3DRenderMode;



    import flash.display3D.textures.Texture;



    import flash.events.*;



    import flash.geom.Matrix;



    import flash.net.*;



    import flash.system.*;



    import flash.ui.Keyboard;



    import flash.utils.getTimer;



    



    import net.hires.debug.Stats;



    



    import org.libspark.betweenas3.BetweenAS3;



    import org.libspark.betweenas3.core.easing.BackEaseOut;



    import org.libspark.betweenas3.easing.Back;



    import org.libspark.betweenas3.tweens.ITween;



    



    public class Main extends Sprite
    {



        private var view:View3D=null;



        private const RADIUS:Number = 800;



        private const SIZE:Number = 130;



        private var img_cnt:int = 458, load_cnt:int = 0;



        private var flickr:FlickrLoader = new FlickrLoader("7320548afe4e4ec5dd13617d53666227");



        private var container:ObjectContainer3D = new ObjectContainer3D();



        private var meshList:Vector.<Mesh>;



        



        private var isMouseDown:Boolean=false;



        private var tweens:Vector.<ITween> = new Vector.<ITween>();



        private var oldX:Number, oldY:Number;



        private var toRx:Number=0, toRy:Number=0;



        



        private var searchComp:SearchComponent;



        private var page:int;



        



        private var clickTarget:Mesh=null;



        private var loading:Boolean = false;



        



        private var imageView:ImageView;



        



        public function Main()



        {



            stage.scaleMode = StageScaleMode.NO_SCALE;



            stage.align = StageAlign.TOP_LEFT;



            stage.frameRate = 60;


 //           graphics.beginFill(0);

  //          graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight);

//            graphics.endFill();


            



            stage.addEventListener(Event.RESIZE, onResize);



            addEventListener(Event.ENTER_FRAME, check);



        }



        



        private function onResize(e:Event):void{
 //           graphics.endFill();
  //          graphics.beginFill(0);
   //         graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight);
    //        graphics.endFill();

            if(view != null){



                view.width = stage.stageWidth;



                view.height = stage.stageHeight;



                searchComp.y = stage.stageHeight-30;



                imageView.resize();



                searchComp.resize();



            }



        }



        



        private function check(e:Event):void{



            if(stage.stageHeight>0){



                removeEventListener(Event.ENTER_FRAME, check);



                start();



            }



        }

        private function start(e:Event=null):void{



            view = new View3D();
            view.width = stage.stageWidth;
            view.height = stage.stageHeight;

            addChild(view);



            view.scene.addChild(container);



            



            view.camera.x = 0;



            view.camera.y = 0;



            view.camera.z = 0;



            



            flickr.addEventListener(FlickrLoader.XML_LOAD_COMPLETE, onSearchComplete);



            flickr.addEventListener(FlickrLoader.THUMB_LOAD_COMPLETE, onThumbComplete);



            



            searchComp = new SearchComponent(stage.stageWidth);



            searchComp.y = stage.stageHeight-30;



            searchComp.searchBtn.click = search;



            addChild(searchComp);



            searchComp.textInput.addEventListener(KeyboardEvent.KEY_DOWN, onTextKeyDown);



            



            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);



            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);



            



            imageView = new ImageView();



            addChild(imageView);



            imageView.visible = false;



            



            init();



            search();



        }



        



        private function init():void{



            // Planeを球体に並べる



            var radian:Number = Math.PI/180;



            var H:int=(RADIUS * Math.PI) / SIZE;



            var theta1:Number;



            var theta2:Number=90;



            var cnt:int = 0;



            meshList = new Vector.<Mesh>();



            for(var i:int=0; i < H; i++)



            {



                theta1=0;



                var pn:int=Math.floor((2 * RADIUS * Math.PI * Math.cos(theta2 * radian)) / SIZE);



                for(var j:int=0; j < pn; j++)



                {



                    var plane:PlaneGeometry = new PlaneGeometry(70, 70, 1, 1, true, false);



                    var bmpTexture:BitmapTexture = new BitmapTexture(new BitmapData(64,64));



                    var texture:TextureMaterial = new TextureMaterial(bmpTexture);



                    var mesh:Mesh = new Mesh(plane, texture);



                    container.addChild(mesh);



                    mesh.rotationX=-theta2-90;



                    mesh.rotationY=theta1;



                    mesh.scaleX = 0;



                    mesh.scaleY = 0;



                    mesh.scaleZ = 0;



                    mesh.mouseEnabled = mesh.mouseChildren = mesh.shaderPickingDetails = true;



                    mesh.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver3D);



                    mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown3D);



                    mesh.addEventListener(MouseEvent3D.MOUSE_UP, onMouseUp3D);



                    mesh.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut3D);



                    //緯度、経度を3D座標に変換



                    mesh.x=RADIUS * Math.cos(theta2 * radian) * Math.sin(theta1 * radian);



                    mesh.y=RADIUS * Math.sin(theta2 * radian);



                    mesh.z=RADIUS * Math.cos(theta2 * radian) * Math.cos(theta1 * radian);



                    mesh.name = cnt.toString();



                    tweens[cnt] = null;



                    theta1+=360 / pn;



                    meshList.push(mesh);



                    cnt++;



                }



                theta2-=180 / H;



            }



            addEventListener(Event.ENTER_FRAME, onEnterFrame);



        }



        



        private function updateMesh():void{



            var tweenList:Array = [];



            for(var i:int = 0; i < meshList.length; i++){



                var bmpd:BitmapData = new BitmapData(64, 64);



                var bmp:Bitmap = flickr.result[i%flickr.result.length].thumbBmp;



                bmpd.draw(bmp, new Matrix(64/bmp.width, 0, 0, 64/bmp.height));



                var t:ITween = BetweenAS3.delay(BetweenAS3.to(meshList[i], {scaleX:0, scaleY:0, scaleZ:0}, 1.0, Back.easeIn), Math.random()*2);



                t.onComplete = function(index:int, b:BitmapData):void{



                    ((meshList[index].material as TextureMaterial).texture as BitmapTexture).bitmapData = b;



                }



                t.onCompleteParams = [i, bmpd];



                var t2:ITween = BetweenAS3.to(meshList[i], {scaleX:1, scaleY:1, scaleZ:1}, 1.0, Back.easeOut);



                tweenList.push(BetweenAS3.serial(t,t2));



            }



            BetweenAS3.parallelTweens(tweenList).play();



        }



        



        private function search(e:MouseEvent=null):void{



            trace("Search");



            page = 1;



            loading = true;



            flickr.loadCnt = 0;



            flickr.searchByTag(searchComp.textInput.text, page, img_cnt);



        }



        



        private function onSearchComplete(e:Event):void{



            trace("SearchComp");



            flickr.loadThumb();



        }



        



        private function onThumbComplete(e:Event):void{



            trace("ThumbLoadComp");



            updateMesh();



            flickr.loading = false;



        }



        



        private function onEnterFrame(e:Event):void{



            if(loading && flickr.result.length > 0){



                var p:int = int(flickr.loadCnt/flickr.result.length*100);



                if(p == 100){



                    searchComp.loadingTxt.text = "Complete";



                    loading = false;



                }



                else searchComp.loadingTxt.text = "Now Loading..."+p.toString()+"%";



            }



            



            if (isMouseDown)



            {



                toRy -=(mouseX - oldX) * 0.2;



                toRx -=(mouseY - oldY) * 0.2;



                if(toRx > 90) toRx = 90;



                if(toRx < -90) toRx = -90;



                oldX=mouseX;



                oldY=mouseY;



            }



            



            view.camera.rotationX += (toRx - view.camera.rotationX)*0.1;



            view.camera.rotationY += (toRy - view.camera.rotationY)*0.1;



            



            view.render();



        }



        



        private function onMouseUp(e:MouseEvent):void{



            isMouseDown = false;



        }



        



        private function onMouseDown(e:MouseEvent):void{



            isMouseDown = true;



            oldX = mouseX;



            oldY = mouseY;



        }



        



        private function onMouseOver3D(e:MouseEvent3D):void{



            var i:int = int(e.target.name);



            if(tweens[i] != null && tweens[i].isPlaying) tweens[i].stop();



            tweens[i] = BetweenAS3.to(e.target, {scaleX:1.2, scaleY:1.2, scaleZ:1.2}, 0.2, Back.easeOut);



            tweens[i].play();



        }



        



        private function onMouseOut3D(e:MouseEvent3D):void{



            var i:int = int(e.target.name);



            if(tweens[i] != null && tweens[i].isPlaying) tweens[i].stop();



            tweens[i] = BetweenAS3.to(e.target, {scaleX:1.0, scaleY:1.0, scaleZ:1.0}, 0.2, Back.easeIn);



            tweens[i].play();



        }



        



        private function onMouseDown3D(e:MouseEvent3D):void{



            clickTarget = e.target as Mesh;



        }



        



        private function onMouseUp3D(e:MouseEvent3D):void{



            if(e.target == clickTarget && !flickr.loading){



                imageView.load(flickr.result[int(clickTarget.name)%flickr.result.length].imgUrl);



            }



        }



        



        private function onTextKeyDown(e:KeyboardEvent):void{



            if(e.keyCode == Keyboard.ENTER){



                search();



            }



        }



    }



}



import flash.display.Bitmap;



    import flash.display.BitmapData;



    import flash.display.GradientType;



    import flash.display.Sprite;



    import flash.events.MouseEvent;



    import flash.geom.Matrix;



    import flash.text.TextField;



    import flash.text.TextFieldAutoSize;



    import flash.text.TextFormat;



    



    class Button extends Sprite



    {



        private var normalBtn:Bitmap;



        private var mouseOverBmp:Bitmap;



        private var mouseDownBmp:Bitmap;



        private var over:Boolean = false;



        



        public function Button(x:Number, y:Number, width:Number, height:Number, label:String, fontSize:int=14, color:uint=0xAAAAAA, fontColor:uint=0)



        {



            super();



            this.x = x;



            this.y = y;



            buttonMode = true;



            



            var normalBmpd:BitmapData = new BitmapData(width, height, true, 0);



            var overBmpd:BitmapData = new BitmapData(width, height, true, 0);



            var downBmpd:BitmapData = new BitmapData(width, height, true, 0);



            



            var tf:TextField = new TextField();



            tf.autoSize = TextFieldAutoSize.LEFT;



            tf.defaultTextFormat = new TextFormat(null, fontSize);



            tf.textColor = fontColor;



            tf.text = label;



            var sp:Sprite = new Sprite();



            sp.addChild(tf);



            tf.x = width/2-tf.width/2;



            tf.y = height/2-tf.height/2;



            tf.mouseEnabled = false;



            



            drawGradient(sp, width, height, color, 0.5);



            normalBmpd.draw(sp);



            normalBtn = new Bitmap(normalBmpd);



            



            drawGradient(sp, width, height, color, 0.3);



            overBmpd.draw(sp);



            mouseOverBmp = new Bitmap(overBmpd);



            



            drawGradient(sp, width, height, color, 0.1);



            downBmpd.draw(sp);



            mouseDownBmp = new Bitmap(downBmpd);



            



            addChild(normalBtn);



            addChild(mouseOverBmp);



            addChild(mouseDownBmp);



            mouseOverBmp.visible = mouseDownBmp.visible = false;



            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);



            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);



            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);



            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);



        }



        



        private function drawGradient(sp:Sprite, width:Number, height:Number, color:int, brightness:Number):void{



            sp.graphics.clear();



            var m:Matrix = new Matrix();



            var hsv:ColorHSV = new ColorRGB(color).toHSV();



            hsv.v = brightness;



            var color2:uint = hsv.toRGB().value;



            m.createGradientBox(width, height, Math.PI/2);



            sp.graphics.beginGradientFill(GradientType.LINEAR, [color, color2], [1, 1], [0, 255], m);



            sp.graphics.drawRoundRect(0,0,width,height,20);



            sp.graphics.endFill();



        }



        



        public function set click(func:Function):void{



            addEventListener(MouseEvent.CLICK, func);



        }



        



        private function onMouseDown(e:MouseEvent):void{



            normalBtn.visible = false;



            mouseOverBmp.visible = false;



            mouseDownBmp.visible = true;



        }



        



        private function onMouseUp(e:MouseEvent):void{



            if(over){



                normalBtn.visible = false;



                mouseOverBmp.visible = true;



                mouseDownBmp.visible = false;



            }



            else{



                normalBtn.visible = true;



                mouseOverBmp.visible = false;



                mouseDownBmp.visible = false;



            }



        }



        



        private function onMouseOver(e:MouseEvent):void{



            normalBtn.visible = false;



            mouseOverBmp.visible = true;



            mouseDownBmp.visible = false;



            over = true;



        }



        



        private function onMouseOut(e:MouseEvent):void{



            normalBtn.visible = true;



            mouseOverBmp.visible = false;



            mouseDownBmp.visible = false;



            over = false;



        }



    }

    

    class ColorHSV



    {



        public var h:Number, s:Number, v:Number;



        public function ColorHSV(h:Number, s:Number, v:Number)



        {



            this.h = h;



            this.s = s;



            this.v = v;



        }



        



        public function toRGB():ColorRGB{



            var f:Number;



            var i:int, p:int, q:int, t:int;



            var rgb:Array = [0,0,0];



            var v:Number = this.v*255, s:Number = this.s*255;



            



            i = int(Math.floor(h / 60.0)) % 6;



            f = Number(h / 60.0) - Number(Math.floor(h / 60.0));



            p = int(Math.round(v * (1.0 - (s / 255.0))));



            q = int(Math.round(v * (1.0 - (s / 255.0) * f)));



            t = int(Math.round(v * (1.0 - (s / 255.0) * (1.0 - f))));



            



            switch(i){



                case 0 : rgb[0] = v; rgb[1] = t; rgb[2] = p; break;



                case 1 : rgb[0] = q; rgb[1] = v; rgb[2] = p; break;



                case 2 : rgb[0] = p; rgb[1] = v; rgb[2] = t; break;



                case 3 : rgb[0] = p; rgb[1] = q; rgb[2] = v; break;



                case 4 : rgb[0] = t; rgb[1] = p; rgb[2] = v; break;



                case 5 : rgb[0] = v; rgb[1] = p; rgb[2] = q; break;



            }



            return new ColorRGB(-1, rgb[0], rgb[1], rgb[2]);



        }



    }

    

    class ColorRGB



    {



        public var r:uint, g:uint, b:uint;



        



        public function ColorRGB(value:int, r:int=-1, g:int=-1, b:int=-1)



        {



            if(value < 0){



                this.r = r;



                this.g = g;



                this.b = b;



            }



            else{



                this.value = value;



            }



        }



        



        public function get value():int{



            return (r<<16) | (g<<8) | b;



        }



        



        public function set value(v:int):void{



            this.r = (v>>16)&0xFF;



            this.g = (v>>8)&0xFF;



            this.b = v&0xFF;



        }



        



        public function toHSV():ColorHSV{



            var h:Number, s:Number, v:Number;



            var max:Number = Math.max(r, Math.max(g, b));



            var min:Number = Math.min(r, Math.min(g, b));



            



            // h



            if(max == min){



                h = 0;



            }



            else if(max == r){



                h = (60 * (g - b) / (max - min) + 360);



            }



            else if(max == g){



                h = (60 * (b - r) / (max - min)) + 120;



            }



            else if(max == b){



                h = (60 * (r - g) / (max - min)) + 240;   



            }



            if(h > 360) h -= 360;



            else if(h < 0) h += 360;



            



            // s



            if(max == 0){



                s = 0;



            }



            else{



                s = ((max - min) / max);



            }



            



            // v



            v = max/255;



            



            return new ColorHSV(h,s,v);



        }



    }    

     

    import flash.display.Bitmap;







    class FlickrImageData



    {



        public var title:String;



        public var thumbUrl:String;



        public var imgUrl:String;



        



        public var thumbBmp:Bitmap;



        public var imgBmp:Bitmap;



    }

    

    import flash.display.*;



    import flash.events.*;



    import flash.net.*;



    import flash.system.Security;







    class FlickrLoader extends EventDispatcher



    {



        private var urlLoader:URLLoader = new URLLoader();



        private var imgLoader:Loader = new Loader();



        private var apiKey:String;



        public var loading:Boolean=false;



        public var loadCnt:int;



        public var totalPage:int;



        public var result:Vector.<FlickrImageData> = new Vector.<FlickrImageData>();



        



        public static const XML_LOAD_COMPLETE:String = "xml_load_comp";



        public static const THUMB_LOAD_COMPLETE:String = "thumb_load_comp";



        



        public function FlickrLoader(apiKey:String)



        {



            this.apiKey = apiKey;



            // ポリシーファイルの読み込み



            Security.loadPolicyFile("http://api.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm1.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm2.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm3.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm4.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm5.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm6.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm7.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm8.static.flickr.com/crossdomain.xml");



            Security.loadPolicyFile("http://farm9.static.flickr.com/crossdomain.xml");



            



            urlLoader.addEventListener(Event.COMPLETE, onXMLLoadComplete);



        }



        



        public function searchByTag(keyword:String, page:int=1, per_page:int=100):void{



            loading = true;



            var url:String = "http://api.flickr.com/services/rest/?+"+



                "method=flickr.photos.search"+



                "&api_key="+apiKey+



                "&tags="+encodeURI(keyword)+



                "&per_page="+per_page.toString()+



                "&page="+page.toString();



            urlLoader.load(new URLRequest(url));



        }







        private function onXMLLoadComplete(e:Event):void{



            result = new Vector.<FlickrImageData>();



            var xml:XML = new XML(urlLoader.data);



            totalPage = xml..photos.@pages;



            for each(var obj:XML in xml..photo){



                var id:String = obj.@id;



                var server:String = obj.@server;



                var farm:String = obj.@farm;



                var secret:String = obj.@secret;



                var data:FlickrImageData = new FlickrImageData();



                data.title = obj.@title;



                data.imgUrl = "http://farm"+farm+".static.flickr.com/"+server+"/"+id+"_"+secret+".jpg";



                data.thumbUrl = "http://farm"+farm+".static.flickr.com/"+server+"/"+id+"_"+secret+"_s.jpg";



                result.push(data);



            }



            dispatchEvent(new Event(XML_LOAD_COMPLETE));



        }



        



        public function loadThumb():void{



            loadCnt = 0;



            for(var i:int = 0; i < result.length; i++){



                var loader:Loader = new Loader();



                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbLoadComplete);



                loader.name = i.toString();



                loader.load(new URLRequest(result[i].thumbUrl));



            }



        }



        



        private function onThumbLoadComplete(e:Event):void{



            loadCnt++;



            var loader:Loader = (e.target as LoaderInfo).loader;



            result[int(loader.name)].thumbBmp = loader.content as Bitmap;



            if(loadCnt == result.length) dispatchEvent(new Event(THUMB_LOAD_COMPLETE));



        }



    }

    

    import flash.display.Loader;



    import flash.display.Sprite;



    import flash.events.Event;



    import flash.events.MouseEvent;



    import flash.events.ProgressEvent;



    import flash.net.URLRequest;



    



    import org.libspark.betweenas3.BetweenAS3;



    import org.libspark.betweenas3.easing.Sine;



    import org.libspark.betweenas3.tweens.ITween;



    



    class ImageView extends Sprite



    {



        private var loader:Loader = new Loader();



        private var loadingRect:Sprite = new Sprite();



        private var container:Sprite = new Sprite();



        private var back:Sprite = new Sprite();



        



        public function ImageView()



        {



            if(stage) init();



            else addEventListener(Event.ADDED_TO_STAGE, init);



        }



        



        private function init(e:Event=null):void{



            back.graphics.beginFill(0xAAAAAA, 0.3);



            back.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);



            back.graphics.endFill();



            addChild(back);



            this.addEventListener(MouseEvent.CLICK, onClose);



            



            loadingRect.graphics.beginFill(0xFFFFFF);



            loadingRect.graphics.drawRect(0,0,stage.stageWidth,10);



            loadingRect.graphics.endFill();



            loadingRect.y = stage.stageHeight/2-10;



            addChild(loadingRect);



            loadingRect.scaleX = 0;



            loadingRect.visible = false;



            



            addChild(container);



            container.x = stage.stageWidth/2;



            container.y = stage.stageHeight/2;



            container.addChild(loader);



            container.visible = false;



            



            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);



            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);



        }



        



        public function load(url:String):void{



            this.visible = true;



            this.alpha = 1;



            container.visible = false;



            loadingRect.visible = true;



            loadingRect.alpha = 1;



            loadingRect.scaleX = 0;



            loader.load(new URLRequest(url));



        }



        



        private function onProgress(e:ProgressEvent):void{



            var p:Number = e.bytesLoaded/e.bytesTotal;



            loadingRect.scaleX = p;



        }



        



        private function onComplete(e:Event):void{



            loadingRect.scaleX = 1;



            var t:ITween = BetweenAS3.to(loadingRect, {alpha:0}, 0.3);



            t.onComplete = function():void{loadingRect.visible = false;};



            t.play();



            



            var r:Number = Math.min(Math.min((stage.stageWidth-200)/loader.width, (stage.stageHeight-200)/loader.height), 1);



            container.scaleY = container.scaleX = 0;



            loader.x = -loader.width/2;



            loader.y = -loader.height/2;



            container.visible = true;



            BetweenAS3.to(container, {scaleX:r, scaleY:r}, 0.5, Sine.easeOut).play();



        }



        



        private function onClose(e:MouseEvent):void{



            if(container.visible){



                container.visible = this.visible = false;



            }



        }



        



        public function resize():void{



            back.graphics.clear();



            back.graphics.beginFill(0xAAAAAA, 0.3);



            back.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);



            back.graphics.endFill();



            container.x = stage.stageWidth/2;



            container.y = stage.stageHeight/2;



        }



    }

    

    import away3d.entities.Mesh;







    class ListObject



    {



        public var label:String;



        public var mesh:Mesh;



        public var url:String;



        



        public function ListObject(label:String, mesh:Mesh, url:String){



            this.label = label;



            this.mesh = mesh;



            this.url = url;



        }



    }
    

    import flash.display.Sprite;



    import flash.display.Stage;



    import flash.display.StageDisplayState;



    import flash.text.*;



    

    class SearchComponent extends Sprite

    {



        public var textInput:TextField = new TextField();



        private var keywordLabel:TextField = new TextField();



        public var searchBtn:Button, fullScreenBtn:Button;



        public var loadingTxt:TextField = new TextField();



        



        public function SearchComponent(w:Number)



        {



            super();



            graphics.beginFill(0xAAAAAA, 0.5);



            graphics.drawRect(0,0, w, 30);



            graphics.endFill();



            



            keywordLabel.defaultTextFormat = new TextFormat(null, 14);



            keywordLabel.autoSize = TextFieldAutoSize.LEFT;



            keywordLabel.text = "Keyword:";



            keywordLabel.textColor = 0xFFFFFF;



            keywordLabel.mouseEnabled = false;



            addChild(keywordLabel);



            keywordLabel.x = 5;



            keywordLabel.y = 6;



            



            textInput.x = 70;



            textInput.y = 5;



            textInput.text = "Japan";



            textInput.type = TextFieldType.INPUT;



            textInput.textColor = 0xFFFFFF;



            textInput.width = 100;



            textInput.height = 20;



            textInput.border = true;



            textInput.borderColor = 0xAAAAAA;



            addChild(textInput);



            



            searchBtn = new Button(180, 5, 60, 20, "Search", 12, 0x0, 0xFFFFFF);



            addChild(searchBtn);



            



            fullScreenBtn = new Button(w-90, 5, 70, 20, "FullScreen", 12, 0x0, 0xFFFFFF);



//            addChild(fullScreenBtn);



            fullScreenBtn.click = function():void{ 



                if(stage.displayState != StageDisplayState.FULL_SCREEN)



                    stage.displayState = StageDisplayState.FULL_SCREEN;



                else



                    stage.displayState = StageDisplayState.NORMAL;



            };



            



            loadingTxt.autoSize = TextFieldAutoSize.LEFT;



            loadingTxt.defaultTextFormat = new TextFormat(null, 14);



            loadingTxt.textColor = 0xFFFFFF;



            loadingTxt.x = 250;



            loadingTxt.y = 3;



            addChild(loadingTxt);



        }



        



        public function resize():void{



            graphics.clear();



            graphics.beginFill(0xAAAAAA, 0.5);



            graphics.drawRect(0,0, stage.stageWidth, 30);



            graphics.endFill();



            fullScreenBtn.x = stage.stageWidth-150;



        }



    }

    