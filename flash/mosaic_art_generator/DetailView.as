package
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	
	import jp.matsu4512.Utility;
	
	public class DetailView extends Sprite
	{
		private var owner:String;
		private var url:String;
		private var title:String;
		private var img:String;
		private var loader:Loader = new Loader();
		
		private var ownerTf:TextField, titleTf:TextField;
		
		public var onComplete:Function;
		public var onProgress:Function;
		
		public function DetailView()
		{
			titleTf = Utility.createTextField(0,0,"",18,0xFFFFFF);
			ownerTf = Utility.createTextField(0,0,"",18,0xFFFFFF);
			addChild(titleTf);
			addChild(ownerTf);
			addChild(loader);
			
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, onClick);
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
		}
		
		public function setData(owner:String, url:String, title:String, img:String):void{
			this.owner = owner;
			this.url = url;
			this.title = title;
			this.img = img;
			
			ownerTf.text = owner;
			titleTf.text = title;
		}
		
		public function loadImg():void{
			loader.load(new URLRequest(img));
		}
		
		private function onLoadComplete(e:Event):void{
			titleTf.x = loader.width/2-titleTf.width/2;
			ownerTf.x = loader.width/2-ownerTf.width/2;
			titleTf.y = loader.height+20;
			ownerTf.y = loader.height+40;
			if(onComplete != null) onComplete.apply();
		}
		
		private function onLoadProgress(e:ProgressEvent):void{
			if(onProgress != null) onProgress.apply(null, [e.bytesLoaded/e.bytesTotal]);
		}
		
		private function onClick(e:MouseEvent):void{
			navigateToURL(new URLRequest(url), "_blank");
		}
	}
}