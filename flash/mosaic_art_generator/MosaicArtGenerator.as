package
{
	import com.adobe.images.PNGEncoder;
	import com.adobe.serialization.json.JSON;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import flashx.textLayout.formats.ITabStopFormat;
	
	import jp.matsu4512.*;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.tweens.ITween;
	import org.osmf.logging.Log;
	
	[SWF(backgroundColor=0, width="900", height="650")]
	public class MosaicArtGenerator extends Sprite
	{
		[Embed(source="assets/mosaic_logo.png")]
		private const Logo:Class;
		[Embed(source="assets/SelectImage.png")]
		private const Normal_selectImage:Class;
		[Embed(source="assets/SelectImage_over.png")]
		private const Over_selectImage:Class;
		[Embed(source="assets/SelectImage_down.png")]
		private const Down_selectImage:Class;
		
		[Embed(source="assets/DownloadImage.png")]
		private const Normal_downloadImage:Class;
		[Embed(source="assets/DownloadImage_over.png")]
		private const Over_downloadImage:Class;
		[Embed(source="assets/DownloadImage_down.png")]
		private const Down_downloadImage:Class;
		
		[Embed(source="assets/loading4.png")]
		private const Loading1Image:Class;
		[Embed(source="assets/loading3.png")]
		private const Loading2Image:Class;
		[Embed(source="assets/loading2.png")]
		private const Loading3Image:Class;
		[Embed(source="assets/loading.png")]
		private const Loading4Image:Class;
		
		[Embed(source="assets/search.png")]
		private const NormalSearchImage:Class;
		[Embed(source="assets/search_over.png")]
		private const OverSearchImage:Class;
		[Embed(source="assets/search_down.png")]
		private const DownSearchImage:Class;
		
		[Embed(source="assets/close.png")]
		private const NormalCloseImage:Class;
		[Embed(source="assets/close_over.png")]
		private const OverCloseImage:Class;
		[Embed(source="assets/close_down.png")]
		private const DownCloseImage:Class;
		
		private const HOST:String = "http://matsu4512.jp/works/flash/mosaic_art_generator/";
//		private const HOST:String = "http://localhost/mosaic/";
		
		private var refBtn:ImageButton, dlBtn:ImageButton, expBtn:ImageButton, closeBtn:ImageButton;
		
		private var ref:FileReference = new FileReference(), saveRef:FileReference = new FileReference();
		private var byteLoader:Loader = new Loader();
		
		private var imageLayer:Sprite = new Sprite();
		private var mosaicLayer:Sprite = new Sprite();
		private var buttonLayer:Sprite = new Sprite();
		private var mainLayer:Sprite = new Sprite();
		private var loadingLayer:Sprite = new Sprite();
		private var loadingRect:Sprite = new Sprite();
		
		private var originalBmp:Bitmap;
		private var originalBmpd:BitmapData;
		
		private var urlLoader:URLLoader = new URLLoader(), urlLoader2:URLLoader = new URLLoader();
		private var urlLoader3:URLLoader = new URLLoader();
		
		private var hsvColors:Array, ww:int, hh:int, sw:int, sh:int;
		private var imgAry:Array, idAry:Array;
		
		private var loading1Bmp:Bitmap = new Loading1Image(), loading2Bmp:Bitmap = new Loading2Image(), loading3Bmp:Bitmap = new Loading3Image(), loading4Bmp:Bitmap = new Loading4Image(), loadingBmp:Bitmap = new Loading4Image();
		
		private var detailView:DetailView = new DetailView();
		
		public function MosaicArtGenerator()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addChild(mainLayer);
			mainLayer.addChild(imageLayer);
			
			addChild(mosaicLayer);
			mosaicLayer.x = 450;
			mosaicLayer.y = 200;
			
			mainLayer.addChild(buttonLayer);
			
			addChild(loadingLayer);
			loadingLayer.graphics.beginFill(0,0.5);
			loadingLayer.graphics.drawRect(0,0,900,650);
			loadingLayer.graphics.endFill();
			loadingLayer.visible = false;
			
			loadingLayer.addChild(loadingBmp);
			loadingBmp.x = 400-loadingBmp.width/2;
			loadingBmp.y = 325-loadingBmp.height/2;
			
			var bmp:Bitmap = new Logo();
			mainLayer.addChild(bmp);
			
			addChild(detailView);
			detailView.visible = false;
			
			refBtn = new ImageButton(new Normal_selectImage(), new Over_selectImage(), new Down_selectImage());
			refBtn.x = 20, refBtn.y = 130;
			buttonLayer.addChild(refBtn);
			refBtn.click = onRefBtnClick;
			
			dlBtn = new ImageButton(new Normal_downloadImage(), new Over_downloadImage(), new Down_downloadImage());
			dlBtn.x = 450, dlBtn.y = 130;
			dlBtn.enabled = false;
			dlBtn.click = onDLBtnClick;
			buttonLayer.addChild(dlBtn);
			
			expBtn = new ImageButton(new NormalSearchImage(), new OverSearchImage(), new DownSearchImage());
			expBtn.x = 650, expBtn.y = 135;
			expBtn.enabled = false;
			expBtn.scaleX = expBtn.scaleY = 0.3;
			expBtn.click = expandImage;
			buttonLayer.addChild(expBtn);
			
			closeBtn = new ImageButton(new NormalCloseImage(), new OverCloseImage(), new DownCloseImage());
			closeBtn.y = 25;
			closeBtn.visible = false;
			closeBtn.scaleX = closeBtn.scaleY = 0.6;
			closeBtn.click = closeImage;
			closeBtn.alpha = 0;
			addChild(closeBtn);
			
			addChild(loading1Bmp);
			addChild(loading2Bmp);
			addChild(loading3Bmp);
			addChild(loading4Bmp);
			loading1Bmp.x = loading2Bmp.x = loading3Bmp.x = loading4Bmp.x = 550;
			loading1Bmp.y = loading2Bmp.y = loading3Bmp.y = loading4Bmp.y = 320;
			loading1Bmp.visible = loading2Bmp.visible = loading3Bmp.visible = loading4Bmp.visible = false;
			
			ref.addEventListener(Event.SELECT, onSelect);
			ref.addEventListener(Event.COMPLETE, onComplete);
			
			byteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onByteLoadComp);
			urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComp);
			urlLoader2.addEventListener(Event.COMPLETE, onUrlLoaderComp2);
			urlLoader3.addEventListener(Event.COMPLETE, onUrlLoaderComp3);
		}
		
		private function onDLBtnClick(e:MouseEvent):void{
			var bmpd:BitmapData = new BitmapData(sw*ww, sh*hh, true, 0);
			bmpd.draw(mosaicLayer);
			saveRef.save(PNGEncoder.encode(bmpd), "mosaic.png");
		}
		
		private function onRefBtnClick(e:MouseEvent):void{
			var filters:Array = [];
			filters.push(new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png" ));
			ref.browse(filters);
		}
		
		private function onSelect(e:Event):void{
			imageLayer.removeChildren();
			mosaicLayer.removeChildren();
			dlBtn.enabled = false;
			expBtn.enabled = false;
			refBtn.enabled = false;
			ref.load();
		}
		
		private function onComplete(e:Event):void{
			byteLoader.loadBytes(ref.data);
		}
		
		private function onByteLoadComp(e:Event):void{
			originalBmp = byteLoader.content as Bitmap;
			originalBmpd = originalBmp.bitmapData;
			
			var size:Point = Utility.resize(originalBmp.width, originalBmp.height, 400, 400);
			if(originalBmp.width > 400 || originalBmp.height > 400){
				originalBmpd = Utility.resizeBitmapData(originalBmpd, size.x, size.y);
				originalBmp = new Bitmap(originalBmpd);
			}	
			imageLayer.addChild(originalBmp);
			originalBmp.y = 200;
			originalBmp.x = 20;
			originalBmp.alpha = 0;
			
			var t:ITween = BetweenAS3.to(originalBmp, {alpha:1}, 0.5);
			t.onComplete = originalImagefadeInComp;
			t.play();
		}
		
		private function originalImagefadeInComp():void{
			loading2Bmp.visible = true;
			loading2Bmp.alpha = 0;
			BetweenAS3.to(loading2Bmp, {alpha:1}, 0.5).play();
			var a:int = originalBmp.width*originalBmp.height;
			a /= 20000;
			a += 5;
			if(a < 0) a = 5;
			else if(a > 10)a = 10;
			//sw × shのマス目ごとの平均のrgb値を計算
			sw = a, sh = a;
			ww = Math.ceil(originalBmp.width/sw);
			hh = Math.ceil(originalBmp.height/sh);
			var hsvMap:Object = {}, data:URLVariables = new URLVariables(), dataCnt:int=0;
			hsvColors = [];
				
			for(var y:int = 0; y < hh; y++){
				for(var x:int = 0; x < ww; x++){
					var r:int=0, g:int=0, b:int= 0, cnt:int=0;
					for(var xx:int = 0; xx < sw; xx++){
						for(var yy:int = 0; yy < sh; yy++){
							if(y*sh+yy<originalBmp.height && x*sw+xx<originalBmp.width){
								var c:uint = originalBmpd.getPixel32(x*sw+xx,y*sh+yy);
								b += c&0xFF;
								g += (c>>8)&0xFF;
								r += (c>>16)&0xFF;
								cnt++;
							}
						}
					}
					//ブロック内の色の平均値を求める
					r /= cnt;
					g /= cnt;
					b /= cnt;
					var hsv:ColorHSV = new ColorRGB(-1, r, g, b).toHSV();
					hsv.s *= 255;
					hsv.v *= 255;
					hsvColors.push(hsv);
					var hue:int = int((hsv.h+5)/10)*10;
					if(hue == 360) hue = 0;
					if(hsvMap[hue] != true){
						hsvMap[hue] = true;
						data["data["+dataCnt+"]"]=hue;
						dataCnt++;
					}
				}
			}
			data["cnt"] = dataCnt;
			var req:URLRequest = new URLRequest(HOST+"getIdByHSV.php");
			req.method = URLRequestMethod.POST;
			req.data = data;
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.load(req);
		}
		
		private function onUrlLoaderComp(e:Event):void{
			loading2Bmp.visible = false;
			loading3Bmp.visible = true;
			idAry = [];
			var response:Array = com.adobe.serialization.json.JSON.decode(urlLoader.data as String);
			var data:URLVariables = new URLVariables();
			var target:Array;
			for(var i:int = 0; i < hsvColors.length; i++){
				var hue:int = Math.floor((hsvColors[i].h+5)/10)*10;
				if(hue == 360) hue = 0;
				for(var j:int = 0; j < response.length; j++){
					if(response[j].h == hue){
						target = response[j].data;
						break;
					}
				}
				var tmpAry:Array = [], min_val:Number = 1000000, min_id:int, min_i:int;
				for(j = 0; j < target.length; j++){
					var dif:Number = Math.abs(target[j].h-hsvColors[i].h)+Math.abs(target[j].s-hsvColors[i].s)+Math.abs(target[j].v-hsvColors[i].v);
					if(min_val > dif){
						min_id = target[j].id;
						min_val = dif;
						min_i = j;
					}
				}
				
				target.splice(min_i,1);
				data["data["+i+"][0]"] = min_id;
				data["data["+i+"][1]"] = hue;
				idAry[i] = {id:min_id, h:hue};
			}
			var req:URLRequest = new URLRequest(HOST+"getImageById.php");
			req.method = URLRequestMethod.POST;
			req.data = data;
			urlLoader2.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader2.load(req);
		}
		
		private function onUrlLoaderComp2(e:Event):void{
			loading3Bmp.visible = false;
			loading4Bmp.visible = true;
			var response:Array = com.adobe.serialization.json.JSON.decode(urlLoader2.data as String);
			var loadCnt:int=0;
			imgAry = []
			for(var i:int = 0; i < response.length; i++){
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
					loadCnt++;
					var l:Loader = e.target.loader;
					mosaicLayer.addChild(l);
					l.width = sw;
					l.height = sh;
					l.alpha = 0;
					if(loadCnt == response.length) imagesLoadComp();
				});
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{
					loadCnt++;
					if(loadCnt == response.length) imagesLoadComp();
				});
				loader.y = int(i/ww)*sh;
				loader.x = i%ww*sw;
				loader.name = i.toString();
				imgAry[i] = loader;
				loader.load(new URLRequest(HOST+response[i]));
			}
		}
		
		private function imagesLoadComp():void{
			var tt:ITween = BetweenAS3.to(loading4Bmp, {alpha:0}, 0.5);
			tt.onComplete = function():void{ loading4Bmp.visible=false; loading4Bmp.alpha=1; };
			tt.play();
			var t:ITween, ary:Array = [];
			for(var i:int = 0; i < ww; i++){
				var x:int = i, y:int = 0;
				var ary2:Array = [];
				while(x >= 0 && y < hh){
					ary2.push(BetweenAS3.to(imgAry[y*ww+x], {alpha:1}, 0.5));
					x--;
					y++;
				}
				ary.push(BetweenAS3.delay(BetweenAS3.parallelTweens(ary2), 0.03*i));
			}
			
			for(i = 1; i < hh; i++){
				x = ww-1, y = i;
				ary2 = [];
				while(x >= 0 && y < hh){
					ary2.push(BetweenAS3.to(imgAry[y*ww+x], {alpha:1}, 0.5));
					x--;
					y++;
				}
				ary.push(BetweenAS3.delay(BetweenAS3.parallelTweens(ary2), 0.03*(i+ww-1)));
			}
			
			t = BetweenAS3.parallelTweens(ary);
			t.play();
			
			dlBtn.enabled = true;
			expBtn.enabled = true;
			refBtn.enabled = true;
		}
		
		private function expandImage(e:MouseEvent):void{
			var t:ITween = BetweenAS3.parallel(
				BetweenAS3.to(mainLayer, {alpha:0}, 0.5),
				BetweenAS3.to(mosaicLayer, {alpha:0}, 0.5)
			);
			t.onComplete = expandImage_step2;
			t.play();
		}
		
		private function expandImage_step2():void{
			mosaicLayer.x = 25;
			mosaicLayer.y = 25;
			var r:Number = Math.min(800/mosaicLayer.width, 600/mosaicLayer.height);
			mosaicLayer.scaleX = mosaicLayer.scaleY = r;
			closeBtn.visible = true;
			closeBtn.x = mosaicLayer.x+mosaicLayer.width+30;
			var t:ITween = BetweenAS3.parallel(
				BetweenAS3.to(mosaicLayer, {alpha:1}, 0.5),
				BetweenAS3.to(closeBtn, {alpha:1}, 0.5)
			);
			t.onComplete = expandImage_step3;
			t.play();
		}
		
		private function expandImage_step3():void{
			mosaicLayer.buttonMode = true;
			mosaicLayer.addEventListener(MouseEvent.CLICK, onImageClick);
		}
		
		private function onImageClick(e:MouseEvent):void{
			loadingLayer.visible = true;
			loadingRect.scaleX = 0;
			var req:URLRequest = new URLRequest(HOST+"getImageInfoById.php");
			req.method = URLRequestMethod.POST;
			var obj:URLVariables = new URLVariables();
			obj.id = idAry[int(e.target.name)].id;
			obj.h = idAry[int(e.target.name)].h;
			req.data = obj;
			urlLoader3.load(req);
		}
		
		private function onUrlLoaderComp3(e:Event):void{
			var response:Object = com.adobe.serialization.json.JSON.decode(urlLoader3.data as String);
			detailView.setData(response.owner_name, response.url, response.title, response.img);
			detailView.onComplete = onImageLoadComp;
			detailView.loadImg();
		}
		
		private function onImageLoadComp():void{
			detailView.x = 400-detailView.width/2+25;
			detailView.y = 325-detailView.height/2;
			
			detailView.visible = true;
		}
		
		private function closeImage(e:MouseEvent):void{
			if(detailView.visible){
				detailView.visible = false;
				loadingLayer.visible = false;
				return;
			}
			
			mosaicLayer.removeEventListener(MouseEvent.CLICK, onImageClick);
			mosaicLayer.buttonMode = false;
			var t:ITween = BetweenAS3.parallel(
				BetweenAS3.to(closeBtn, {alpha:0}, 0.5),
				BetweenAS3.to(mosaicLayer, {alpha:0}, 0.5)
			);
			t.onComplete = closeImage_step2;
			t.play();
		}
		
		private function closeImage_step2():void{
			closeBtn.alpha = 0;
			closeBtn.visible = false;
			mosaicLayer.x = 450;
			mosaicLayer.y = 200;
			mosaicLayer.scaleX = mosaicLayer.scaleY = 1;
			var t:ITween = BetweenAS3.parallel(
				BetweenAS3.to(mainLayer, {alpha:1}, 0.5),
				BetweenAS3.to(mosaicLayer, {alpha:1}, 0.5)
			);
			t.play();
		}
	}
}