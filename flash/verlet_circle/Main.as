package
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.Slider;
	import com.bit101.components.Style;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import jp.matsu4512.physics.VerletCircle;
	import jp.matsu4512.physics.VerletSquare;
	import jp.matsu4512.physics.VerletStick;
	
	[SWF(width="600", height="600")]
	public class Main extends Sprite
	{
		private var squareSp:Sprite;
		private var circle:VerletCircle;
		private var rect:Rectangle = new Rectangle(50,50,500, 500);
		
		private var oldX:Number, oldY:Number, down:Boolean=false;
		
		private var check:CheckBox;
		private var slider:Slider;
		
		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			check = new CheckBox(this, 50, 20, "display architecture");
			new Label(this, 200, 15, "flexibility");
			slider = new Slider("horizontal", this, 250, 20, onSliderChange);
			slider.value = 5;
			slider.maximum = 20;
			slider.minimum = 2;
			
			graphics.lineStyle(3,0);
			graphics.drawRect(50,50,500,500);
			
			squareSp = new Sprite();
			addChild(squareSp);
			
			circle = new VerletCircle(300, 150, 70, 10, 5);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onSliderChange(e:Event):void{
			for(var i:int = 0; i < circle.sticks.length; i++)
				circle.sticks[i].k = slider.value;
		}
		
		private function onMouseDown(e:MouseEvent):void{
			down = true;
			oldX = mouseX;
			oldY = mouseY;
		}
		
		private function onMouseUp(e:MouseEvent):void{
			down = false;
		}
		
		private function onMouseMove(e:MouseEvent):void{
			if(down){
				for(var i:int = 0; i < circle.points.length; i++){
					circle.points[i].x += (mouseX-oldX)/8;
					circle.points[i].y += (mouseY-oldY)/8;
				}
				oldX = mouseX;
				oldY = mouseY;
			}
		}
		
		private function onEnterFrame(e:Event):void{
			squareSp.graphics.clear();
			circle.constrain(rect);
			if(check.selected)circle.render_architecture(squareSp.graphics);
			else circle.render_bezier(squareSp.graphics);
			circle.update();
			
			for(var i:int = 0; i < circle.points.length; i++){
				circle.points[i].vy += 0.5;
			}
		}
	}
}